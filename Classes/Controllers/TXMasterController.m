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

#define KInternetEventClass		1196773964
#define KAEGetURL				1196773964

#ifndef TEXTUAL_BUILT_WITH_HOCKEYAPP_SDK_DISABLED
	#define _hockeyAppApplicationIdentifier			@"b0b1c84f339487c2e184f7d1ebfe5997"
	#define _hockeyAppApplicationCompanyName		@"Codeux Software"
#endif

@implementation TXMasterController

- (id)init
{
    if ((self = [super init])) {
		[NSObject setGlobalMasterControllerClassReference:self];
		
		// ---- //
		
#if defined(DEBUG)
		self.ghostModeIsOn = YES; // Do not use autoconnect during debug.
#else
		if ([NSEvent modifierFlags] & NSShiftKeyMask) {
			self.ghostModeIsOn = YES;
			
			LogToConsole(@"Launching without autoconnecting to the configured servers.");
		}
#endif
		
		// ---- //

		if ([NSEvent modifierFlags] & NSControlKeyMask) {
			self.debugModeIsOn = YES;

			LogToConsole(@"Launching in debug mode.");
		}

		// ---- //

		return self;
    }

    return nil;
}

- (void)awakeFromNib
{
	static BOOL _awakeFromNibCalled = NO;
	
	if (_awakeFromNibCalled == NO) {
		_awakeFromNibCalled = YES;
	
		/* We wait until -awakeFromNib to wake the window so that the menu
		 controller created by the main nib has time to load. */
		if ([CSFWSystemInformation featureAvailableToOSXYosemite]) {
			[RZMainBundle() loadCustomNibNamed:@"TVCMainWindowYosemite" owner:self topLevelObjects:nil];
		} else {
			[RZMainBundle() loadCustomNibNamed:@"TVCMainWindowMavericks" owner:self topLevelObjects:nil];
		}
	}
}

- (void)performAwakeningBeforeMainWindowDidLoad
{
	[TPCPreferences initPreferences];
	
#ifdef TEXTUAL_BUILT_WITH_ICLOUD_SUPPORT
	/* Cloud files are synced regardless of user preference
	 so we still have to initalize it at some point. */
	[sharedCloudManager() initializeCloudSyncSession];
#endif
	
	self.world = [IRCWorld new];
}

- (void)performAwakeningAfterMainWindowDidLoad
{
	[[TXSharedApplication sharedNetworkReachabilityObject] startNotifier];
	
	[RZWorkspaceNotificationCenter() addObserver:self selector:@selector(computerDidWakeUp:) name:NSWorkspaceDidWakeNotification object:nil];
	[RZWorkspaceNotificationCenter() addObserver:self selector:@selector(computerWillSleep:) name:NSWorkspaceWillSleepNotification object:nil];
	[RZWorkspaceNotificationCenter() addObserver:self selector:@selector(computerWillPowerOff:) name:NSWorkspaceWillPowerOffNotification object:nil];
	[RZWorkspaceNotificationCenter() addObserver:self selector:@selector(computerScreenDidWake:) name:NSWorkspaceScreensDidWakeNotification object:nil];
	[RZWorkspaceNotificationCenter() addObserver:self selector:@selector(computerScreenWillSleep:) name:NSWorkspaceScreensDidSleepNotification object:nil];
	
	[RZNotificationCenter() addObserver:self selector:@selector(systemTintChangedNotification:) name:NSControlTintDidChangeNotification object:nil];
	
	[RZAppleEventManager() setEventHandler:self andSelector:@selector(handleURLEvent:withReplyEvent:) forEventClass:KInternetEventClass andEventID:KAEGetURL];
	
	[sharedPluginManager() loadPlugins];
	
	[TPCResourceManager copyResourcesToCustomAddonsFolder];
	
	[self applicationDidFinishLaunching];
}

#pragma mark -
#pragma mark NSApplication Delegate

- (void)awakeHockeyApp
{
#ifndef TEXTUAL_BUILT_WITH_HOCKEYAPP_SDK_DISABLED
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:_hockeyAppApplicationIdentifier
														companyName:_hockeyAppApplicationCompanyName
														   delegate:self];
	
	[[BITHockeyManager sharedHockeyManager] startManager];
#endif
}

- (void)applicationDidFinishLaunching
{
	/* Register for HockeyApp. */
	[self awakeHockeyApp];
	
	if ([worldController() clientCount] < 1) {
		[mainWindowLoadingScreen() hideAll:NO];
		[mainWindowLoadingScreen() popWelcomeAddServerView];
	} else {
		[mainWindowLoadingScreen() hideLoadingConfigurationView];

		[worldController() autoConnectAfterWakeup:NO];
	}

	[mainWindow() maybeToggleFullscreenAfterLaunch];
}

- (void)systemTintChangedNotification:(NSNotification *)notification;
{
	NSAssertReturn(self.applicationIsTerminating == NO);
	
	[mainWindowMemberList() reloadAllUserInterfaceElements];
	
	[mainWindowServerList() reloadAllDrawings];
}

- (void)reloadMainWindowFrameOnScreenChange
{
	NSAssertReturn(self.applicationIsTerminating == NO);
	
	[TVCDockIcon resetCachedCount];
	[TVCDockIcon updateDockIcon];
	
	[mainWindowMemberList() reloadAllUserInterfaceElements];
		
	[mainWindowServerList() reloadAllDrawings];
}

- (void)reloadUserInterfaceItems
{
	NSAssertReturn(self.applicationIsTerminating == NO);
	
	[mainWindowServerList() updateBackgroundColor];
	[mainWindowServerList() reloadAllDrawings];

	[mainWindowMemberList() updateBackgroundColor];
	[mainWindowMemberList() reloadAllDrawings];
}

