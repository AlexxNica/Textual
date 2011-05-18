// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#define TransparencyDidChangeNotification		@"TransparencyDidChangeNotification"
#define ThemeDidChangeNotification				@"ThemeDidChangeNotification"
#define ThemeStyleDidChangeNotification			@"ThemeStyleDidChangeNotification"
#define ThemeSelectedConsoleNotification		@"ThemeSelectedConsoleNotification"
#define ThemeSelectedChannelNotification		@"ThemeSelectedChannelNotification"
#define InputHistoryGlobalSchemeNotification	@"InputHistoryGlobalSchemeNotification"

@interface PreferencesController : NSWindowController
{
	id delegate;
	
	IRCWorld *world;
	
	IBOutlet NSView *contentView;
	IBOutlet NSView *highlightView;
	IBOutlet NSView *interfaceView;
	IBOutlet NSView *alertsView;
	IBOutlet NSView *stylesView;
	IBOutlet NSView *transfersView;
	IBOutlet NSView *logView;
	IBOutlet NSView *generalView;
	IBOutlet NSView *scriptsView;
	IBOutlet NSView *identityView;
	IBOutlet NSView *updatesView;
	IBOutlet NSView *floodControlView;
	IBOutlet NSView *IRCopServicesView;
	IBOutlet NSView *channelManagementView;
	
	IBOutlet NSTableView *keywordsTable;
	IBOutlet NSTableView *excludeWordsTable;
	IBOutlet NSTableView *installedScriptsTable;
	
	IBOutlet NSArrayController *keywordsArrayController;
	IBOutlet NSArrayController *excludeWordsArrayController;
	
	IBOutlet NSPopUpButton *transcriptFolderButton;
	IBOutlet NSPopUpButton *themeButton;
	
	IBOutlet NSTextField *scriptLocationField;
	
	IBOutlet NSMenu *installedScriptsMenu;
	IBOutlet NSToolbar *preferenceSelectToolbar;
	
	ScriptsWrapper *scriptsController;
	
	NSMutableArray *sounds;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) IRCWorld *world;
@property (nonatomic, retain) ScriptsWrapper *scriptsController;
@property (nonatomic, readonly) NSArray *availableSounds;
@property (nonatomic, readonly) NSMutableArray *sounds;
@property (nonatomic, retain) NSView *contentView;
@property (nonatomic, retain) NSView *highlightView;
@property (nonatomic, retain) NSView *interfaceView;
@property (nonatomic, retain) NSView *alertsView;
@property (nonatomic, retain) NSView *stylesView;
@property (nonatomic, retain) NSView *transfersView;
@property (nonatomic, retain) NSView *logView;
@property (nonatomic, retain) NSView *generalView;
@property (nonatomic, retain) NSView *scriptsView;
@property (nonatomic, retain) NSView *identityView;
@property (nonatomic, retain) NSView *updatesView;
@property (nonatomic, retain) NSView *floodControlView;
@property (nonatomic, retain) NSView *IRCopServicesView;
@property (nonatomic, retain) NSView *channelManagementView;
@property (nonatomic, retain) NSTableView *keywordsTable;
@property (nonatomic, retain) NSTableView *excludeWordsTable;
@property (nonatomic, retain) NSTableView *installedScriptsTable;
@property (nonatomic, retain) NSArrayController *keywordsArrayController;
@property (nonatomic, retain) NSArrayController *excludeWordsArrayController;
@property (nonatomic, retain) NSPopUpButton *transcriptFolderButton;
@property (nonatomic, retain) NSPopUpButton *themeButton;
@property (nonatomic, retain) NSMenu *installedScriptsMenu;
@property (nonatomic, retain) NSTextField *scriptLocationField;
@property (nonatomic, retain) NSToolbar *preferenceSelectToolbar;

- (id)initWithWorldController:(IRCWorld *)word;

- (void)show;

- (IBAction)onAddKeyword:(id)sender;
- (IBAction)onAddExcludeWord:(id)sender;

- (IBAction)onSelectFont:(id)sender;
- (IBAction)onStyleChanged:(id)sender;
- (IBAction)onPrefPaneSelected:(id)sender;
- (IBAction)onOpenPathToThemes:(id)sender;
- (IBAction)onOpenPathToScripts:(id)sender;
- (IBAction)onChangedTransparency:(id)sender;
- (IBAction)onTranscriptFolderChanged:(id)sender;
@end

@interface NSObject (PreferencesControllerDelegate)
- (void)preferencesDialogWillClose:(PreferencesController *)sender;
@end