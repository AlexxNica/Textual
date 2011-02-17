/*
 * The AutoHyperlinks Framework is the legal property of its developers (DEVELOPERS), 
 * whose names are listed in the copyright file included with this source distribution.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * Neither the name of the AutoHyperlinks Framework nor the
 *       names of its contributors may be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY ITS DEVELOPERS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ITS DEVELOPERS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#define DEFAULT_URL_SCHEME	@"http://"
#define ENC_INDEX_KEY		@"encIndex"
#define ENC_CHAR_KEY		@"encChar"

@interface AHHyperlinkScanner (Private)
- (NSArray *)_allMatches;
- (NSRange)_longestBalancedEnclosureInRange:(NSRange)inRange;
- (BOOL)_scanString:(NSString *)inString charactersFromSet:(NSCharacterSet *)inCharSet intoRange:(NSRange *)outRangeRef fromIndex:(unsigned long *)idx;
- (BOOL)_scanString:(NSString *)inString upToCharactersFromSet:(NSCharacterSet *)inCharSet intoRange:(NSRange *)outRangeRef fromIndex:(unsigned long *)idx;
@end

@implementation AHHyperlinkScanner

static NSCharacterSet			*skipSet						= nil;
static NSCharacterSet			*endSet							= nil;
static NSCharacterSet			*startSet						= nil;
static NSCharacterSet			*puncSet						= nil;
static NSCharacterSet			*hostnameComponentSeparatorSet	= nil;
static NSArray					*enclosureStartArray			= nil;
static NSCharacterSet			*enclosureSet					= nil;
static NSArray					*enclosureStopArray				= nil;
static NSArray					*encKeys						= nil;

@synthesize urlSchemes			= m_urlSchemes;
@synthesize scanString			= m_scanString;
@synthesize strictChecking		= m_strictChecking;
@synthesize scanLocation		= m_scanLocation;
@synthesize scanStringLength	= m_scanStringLength;

#pragma mark -
#pragma mark Initalization

+ (void)initialize
{
	if (self == [AHHyperlinkScanner class]) {
		NSMutableCharacterSet *mutableSkipSet = [[NSMutableCharacterSet alloc] init];
		NSMutableCharacterSet *mutableStartSet = [[NSMutableCharacterSet alloc] init];
		
		[mutableSkipSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[mutableSkipSet formUnionWithCharacterSet:[NSCharacterSet illegalCharacterSet]];
		[mutableSkipSet formUnionWithCharacterSet:[NSCharacterSet controlCharacterSet]];
		[mutableSkipSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
		
		[mutableStartSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		[mutableStartSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"\"'.,:;<?!-@%C%C", 0x2014, 0x2013]]];
		
		skipSet = [NSCharacterSet characterSetWithBitmapRepresentation:[mutableSkipSet bitmapRepresentation]];
		startSet = [NSCharacterSet characterSetWithBitmapRepresentation:[mutableStartSet bitmapRepresentation]];
		endSet = [NSCharacterSet characterSetWithCharactersInString:@"\"',:;>)]}.?!@"];
		puncSet = [NSCharacterSet characterSetWithCharactersInString:@"\"'.,:;<?!"];
		hostnameComponentSeparatorSet = [NSCharacterSet characterSetWithCharactersInString:@"./"];
		enclosureStartArray = [NSArray arrayWithObjects:@"(",@"[",@"{",nil];
		enclosureSet = [NSCharacterSet characterSetWithCharactersInString:@"()[]{}"];
		enclosureStopArray = [NSArray arrayWithObjects:@")",@"]",@"}",nil];
		encKeys = [NSArray arrayWithObjects:ENC_INDEX_KEY, ENC_CHAR_KEY, nil];
		
		[endSet retain];
		[puncSet retain];
		[encKeys retain];
		[skipSet retain];
		[startSet retain];
		[enclosureSet retain];
		[enclosureStopArray retain];
		[enclosureStartArray retain];
		[hostnameComponentSeparatorSet retain];
		
		[mutableStartSet release];
		[mutableSkipSet release];
	}
}

+ (AHHyperlinkScanner *)linkScanner
{
	return [[[self class] new] autorelease];
}

- (NSArray *)matchesForString:(NSString *)inString
{
	m_strictChecking = NO;
	m_scanString = inString;
	m_scanStringLength = [m_scanString length];
	m_urlSchemes = [NSDictionary dictionaryWithObjectsAndKeys:@"ftp://", @"ftp", nil];
	
	[m_scanString retain];
	[m_urlSchemes retain];
	
	return [self _allMatches];
}

- (NSArray *)strictMatchesForString:(NSString *)inString
{
	m_strictChecking = YES;
	m_scanString = inString;
	m_scanStringLength = [m_scanString length];
	m_urlSchemes = [NSDictionary dictionaryWithObjectsAndKeys:@"ftp://", @"ftp", nil];
	
	[m_scanString retain];
	[m_urlSchemes retain];
	
	return [self _allMatches];
}

- (void)dealloc
{
	m_scanLocation = 0;
	
	[m_scanString release];
	[m_urlSchemes release];
	
	[super dealloc];
}

- (BOOL)isStringValidURI:(NSString *)inString usingStrict:(BOOL)useStrictChecking fromIndex:(unsigned long *)sIndex 
{
    AH_BUFFER_STATE		buf;  
	AH_URI_STATUS		validStatus;
	const char			*inStringEnc;
    unsigned long		encodedLength;
	yyscan_t			scanner; 
	
	validStatus = AH_URL_INVALID; 
	
	NSStringEncoding stringEnc = [inString fastestEncoding];
	
	if ([@" " lengthOfBytesUsingEncoding:stringEnc] > 1U) {
		stringEnc = NSUTF8StringEncoding;
	}
	
	if ((inStringEnc = [inString cStringUsingEncoding:stringEnc]) == NO) {
		return NO;
	}
	
	encodedLength = strlen(inStringEnc); 
    
	AHlex_init(&scanner);
	
    buf = AH_scan_string(inStringEnc, scanner);
	
    validStatus = (AH_URI_STATUS)AHlex(scanner);
	
	if (sIndex) {
		*sIndex += AHget_leng(scanner);
	}
	
    if ((validStatus == AH_URL_VALID || validStatus == AH_MAILTO_VALID || validStatus == AH_FILE_VALID) ||
		((validStatus == AH_URL_DEGENERATE || validStatus == AH_MAILTO_DEGENERATE) && useStrictChecking == NO)) {
		
        AH_delete_buffer(buf, scanner); 
		
        buf = NULL;
        
        if (AHget_leng(scanner) == encodedLength) {
			AHlex_destroy(scanner);
			
            return YES;
        }
    } else {
        AH_delete_buffer(buf, scanner);
		
        buf = NULL;
		
		AHlex_destroy(scanner);
		
        return NO;
    }
	
	AHlex_destroy(scanner);
	
    return NO;
}	

- (NSString *)nextURI
{
	NSRange	scannedRange;
	
	unsigned long scannedLocation = m_scanLocation;
	
	[self _scanString:m_scanString charactersFromSet:startSet intoRange:nil fromIndex:&scannedLocation];
	
	while ([self _scanString:m_scanString upToCharactersFromSet:skipSet intoRange:&scannedRange fromIndex:&scannedLocation]) {
		if ([enclosureSet characterIsMember:[m_scanString characterAtIndex:scannedRange.location]]) {
			unsigned long encIdx = [enclosureStartArray indexOfObject:[m_scanString substringWithRange:NSMakeRange(scannedRange.location, 1)]];
			
			NSRange encRange;
			
			if (NSNotFound != encIdx) {
				encRange = [m_scanString rangeOfString:[enclosureStopArray objectAtIndex:encIdx] options:NSBackwardsSearch range:scannedRange];
				
				if (NSNotFound != encRange.location) {
					scannedRange.location++; 
					scannedRange.length -= 2;
				}
			}
		}
		
		if (scannedRange.length <= 0) {
			break;
		}
		
		NSRange longestEnclosure = [self _longestBalancedEnclosureInRange:scannedRange];
		
		while (scannedRange.length > 2 && [endSet characterIsMember:[m_scanString characterAtIndex:(scannedRange.location + scannedRange.length - 1)]]) {
			if ((longestEnclosure.location + longestEnclosure.length) < scannedRange.length) {
				scannedRange.length -= 1;
			} else {
				break;
			}
		}
		
		if (m_firstCharOnlyMatch) {
			if (scannedRange.location >= 1) {
				scannedRange.location--; 
				scannedRange.length++;
			}
			
			m_firstCharOnlyMatch = NO;
		}
		
		if (scannedRange.length >= 4) {
			
			NSString *_scanString = [m_scanString substringWithRange:scannedRange];
			
			if ([self isStringValidURI:_scanString usingStrict:m_strictChecking fromIndex:&m_scanLocation]) {
				return NSStringFromRange(scannedRange);
			}
		}
		
		NSRange startRange = [m_scanString rangeOfCharacterFromSet:puncSet options:NSLiteralSearch range:scannedRange];
		
		if (startRange.location == NSNotFound) {
			m_scanLocation += scannedRange.length;
		} else {
			m_firstCharOnlyMatch = YES;
			
			m_scanLocation++;
		}
		
		scannedLocation = m_scanLocation;
	}
	
    m_scanLocation = m_scanStringLength;
	
    return nil;
}

#pragma mark -
#pragma mark Private Methods

- (NSArray *)_allMatches;
{
    NSMutableArray *rangeArray = [NSMutableArray array];
	
	m_scanLocation = 0; 
    
	while (m_scanLocation < [m_scanString length]) {
		NSString *markedLink = [self nextURI];
		
		if (markedLink) {	
			[rangeArray addObject:markedLink];
		}	
	}
	
	return rangeArray;
}

- (NSRange)_longestBalancedEnclosureInRange:(NSRange)inRange
{
	NSDictionary *encDict = nil;
	
	NSMutableArray *enclosureStack = nil;
	NSMutableArray *enclosureArray = nil;
	
	NSString *matchChar = nil;
	
	unsigned long encScanLocation = inRange.location;
	
	while (encScanLocation < (inRange.length + inRange.location)) {
		[self _scanString:m_scanString upToCharactersFromSet:enclosureSet intoRange:nil fromIndex:&encScanLocation];
		
		if (encScanLocation >= (inRange.location + inRange.length)) {
			break;
		}
		
		matchChar = [m_scanString substringWithRange:NSMakeRange(encScanLocation, 1)];
		
		if ([enclosureStartArray containsObject:matchChar]) {
			encDict = [NSDictionary	dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedLong:encScanLocation], matchChar, nil]
												  forKeys:encKeys];
			
			if (enclosureStack == nil) {
				enclosureStack = [NSMutableArray array];
			}
			
			[enclosureStack addObject:encDict];
		} else if ([enclosureStopArray containsObject:matchChar]) {
			NSEnumerator *encEnumerator = [enclosureStack objectEnumerator];
			
			while ((encDict = [encEnumerator nextObject])) {
				unsigned long encTagIndex	 = [[encDict objectForKey:ENC_INDEX_KEY] unsignedLongValue];
				unsigned long encStartIndex  = [enclosureStartArray indexOfObjectIdenticalTo:[encDict objectForKey:ENC_CHAR_KEY]];
				
				if ([enclosureStopArray indexOfObjectIdenticalTo:matchChar] == encStartIndex) {
					NSRange encRange = NSMakeRange(encTagIndex, (encScanLocation - encTagIndex + 1));
					
					if (enclosureStack == nil) {
						enclosureStack = [NSMutableArray array];
					}
					
					if (enclosureArray == nil) {
						enclosureArray = [NSMutableArray array];
					}
					
					if ([enclosureStack containsObject:encDict]) {
						[enclosureStack removeObject:encDict];
					}
					
					[enclosureArray addObject:NSStringFromRange(encRange)];
					
					break;
				}
			}
		}
		
		if (encScanLocation < (inRange.length + inRange.location)) {
			encScanLocation++;
		}
	}
	
	if (enclosureArray && [enclosureArray count]) {
		return NSRangeFromString([enclosureArray lastObject]);
	} else {
		return NSMakeRange(0, 0);
	}
}

- (BOOL)_scanString:(NSString *)inString upToCharactersFromSet:(NSCharacterSet *)inCharSet intoRange:(NSRange *)outRangeRef fromIndex:(unsigned long *)idx
{
	unichar			_curChar;
	NSRange			_outRange;
	unsigned long	_scanLength = [inString length];
	unsigned long	_idx;
	
	if (_scanLength <= *idx) {
		return NO;
	}
	
	for (_idx = *idx; _scanLength > _idx; _idx++) {
		_curChar = [inString characterAtIndex:_idx];
		
		if ([skipSet characterIsMember:_curChar] == NO) {
			break;
		}
	}
	
	for (*idx = _idx; _scanLength > _idx; _idx++) {
		_curChar = [inString characterAtIndex:_idx];
		
		if ([inCharSet characterIsMember:_curChar] || 
			[skipSet characterIsMember:_curChar]) {
			
			break;
		}
	}
	
	_outRange = NSMakeRange(*idx, (_idx - *idx));
	
	*idx = _idx;
	
	if (_outRange.length) {
		if (outRangeRef) {
			*outRangeRef = _outRange;
		}
		
		return YES;
	} else {
		return NO;
	}
}

- (BOOL)_scanString:(NSString *)inString charactersFromSet:(NSCharacterSet *)inCharSet intoRange:(NSRange *)outRangeRef fromIndex:(unsigned long *)idx
{
	unichar			_curChar;
	NSRange			_outRange;
	unsigned long	_scanLength = [inString length];
	unsigned long	_idx = *idx;
	
	if (_scanLength <= _idx) {
		return NO;
	}
	
	for (_idx = *idx; _scanLength > _idx; _idx++) {
		_curChar = [inString characterAtIndex:_idx];
		
		if ([skipSet characterIsMember:_curChar] == NO) {
			break;
		}
	}
	
	for (*idx = _idx; _scanLength > _idx; _idx++) {
		_curChar = [inString characterAtIndex:_idx];
		
		if ([inCharSet characterIsMember:_curChar] == NO) {
			break;
		}
	}
	
	_outRange = NSMakeRange(*idx, (_idx - *idx));
	
	*idx = _idx;
	
	if (_outRange.length) {
		if (outRangeRef) {
			*outRangeRef = _outRange;
		}
		
		return YES;
	} else {
		return NO;
	}
}

@end