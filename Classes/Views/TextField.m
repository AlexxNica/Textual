// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

@implementation TextField

@synthesize _oldInputValue;
@synthesize _oldTextColor;
@synthesize _usesCustomUndoManager;
@synthesize _spellingAlreadyToggled;

- (void)dealloc
{
	if (_usesCustomUndoManager) {
		[_oldInputValue drain];
	}
	
	[_oldTextColor drain];
	
	[super dealloc];
}

- (void)setFontColor:(NSColor *)color
{
	[_oldTextColor drain];
	_oldTextColor = nil;
	
	_oldTextColor = [[self textColor] retain];
	
	[self setTextColor:color];
}

- (void)removeAllUndoActions
{
	if (_usesCustomUndoManager) {
		[[self undoManager] removeAllActions];
	}
}

- (void)setUsesCustomUndoManager:(BOOL)customManager
{
	if (_usesCustomUndoManager) {
		if (customManager == NO) {
			[_oldInputValue drain];
			_oldInputValue = nil;
			
			[[self undoManager] removeAllActionsWithTarget:self];
			[[self.window selectedFieldEditor] setAllowsUndo:YES];
			
			_usesCustomUndoManager = NO;
		}
	} else {
		if (customManager) {
			_oldInputValue = [NSNullObject retain];
			
			[[self undoManager] removeAllActionsWithTarget:self];
			[[self.window selectedFieldEditor] setAllowsUndo:NO];
			
			_usesCustomUndoManager = YES;
		}
	}
}

- (void)setObjectValue:(id)obj recordUndo:(BOOL)undo
{
	if (_usesCustomUndoManager) {
		[_oldInputValue drain];
		_oldInputValue = nil;
		
		_oldInputValue = [[self objectValue] retain];
		
		NSUndoManager *undoMan = [self undoManager];
		
		if ([undoMan canUndo] == NO) {
			[[undoMan prepareWithInvocationTarget:self] setObjectValue:NSNullObject recordUndo:YES];
		}
		
		if (undo && [obj isEqual:_oldInputValue] == NO) {
			[[undoMan prepareWithInvocationTarget:self] setObjectValue:_oldInputValue recordUndo:YES];
		}
	}
	
	[super setObjectValue:obj];
}

- (void)setStringValue:(NSString *)aString
{
	[self setObjectValue:aString recordUndo:YES];
}

- (void)setAttributedStringValue:(NSAttributedString *)obj
{
	[self setObjectValue:obj recordUndo:YES];
}

- (void)setFilteredAttributedStringValue:(NSAttributedString *)string
{
	string = [string sanitizeIRCCompatibleAttributedString:[self textColor] 
												  oldColor:_oldTextColor 
										   backgroundColor:[self backgroundColor] 
											   defaultFont:[self font]];
	
	string = [string attributedStringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
	
	[super setObjectValue:string];
}

- (void)pasteFilteredAttributedString:(NSRange)selectedRange
{
	NSText *currentEditor = [self currentEditor];
	
	NSString *rawData = [_NSPasteboard() stringContent];
	NSData   *rtfData = [_NSPasteboard() dataForType:NSRTFPboardType];
	
	if (PointerIsEmpty(rtfData) == NO || PointerIsEmpty(rawData) == NO) {
		NSRange frontChop;
		
		NSMutableAttributedString *newString = [NSMutableAttributedString alloc];
		NSMutableAttributedString *oldString = [[self attributedStringValue] mutableCopy];
		
		NSString *currentValue = [self stringValue];
        
		if ([currentValue hasPrefix:@"/"] == NO && PointerIsEmpty(rtfData) == NO) {
			newString = [newString initWithRTF:rtfData documentAttributes:nil];
		} else {
			newString = [newString initWithString:rawData];
		}
		
		[newString autodrain];
		[oldString autodrain];
		
		newString = (id)[newString sanitizeNSLinkedAttributedString:[self textColor]];
		newString = (id)[newString sanitizeIRCCompatibleAttributedString:[self textColor]
                                                                oldColor:_oldTextColor
                                                         backgroundColor:[self backgroundColor]
                                                             defaultFont:[self font]];
        
		if (selectedRange.length >= 1) {
			[oldString replaceCharactersInRange:selectedRange withString:[newString string]];
		} else {
			[oldString insertAttributedString:newString atIndex:selectedRange.location];
		}
		
		oldString = (id)[oldString attributedStringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet] frontChop:&frontChop];
		
		[self setObjectValue:oldString recordUndo:YES];
		
		selectedRange.length    = 0;
		selectedRange.location += [newString length];
		
		if (frontChop.length >= 1) {
			selectedRange.location -= frontChop.location;
		}
		
		if (selectedRange.location <= [oldString length]) {
			[currentEditor setSelectedRange:selectedRange];
		} else {
			[self focus];
		}
	}
}

- (void)textDidChange:(NSNotification *)notification
{
	if (_usesCustomUndoManager) {
		NSUndoManager *undoMan = [self undoManager];
		
		if ([undoMan canUndo] == NO) {
			[[undoMan prepareWithInvocationTarget:self] setObjectValue:NSNullObject recordUndo:YES];
		}
		
		id newValue = [self objectValue];
		
		if ([newValue isEqual:_oldInputValue] == NO) {
			[[undoMan prepareWithInvocationTarget:self] setObjectValue:_oldInputValue recordUndo:YES];
		}
		
		[_oldInputValue drain];
		_oldInputValue = nil;
		
		_oldInputValue = [[self objectValue] retain];
		
		[super setObjectValue:_oldInputValue];
	}
    
#ifdef _RUNNING_MAC_OS_LION
    if ([Preferences applicationRanOnLion] == NO) {
#endif
        
        /* Force spell checker to validate input value by toggling it off
         and on when exiting the editing of a word. Dirty fix for bug on 
         Snow Leopard resulting in only the first word of string value 
         being validated. */
        
        NSRange selectedRange = [self selectedRange];
        
        if (selectedRange.location >= 2) {
            NSString *stringValue  = [self stringValue];
            UniChar   previousChar = [stringValue characterAtIndex:(selectedRange.location - 1)];
            
            if (previousChar) {
                if (IsAlpha(previousChar) == NO) {
                    if (_spellingAlreadyToggled == NO) {
                        _spellingAlreadyToggled = YES;
                        
                        NSTextView *editor = (id)[self currentEditor];
                        
                        [editor toggleContinuousSpellChecking:nil];
                        [editor toggleContinuousSpellChecking:nil];
                    }
                } else {
                    _spellingAlreadyToggled = NO;
                }
            }
        }
        
#ifdef _RUNNING_MAC_OS_LION
    }
#endif
}

@end