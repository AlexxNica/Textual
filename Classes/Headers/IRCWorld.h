// Created by Satoshi Nakagawa <psychs AT limechat DOT net> <http://github.com/psychs/limechat>
// Modifications by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

@class MasterController;
@class IRCClient, IRCChannel, IRCChannelConfig, IRCClientConfig;

@interface IRCWorld : NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate>
{
	ChatBox *chatBox;
	MainWindow *window;
	ViewTheme *viewTheme;
	ServerTreeView *tree;
	InputTextField *text;
	GrowlController *growl;
	LogController *dummyLog;
	MasterController *master;
	MemberListView *memberList;
	MenuController *menuController;
	FieldEditorTextView *fieldEditor;
	
	NSBox *logBase;
	
	NSMenu *logMenu;
	NSMenu *urlMenu;
	NSMenu *addrMenu;
	NSMenu *chanMenu;
	NSMenu *treeMenu;
	NSMenu *memberMenu;
	NSMenu *serverMenu;
	NSMenu *channelMenu;
	
	NSInteger messagesSent;
	NSInteger messagesReceived;
	
	TXFSLongInt bandwidthIn;
	TXFSLongInt bandwidthOut;
	
	IRCWorldConfig *config;
	
	NSMutableArray *clients;
	
	NSInteger itemId;
	
	BOOL soundMuted;
	BOOL reloadingTree;
	
	IRCExtras *extrac;
	
	IRCTreeItem *selected;
	
	NSInteger previousSelectedClientId;
	NSInteger previousSelectedChannelId;
	
	NSArray *allLoadedBundles;
	NSArray *bundlesWithPreferences;
	NSDictionary *bundlesForUserInput;
	NSDictionary *bundlesForServerInput;
}

@property (nonatomic, assign) ChatBox *chatBox;
@property (nonatomic, assign) MainWindow *window;
@property (nonatomic, assign) ViewTheme *viewTheme;
@property (nonatomic, assign) ServerTreeView *tree;
@property (nonatomic, assign) InputTextField *text;
@property (nonatomic, assign) GrowlController *growl;
@property (nonatomic, assign) MasterController *master;
@property (nonatomic, retain) LogController *dummyLog;
@property (nonatomic, assign) MemberListView *memberList;
@property (nonatomic, assign) MenuController *menuController;
@property (nonatomic, assign) FieldEditorTextView *fieldEditor;
@property (nonatomic, assign) NSBox *logBase;
@property (nonatomic, assign) NSMenu *logMenu;
@property (nonatomic, assign) NSMenu *urlMenu;
@property (nonatomic, assign) NSMenu *addrMenu;
@property (nonatomic, assign) NSMenu *chanMenu;
@property (nonatomic, assign) NSMenu *treeMenu;
@property (nonatomic, assign) NSMenu *memberMenu;
@property (nonatomic, retain) NSMenu *serverMenu;
@property (nonatomic, retain) NSMenu *channelMenu;
@property (nonatomic, assign) NSInteger messagesSent;
@property (nonatomic, assign) NSInteger messagesReceived;
@property (nonatomic, assign) TXFSLongInt bandwidthIn;
@property (nonatomic, assign) TXFSLongInt bandwidthOut;
@property (nonatomic, retain) IRCWorldConfig *config;
@property (nonatomic, assign) NSMutableArray *clients;
@property (nonatomic, assign) NSInteger itemId;
@property (nonatomic, assign) BOOL soundMuted;
@property (nonatomic, assign) BOOL reloadingTree;
@property (nonatomic, assign) IRCExtras *extrac;
@property (nonatomic, retain) IRCTreeItem *selected;
@property (nonatomic, assign) NSInteger previousSelectedClientId;
@property (nonatomic, assign) NSInteger previousSelectedChannelId;
@property (nonatomic, retain) NSArray *allLoadedBundles;
@property (nonatomic, retain) NSArray *bundlesWithPreferences;
@property (nonatomic, retain) NSDictionary *bundlesForUserInput;
@property (nonatomic, retain) NSDictionary *bundlesForServerInput;

- (void)setup:(IRCWorldConfig *)seed;
- (void)setupTree;
- (void)save;
- (NSMutableDictionary *)dictionaryValue;

- (void)setServerMenuItem:(NSMenuItem *)item;
- (void)setChannelMenuItem:(NSMenuItem *)item;

- (void)resetLoadedBundles;

- (void)autoConnectAfterWakeup:(BOOL)afterWakeUp;
- (void)terminate;
- (void)prepareForSleep;

- (IRCClient *)findClient:(NSString *)name;
- (IRCClient *)findClientById:(NSInteger)uid;
- (IRCChannel *)findChannelByClientId:(NSInteger)uid channelId:(NSInteger)cid;

- (void)select:(id)item;
- (void)selectChannelAt:(NSInteger)n;
- (void)selectClientAt:(NSInteger)n;
- (void)selectPreviousItem;

- (IRCClient *)selectedClient;
- (IRCChannel *)selectedChannel;
- (IRCChannel *)selectedChannelOn:(IRCClient *)c;

- (IRCTreeItem *)previouslySelectedItem;

- (void)focusInputText;
- (BOOL)inputText:(NSString *)s command:(NSString *)command;

- (void)markAllAsRead;
- (void)markAllScrollbacks;

- (void)updateIcon;

- (void)reloadTree;
- (void)adjustSelection;
- (void)expandClient:(IRCClient *)client;

- (void)updateTitle;
- (void)updateClientTitle:(IRCClient *)client;
- (void)updateChannelTitle:(IRCChannel *)channel;

- (void)notifyOnGrowl:(GrowlNotificationType)type title:(NSString *)title desc:(NSString *)desc context:(id)context;

- (void)preferencesChanged;
- (void)reloadTheme;
- (void)updateThemeStyle;
- (void)changeTextSize:(BOOL)bigger;

- (IRCClient *)createClient:(IRCClientConfig *)seed reload:(BOOL)reload;
- (IRCChannel *)createChannel:(IRCChannelConfig *)seed client:(IRCClient *)client reload:(BOOL)reload adjust:(BOOL)adjust;
- (IRCChannel *)createTalk:(NSString *)nick client:(IRCClient *)client;

- (void)destroyChannel:(IRCChannel *)channel;
- (void)destroyClient:(IRCClient *)client;

- (void)logKeyDown:(NSEvent *)e;
- (void)logDoubleClick:(NSString *)s;

- (void)createConnection:(NSString *)str chan:(NSString *)channel;

- (void)clearContentsOfClient:(IRCClient *)u;
- (void)clearContentsOfChannel:(IRCChannel *)c inClient:(IRCClient *)u;

- (LogController *)createLogWithClient:(IRCClient *)client channel:(IRCChannel *)channel;

@end