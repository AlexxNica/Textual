// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#define URL_ATTR				(1 << 31)
#define ADDRESS_ATTR			(1 << 30)
#define CHANNEL_NAME_ATTR		(1 << 29)
#define BOLD_ATTR				(1 << 28)
#define UNDERLINE_ATTR			(1 << 27)
#define ITALIC_ATTR				(1 << 26)
#define TEXT_COLOR_ATTR			(1 << 25)
#define BACKGROUND_COLOR_ATTR	(1 << 24)
#define CONVERSATION_TRKR_ATTR	(1 << 23)
#define HIGHLIGHT_KEYWORD_ATTR	(1 << 22)

#define BACKGROUND_COLOR_MASK	(0xF0)
#define TEXT_COLOR_MASK			(0x0F)

#define EFFECT_MASK				(BOLD_ATTR | UNDERLINE_ATTR | ITALIC_ATTR | TEXT_COLOR_ATTR | BACKGROUND_COLOR_ATTR)

typedef uint32_t attr_t;

static void setFlag(attr_t* attrBuf, attr_t flag, NSInteger start, NSInteger len)
{
	attr_t* target = attrBuf + start;
	attr_t* end = target + len;
	
	while (target < end) {
		*target |= flag;
		++target;
	}
}

static BOOL isClear(attr_t* attrBuf, attr_t flag, NSInteger start, NSInteger len)
{
	attr_t* target = attrBuf + start;
	attr_t* end = target + len;
	
	while (target < end) {
		if (*target & flag) return NO;
		++target;
	}
	
	return YES;
}

static NSInteger getNextAttributeRange(attr_t* attrBuf, NSInteger start, NSInteger len)
{
	attr_t target = attrBuf[start];
	
	for (NSInteger i = start; i < len; ++i) {
		attr_t t = attrBuf[i];
		
		if (t != target) {
			return i - start;
		}
	}
	
	return len - start;
}

NSComparisonResult nicknameLengthSort(IRCUser *s1, IRCUser *s2, void *context) 
{
	return ([s1.nick length] <= [s2.nick length]);
}

NSString *logEscape(NSString *s)
{
	return [[s gtm_stringByEscapingForHTML] stringByReplacingOccurrencesOfString:@"  " withString:@" &nbsp;"];
}

NSInteger mapColorValue(NSColor *color)
{
	for (NSInteger i = 0; i <= 15; i++) {
		NSColor *mapped = mapColorCode(i);
		
		if ([mapped isEqual:color]) {
			return i;
		}
	}
	
	return -1;
}

NSColor *mapColorCode(NSInteger colorChar) 
{
	switch (colorChar) {
		case 0:  return [NSColor fromCSS:@"#ffffff"]; 
		case 1:  return [NSColor fromCSS:@"#000000"]; 
		case 2:  return [NSColor fromCSS:@"#000088"]; 
		case 3:  return [NSColor fromCSS:@"#008800"]; 
		case 4:  return [NSColor fromCSS:@"#ff0000"]; 
		case 5:  return [NSColor fromCSS:@"#880000"]; 
		case 6:  return [NSColor fromCSS:@"#880088"]; 
		case 7:  return [NSColor fromCSS:@"#ff8800"]; 
		case 8:  return [NSColor fromCSS:@"#ffff00"]; 
		case 9:  return [NSColor fromCSS:@"#00ff00"]; 
		case 10: return [NSColor fromCSS:@"#008888"]; 
		case 11: return [NSColor fromCSS:@"#00ffff"]; 
		case 12: return [NSColor fromCSS:@"#0000ff"]; 
		case 13: return [NSColor fromCSS:@"#ff00ff"]; 
		case 14: return [NSColor fromCSS:@"#888888"]; 
		case 15: return [NSColor fromCSS:@"#cccccc"]; 
	}
	
	return nil;
}

