/* ********************************************************************* 
       _____        _               _    ___ ____   ____
      |_   _|___  _| |_ _   _  __ _| |  |_ _|  _ \ / ___|
       | |/ _ \ \/ / __| | | |/ _` | |   | || |_) | |
       | |  __/>  <| |_| |_| | (_| | |   | ||  _ <| |___
       |_|\___/_/\_\\__|\__,_|\__,_|_|  |___|_| \_\\____|
 
 Copyright (c) 2008 - 2010 Satoshi Nakagawa <psychs AT limechat DOT net>
 Copyright (c) 2010 — 2014 Codeux Software & respective contributors.
     Please see Acknowledgements.pdf for additional information.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Textual IRC Client & Codeux Software nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.

 *********************************************************************** */

#import "TextualApplication.h"

/* Refuse to have more than X number of items incoming at any given time. */
#define _addReceiverHardLimit			100

@implementation TDCFileTransferDialog

- (id)init
{
	if (self = [super init]) {
		self.fileTransfers = [NSMutableArray array];
		
		[RZMainBundle() loadCustomNibNamed:@"TDCFileTransferDialog" owner:self topLevelObjects:nil];
		
		self.maintenanceTimer = [TLOTimer new];
		self.maintenanceTimer.delegate = self;
		self.maintenanceTimer.selector = @selector(onMaintenanceTimer:);
		self.maintenanceTimer.reqeatTimer = YES;
	}
	
	return self;
}

- (void)show:(BOOL)key restorePosition:(BOOL)restoreFrame
{
	if (key) {
		[self.window makeKeyAndOrderFront:nil];
	} else {
		[self.window orderFront:nil];
	}
	
	if (restoreFrame) {
		[self.window restoreWindowStateForClass:self.class];
	}
}

- (void)close
{
	[self.window close];
}

- (void)prepareForApplicationTermination
{
	[self close];
	
	for (id e in self.fileTransfers) {
		[e prepareForDestruction];
	}
}

- (void)nicknameChanged:(NSString *)oldNickname toNickname:(NSString *)newNickname client:(IRCClient *)client
{
	for (id e in self.fileTransfers) {
		if ([e associatedClient] == client) {
			if (NSObjectsAreEqual([e peerNickname], oldNickname)) {
				[e setPeerNickname:newNickname];
				
				[e reloadStatusInformation];
			}
		}
	}
}

- (void)addReceiverForClient:(IRCClient *)client nickname:(NSString *)nickname address:(NSString *)hostAddress port:(NSInteger)hostPort filename:(NSString *)filename size:(TXFSLongInt)size
{
	NSAssertReturn([self.fileTransfers count] < _addReceiverHardLimit);
	
	NSView *newView = [self.fileTransferTable makeViewWithIdentifier:@"ReceiverView" owner:self];
	
	if ([newView isKindOfClass:[TDCFileTransferDialogTransferReceiver class]]) {
		TDCFileTransferDialogTransferReceiver *groupItem = (TDCFileTransferDialogTransferReceiver *)newView;
		
		[groupItem setTransferDialog:self];
		[groupItem setAssociatedClient:client];
		[groupItem setPeerNickname:nickname];
		[groupItem setHostAddress:hostAddress];
		[groupItem setTransferPort:hostPort];
		[groupItem setFilename:filename];
		[groupItem setTotalFilesize:size];
		[groupItem setIsReceiving:YES];
		
		[groupItem populateBasicInformation];
		
		[self addReceiver:groupItem];
		
		if ([TPCPreferences fileTransferRequestReplyAction] == TXFileTransferRequestReplyAutomaticallyDownloadAction) {
			/* If the user is set to automatically download, then just save to the downloads folder. */
			[groupItem setPath:[TPCPreferences userDownloadFolderPath]];
			
			/* Begin the transfer. */
			[groupItem open];
		} else {
			[groupItem reloadStatusInformation];
		}
		
		[self show:NO restorePosition:NO];
	}
}

