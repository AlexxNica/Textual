/* ********************************************************************* 
       _____        _               _    ___ ____   ____
      |_   _|___  _| |_ _   _  __ _| |  |_ _|  _ \ / ___|
       | |/ _ \ \/ / __| | | |/ _` | |   | || |_) | |
       | |  __/>  <| |_| |_| | (_| | |   | ||  _ <| |___
       |_|\___/_/\_\\__|\__,_|\__,_|_|  |___|_| \_\\____|

 Copyright (c) 2010 — 2014 Codeux Software & respective contributors.
     Please see Acknowledgements.pdf for additional information.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Textual IRC Client & Codeux Software nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.

 *********************************************************************** */

#import "TextualApplication.h"

#define _WindowContentBorderTotalPadding		14.0

#define _WindowSegmentedControllerDefaultWidth	146.0
#define _WindowSegmentedControllerLeadingEdge	10.0

#define _InputTextFieldOriginDefaultX			166.0

#define _KeyObservingArray 	@[	@"TextFieldAutomaticSpellCheck", \
								@"TextFieldAutomaticGrammarCheck", \
								@"TextFieldAutomaticSpellCorrection", \
								@"TextFieldSmartCopyPaste", \
								@"TextFieldSmartQuotes", \
								@"TextFieldSmartDashes", \
								@"TextFieldSmartLinks", \
								@"TextFieldDataDetectors", \
								@"TextFieldTextReplacement"]

@interface TVCMainWindowTextView ()
@property (nonatomic, assign) NSInteger lastDrawLineCount;
@property (nonatomic, assign) TXMainTextBoxFontSize cachedFontSize;
@property (nonatomic, strong) NSLayoutConstraint *segmentedControllerWidthConstraint;
@end

@implementation TVCMainWindowTextView

#pragma mark -
#pragma mark Drawing

- (void)awakeFromNib
{
	/* Observe certain keys. */
	for (NSString *key in _KeyObservingArray) {
		[RZUserDefaults() addObserver:self
						   forKeyPath:key
							  options:(NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew)
							  context:NULL];
	}
	
	/* Blending background. */
	if ([TPCPreferences featureAvailableToOSXYosemite]) {
		/* Comment out a specific variation for debugging purposes. */
		/* The uncommented sections are the defaults. */
		self.backgroundView.backgroundVisualEffectView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
		
		self.backgroundView.backgroundVisualEffectView.material = NSVisualEffectMaterialAppearanceBased;
		self.backgroundView.backgroundVisualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
		
		/* Uncomment one of the following. */
		
		/* 1. */
		// self.backgroundView.backgroundVisualEffectView.material = NSVisualEffectMaterialDark;
		// self.backgroundView.backgroundVisualEffectView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
		
		/* 2. */
		// self.backgroundView.backgroundVisualEffectView.material = NSVisualEffectMaterialLight;
		// self.backgroundView.backgroundVisualEffectView.ppearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
		
		/* Use font color depending on appearance. */
		self.defaultTextFieldFontColor = [self.backgroundView systemSpecificTextFieldTextFontColor];
	}
	
	/* We changed the font color so we must inform our parent. */
	[self updateTypeSetterAttributesBasedOnAppearanceSettings];
}

- (void)dealloc
{
	/* Stop observing keys. */
	for (NSString *key in _KeyObservingArray) {
		[RZUserDefaults() removeObserver:self forKeyPath:key];
	}
}

- (void)updateTypeSetterAttributesBasedOnAppearanceSettings
{
	[self updateTextBoxCachedPreferredFontSize];
	[self defineDefaultTypeSetterAttributes];
	[self updateTypeSetterAttributes];
}

#pragma mark -
#pragma mark Events

- (void)rightMouseDown:(NSEvent *)theEvent
{
	/* Do not pass mouse events with sheet open. */
	NSWindowNegateActionWithAttachedSheet();

	/* Pass event. */
	[super rightMouseDown:theEvent];
}

- (void)mouseDown:(NSEvent *)theEvent
{
	/* Do not pass mouse events with sheet open. */
	NSWindowNegateActionWithAttachedSheet();

	/* Don't know why control click is broken in the text field. 
	 Possibly because of how hacked together it is… anyways, this
	 is a quick fix for control click to open the right click menu. */
	if ([NSEvent modifierFlags] & NSControlKeyMask) {
		[super rightMouseDown:theEvent];

		return;
	}
	
	/* Pass event. */
	[super mouseDown:theEvent];
}

