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

@interface TVCMemberList : NSOutlineView
@property (nonatomic, uweak) id keyDelegate;
@property (nonatomic, assign) BOOL isHiddenByUser;
@property (nonatomic, strong) IBOutlet TVCMemberListUserInfoPopover *memberListUserInfoPopover;
@property (nonatomic, nweak) IBOutlet NSVisualEffectView *visualEffectView;
@property (nonatomic, nweak) IBOutlet TVCMemberListBackgroundView *backgroundView;

/* Additions & Removals. */
- (void)addItemToList:(NSInteger)index;

- (void)removeItemFromList:(id)oldObject;

/* Drawing. */
- (void)beginGroupedUpdates;
- (void)endGroupedUpdates;

@property (readonly) BOOL updatesArePaging;

- (void)reloadAllDrawings;

- (void)updateDrawingForMember:(IRCUser *)cellItem;
- (void)updateDrawingForRow:(NSInteger)rowIndex;

- (void)updateBackgroundColor; // Do not call.

@property (readonly, strong) id userInterfaceObjects;

/* Event monitor. */
- (void)destroyUserInfoPopoverOnWindowKeyChange;
@end

@interface TVCMemberListBackgroundView : NSBox
@end

@interface TVCMemberListSharedUserInterface : NSObject
+ (BOOL)yosemiteIsUsingVibrantDarkMode;

+ (NSColor *)memberListBackgroundColor;

+ (NSColor *)userMarkBadgeBackgroundColor_Y;
+ (NSColor *)userMarkBadgeBackgroundColor_A;
+ (NSColor *)userMarkBadgeBackgroundColor_H;
+ (NSColor *)userMarkBadgeBackgroundColor_O;
+ (NSColor *)userMarkBadgeBackgroundColor_Q;
+ (NSColor *)userMarkBadgeBackgroundColor_V;

+ (NSColor *)userMarkBadgeBackgroundColor_YDefault;
+ (NSColor *)userMarkBadgeBackgroundColor_ADefault;
+ (NSColor *)userMarkBadgeBackgroundColor_HDefault;
+ (NSColor *)userMarkBadgeBackgroundColor_ODefault;
+ (NSColor *)userMarkBadgeBackgroundColor_QDefault;
+ (NSColor *)userMarkBadgeBackgroundColor_VDefault;

+ (NSFont *)userMarkBadgeFont;

+ (NSInteger)userMarkBadgeHeight;
+ (NSInteger)userMarkBadgeWidth;
+ (NSInteger)userMarkBadgeLeftMargin;
+ (NSInteger)userMarkBadgeBottomMargin;

+ (NSInteger)textCellLeftMargin;
+ (NSInteger)textCellBottomMargin;
@end

@interface TVCMemberListMavericksLightUserInterface : TVCMemberListSharedUserInterface
+ (NSColor *)rowSelectionColorForActiveWindow;
+ (NSColor *)rowSelectionColorForInactiveWindow;

+ (NSColor *)memberListBackgroundColorForActiveWindow;
+ (NSColor *)memberListBackgroundColorForInactiveWindow;

+ (NSColor *)userMarkBadgeBackgroundColorForAqua;
+ (NSColor *)userMarkBadgeBackgroundColorForGraphite;

+ (NSColor *)userMarkBadgeSelectedBackgroundColor;

+ (NSColor *)userMarkBadgeNormalTextColor;
+ (NSColor *)userMarkBadgeSelectedTextColor;

+ (NSColor *)userMarkBadgeShadowColor;

+ (NSFont *)userMarkBadgeFont;

+ (NSFont *)normalCellFont;
+ (NSFont *)selectedCellFont;

+ (NSColor *)normalCellTextColor;
+ (NSColor *)awayUserCellTextColor;
+ (NSColor *)selectedCellTextColor;

+ (NSColor *)normalCellTextShadowColor;

+ (NSColor *)normalSelectedCellTextShadowColorForActiveWindow;
+ (NSColor *)normalSelectedCellTextShadowColorForInactiveWindow;
+ (NSColor *)graphiteSelectedCellTextShadowColorForActiveWindow;
@end

@interface TVCMemberListMavericksDarkUserInterface : TVCMemberListSharedUserInterface
+ (NSColor *)rowSelectionColorForActiveWindow;
+ (NSColor *)rowSelectionColorForInactiveWindow;

+ (NSColor *)memberListBackgroundColorForActiveWindow;
+ (NSColor *)memberListBackgroundColorForInactiveWindow;
@end

@interface TVCMemberListLightYosemiteUserInterface : TVCMemberListSharedUserInterface
+ (NSColor *)normalCellTextColorForActiveWindow;
+ (NSColor *)normalCellTextColorForInactiveWindow;

+ (NSColor *)awayUserCellTextColorForActiveWindow;
+ (NSColor *)awayUserCellTextColorForInactiveWindow;

+ (NSColor *)selectedCellTextColorForActiveWindow;
+ (NSColor *)selectedCellTextColorForInactiveWindow;

+ (NSColor *)userMarkBadgeNormalTextColor;

+ (NSColor *)userMarkBadgeSelectedBackgroundColor;
+ (NSColor *)userMarkBadgeSelectedTextColor;

+ (NSColor *)rowSelectionColorForActiveWindow;
+ (NSColor *)rowSelectionColorForInactiveWindow;

+ (NSColor *)memberListBackgroundColorForActiveWindow;
+ (NSColor *)memberListBackgroundColorForInactiveWindow;

+ (NSColor *)userMarkBadgeBackgroundColorForActiveWindow;
+ (NSColor *)userMarkBadgeBackgroundColorForInactiveWindow;
@end

@interface TVCMemberListDarkYosemiteUserInterface : TVCMemberListSharedUserInterface
+ (NSColor *)normalCellTextColorForActiveWindow;
+ (NSColor *)normalCellTextColorForInactiveWindow;

+ (NSColor *)awayUserCellTextColorForActiveWindow;
+ (NSColor *)awayUserCellTextColorForInactiveWindow;

+ (NSColor *)selectedCellTextColorForActiveWindow;
+ (NSColor *)selectedCellTextColorForInactiveWindow;

+ (NSColor *)userMarkBadgeNormalTextColor;

+ (NSColor *)userMarkBadgeSelectedBackgroundColor;
+ (NSColor *)userMarkBadgeSelectedTextColor;

+ (NSColor *)rowSelectionColorForActiveWindow;
+ (NSColor *)rowSelectionColorForInactiveWindow;

+ (NSColor *)memberListBackgroundColorForActiveWindow;
+ (NSColor *)memberListBackgroundColorForInactiveWindow;

+ (NSColor *)userMarkBadgeBackgroundColorForActiveWindow;
+ (NSColor *)userMarkBadgeBackgroundColorForInactiveWindow;
@end

@protocol TVCMemberListDelegate <NSObject>
@required

- (void)memberListViewKeyDown:(NSEvent *)e;
@end
