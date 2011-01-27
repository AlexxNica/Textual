// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#define IsAlpha(c)							('a' <= (c) && (c) <= 'z' || 'A' <= (c) && (c) <= 'Z')
#define IsNumeric(c)						('0' <= (c) && (c) <= '9' && IsAlpha(c) == NO) 
#define IsAlphaNum(c)						(IsAlpha(c) || IsNumeric(c))
#define IsWordLetter(c)						(IsAlphaNum(c) || (c) == '_')
#define IsIRCColor(c,f)						([NSNumber compareIRCColor:c against:f])
#define IsAlphaWithDiacriticalMark(c)		(0xc0 <= c && c <= 0xff && c != 0xd7 && c != 0xf7)

@interface NSString (NSStringHelper)
- (NSString *)safeSubstringAfterIndex:(NSInteger)anIndex;
- (NSString *)safeSubstringBeforeIndex:(NSInteger)anIndex;

- (NSString *)safeSubstringFromIndex:(NSInteger)anIndex;
- (NSString *)safeSubstringToIndex:(NSInteger)anIndex;
- (NSString *)safeSubstringWithRange:(NSRange)range;

- (NSString *)fastChopEndWithChars:(NSArray *)chars;

- (NSString *)nicknameFromHostmask;
- (NSString *)cleanedServerHostmask;

- (BOOL)isEqualNoCase:(NSString *)other;

- (BOOL)contains:(NSString *)str;
- (BOOL)containsIgnoringCase:(NSString *)str;

- (NSInteger)findCharacter:(UniChar)c;
- (NSInteger)findCharacter:(UniChar)c start:(NSInteger)start;
- (NSInteger)findString:(NSString *)str;
- (NSInteger)stringPosition:(NSString *)needle;

- (NSArray *)split:(NSString *)delimiter;
- (NSArray *)splitIntoLines;

- (NSString *)trim;

- (id)attributedStringWithIRCFormatting;

- (BOOL)isAlphaNumOnly;
- (BOOL)isNumericOnly;

- (NSInteger)firstCharCodePoint;
- (NSInteger)lastCharCodePoint;

- (NSString *)safeUsername;
- (NSString *)safeFileName;
- (NSString *)canonicalName;

- (NSString *)stripEffects;

- (NSRange)rangeOfAddress;
- (NSRange)rangeOfAddressStart:(NSInteger)start;

- (NSRange)rangeOfChannelName;
- (NSRange)rangeOfChannelNameStart:(NSInteger)start;

- (NSString *)encodeURIComponent;
- (NSString *)encodeURIFragment;

- (BOOL)isChannelName;
- (BOOL)isModeChannelName;

+ (NSString *)stringWithUUID;

- (NSString *)stringWithInputIRCFormatting;
- (NSString *)stringWithASCIIFormatting;
@end

@interface NSString (NSStringNumberHelper)
+ (NSString *)stringWithChar:(char)value;
+ (NSString *)stringWithUniChar:(UniChar)value;
+ (NSString *)stringWithUnsignedChar:(unsigned char)value;
+ (NSString *)stringWithShort:(short)value;
+ (NSString *)stringWithUnsignedShort:(unsigned short)value;
+ (NSString *)stringWithInt:(int)value;
+ (NSString *)stringWithUnsignedInt:(unsigned int)value;
+ (NSString *)stringWithLong:(long)value;
+ (NSString *)stringWithUnsignedLong:(unsigned long)value;
+ (NSString *)stringWithLongLong:(long long)value;
+ (NSString *)stringWithUnsignedLongLong:(unsigned long long)value;
+ (NSString *)stringWithFloat:(float)value;
+ (NSString *)stringWithDouble:(double)value;
+ (NSString *)stringWithInteger:(NSInteger)value;
+ (NSString *)stringWithUnsignedInteger:(NSUInteger)value;
@end

@interface NSMutableString (NSMutableStringHelper)
- (NSString *)getToken;
- (NSString *)getIgnoreToken;
@end