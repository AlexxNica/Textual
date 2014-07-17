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

@implementation TPCPreferences (TPCPreferencesCloudSyncExtension)

#ifdef TEXTUAL_BUILT_WITH_ICLOUD_SUPPORT
+ (BOOL)syncPreferencesToTheCloud
{
	return [RZUserDefaults() boolForKey:TPCPreferencesCloudSyncKeyValueStoreServicesDefaultsKey];
}

+ (BOOL)syncPreferencesToTheCloudLimitedToServers
{
	return [RZUserDefaults() boolForKey:TPCPreferencesCloudSyncKeyValueStoreServicesLimitedToServersDefaultsKey];
}
#endif

+ (void)performReloadActionForKeyValues:(NSArray *)prefKeys
{
	/* Begin the process… */
	/* Some of these keys may be repeated because they are shared amongst different elements… */
	/* The -performReloadActionForActionType: method the keys are used to update is smart enough
	 to know when specific actions repeat and will accomidate that. */
	TPCPreferencesKeyReloadActionMask reloadActions = 0;
	
	/* Style specific reloads… */
	if ([prefKeys containsObject:TPCPreferencesThemeNameDefaultsKey] ||					/* Style name. */
		[prefKeys containsObject:TPCPreferencesThemeFontNameDefaultsKey] ||				/* Style font name. */
		[prefKeys containsObject:@"Theme -> Font Size"] ||								/* Style font size. */
		[prefKeys containsObject:@"Theme -> Nickname Format"] ||						/* Nickname format. */
		[prefKeys containsObject:@"Theme -> Timestamp Format"] ||						/* Timestamp format. */
		[prefKeys containsObject:@"Theme -> Channel Font Preference Enabled"] ||		/* Indicates whether a style overrides a specific preference. */
		[prefKeys containsObject:@"Theme -> Nickname Format Preference Enabled"] ||		/* Indicates whether a style overrides a specific preference. */
		[prefKeys containsObject:@"Theme -> Timestamp Format Preference Enabled"] ||	/* Indicates whether a style overrides a specific preference. */
		[prefKeys containsObject:@"DisableRemoteNicknameColorHashing"] ||				/* Do not colorize nicknames. */
		[prefKeys containsObject:@"DisplayEventInLogView -> Inline Media"])				/* Display inline media. */
	{
		reloadActions |= TPCPreferencesKeyReloadStyleAction;
	}
	
	/* Highlight lists. */
	if ([prefKeys containsObject:@"Highlight List -> Primary Matches"] ||		/* Primary keyword list. */
		[prefKeys containsObject:@"Highlight List -> Excluded Matches"])		/* Excluded keyword list. */
	{
		reloadActions |= TPCPreferencesKeyReloadHighlightKeywordsAction;
	}
	
	/* Highlight logging. */
	if ([prefKeys containsObject:@"LogHighlights"]) {
		reloadActions |= TPCPreferencesKeyReloadHighlightLoggingAction;
	}
	
	/* Text direction: right-to-left, left-to-right */
	if ([prefKeys containsObject:@"RightToLeftTextFormatting"]) {
		reloadActions |= TPCPreferencesKeyReloadTextDirectionAction;
	}
	
	/* Text field font size. */
	if ([prefKeys containsObject:@"Main Input Text Field -> Font Size"]) {
		reloadActions |= TPCPreferencesKeyReloadTextFieldFontSizeAction;
	}
	
	/* Input history scope. */
	if ([prefKeys containsObject:@"SaveInputHistoryPerSelection"]) {
		reloadActions |= TPCPreferencesKeyReloadInputHistoryScopeAction;
	}
	
	/* Main window segmented controller. */
	if ([prefKeys containsObject:@"DisableMainWindowSegmentedController"]) {
		reloadActions |= TPCPreferencesKeyReloadTextFieldSegmentedControllerOriginAction;
	}
	
	/* Main window alpha level. */
	if ([prefKeys containsObject:@"MainWindowTransparencyLevel"]) {
		reloadActions |= TPCPreferencesKeyReloadMainWindowTransparencyLevelAction;
	}
	
	/* Dock icon. */
	if ([prefKeys containsObject:@"DisplayDockBadges"] ||						/* Display dock badges. */
		[prefKeys containsObject:@"DisplayPublicMessageCountInDockBadge"])		/* Count public messages in dock badges. */
	{
		reloadActions |= TPCPreferencesKeyReloadDockIconBadgesAction;
	}
	
	/* Main window appearance. */
	if ([prefKeys containsObject:@"InvertSidebarColors"] ||									/* Dark or light mode UI. */
		[prefKeys containsObject:@"Theme -> Invert Sidebar Colors Preference Enabled"])		/* Indicates whether a style overrides a specific preference. */
	{
		reloadActions |= TPCPreferencesKeyReloadMainWindowAppearanceAction;
	}
	
	/* Member list sort order. */
	if ([prefKeys containsObject:@"MemberListSortFavorsServerStaff"]) { // Place server staff at top of list…
		reloadActions |= TPCPreferencesKeyReloadMemberListSortOrderAction;
	}
	
	/* Member list user badge colors. */
	if ([prefKeys containsObject:@"User List Mode Badge Colors —> +y"] ||						/* User mode badge color. */
		[prefKeys containsObject:@"User List Mode Badge Colors —> +q"] ||						/* User mode badge color. */
		[prefKeys containsObject:@"User List Mode Badge Colors —> +a"] ||						/* User mode badge color. */
		[prefKeys containsObject:@"User List Mode Badge Colors —> +o"] ||						/* User mode badge color. */
		[prefKeys containsObject:@"User List Mode Badge Colors —> +h"] ||						/* User mode badge color. */
		[prefKeys containsObject:@"User List Mode Badge Colors —> +v"])							/* User mode badge color. */
	{
		reloadActions |= TPCPreferencesKeyReloadMemberListUserBadgesAction;
	}
	
	/* After this is all complete; we call preferencesChanged just to take care
	 of everything else that does not need specific reloads. */
	reloadActions |= TPCPreferencesKeyReloadPreferencesChangedAction;
	
	[TPCPreferences performReloadActionForActionType:reloadActions];
}

