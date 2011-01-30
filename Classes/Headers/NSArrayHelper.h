// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// You can redistribute it and/or modify it under the new BSD license.

@interface NSArray (NSArrayHelper)
- (id)safeObjectAtIndex:(NSInteger)n;
- (BOOL)containsObjectIgnoringCase:(id)anObject;
@end

@interface NSMutableArray (NSMutableArrayHelper)
- (void)safeRemoveObjectAtIndex:(NSInteger)n;
@end

@interface NSIndexSet (NSIndexSetHelper)
- (NSArray *)arrayFromIndexSet;
@end