#pragma mark -
#pragma mark Segmented Controller

- (void)redrawOriginPoints
{
	[self redrawOriginPoints:NO];
}

- (void)redrawOriginPoints:(BOOL)resetSize
{
	/* Discussion: With Auto Layout, the frame of a view is still retained even if the view
	 itself is hidden from view. The solution is to maintain a constraint for the view height
	 and update it using a pre-defined width or set it to zero when disabled. A constraint
	 is also maintained for the leading of the segmented controller to allow that spacing to 
	 be removed when it is hidden from view. */
	TVCMainWindowSegmentedControl *controller = self.masterController.mainWindowButtonController;
	
	if (self.segmentedControllerWidthConstraint == nil) {
		self.segmentedControllerWidthConstraint = [NSLayoutConstraint constraintWithItem:controller
																			attribute:NSLayoutAttributeWidth
																			relatedBy:NSLayoutRelationEqual
																			   toItem:nil
																			attribute:NSLayoutAttributeNotAnAttribute
																		   multiplier:1.0f
																			 constant:0];
		
		[controller addConstraint:self.segmentedControllerWidthConstraint];
	}
	
	if ([TPCPreferences hideMainWindowSegmentedController]) {
		[self.segmentedControllerWidthConstraint setConstant:0];
		[self.segmentedControllerLeadingConstraint setConstant:0];
	} else {
		[self.segmentedControllerWidthConstraint setConstant:_WindowSegmentedControllerDefaultWidth];
		[self.segmentedControllerLeadingConstraint setConstant:_WindowSegmentedControllerLeadingEdge];
	}
	
	/* There seems to be a slight delay while the constraints are updated
	 so we set a very small timer to resize the text field. */
	if (resetSize) {
		[self performSelector:@selector(resetTextFieldCellSize:) withObject:@(YES) afterDelay:0.1];
	}
}

#pragma mark -
#pragma mark Everything Else.

- (void)updateTextDirection
{
	if ([TPCPreferences rightToLeftFormatting]) {
		[self setBaseWritingDirection:NSWritingDirectionRightToLeft];
	} else {
		[self setBaseWritingDirection:NSWritingDirectionLeftToRight];
	}
}

- (void)internalTextDidChange:(NSNotification *)aNotification
{
	[self resetTextFieldCellSize:NO];
}

- (void)drawRect:(NSRect)dirtyRect
{
	if ([self needsToDrawRect:dirtyRect]) {
		NSString *value = [self stringValue];
		
		if ([value length] == 0) {
			if ([self baseWritingDirection] == NSWritingDirectionLeftToRight) {
				if (self.cachedFontSize == TXMainTextBoxFontLargeSize) {
					[self.placeholderString drawAtPoint:NSMakePoint(6, 2)];
				} else {
					[self.placeholderString drawAtPoint:NSMakePoint(6, 1)];
				}
			}
		} else {
			[super drawRect:dirtyRect];
		}
	}
}

- (void)paste:(id)sender
{
    [super paste:self];
    
    [self resetTextFieldCellSize:NO];
}