+ (void)performReloadActionForActionType:(TPCPreferencesKeyReloadActionMask)reloadAction
{
	/* Reload style. */
	/* Given an action mask, this method is designed to find every reload action in it,
	 break them down so there is none repeating themselves, then reload everything. */
	/* As the mask will specify more than one action, a switch statement is not used. 
	 Instead, individual if statements are used. */
	
	/* Update dock icon. */
	if (reloadAction & TPCPreferencesKeyReloadDockIconBadgesAction) {
		[TVCDockIcon updateDockIcon];
	}
	
	/* As reloading the theme will also reload the server and member list, we keep 
	 track of whether that happened so it is not performed more than one time. */
	BOOL didReloadUserInterface = NO;
	BOOL didReloadActiveStyle = NO;
	
	/* Window appearance. */
	if (reloadAction & TPCPreferencesKeyReloadMainWindowAppearanceAction) {
		[mainWindow() updateBackgroundColor];
		
		didReloadUserInterface = YES;
	}
	
	/* Active style. */
	if (reloadAction & TPCPreferencesKeyReloadStyleAction) {
		[worldController() reloadTheme:NO];
		
		didReloadActiveStyle = YES;
	} else if (reloadAction & TPCPreferencesKeyReloadStyleWithTableViewsAction) {
		[worldController() reloadTheme:(didReloadUserInterface == NO)]; // -reloadTheme being sent NO tells it not to reload appearance. We did tha above.
		
		didReloadActiveStyle = YES;
		didReloadUserInterface = YES;
	}
	
	/* Server list. */
	if (reloadAction & TPCPreferencesKeyReloadServerListAction) {
		if (didReloadUserInterface == NO) {
			[mainWindowServerList() updateBackgroundColor];
			
			[mainWindowServerList() reloadAllDrawings];
		}
	}
	
	/* Member list appearance. */
	BOOL didReloadMemberListUserInterface = NO;
	
	if (reloadAction & TPCPreferencesKeyReloadMemberListAction) {
		if (didReloadUserInterface == NO) {
			[mainWindowMemberList() updateBackgroundColor];
		}
		
		didReloadMemberListUserInterface = YES;
	}
	
	/* Member list sort order. */
	BOOL didReloadMemberListSortOrder = NO;
	
	if (reloadAction & TPCPreferencesKeyReloadMemberListSortOrderAction) {
		IRCChannel *selectedChannel = [mainWindow() selectedChannel];
		
		if ( selectedChannel) {
			didReloadMemberListSortOrder = YES;
			
			[selectedChannel reloadDataForTableViewBySortingMembers];
		}
	}
	
	/* Member list appearance. */
	if (reloadAction & TPCPreferencesKeyReloadMemberListAction ||
		reloadAction & TPCPreferencesKeyReloadMemberListUserBadgesAction)
	{
		/* Sort order will redraw these for us. */
		if (didReloadMemberListSortOrder == NO) {
			[mainWindowMemberList() reloadAllDrawings];
		}
	}
	
	/* Main window segmented controller. */
	if (reloadAction & TPCPreferencesKeyReloadTextFieldSegmentedControllerOriginAction) {
		[mainWindowTextField() reloadSegmentedControllerOrigin];
	}
	
	/* Main window alpha level. */
	if (reloadAction & TPCPreferencesKeyReloadMainWindowTransparencyLevelAction) {
		[mainWindow() setAlphaValue:[TPCPreferences themeTransparency]];
	}

	/* Highlight keywords. */
	if (reloadAction & TPCPreferencesKeyReloadHighlightKeywordsAction) {
		[TPCPreferences cleanUpHighlightKeywords];
	}
	
	/* Highlight logging. */
	if (reloadAction & TPCPreferencesKeyReloadHighlightLoggingAction) {
		if ([TPCPreferences logHighlights] == NO) {
			for (IRCClient *u in [worldController() clientList]) {
				[u setCachedHighlights:@[]];
			}
		}
	}
	
	/* Text direction: right-to-left, left-to-right */
	if (reloadAction & TPCPreferencesKeyReloadTextDirectionAction) {
		[mainWindowTextField() updateTextDirection];
		
		if (didReloadActiveStyle == NO) {
			[worldController() reloadTheme:NO]; // Reload style to set ltr or rtl on WebKit
		}
	}
	
	/* Text field font size. */
	if (reloadAction & TPCPreferencesKeyReloadTextFieldFontSizeAction) {
		[mainWindowTextField() updateTextBoxBasedOnPreferredFontSize];
	}
	
	/* Input history scope. */
	if (reloadAction & TPCPreferencesKeyReloadInputHistoryScopeAction) {
		[[TXSharedApplication sharedInputHistoryManager] inputHistoryObjectScopeDidChange];
	}
	
	/* World controller preferences changed call. */
	if (reloadAction & TPCPreferencesKeyReloadPreferencesChangedAction) {
		[worldController() preferencesChanged];
	}
}

