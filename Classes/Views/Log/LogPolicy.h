// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Michael Morris <mikey AT codeux DOT com> <http://github.com/mikemac11/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import <Cocoa/Cocoa.h>

@class MenuController;

@interface LogPolicy : NSObject
{
	MenuController* menuController;
	NSMenu* menu;
	NSMenu* urlMenu;
	NSMenu* addrMenu;
	NSMenu* memberMenu;
	NSMenu* chanMenu;
	NSString* url;
	NSString* addr;
	NSString* nick;
	NSString* chan;
}

@property (nonatomic, assign) id menuController;
@property (nonatomic, retain) NSMenu* menu;
@property (nonatomic, retain) NSMenu* urlMenu;
@property (nonatomic, retain) NSMenu* addrMenu;
@property (nonatomic, retain) NSMenu* memberMenu;
@property (nonatomic, retain) NSMenu* chanMenu;
@property (nonatomic, retain) NSString* url;
@property (nonatomic, retain) NSString* addr;
@property (nonatomic, retain) NSString* nick;
@property (nonatomic, retain) NSString* chan;

@end