- (BOOL)textView:(NSTextView *)aTextView doCommandBySelector:(SEL)aSelector
{
    if (aSelector == @selector(insertNewline:)) {
		/* -textEntered takes the current value of the text field,
		 copies it into a variable, sends that value off to IRCWorld,
		 then nullifies the text field itsef. */
		[self.masterController textEntered];
		
		/* -textEntered sets the length of text fied to 0 so we must
		 update the text field size to reflect this fact. */
        [self resetTextFieldCellSize:NO];
		
		/* Let delegate know we handled this event. */
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark Multi-line Text Box Drawing

- (NSColor *)placeholderTextFontColor
{
	return [self.backgroundView systemSpecificPlaceholderTextFontColor];
}

- (void)updateTextBoxCachedPreferredFontSize
{
	/* Update the font. */
	self.cachedFontSize = [TPCPreferences mainTextBoxFontSize];

	if (self.cachedFontSize == TXMainTextBoxFontNormalSize) {
		[self setDefaultTextFieldFont:[NSFont fontWithName:@"Helvetica" size:12.0]];
	} else if (self.cachedFontSize == TXMainTextBoxFontLargeSize) {
		[self setDefaultTextFieldFont:[NSFont fontWithName:@"Helvetica" size:14.0]];
	} else if (self.cachedFontSize == TXMainTextBoxFontExtraLargeSize) {
		[self setDefaultTextFieldFont:[NSFont fontWithName:@"Helvetica" size:16.0]];
	}

	/* Update the placeholder string. */
	NSMutableDictionary *attrs = [NSMutableDictionary dictionary];

	attrs[NSFontAttributeName] = [self defaultTextFieldFont];
	attrs[NSForegroundColorAttributeName] = [self placeholderTextFontColor];

	self.placeholderString = nil;
	self.placeholderString = [NSAttributedString stringWithBase:TXTLS(@"TDCMainWindow[1000]") attributes:attrs];

	/* Prepare draw. */
	[self setNeedsDisplay:YES];
}

- (void)updateTextBoxBasedOnPreferredFontSize
{
	TXMainTextBoxFontSize cachedFontSize = self.cachedFontSize;

	/* Update actual cache. */
	[self updateTextBoxCachedPreferredFontSize];

	/* We only update the font sizes if there was a chagne. */
	if (NSDissimilarObjects(cachedFontSize, self.cachedFontSize)) {
		[self updateAllFontSizesToMatchTheDefaultFont];
		[self updateTypeSetterAttributes];
	}

	/* Reset frames. */
	[self resetTextFieldCellSize:YES];
}

- (NSInteger)backgroundViewDefaultHeight
{
	if (self.cachedFontSize == TXMainTextBoxFontNormalSize) {
		return 23.0;
	} else if (self.cachedFontSize == TXMainTextBoxFontLargeSize) {
		return 28.0;
	} else if (self.cachedFontSize == TXMainTextBoxFontExtraLargeSize) {
		return 30.0;
	}
	
	return 23.0;
}

- (NSInteger)backgroundViewHeightMultiplier
{
	if (self.cachedFontSize == TXMainTextBoxFontNormalSize) {
		return 14.0;
	} else if (self.cachedFontSize == TXMainTextBoxFontLargeSize) {
		return 17.0;
	} else if (self.cachedFontSize == TXMainTextBoxFontExtraLargeSize) {
		return 19.0;
	}

	return 14.0;
}

/* Do actual size math. */
- (void)resetTextFieldCellSize:(BOOL)force
{
	BOOL drawBezel = YES;
	BOOL hasScroller = NO;

	NSWindow *mainWindow = self.window;
	
	NSRect windowFrame = mainWindow.frame;

	NSInteger backgroundHeight;
	
	NSInteger backgroundDefaultHeight = [self backgroundViewDefaultHeight];
	NSInteger backgroundHeightMultiplier = [self backgroundViewHeightMultiplier];

	NSString *stringv = self.stringValue;

	if (stringv.length < 1) {
		backgroundHeight = (backgroundDefaultHeight + _WindowContentBorderTotalPadding);

		if (self.lastDrawLineCount >= 2) {
			drawBezel = YES;
		}

		self.lastDrawLineCount = 1;
	} else {
		NSInteger totalLinesBase = [self numberOfLines];

		if (self.lastDrawLineCount == totalLinesBase && force == NO) {
			drawBezel = NO;
		}

		self.lastDrawLineCount = totalLinesBase;

		if (drawBezel) {
			NSInteger totalLinesMath = (totalLinesBase - 1);
	
			/* Calculate unfiltered height. */
			backgroundHeight  = _WindowContentBorderTotalPadding;
			
			backgroundHeight +=  backgroundDefaultHeight;
			backgroundHeight += (backgroundHeightMultiplier * totalLinesMath);

			/* Minimum size constraint for centered view is 35 so we just add a few more
			 to give us more space to work with. */
			NSInteger backgroundViewMaxHeight = (windowFrame.size.height - (35 + _WindowContentBorderTotalPadding));

			/* Fix height if it exceeds are maximum. */
			if (backgroundHeight > backgroundViewMaxHeight) {
				for (NSInteger i = totalLinesMath; i >= 0; i--) {
					NSInteger newSize = 0;
					
					newSize  = _WindowContentBorderTotalPadding;
					
					newSize +=      backgroundDefaultHeight;
					newSize += (i * backgroundHeightMultiplier);

					if (newSize > backgroundViewMaxHeight) {
						continue;
					} else {
						backgroundHeight = newSize;

						break;
					}
				}
				
				hasScroller = YES;
			}
		}
	}

	if (drawBezel) {
		[mainWindow setContentBorderThickness:backgroundHeight forEdge:NSMinYEdge];

		[self.textFieldHeightConstraint setConstant:backgroundHeight];
		
		if (hasScroller) {
			[self.textFieldInsideTrailingConstraint setConstant:5.0];
		} else {
			[self.textFieldInsideTrailingConstraint setConstant:0.0];
		}
	}
}

#pragma mark -
#pragma mark NSTextView Context Menu Preferences

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualIgnoringCase:@"TextFieldAutomaticSpellCheck"]) {
		[self setContinuousSpellCheckingEnabled:[TPCPreferences textFieldAutomaticSpellCheck]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldAutomaticGrammarCheck"]) {
		[self setGrammarCheckingEnabled:[TPCPreferences textFieldAutomaticGrammarCheck]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldAutomaticSpellCorrection"]) {
		[self setAutomaticSpellingCorrectionEnabled:[TPCPreferences textFieldAutomaticSpellCorrection]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldSmartCopyPaste"]) {
		[self setSmartInsertDeleteEnabled:[TPCPreferences textFieldSmartCopyPaste]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldSmartQuotes"]) {
		[self setAutomaticQuoteSubstitutionEnabled:[TPCPreferences textFieldSmartQuotes]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldSmartDashes"]) {
		[self setAutomaticDashSubstitutionEnabled:[TPCPreferences textFieldSmartDashes]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldSmartLinks"]) {
		[self setAutomaticLinkDetectionEnabled:[TPCPreferences textFieldSmartLinks]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldDataDetectors"]) {
		[self setAutomaticDataDetectionEnabled:[TPCPreferences textFieldDataDetectors]];
	} else if ([keyPath isEqualIgnoringCase:@"TextFieldTextReplacement"]) {
		[self setAutomaticTextReplacementEnabled:[TPCPreferences textFieldTextReplacement]];
	} else if ([super respondsToSelector:@selector(observeValueForKeyPath:ofObject:change:context:)]) {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)setContinuousSpellCheckingEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldAutomaticSpellCheck:flag];
	
	[super setContinuousSpellCheckingEnabled:flag];
}

- (void)setGrammarCheckingEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldAutomaticGrammarCheck:flag];
	
	[super setGrammarCheckingEnabled:flag];
}

- (void)setAutomaticSpellingCorrectionEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldAutomaticSpellCorrection:flag];
	
	[super setAutomaticSpellingCorrectionEnabled:flag];
}

- (void)setSmartInsertDeleteEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldSmartCopyPaste:flag];
	
	[super setSmartInsertDeleteEnabled:flag];
}

- (void)setAutomaticQuoteSubstitutionEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldSmartQuotes:flag];
	
	[super setAutomaticQuoteSubstitutionEnabled:flag];
}

- (void)setAutomaticDashSubstitutionEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldSmartDashes:flag];
	
	[super setAutomaticDashSubstitutionEnabled:flag];
}

- (void)setAutomaticLinkDetectionEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldSmartLinks:flag];
	
	[super setAutomaticLinkDetectionEnabled:flag];
}

- (void)setAutomaticDataDetectionEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldDataDetectors:flag];
	
	[super setAutomaticDataDetectionEnabled:flag];
}

- (void)setAutomaticTextReplacementEnabled:(BOOL)flag
{
	[TPCPreferences setTextFieldTextReplacement:flag];
	
	[super setAutomaticTextReplacementEnabled:flag];
}

@end

#pragma mark -
#pragma mark Background Drawing

@implementation TVCMainWindowTextViewBackground

#pragma mark -
#pragma mark Mavericks UI Drawing

- (NSColor *)inputTextFieldBlackOutlineColorMavericks
{
	if ([self windowIsActive]) {
		return [NSColor colorWithCalibratedWhite:0.0 alpha:0.4];
	} else {
		return [NSColor colorWithCalibratedWhite:0.0 alpha:0.23];
	}
}

- (NSColor *)inputTextFieldBackgroundColorMavericks
{
	return [NSColor whiteColor];
}

- (NSColor *)inputTextFieldInsideShadowColorMavericks
{
	return [NSColor colorWithCalibratedWhite:0.88 alpha:1.0];
}