+ (BOOL)performValidationForKeyValues:(BOOL)duringInitialization
{
	/* Validate font. */
	BOOL keyChanged = NO;
	
	if ([NSFont fontIsAvailable:[TPCPreferences themeChannelViewFontName]] == NO) {
		[RZUserDefaults() setObject:TXDefaultTextualChannelViewFont forKey:TPCPreferencesThemeFontNameDefaultsKey];
		
		keyChanged = YES;
	}
	
	/* Validate theme. */
	NSString *activeTheme = [TPCPreferences themeName];
	
	if (duringInitialization == NO) { // themeController is not available during initialization.
		if ([themeController() actualPathForCurrentThemeIsEqualToCachedPath]) {
			return keyChanged;
		} else {
			/* If the path is invalid, but the theme still exists, then its possible
			 it moved from the cloud to the local application support path. */
			if ([TPCThemeController themeExists:activeTheme]) {
				/* If it shows up as still existing, then we just mark it as keyChanged
				 so the controller knows to reload it, but we don't have to do any other
				 checks at this point since we know it just moved somewhere else. */
				keyChanged = YES;
				
				return keyChanged;
			}
		}
	}
	
	/* Continue with normal checks. */
	if ([TPCThemeController themeExists:activeTheme] == NO) {
		NSString *filekind = [TPCThemeController extractThemeSource:activeTheme];
		NSString *filename = [TPCThemeController extractThemeName:activeTheme];
		
		if ([filekind isEqualToString:TPCThemeControllerBundledStyleNameBasicPrefix]) {
			[TPCPreferences setThemeName:TXDefaultTextualChannelViewStyle];
		} else {
			activeTheme = [TPCThemeController buildResourceFilename:filename];
			
			if ([TPCThemeController themeExists:activeTheme]) {
				[TPCPreferences setThemeName:activeTheme];
			} else {
				[TPCPreferences setThemeName:TXDefaultTextualChannelViewStyle];
			}
		}
		
		keyChanged = YES;
	}
	
	return keyChanged;
}

@end
