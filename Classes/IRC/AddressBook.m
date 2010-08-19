// Created by Michael Morris <mikey AT codeux DOT com> <http://github.com/mikemac11/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import "AddressBook.h"
#import "NSDictionaryHelper.h"
#import "NSStringHelper.h"
#import "GlobalModels.h"

@implementation AddressBook

@synthesize cid;
@synthesize hostmask;
@synthesize ignorePublicMsg;
@synthesize ignorePrivateMsg;
@synthesize ignoreHighlights;
@synthesize ignoreNotices;
@synthesize ignoreCTCP;
@synthesize ignoreDCC;
@synthesize ignoreJPQE;
@synthesize hostmaskRegex;
@synthesize notifyJoins;
@synthesize notifyWhoisJoins;

- (void)dealloc
{
	[hostmask release];
	[hostmaskRegex release];
	[super dealloc];
}

- (id)init
{
	if (self = [super init]) {
	}
	return self;
}

- (id)initWithDictionary:(NSDictionary*)dic
{
	if ([self init]) {
		cid = TXRandomThousandNumber();
		
		cid = [dic intForKey:@"cid"] ?: cid;
		hostmask = [[dic objectForKey:@"hostmask"] retain];
		ignorePublicMsg = [dic boolForKey:@"ignorePublicMsg"];
		ignorePrivateMsg = [dic boolForKey:@"ignorePrivateMsg"];
		ignoreHighlights = [dic boolForKey:@"ignoreHighlights"];
		ignoreNotices = [dic boolForKey:@"ignoreNotices"];
		ignoreCTCP = [dic boolForKey:@"ignoreCTCP"];
		ignoreDCC = [dic boolForKey:@"ignoreDCC"];
		ignoreJPQE = [dic boolForKey:@"ignoreJPQE"];
		notifyJoins = [dic boolForKey:@"notifyJoins"];
		notifyWhoisJoins = [dic boolForKey:@"notifyWhoisJoins"];
		
		[self processHostMaskRegex];
	}
	return self;
}

- (void)processHostMaskRegex
{
	if (!hostmaskRegex && hostmask) {
		NSString *new_hostmask = [hostmask stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"{" withString:@"\\{"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"}" withString:@"\\}"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@")" withString:@"\\)"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"(" withString:@"\\("];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"]" withString:@"\\]"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"[" withString:@"\\["];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"^" withString:@"\\^"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"|" withString:@"\\|"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"~" withString:@"\\~"];
		new_hostmask = [new_hostmask stringByReplacingOccurrencesOfString:@"*" withString:@"(.*?)"];
		
		hostmaskRegex = [[NSString stringWithFormat:@"^%@$", new_hostmask] retain];
		new_hostmask = nil;
	}
}

- (NSDictionary*)dictionaryValue
{
	NSMutableDictionary* dic = [NSMutableDictionary dictionary];
	
	if (hostmask) [dic setObject:hostmask forKey:@"hostmask"];
	
	[dic setInt:cid forKey:@"cid"];
	[dic setBool:ignorePublicMsg forKey:@"ignorePublicMsg"];
	[dic setBool:ignorePrivateMsg forKey:@"ignorePrivateMsg"];
	[dic setBool:ignoreHighlights forKey:@"ignoreHighlights"];
	[dic setBool:ignoreNotices forKey:@"ignoreNotices"];
	[dic setBool:ignoreCTCP forKey:@"ignoreCTCP"];
	[dic setBool:ignoreDCC forKey:@"ignoreDCC"];
	[dic setBool:ignoreJPQE forKey:@"ignoreJPQE"];
	[dic setBool:notifyJoins forKey:@"notifyJoins"];
	[dic setBool:notifyWhoisJoins forKey:@"notifyWhoisJoins"];
	
	return dic;
}

- (BOOL)checkIgnore:(NSString*)thehost
{
	if (hostmaskRegex) {
		if ([thehost isMatchedByRegex:hostmaskRegex]) {
			return YES;
		}
	}
	
	return NO;
}

@end