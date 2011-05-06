// Created by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

@implementation NSDate (NSDateHelper)
 
+ (NSInteger)secondsSinceUnixTimestamp:(NSInteger)stamp
{
	return ([[NSDate date] timeIntervalSince1970] - stamp);
}

@end