- (NSColor *)inputTextFieldOutsideWhiteShadowColorMavericks
{
	return [NSColor colorWithCalibratedWhite:1.0 alpha:0.394];
}

- (NSColor *)inputTextFieldPlaceholderTextColorMavericks
{
	return [NSColor grayColor];
}

- (NSColor *)inputTextFieldPrimaryTextColorMavericks
{
	return TXDefaultTextFieldFontColor;
}

- (void)drawControllerForMavericks
{
	/* General Declarations. */
	NSRect cellBounds = [self frame];
	NSRect controlFrame;

	NSColor *controlColor;

	NSBezierPath *controlPath;

	/* Control Outside White Shadow. */
	controlColor = [self inputTextFieldOutsideWhiteShadowColorMavericks];
	controlFrame = NSMakeRect(0.0, 0.0, cellBounds.size.width, 1.0);
	controlPath = [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:3.6 yRadius:3.6];

	[controlColor set];
	[controlPath fill];

	/* Black Outline. */
	controlColor = [self inputTextFieldBlackOutlineColorMavericks];
	controlFrame = NSMakeRect(0.0, 1.0, cellBounds.size.width, (cellBounds.size.height - 1.0));
	controlPath = [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:3.6 yRadius:3.6];

	[controlColor set];
	[controlPath fill];

	/* White Background. */
	controlColor = [self inputTextFieldBackgroundColorMavericks];
	controlFrame = NSMakeRect(1, 2, (cellBounds.size.width - 2.0), (cellBounds.size.height - 4.0));
	controlPath	= [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:2.6 yRadius:2.6];

	[controlColor set];
	[controlPath fill];

	/* Inside White Shadow. */
	controlColor = [self inputTextFieldInsideShadowColorMavericks];
	controlFrame = NSMakeRect(2, (cellBounds.size.height - 2.0), (cellBounds.size.width - 4.0), 1.0);
	controlPath = [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:2.9 yRadius:2.9];

	[controlColor set];
	[controlPath fill];
}

#pragma mark -
#pragma mark Yosemite UI Drawing

- (NSColor *)blackInputTextFieldPlaceholderTextColorYosemite
{
	/* Cannot be exactly white or it will interfere with text formatting engine for IRC. */

	return [NSColor colorWithCalibratedWhite:0.99 alpha:1.0];
}

- (NSColor *)whiteInputTextFieldPlaceholderTextColorYosemite
{
	return TXDefaultTextFieldFontColor;
}

- (NSColor *)blackInputTextFieldPrimaryTextColorYosemite
{
	return [NSColor colorWithCalibratedRed:0.660 green:0.660 blue:0.660 alpha:1.0];
}

- (NSColor *)whiteInputTextFieldPrimaryTextColorYosemite
{
	return [NSColor grayColor];
}

- (NSColor *)blackInputTextFieldInsideBlackBackgroundColorYosemite
{
	return [NSColor colorWithCalibratedRed:0.386 green:0.386 blue:0.386 alpha:1.0];
}

- (NSColor *)blackInputTextFieldOutsideBottomGrayShadowColorWithRetinaYosemite
{
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.15];
}

- (NSColor *)blackInputTextFieldOutsideBottomGrayShadowColorWithoutRetinaYosemite
{
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.10];
}

- (NSColor *)whiteInputTextFieldOutsideTopsideWhiteBorderYosemite
{
	return [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
}

- (NSColor *)whiteInputTextFieldInsideWhiteGradientStartColorYosemite
{
	return [NSColor colorWithCalibratedRed:0.992 green:0.992 blue:0.992 alpha:1.0];
}

- (NSColor *)whiteInputTextFieldInsideWhiteGradientEndColorYosemite
{
	return [NSColor colorWithCalibratedRed:0.988 green:0.988 blue:0.988 alpha:1.0];
}

- (NSGradient *)whiteInputTextFieldInsideWhiteGradientYosemite
{
	return [NSGradient gradientWithStartingColor:[self whiteInputTextFieldInsideWhiteGradientStartColorYosemite]
									 endingColor:[self whiteInputTextFieldInsideWhiteGradientEndColorYosemite]];
}

- (NSColor *)whiteInputTextFieldOutsideBottomPrimaryGrayShadowColorWithRetinaYosemite
{
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.15];
}

