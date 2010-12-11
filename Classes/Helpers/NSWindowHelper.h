// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import <Foundation/Foundation.h>

@interface NSWindow (NSWindowHelper)
- (void)centerOfWindow:(NSWindow*)window;
- (id)isOnCurrentWorkspace;
- (void)centerWindow;
@end