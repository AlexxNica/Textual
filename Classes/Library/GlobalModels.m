// Created by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#define TIME_BUFFER_SIZE	256

extern BOOL NSObjectIsEmpty(id obj)
{
	if ([obj respondsToSelector:@selector(length)]) {
		return (PointerIsEmpty(obj) || (NSInteger)[obj performSelector:@selector(length)] < 1);
	} else {
		if ([obj respondsToSelector:@selector(count)]) {
			return (PointerIsEmpty(obj) || (NSInteger)[obj performSelector:@selector(count)] < 1);
		}
	}
	
	return PointerIsEmpty(obj);
}

extern BOOL NSObjectIsNotEmpty(id obj)
{
	return BOOLReverseValue(NSObjectIsEmpty(obj));
}

extern void DevNullDestroyObject(BOOL condition, ...)
{
	return;
}

extern NSInteger TXRandomThousandNumber(void)
{
	return ((1 + arc4random()) % (9999 + 1));
}

extern NSString *TXTLS(NSString *key)
{
	return [LanguagePreferences localizedStringWithKey:key];
}

extern NSString *TXTFLS(NSString *key, ...)
{
	NSString *formattedString = [NSString alloc];
	NSString *languageString = [LanguagePreferences localizedStringWithKey:key];
	
	va_list args;
	va_start(args, key);
	
	formattedString = [formattedString initWithFormat:languageString arguments:args];
	
	va_end(args);
	
	return [formattedString autodrain];
}

extern NSString *TXFormattedTimestampWithOverride(NSString *format, NSString *override) 
{
	if (NSObjectIsEmpty(format)) format = @"[%H:%M:%S]";
	if (NSObjectIsNotEmpty(override)) format = override;
	
	return [NSString stringWithFormat:@"%@", [[NSDate date] dateWithCalendarFormat:format timeZone:nil]];
}

extern NSString *TXFormattedTimestamp(NSString *format) 
{
	return TXFormattedTimestampWithOverride(format, nil);
}

extern NSString *TXReadableTime(NSInteger dateInterval) 
{
	NSArray *orderMatrix = [NSArray arrayWithObjects:@"year", @"month", @"week", @"day", @"hour", @"minute", @"second", nil];
	
	NSCalendar *sysCalendar = [NSCalendar currentCalendar];
	
	NSDate *date1 = [NSDate date];
	NSDate *date2 = [NSDate dateWithTimeIntervalSinceNow:(-(dateInterval + 1))];
	
	NSUInteger unitFlags = (NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | 
							NSWeekCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit);
	
	NSDateComponents *breakdownInfo = [sysCalendar components:unitFlags fromDate:date1 toDate:date2  options:0];
	
	if (breakdownInfo) {
		NSMutableString *finalResult = [NSMutableString string];
		
		for (NSString *unit in orderMatrix) {
			NSInteger total = (NSInteger)[breakdownInfo performSelector:NSSelectorFromString(unit)];
			
			if (total < 0) {
				total *= -1;
			}
			
			if (total >= 1) {
				NSString *languageKey = [@"TIME_CONVERT_" stringByAppendingString:[unit uppercaseString]];
				
				if (total > 1 || total < 1) {
					languageKey = [languageKey stringByAppendingString:@"_PLURAL"];
				}
				
				[finalResult appendFormat:@"%i %@, ", total, TXTLS(languageKey)];
			}
		}
		
		[finalResult deleteCharactersInRange:NSMakeRange(([finalResult length] - 2), 2)];
		
		return finalResult;
	}
	
	return nil;
}
