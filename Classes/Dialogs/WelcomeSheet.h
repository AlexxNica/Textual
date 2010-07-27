// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Michael Morris <mikey AT codeux DOT com> <http://github.com/mikemac11/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import <Foundation/Foundation.h>
#import "ListView.h"
#import "SheetBase.h"

@interface WelcomeSheet : SheetBase
{
	NSMutableArray* channels;
	
	IBOutlet NSTextField* nickText;
	IBOutlet NSTextField* hostCombo;
	IBOutlet ListView* channelTable;
	IBOutlet NSButton* autoConnectCheck;
	IBOutlet NSButton* addChannelButton;
	IBOutlet NSButton* deleteChannelButton;
}

@property (retain) NSMutableArray* channels;
@property (retain) NSTextField* nickText;
@property (retain) NSTextField* hostCombo;
@property (retain) ListView* channelTable;
@property (retain) NSButton* autoConnectCheck;
@property (retain) NSButton* addChannelButton;
@property (retain) NSButton* deleteChannelButton;

- (void)show;
- (void)close;

- (void)onOK:(id)sender;
- (void)onCancel:(id)sender;
- (void)onAddChannel:(id)sender;
- (void)onDeleteChannel:(id)sender;

- (void)onHostComboChanged:(id)sender;
@end

@interface NSObject (WelcomeSheetDelegate)
- (void)WelcomeSheet:(WelcomeSheet*)sender onOK:(NSDictionary*)config;
- (void)WelcomeSheetWillClose:(WelcomeSheet*)sender;
@end