// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// You can redistribute it and/or modify it under the new BSD license.

#import "NSPasteboardHelper.h"

@implementation NSPasteboard (NSPasteboardHelper)

- (BOOL)hasStringContent
{
	return [self availableTypeFromArray:[NSArray arrayWithObject:NSStringPboardType]] != nil;
}

- (NSString*)stringContent
{
	return [self stringForType:NSStringPboardType];
}

- (void)setStringContent:(NSString*)s
{
	[self declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[self setString:s forType:NSStringPboardType];
}

@end