- (NSColor *)whiteInputTextFieldOutsideBottomSecondaryGrayShadowColorWithRetinaYosemite
{
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.06];
}

- (NSColor *)whiteInputTextFieldOutsideBottomGrayShadowColorWithoutRetinaYosemite
{
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.10];
}

- (NSColor *)whiteInputTextFieldUnfocusedWindowStrokeColorYosemite
{
	return [NSColor colorWithCalibratedWhite:0.0 alpha:0.10];
}

- (NSColor *)whiteInputTextFieldUnfocusedWindowBackgroundColorYosemite
{
	return [NSColor whiteColor];
}

- (void)drawControllerForYosemite
{
	if ([self yosemiteIsUsingVibrantDarkMode]) {
		[self drawBlackControllerForYosemiteInFocusedWindow];
	} else {
		if ([self windowIsActive]) {
			[self drawWhiteControllerForYosemiteInFocusedWindow];
		} else {
			[self drawWhiteControllerForYosemiteInUnfocusedWindow];
		}
	}
}

- (BOOL)yosemiteIsUsingVibrantDarkMode
{
	NSString *currentName = self.backgroundVisualEffectView.appearance.name;
	
	if ([currentName hasPrefix:NSAppearanceNameVibrantDark]) {
		return YES;
	} else {
		return NO;
	}
}

- (void)drawBlackControllerForYosemiteInFocusedWindow
{
	/* General Declarations. */
	NSRect cellBounds = [self frame];
	
	BOOL inHighresMode = [TPCPreferences runningInHighResolutionMode];
	
	NSRect controlFrame = NSMakeRect(1, 1,  (cellBounds.size.width - 2.0),
											(cellBounds.size.height - 1.0));

	/* Inner background color. */
	NSColor *background = [self blackInputTextFieldInsideBlackBackgroundColorYosemite];
	
	/* Shadow colors. */
	NSShadow *shadow4 = [NSShadow new];
	
	if (inHighresMode) {
		[shadow4 setShadowColor:[self blackInputTextFieldOutsideBottomGrayShadowColorWithRetinaYosemite]];
		[shadow4 setShadowOffset:NSMakeSize(0.1, -0.25)];
		[shadow4 setShadowBlurRadius:0.0];
	} else {
		[shadow4 setShadowColor:[self blackInputTextFieldOutsideBottomGrayShadowColorWithoutRetinaYosemite]];
		[shadow4 setShadowOffset:NSMakeSize(0.1, -1.1)];
		[shadow4 setShadowBlurRadius:0.0];
	}
	
	/* Rectangle drawing. */
	NSBezierPath *rectanglePath = [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:3.0 yRadius:3.0];
	
	[NSGraphicsContext saveGraphicsState];
	
	/* Draw shadow. */
	[shadow4 set];
	
	/* Draw background. */
	[background setFill];
	
	/* Draw rectangle. */
	[rectanglePath fill];
	
	/* Finish up. */
	[NSGraphicsContext restoreGraphicsState];
}

- (void)drawWhiteControllerForYosemiteInUnfocusedWindow
{
	/* General Declarations. */
	NSRect cellBounds = [self frame];
	NSRect controlFrame;

	NSColor *controlColor;

	NSBezierPath *controlPath;

	/* Black Outline. */
	controlColor = [self whiteInputTextFieldUnfocusedWindowStrokeColorYosemite];
	controlFrame = NSMakeRect(0.0, 1.0, cellBounds.size.width, (cellBounds.size.height - 1.0));
	controlPath = [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:3.6 yRadius:3.6];

	[controlColor set];
	[controlPath fill];

	/* White Background. */
	controlColor = [self whiteInputTextFieldUnfocusedWindowBackgroundColorYosemite];
	controlFrame = NSMakeRect(1, 2, (cellBounds.size.width - 2.0), (cellBounds.size.height - 3.0));
	controlPath	= [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:2.6 yRadius:2.6];

	[controlColor set];
	[controlPath fill];
}