- (void)resetSelectedItemState
{
	NSAssertReturn(self.applicationIsTerminating == NO);

	id sel = [mainWindow() selectedItem];

	if (sel) {
		[sel resetState];
	}

	[TVCDockIcon updateDockIcon];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
	self.applicationIsChangingActiveState = YES;
}

- (void)applicationWillBecomeActive:(NSNotification *)notification
{
	self.applicationIsChangingActiveState = YES;
}

- (void)applicationDidResignActive:(NSNotification *)notification
{
	self.applicationIsActive = NO;
	self.applicationIsChangingActiveState = NO;

	[self reloadUserInterfaceItems];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
	self.applicationIsActive = YES;
	self.applicationIsChangingActiveState = NO;

	[self reloadUserInterfaceItems];
}

- (BOOL)queryTerminate
{
	if (self.applicationIsTerminating) {
		return YES;
	}
	
	if ([TPCPreferences confirmQuit]) {
		NSInteger result = [TLOPopupPrompts dialogWindowWithQuestion:TXTLS(@"BasicLanguage[1000][1]")
															   title:TXTLS(@"BasicLanguage[1000][2]") 
													   defaultButton:TXTLS(@"BasicLanguage[1000][3]") 
													 alternateButton:BLS(1009)
													  suppressionKey:nil
													 suppressionText:nil];
		
		return result;
	}
	
	return YES;
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	if ([self queryTerminate]) {
		self.applicationIsTerminating = YES;

		return NSTerminateNow;
	} else {
		return NSTerminateCancel;
	}
}

- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
	return [menuController() dockMenu];
}

- (BOOL)isNotSafeToPerformApplicationTermination
{
#ifdef TEXTUAL_BUILT_WITH_ICLOUD_SUPPORT
	if (sharedCloudManager()) {
		return (
				/* Clients are still disconnecting. */
				self.terminatingClientCount > 0 ||

				/* iCloud is syncing. */
				([sharedCloudManager() isSyncingLocalKeysDownstream] ||
				 [sharedCloudManager() isSyncingLocalKeysUpstream])
		);
	} else {
		return (self.terminatingClientCount > 0);
	}
#else
	return (self.terminatingClientCount > 0);
#endif
}

- (void)applicationWillTerminate:(NSNotification *)note
{
	[mainWindow() prepareForApplicationTermination];
	
	[RZRunningApplication() hide];

	[RZWorkspaceNotificationCenter() removeObserver:self];

	[RZNotificationCenter() removeObserver:self];

	[RZAppleEventManager() removeEventHandlerForEventClass:KInternetEventClass andEventID:KAEGetURL];
	
	[[TXSharedApplication sharedNetworkReachabilityObject] stopNotifier];
	
#ifdef TEXTUAL_BUILT_WITH_ICLOUD_SUPPORT
	[sharedCloudManager() setApplicationIsTerminating:YES];
#endif
	
	[menuController() prepareForApplicationTermination];

	if (self.skipTerminateSave == NO) {
		self.terminatingClientCount = [worldController() clientCount];

		[worldController() prepareForApplicationTermination];
		[worldController() save];

		while ([self isNotSafeToPerformApplicationTermination])
		{
			[RZMainRunLoop() runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
		}
	}
	
	[sharedPluginManager() unloadPlugins];
	
	[TXSharedApplication releaseSharedMutableSynchronizationSerialQueue];
	
	[TPCApplicationInfo saveTimeIntervalSinceApplicationInstall];

#ifdef TEXTUAL_BUILT_WITH_ICLOUD_SUPPORT
	[sharedCloudManager() closeCloudSyncSession];
#endif
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
	[self.mainWindow makeKeyAndOrderFront:nil];

	return YES;
}

#pragma mark -
#pragma mark NSWorkspace Notifications

- (void)handleURLEvent:(NSAppleEventDescriptor *)event
		withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
	TVCMainWindowNegateActionWithAttachedSheet();
	
	NSAppleEventDescriptor *desc = [event descriptorAtIndex:1];

	[IRCExtras parseIRCProtocolURI:[desc stringValue] withDescriptor:event];
}

- (void)computerScreenWillSleep:(NSNotification *)note
{
	[worldController() prepareForScreenSleep];
}

- (void)computerScreenDidWake:(NSNotification *)note
{
	[worldController() awakeFomScreenSleep];
}

- (void)computerWillSleep:(NSNotification *)note
{
	[worldController() prepareForSleep]; // Tell world to prepare.

	[[TXSharedApplication sharedSpeechSynthesizer] setIsStopped:YES]; // Stop speaking during sleep.
	[[TXSharedApplication sharedSpeechSynthesizer] clearQueue]; // Destroy pending spoken items.
}

- (void)computerDidWakeUp:(NSNotification *)note
{
	[[TXSharedApplication sharedSpeechSynthesizer] setIsStopped:NO]; // We can speak again!

	[worldController() autoConnectAfterWakeup:YES]; // Wake clients up…
}

- (void)computerWillPowerOff:(NSNotification *)note
{
	self.applicationIsTerminating = YES;
	
	[NSApp terminate:nil];
}

- (BOOL)applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	[self.mainWindow makeKeyAndOrderFront:nil];
	
	return YES;
}

#pragma mark -
#pragma mark NSWindow Delegate

- (void)windowDidChangeScreen:(NSNotification *)notification
{
	[self reloadMainWindowFrameOnScreenChange];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
	if (self.applicationIsChangingActiveState == NO) {
		[self reloadUserInterfaceItems];
	}

	[self resetSelectedItemState];
}

- (void)windowDidResignKey:(NSNotification *)notification
{
	if (self.applicationIsChangingActiveState == NO) {
		[self reloadUserInterfaceItems];
	}
}

@end