- (void)addSenderForClient:(IRCClient *)client nickname:(NSString *)nickname path:(NSString *)completePath autoOpen:(BOOL)autoOpen
{
	/* Gather file information. */
	NSDictionary *fileAttrs = [RZFileManager() attributesOfItemAtPath:completePath error:NULL];
	
	NSObjectIsEmptyAssert(fileAttrs);
	
	TXFSLongInt filesize = [fileAttrs longLongForKey:NSFileSize];
	
	NSAssertReturn(filesize > 0);
	
	NSString *actualFilename = [completePath lastPathComponent];
	NSString *actualFilePath = [completePath stringByDeletingLastPathComponent];
	
	/* Build view. */
	NSView *newView = [self.fileTransferTable makeViewWithIdentifier:@"SenderView" owner:self];
	
	if ([newView isKindOfClass:[TDCFileTransferDialogTransferSender class]]) {
		TDCFileTransferDialogTransferSender *groupItem = (TDCFileTransferDialogTransferSender *)newView;
		
		[groupItem setTransferDialog:self];
		[groupItem setAssociatedClient:client];
		[groupItem setPeerNickname:nickname];
		[groupItem setFilename:actualFilename];
		[groupItem setPath:actualFilePath];
		[groupItem setTotalFilesize:filesize];
		[groupItem setIsReceiving:NO];
		
		[groupItem populateBasicInformation];
		
		[self addSender:groupItem];
		
		/* Check if our sender address exists. */
		if (autoOpen) {
			[groupItem open];
		} else {
			[groupItem reloadStatusInformation];
		}
		
		/* Update dialog. */
		[self show:NO restorePosition:NO];
	}
}

- (void)updateClearButton
{
	BOOL enabled = NO;
	
	for (id e in self.fileTransfers) {
		if ([e transferStatus] == TDCFileTransferDialogTransferErrorStatus ||
			[e transferStatus] == TDCFileTransferDialogTransferCompleteStatus ||
			[e transferStatus] == TDCFileTransferDialogTransferStoppedStatus)
		{
			enabled = YES;
			
			break;
		}
	}
	
	[self.clearButton setEnabled:enabled];
}

- (void)addReceiver:(TDCFileTransferDialogTransferReceiver *)groupItem
{
	[self.fileTransfers addObject:groupItem];
	
	NSInteger i = [self.fileTransfers indexOfObject:groupItem];
	
	[self.fileTransferTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:i]
								  withAnimation:NSTableViewAnimationSlideUp];
}

- (void)addSender:(TDCFileTransferDialogTransferSender *)groupItem
{
	[self.fileTransfers addObject:groupItem];
	
	NSInteger i = [self.fileTransfers indexOfObject:groupItem];
	
	[self.fileTransferTable insertRowsAtIndexes:[NSIndexSet indexSetWithIndex:i]
								  withAnimation:NSTableViewAnimationSlideUp];
}

#pragma mark -
#pragma mark Actions

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	NSInteger tag = [item tag];
	
	/* What are we going to do with nothing selected? */
	if ([self.fileTransferTable countSelectedRows] <= 0) {
		return NO;
	}
	
	/* Build array of all selected rows. */
	NSMutableArray *sel = [NSMutableArray array];
	
	NSIndexSet *indexes = [self.fileTransferTable selectedRowIndexes];
	
	for (NSNumber *index in [indexes arrayFromIndexSet]) {
		NSInteger actlIndex = [index integerValue];
		
		[sel addObject:self.fileTransfers[actlIndex]];
	}
	
	/* Begin actual validation. */
	switch (tag) {
		case 3001:	// Start Download
		{
			for (id e in sel) {
				if ([e transferStatus] == TDCFileTransferDialogTransferErrorStatus ||
					[e transferStatus] == TDCFileTransferDialogTransferStoppedStatus)
				{
					return YES;
				}
			}
			
			return NO;
			
			break;
		}
		case 3003: // Stop Download
		{
			for (id e in sel) {
				if ([e transferStatus] == TDCFileTransferDialogTransferConnectingStatus ||
					[e transferStatus] == TDCFileTransferDialogTransferReceivingStatus ||
					[e transferStatus] == TDCFileTransferDialogTransferListeningStatus ||
					[e transferStatus] == TDCFileTransferDialogTransferSendingStatus)
				{
					return YES;
				}
			}
			
			return NO;
			
			break;
		}
		case 3004: // Remove Item
		{
			return YES;
			
			break;
		}
		case 3005: // Open File
		{
			for (id e in sel) {
				NSObjectIsKindOfClassAssertContinue(e, TDCFileTransferDialogTransferReceiver);
				
				if ([e transferStatus] == TDCFileTransferDialogTransferCompleteStatus) {
					return YES;
				}
			}
			
			return NO;
			
			break;
		}
		case 3006: // Reveal In Finder
		{
			for (id e in sel) {
				NSObjectIsKindOfClassAssertContinue(e, TDCFileTransferDialogTransferReceiver);
				
				if ([e transferStatus] == TDCFileTransferDialogTransferCompleteStatus) {
					return YES;
				}
			}
			
			return NO;
			
			break;
		}
	}
	
	return NO; // Default validation to NO.
}