static NSMutableAttributedString *renderAttributedRange(NSMutableAttributedString *body, attr_t attr, NSInteger start, NSInteger len)
{
	NSRange r = NSMakeRange(start, len);
	
	if (attr & EFFECT_MASK) {
		NSFont *boldItalic = [NSFont fontWithName:@"Lucida Grande" size:12.0];
		
		if (attr & BOLD_ATTR) {
			boldItalic = [_NSFontManager() convertFont:boldItalic toHaveTrait:NSBoldFontMask];
			
			[body addAttribute:IRCTextFormatterBoldAttributeName value:[NSNumber numberWithBool:YES] range:r];
		}
		
		if (attr & ITALIC_ATTR) {
			boldItalic = [boldItalic convertToItalics];
			
			[body addAttribute:IRCTextFormatterItalicAttributeName value:[NSNumber numberWithBool:YES] range:r];
		}
		
		if (boldItalic) {
			[body addAttribute:NSFontAttributeName value:boldItalic range:r];
		}
		
		if (attr & UNDERLINE_ATTR) {
			[body addAttribute:IRCTextFormatterUnderlineAttributeName value:[NSNumber numberWithBool:YES]					range:r];
			[body addAttribute:NSUnderlineStyleAttributeName		  value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:r];
		}
		
		if (attr & TEXT_COLOR_ATTR) {
			NSInteger colorCode = (attr & TEXT_COLOR_MASK);
			
			[body addAttribute:NSForegroundColorAttributeName				value:mapColorCode(colorCode)				 range:r];
			[body addAttribute:IRCTextFormatterForegroundColorAttributeName value:[NSNumber numberWithInteger:colorCode] range:r];
		}
		
		if (attr & BACKGROUND_COLOR_ATTR) {
			NSInteger colorCode = ((attr & BACKGROUND_COLOR_MASK) >> 4);
			
			[body addAttribute:NSBackgroundColorAttributeName				value:mapColorCode(colorCode)				 range:r];
			[body addAttribute:IRCTextFormatterBackgroundColorAttributeName value:[NSNumber numberWithInteger:colorCode] range:r];
		}
	}
	
	return body;
}

static NSString *renderRange(NSString *body, attr_t attr, NSInteger start, NSInteger len, LogController *log)
{
	NSString *content = [body safeSubstringWithRange:NSMakeRange(start, len)];
	
	if (attr & URL_ATTR) {
		NSString *link = content;
		
		if ([link contains:@"://"] == NO) {
			link = [NSString stringWithFormat:@"http://%@", link];
		}	
		
		return [NSString stringWithFormat:@"<a href=\"%@\" class=\"url\" oncontextmenu=\"Textual.on_url()\">%@</a>", link, logEscape(content)];
	} else if (attr & ADDRESS_ATTR) {
		return [NSString stringWithFormat:@"<span class=\"address\" oncontextmenu=\"Textual.on_addr()\">%@</span>", logEscape(content)];
	} else if (attr & CHANNEL_NAME_ATTR) {
		return [NSString stringWithFormat:@"<span class=\"channel\" ondblclick=\"Textual.on_dblclick_chname()\" oncontextmenu=\"Textual.on_chname()\">%@</span>", logEscape(content)];
	} else {
		BOOL matchedUser = NO;
		
		content = logEscape(content);
		
		NSMutableString *s = [NSMutableString string];
		
		if (attr & CONVERSATION_TRKR_ATTR) {
			IRCUser *user = [log.channel findMember:content options:NSCaseInsensitiveSearch];
			
			if (PointerIsEmpty(user) == NO) {
				matchedUser = YES;
				
				[s appendFormat:@"<span class=\"inline_nickname\" ondblclick=\"Textual.on_dblclick_ct_nick()\" oncontextmenu=\"Textual.on_ct_nick()\" colornumber=\"%d\">", [user colorNumber]];
			} 
		}
		
		if (attr & EFFECT_MASK) {
			[s appendString:@"<span class=\"effect\" style=\""];
			
			if (attr & BOLD_ATTR)	   [s appendString:@"font-weight:bold;"];
			if (attr & ITALIC_ATTR)    [s appendString:@"font-style:italic;"];
			if (attr & UNDERLINE_ATTR) [s appendString:@"text-decoration:underline;"];
			
			[s appendString:@"\""];
			
			if (attr & TEXT_COLOR_ATTR)		  [s appendFormat:@" color-number=\"%d\"", (attr & TEXT_COLOR_MASK)];
			if (attr & BACKGROUND_COLOR_ATTR) [s appendFormat:@" bgcolor-number=\"%d\"", (attr & BACKGROUND_COLOR_MASK) >> 4];
			
			[s appendFormat:@">%@</span>", content];
		} else {
			if (matchedUser == NO) {
				return content;
			} else {
				[s appendString:content];
			}
		}
		
		if (matchedUser) {
			[s appendString:@"</span>"];
		}
		
		return s;
	}
}