- (void)drawWhiteControllerForYosemiteInFocusedWindow
{
	/* General Declarations. */
	NSRect cellBounds = [self frame];

	CGContextRef context = [RZGraphicsCurrentContext() graphicsPort];

	BOOL inHighresMode = [TPCPreferences runningInHighResolutionMode];

	NSRect controlFrame = NSMakeRect(1, 1,  (cellBounds.size.width - 2.0),
											(cellBounds.size.height - 1.0));

	/* Inner gradient color. */
	NSGradient *gradient = [self whiteInputTextFieldInsideWhiteGradientYosemite];

	/* Shadow colors. */
	NSShadow *shadow3 = [NSShadow new];
	NSShadow *shadow4 = [NSShadow new];

	[shadow3 setShadowColor:[self whiteInputTextFieldOutsideTopsideWhiteBorderYosemite]];
	[shadow3 setShadowOffset:NSMakeSize(0.1, -1.1)];
	[shadow3 setShadowBlurRadius:0.0];

	if (inHighresMode) {
		[shadow4 setShadowColor:[self whiteInputTextFieldOutsideBottomPrimaryGrayShadowColorWithRetinaYosemite]];
		[shadow4 setShadowOffset:NSMakeSize(0.1, -0.25)];
		[shadow4 setShadowBlurRadius:0.0];
	} else {
		[shadow4 setShadowColor:[self whiteInputTextFieldOutsideBottomGrayShadowColorWithoutRetinaYosemite]];
		[shadow4 setShadowOffset:NSMakeSize(0.1, -1.1)];
		[shadow4 setShadowBlurRadius:0.0];
	}

	/* Rectangle drawing. */
	NSBezierPath *rectanglePath = [NSBezierPath bezierPathWithRoundedRect:controlFrame xRadius:3.0 yRadius:3.0];

	[shadow4 set];

	CGContextBeginTransparencyLayer(context, NULL);

	[gradient drawInBezierPath:rectanglePath angle:-(90)];

	CGContextEndTransparencyLayer(context);

	/* Prepare drawing for inside shadow. */
	CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);

	CGContextSetAlpha(context, [[shadow3 shadowColor] alphaComponent]);

	CGContextBeginTransparencyLayer(context, NULL);
	{
		/* Inside shadow drawing. */
		[shadow3 set];

		CGContextSetBlendMode(context, kCGBlendModeSourceOut);

		CGContextBeginTransparencyLayer(context, NULL);

		/* Fill shadow. */
		[[shadow3 shadowColor] setFill];

		[rectanglePath fill];

		/* Complete drawing. */
		CGContextEndTransparencyLayer(context);
	}

	CGContextEndTransparencyLayer(context);

	/* On retina, we fake a second shadow under the bottommost one. */
	if (inHighresMode) {
		NSPoint linePoint1 = NSMakePoint(4.0, 0.0);
		NSPoint linePoint2 = NSMakePoint((cellBounds.size.width - 4.0), 0.0);

		NSColor *controlColor = [self whiteInputTextFieldOutsideBottomSecondaryGrayShadowColorWithRetinaYosemite];

		[controlColor setStroke];

		[NSBezierPath strokeLineFromPoint:linePoint1 toPoint:linePoint2];
	}
}

#pragma mark -
#pragma mark Drawing Factory

- (NSColor *)systemSpecificTextFieldTextFontColor
{
	if ([TPCPreferences featureAvailableToOSXYosemite]) {
		if ([self yosemiteIsUsingVibrantDarkMode]) {
			return [self blackInputTextFieldPlaceholderTextColorYosemite];
		} else {
			return [self whiteInputTextFieldPlaceholderTextColorYosemite];
		}
	} else {
		return [self inputTextFieldPlaceholderTextColorMavericks];
	}
}

- (NSColor *)systemSpecificPlaceholderTextFontColor
{
	if ([TPCPreferences featureAvailableToOSXYosemite]) {
		if ([self yosemiteIsUsingVibrantDarkMode]) {
			return [self blackInputTextFieldPrimaryTextColorYosemite];
		} else {
			return [self whiteInputTextFieldPrimaryTextColorYosemite];
		}
	} else {
		return [self inputTextFieldPrimaryTextColorMavericks];
	}
}

- (BOOL)windowIsActive
{
	return ([[[self masterController] mainWindow] isInactive] == NO);
}

- (void)drawRect:(NSRect)dirtyRect
{
	if ([self needsToDrawRect:dirtyRect]) {
		if ([TPCPreferences featureAvailableToOSXYosemite]) {
			[self drawControllerForYosemite];
		} else {
			[self drawControllerForMavericks];
		}
	}
}

@end

@implementation TVCMainWindowTextViewBackgroundVibrantView

- (BOOL)allowsVibrancy
{
	return NO;
}

@end