- (void)clear:(id)sender
{
	for (NSInteger i = ([self.fileTransfers count] - 1); i >= 0; i--) {
		id obj = self.fileTransfers[i];
		
		if ([obj transferStatus] == TDCFileTransferDialogTransferErrorStatus ||
			[obj transferStatus] == TDCFileTransferDialogTransferCompleteStatus ||
			[obj transferStatus] == TDCFileTransferDialogTransferStoppedStatus)
		{
			[obj prepareForDestruction];
			
			[self.fileTransfers removeObjectAtIndex:i];
		}
	}
	
	[self.fileTransferTable reloadData];
	
	[self updateClearButton];
}

- (void)startTransferOfFile:(id)sender
{
	NSIndexSet *indexes = [self.fileTransferTable selectedRowIndexes];
	
	__block NSMutableArray *incomingTransfers = [NSMutableArray array];
	
	for (NSNumber *index in [indexes arrayFromIndexSet]) {
		NSInteger actualIndx = [index integerValue];
		
		id e = self.fileTransfers[actualIndx];
		
		if ([e transferStatus] == TDCFileTransferDialogTransferErrorStatus ||
			[e transferStatus] == TDCFileTransferDialogTransferStoppedStatus)
		{
			if ([e isKindOfClass:[TDCFileTransferDialogTransferSender class]]) {
				[e open];
			} else {
				if ([e path] == nil) {
					[incomingTransfers addObject:e];
				} else {
					[e open];
				}
			}
		}
	}
	
	if ([incomingTransfers count] > 0) {
		NSOpenPanel *d = [NSOpenPanel openPanel];
		
		NSURL *folderRep = [NSURL fileURLWithPath:[TPCPreferences userDownloadFolderPath]];
		
		[d setDirectoryURL:folderRep];
		
		[d setCanChooseFiles:NO];
		[d setResolvesAliases:YES];
		[d setCanChooseDirectories:YES];
		[d setCanCreateDirectories:YES];
		[d setAllowsMultipleSelection:NO];
		
		[d setPrompt:TXTLS(@"SelectButton")];
		[d setMessage:TXTLS(@"FileTransferDialogTransferSavePanelDialogMessage")];
		
		[d beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
			if (result == NSOKButton) {
				NSString *newPath = [d.URL path]; // Define path.
				
				for (TDCFileTransferDialogTransferReceiver *e in incomingTransfers) {
					[e setPath:newPath];
					[e open]; // Begin transfer.
				}
				
				incomingTransfers = nil;
			}
		}];
	}
}

- (void)stopTransferOfFile:(id)sender
{
	NSIndexSet *indexes = [self.fileTransferTable selectedRowIndexes];
	
	for (NSNumber *index in [indexes arrayFromIndexSet]) {
		NSInteger actualIndx = [index integerValue];
		
		id e = self.fileTransfers[actualIndx];
		
		if ([e isKindOfClass:[TDCFileTransferDialogTransferSender class]]) {
			[(TDCFileTransferDialogTransferSender *)e close:NO];
		} else {
			[(TDCFileTransferDialogTransferReceiver *)e close:NO];
		}
	}
}

- (void)removeTransferFromList:(id)sender
{
	NSIndexSet *indexes = [self.fileTransferTable selectedRowIndexes];
	
	[self.fileTransferTable removeRowsAtIndexes:indexes
								  withAnimation:NSTableViewAnimationSlideDown];
	
	for (NSNumber *index in [indexes arrayFromIndexSet]) {
		NSInteger actualIndx = [index integerValue];
		
		id e = self.fileTransfers[actualIndx];
		
		[e prepareForDestruction];
		
		[self.fileTransfers removeObjectAtIndex:actualIndx];
	}
}