@implementation LogRenderer

+ (NSString *)renderBody:(NSString *)body 
			  controller:(LogController *)log
			  renderType:(LogRendererType)drawingType
			  properties:(NSDictionary *)inputDictionary
			  resultInfo:(NSDictionary **)outputDictionary
{
	NSMutableDictionary *resultInfo = [NSMutableDictionary dictionary];
	
	BOOL renderLinks = [inputDictionary boolForKey:@"renderLinks"];
	BOOL exactWordMatching = ([Preferences keywordMatchingMethod] == KEYWORD_MATCH_EXACT);
	
	NSArray *keywords = [inputDictionary arrayForKey:@"keywords"];
	NSArray *excludeWords = [inputDictionary arrayForKey:@"excludeWords"];
	
	NSInteger len = [body length];
	NSInteger start = 0;
	NSInteger n = 0;
	
	attr_t attrBuf[len];
	attr_t currentAttr = 0;
	
	memset(attrBuf, 0, (len * sizeof(attr_t)));
	
	UniChar dest[len];
	UniChar source[len];
	
	CFStringGetCharacters((CFStringRef)body, CFRangeMake(0, len), source);
	
	for (NSInteger i = 0; i < len; i++) {
		UniChar c = source[i];
		
		if (c < 0x20) {
			switch (c) {
				case 0x02:
					if (currentAttr & BOLD_ATTR) {
						currentAttr &= ~BOLD_ATTR;
					} else {
						currentAttr |= BOLD_ATTR;
					}
					
					continue;
				case 0x03:
				{
					NSInteger textColor = -1;
					NSInteger backgroundColor = -1;
					
					if ((i + 1) < len) {
						c = source[i+1];
						
						if (IsNumeric(c)) {
							++i;
							
							textColor = (c - '0');
							
							if ((i + 1) < len) {
								c = source[i+1];
								
								if (IsIRCColor(c, textColor)) {
									++i;
									
									textColor = (textColor * 10 + c - '0');
								}
								
								if ((i + 1) < len) {
									c = source[i+1];
									
									if (c == ',') {
										++i;
										
										if ((i + 1) < len) {
											c = source[i+1];
											
											if (IsNumeric(c)) {
												++i;
												
												backgroundColor = (c - '0');
												
												if ((i + 1) < len) {
													c = source[i+1];
													
													if (IsIRCColor(c, backgroundColor)) {
														++i;
														
														backgroundColor = (backgroundColor * 10 + c - '0');
													}
												}
											} else {
												i--;
											}
										}
									}
								}
							}
						}
						
						currentAttr &= ~(TEXT_COLOR_ATTR | BACKGROUND_COLOR_ATTR | 0xFF);
						
						if (backgroundColor >= 0) {
							backgroundColor %= 16;
							
							currentAttr |= BACKGROUND_COLOR_ATTR;
							currentAttr |= (backgroundColor << 4) & BACKGROUND_COLOR_MASK;
						} else {
							currentAttr &= ~(BACKGROUND_COLOR_ATTR | BACKGROUND_COLOR_MASK);
						}
						
						if (textColor >= 0) {
							textColor %= 16;
							
							currentAttr |= TEXT_COLOR_ATTR;
							currentAttr |= textColor & TEXT_COLOR_MASK;
						} else {
							currentAttr &= ~(TEXT_COLOR_ATTR | TEXT_COLOR_MASK);
						}
					}
					continue;
				}
				case 0x0F:
					currentAttr = 0;
					continue;
				case 0x16:
					if (currentAttr & ITALIC_ATTR) {
						currentAttr &= ~ITALIC_ATTR;
					} else {
						currentAttr |= ITALIC_ATTR;
					}
					
					continue;
				case 0x1F:
					if (currentAttr & UNDERLINE_ATTR) {
						currentAttr &= ~UNDERLINE_ATTR;
					} else {
						currentAttr |= UNDERLINE_ATTR;
					}
					
					continue;
			}
		}
		
		attrBuf[n] = currentAttr;
		dest[n++] = c;
	}
	
	len = n;
	body = [NSString stringWithCharacters:dest length:n];
	
	if (drawingType == ASCII_TO_HTML) {
		/* Links */
		
		if (renderLinks) {
			NSMutableArray *urlAry = [NSMutableArray array];
			
			NSArray *urlAryRanges = [URLParser locatedLinksForString:body];
			
			if (NSObjectIsNotEmpty(urlAryRanges)) {
				for (NSString *rn in urlAryRanges) {
					NSRange r = NSRangeFromString(rn);
					
					if (r.length >= 1) {
						setFlag(attrBuf, URL_ATTR, r.location, r.length);
						
						[urlAry safeAddObject:[NSValue valueWithRange:r]];
					}
				}
			}
			
			[resultInfo setObject:urlAry forKey:@"URLRanges"];
		}
		
		/* Word Matching — Highlights */
		
		BOOL foundKeyword = NO;
		
		NSMutableArray *excludeRanges = [NSMutableArray array];
		
		if (exactWordMatching == NO) {
			for (NSString *excludeWord in excludeWords) {
				start = 0;
				
				while (start < len) {
					NSRange r = [body rangeOfString:excludeWord 
											options:NSCaseInsensitiveSearch 
											  range:NSMakeRange(start, (len - start))];
					
					if (r.location == NSNotFound) {
						break;
					}
					
					[excludeRanges safeAddObject:[NSValue valueWithRange:r]];
					
					start = (NSMaxRange(r) + 1);
				}
			}
		}
		
		for (NSString *keyword in keywords) {
			start = 0;
			
			while (start < len) {
				NSRange r = [body rangeOfString:keyword 
										options:NSCaseInsensitiveSearch 
										  range:NSMakeRange(start, (len - start))];
				
				if (r.location == NSNotFound) {
					break;
				}
				
				BOOL enabled = YES;
				
				for (NSValue *e in excludeRanges) {
					if (NSIntersectionRange(r, [e rangeValue]).length > 0) {
						enabled = NO;
						
						break;
					}
				}
				
				if (exactWordMatching) {
					if (enabled) {
						UniChar c = [body characterAtIndex:r.location];
						
						if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
							NSInteger prev = (r.location - 1);
							
							if (0 <= prev && prev < len) {
								UniChar c = [body characterAtIndex:prev];
								
								if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
									enabled = NO;
								}
							}
						}
					}
					
					if (enabled) {
						UniChar c = [body characterAtIndex:(NSMaxRange(r) - 1)];
						
						if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
							NSInteger next = NSMaxRange(r);
							
							if (next < len) {
								UniChar c = [body characterAtIndex:next];
								
								if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
									enabled = NO;
								}
							}
						}
					}
				}
				
				if (enabled) {
					if (isClear(attrBuf, URL_ATTR, r.location, r.length)) {
						setFlag(attrBuf, HIGHLIGHT_KEYWORD_ATTR, r.location, r.length);
						
						foundKeyword = YES;
						
						break;
					}
				}
				
				start = (NSMaxRange(r) + 1);
			}
			
			if (foundKeyword) break;
		}
		
		[resultInfo setBool:foundKeyword forKey:@"wordMatchFound"];
		
		/* IP Address and Channel Name Detection */
		
		start = 0;
		
		while (start < len) {
			NSRange r = [body rangeOfAddressStart:start];
			
			if (r.location == NSNotFound) {
				break;
			}
			
			if (isClear(attrBuf, URL_ATTR, r.location, r.length)) {
				setFlag(attrBuf, ADDRESS_ATTR, r.location, r.length);
			}
			
			start = (NSMaxRange(r) + 1);
		}
		
		start = 0;
		
		while (start < len) {
			NSRange r = [body rangeOfChannelNameStart:start];
			
			if (r.location == NSNotFound) {
				break;
			}
			
			if (isClear(attrBuf, URL_ATTR, r.location, r.length)) {
				setFlag(attrBuf, CHANNEL_NAME_ATTR, r.location, r.length);
			}
			
			start = (NSMaxRange(r) + 1);
		}
		
		/* Conversation Tracking */
		
		if ([Preferences trackConversations]) {
			if (log) {
				IRCChannel *log_channel = log.channel;
				
				if (log_channel) {
					NSArray *channel_members = [[NSArray arrayWithArray:log_channel.members] sortedArrayUsingFunction:nicknameLengthSort context:nil];
					
					if (channel_members) {
						for (IRCUser *user in channel_members) {
							start = 0;
							
							while (start < len) {
								NSRange r = [body rangeOfString:user.nick 
														options:NSCaseInsensitiveSearch 
														  range:NSMakeRange(start, (len - start))];
								
								if (r.location == NSNotFound) {
									break;
								}
								
								BOOL cleanMatch = YES;
								
								UniChar c = [body characterAtIndex:r.location];
								
								if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
									NSInteger prev = (r.location - 1);
									
									if (0 <= prev && prev < len) {
										UniChar c = [body characterAtIndex:prev];
										
										if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
											cleanMatch = NO;
										}
									}
								}
								
								if (cleanMatch) {
									UniChar c = [body characterAtIndex:(NSMaxRange(r) - 1)];
									
									if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
										NSInteger next = NSMaxRange(r);
										
										if (next < len) {
											UniChar c = [body characterAtIndex:next];
											
											if ([UnicodeHelper isAlphabeticalCodePoint:c]) {
												cleanMatch = NO;
											}
										}
									}
								}
								
								if (cleanMatch) {
									if (isClear(attrBuf, URL_ATTR, r.location, r.length) && 
										isClear(attrBuf, HIGHLIGHT_KEYWORD_ATTR, r.location, r.length)) {
										
										setFlag(attrBuf, CONVERSATION_TRKR_ATTR, r.location, r.length);
									}
								}
								
								start = (NSMaxRange(r) + 1);
							}
						}
					}
				}
			}
		}
		
		if (PointerIsEmpty(outputDictionary) == NO) {
			*outputDictionary = resultInfo;
		}
	}
	
	/* Draw Actual Result */
	
	id result = nil;
	
	if (drawingType == ASCII_TO_ATTRIBUTED_STRING) {
		result = [[[NSMutableAttributedString alloc] initWithString:body] autodrain];
	} else {
		result = [NSMutableString string];
	}
	
	start = 0;
	
	while (start < len) {
		NSInteger n = getNextAttributeRange(attrBuf, start, len);
		
		if (n <= 0) break;
		
		attr_t t = attrBuf[start];
		
		if (drawingType == ASCII_TO_ATTRIBUTED_STRING) {
			result = renderAttributedRange(result, t, start, n);	
		} else {
			[result appendString:renderRange(body, t, start, n, log)];
		}
		
		start += n;
	}
	
	return result;
}

@end