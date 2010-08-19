// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Michael Morris <mikey AT codeux DOT com> <http://github.com/mikemac11/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import <Foundation/Foundation.h>
#import "SheetBase.h"

@interface InviteSheet : SheetBase
{
	NSArray* nicks;
	NSInteger uid;
	
	IBOutlet NSTextField* titleLabel;
	IBOutlet NSPopUpButton* channelPopup;
}

@property (nonatomic, retain) NSArray* nicks;
@property (nonatomic, assign) NSInteger uid;
@property (nonatomic, retain) NSTextField* titleLabel;
@property (nonatomic, retain) NSPopUpButton* channelPopup;

- (void)startWithChannels:(NSArray*)channels;
- (void)invite:(id)sender;
@end

@interface NSObject (InviteSheetDelegate)
- (void)inviteSheet:(InviteSheet*)sender onSelectChannel:(NSString*)channelName;
- (void)inviteSheetWillClose:(InviteSheet*)sender;
@end