- (void)openReceivedFile:(id)sender
{
	NSIndexSet *indexes = [self.fileTransferTable selectedRowIndexes];
	
	for (NSNumber *index in [indexes arrayFromIndexSet]) {
		NSInteger actualIndx = [index integerValue];
		
		id e = self.fileTransfers[actualIndx];
		
		NSObjectIsKindOfClassAssertContinue(e, TDCFileTransferDialogTransferReceiver);
		
		[RZWorkspace() openFile:[e completePath]];
	}
}

- (void)revealReceivedFileInFinder:(id)sender
{
	NSIndexSet *indexes = [self.fileTransferTable selectedRowIndexes];
	
	for (NSNumber *index in [indexes arrayFromIndexSet]) {
		NSInteger actualIndx = [index integerValue];
		
		id e = self.fileTransfers[actualIndx];
		
		NSObjectIsKindOfClassAssertContinue(e, TDCFileTransferDialogTransferReceiver);
		
		[RZWorkspace() selectFile:[e completePath] inFileViewerRootedAtPath:nil];
	}
}

#pragma mark -
#pragma mark Timer

- (void)updateMaintenanceTimerOnMainThread
{
	BOOL foundActive = NO;
	
	for (id e in self.fileTransfers) {
		if ([e transferStatus] == TDCFileTransferDialogTransferReceivingStatus ||
			[e transferStatus] == TDCFileTransferDialogTransferSendingStatus)
		{
			foundActive = YES;
			
			break;
		}
	}
	
    if ([self.maintenanceTimer timerIsActive]) {
        if (foundActive == NO) {
            [self.maintenanceTimer stop];
        }
    } else {
        if (foundActive) {
            [self.maintenanceTimer start:1];
        }
    }
}

- (void)updateMaintenanceTimer
{
	[self performSelectorOnMainThread:@selector(updateMaintenanceTimerOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)onMaintenanceTimer:(TLOTimer *)sender
{
	for (id e in self.fileTransfers) {
		if ([e transferStatus] == TDCFileTransferDialogTransferReceivingStatus ||
			[e transferStatus] == TDCFileTransferDialogTransferSendingStatus)
		{
			[e onMaintenanceTimer];
		}
	}
}

#pragma mark -
#pragma mark Table View Delegate

- (NSInteger)numberOfRowsInTableView:(NSTableView *)sender
{
	return [self.fileTransfers count];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return self.fileTransfers[row];
}

#pragma mark -
#pragma mark Network Information

- (void)requestIPAddressFromExternalSource
{
	[self.sourceIPAddressTextField setStringValue:TXTLS(@"FileTransferDialogSourceIPAddressUnknown")];
	
	if ([TPCPreferences fileTransferIPAddressDetectionMethod] == TXFileTransferIPAddressAutomaticDetectionMethod) {
		TDCFileTransferDialogRemoteAddress *request = [TDCFileTransferDialogRemoteAddress new];
		
		[request requestRemoteIPAddressFromExternalSource:self];
	} else {
		[self fileTransferRemoteAddressRequestDidDetectAddress:[TPCPreferences fileTransferManuallyEnteredIPAddress]];
	}
}

- (void)fileTransferRemoteAddressRequestDidCloseWithError:(NSError *)errPntr
{
	LogToConsole(@"Failed to complete connection request with error: %@", [errPntr localizedDescription]);
}

- (void)fileTransferRemoteAddressRequestDidDetectAddress:(NSString *)address
{
	/* Trim input. */
	address = [address trim];
	
	/* Is it even IP? */
	NSAssertReturn([address isIPAddress]);
	
	/* Okay, we are good… */
	self.cachedIPAddress = address;

	[self.sourceIPAddressTextField setStringValue:TXTFLS(@"FileTransferDialogSourceIPAddressValue", self.cachedIPAddress)];
}

#pragma mark -
#pragma mark Window Delegate

- (void)windowWillClose:(NSNotification *)note
{
	[self.window saveWindowStateForClass:self.class];
}

@end
