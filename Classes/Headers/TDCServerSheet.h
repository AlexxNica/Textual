/* *********************************************************************
       _____        _               _    ___ ____   ____
      |_   _|___  _| |_ _   _  __ _| |  |_ _|  _ \ / ___|
       | |/ _ \ \/ / __| | | |/ _` | |   | || |_) | |
       | |  __/>  <| |_| |_| | (_| | |   | ||  _ <| |___
       |_|\___/_/\_\\__|\__,_|\__,_|_|  |___|_| \_\\____|

 Copyright (c) 2008 - 2010 Satoshi Nakagawa <psychs AT limechat DOT net>
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

typedef enum TDCServerSheetNavigationSelection : NSInteger {
	TDCServerSheetDefaultNavigationSelection	= 0,
	TDCServerSheetAddressBookNavigationSelection,
	TDCServerSheetFloodControlNavigationSelection,
	TDCServerSheetNewIgnoreEntryNavigationSelection
} TDCServerSheetNavigationSelection;

@interface TDCServerSheet : TDCSheetBase <NSOutlineViewDataSource, NSOutlineViewDelegate, TDCAddressBookSheetDelegate, TDCHighlightEntrySheetDelegate, TDChannelSheetDelegate>
@property (nonatomic, copy) NSString *clientID;
@property (nonatomic, copy) NSArray *tabViewList;
@property (nonatomic, copy) NSDictionary *serverList;
@property (nonatomic, copy) NSDictionary *encodingList;
@property (nonatomic, copy) IRCClientConfig *config;
@property (nonatomic, nweak) IBOutlet NSButton *addChannelButton;
@property (nonatomic, nweak) IBOutlet NSButton *addHighlightButton;
@property (nonatomic, nweak) IBOutlet NSButton *addIgnoreButton;
@property (nonatomic, nweak) IBOutlet NSButton *autoConnectCheck;
@property (nonatomic, nweak) IBOutlet NSButton *autoDisconnectOnSleepCheck;
@property (nonatomic, nweak) IBOutlet NSButton *autoReconnectCheck;
@property (nonatomic, nweak) IBOutlet NSButton *connectionUsesSSLCheck;
@property (nonatomic, nweak) IBOutlet NSButton *deleteChannelButton;
@property (nonatomic, nweak) IBOutlet NSButton *deleteHighlightButton;
@property (nonatomic, nweak) IBOutlet NSButton *deleteIgnoreButton;
@property (nonatomic, nweak) IBOutlet NSButton *disconnectOnReachabilityChangeCheck;
@property (nonatomic, nweak) IBOutlet NSButton *editChannelButton;
@property (nonatomic, nweak) IBOutlet NSButton *editHighlightButton;
@property (nonatomic, nweak) IBOutlet NSButton *editIgnoreButton;
@property (nonatomic, nweak) IBOutlet NSButton *excludedFromCloudSyncingCheck;
@property (nonatomic, nweak) IBOutlet NSButton *floodControlCheck;
@property (nonatomic, nweak) IBOutlet NSButton *invisibleModeCheck;
@property (nonatomic, nweak) IBOutlet NSButton *pongTimerCheck;
@property (nonatomic, nweak) IBOutlet NSButton *pongTimerDisconnectCheck;
@property (nonatomic, nweak) IBOutlet NSButton *prefersIPv6Check;
@property (nonatomic, nweak) IBOutlet NSButton *sslCertificateChangeCertButton;
@property (nonatomic, nweak) IBOutlet NSButton *sslCertificateSHA1FingerprintCopyButton;
@property (nonatomic, nweak) IBOutlet NSButton *sslCertificateMD5FingerprintCopyButton;
@property (nonatomic, nweak) IBOutlet NSButton *sslCertificateResetButton;
@property (nonatomic, nweak) IBOutlet NSButton *validateServerSSLCertificateCheck;
@property (nonatomic, nweak) IBOutlet NSButton *zncIgnoreConfiguredAutojoinCheck;
@property (nonatomic, nweak) IBOutlet NSButton *zncIgnorePlaybackNotificationsCheck;
@property (nonatomic, nweak) IBOutlet NSComboBox *serverAddressCombo;
@property (nonatomic, nweak) IBOutlet NSPopUpButton *fallbackEncodingButton;
@property (nonatomic, nweak) IBOutlet NSPopUpButton *primaryEncodingButton;
@property (nonatomic, nweak) IBOutlet NSPopUpButton *proxyTypeButton;
@property (nonatomic, nweak) IBOutlet NSSlider *floodControlDelayTimerSlider;
@property (nonatomic, nweak) IBOutlet NSSlider *floodControlMessageCountSlider;
@property (nonatomic, nweak) IBOutlet NSTextField *alternateNicknamesField;
@property (nonatomic, nweak) IBOutlet NSTextField *awayNicknameField;
@property (nonatomic, nweak) IBOutlet NSTextField *nicknameField;
@property (nonatomic, nweak) IBOutlet NSTextField *nicknamePasswordField;
@property (nonatomic, nweak) IBOutlet NSTextField *normalLeavingCommentField;
@property (nonatomic, nweak) IBOutlet NSTextField *proxyAddressField;
@property (nonatomic, nweak) IBOutlet NSTextField *proxyPasswordField;
@property (nonatomic, nweak) IBOutlet NSTextField *proxyPortField;
@property (nonatomic, nweak) IBOutlet NSTextField *proxyUsernameField;
@property (nonatomic, nweak) IBOutlet NSTextField *realnameField;
@property (nonatomic, nweak) IBOutlet NSTextField *serverNameField;
@property (nonatomic, nweak) IBOutlet NSTextField *serverPasswordField;
@property (nonatomic, nweak) IBOutlet NSTextField *serverPortField;
@property (nonatomic, nweak) IBOutlet NSTextField *sleepModeQuitMessageField;
@property (nonatomic, nweak) IBOutlet NSTextField *sslCertificateCommonNameField;
@property (nonatomic, nweak) IBOutlet NSTextField *sslCertificateSHA1FingerprintField;
@property (nonatomic, nweak) IBOutlet NSTextField *sslCertificateMD5FingerprintField;
@property (nonatomic, nweak) IBOutlet NSTextField *usernameField;
@property (nonatomic, nweak) IBOutlet TVCBasicTableView *channelTable;
@property (nonatomic, nweak) IBOutlet TVCBasicTableView *highlightsTable;
@property (nonatomic, nweak) IBOutlet TVCBasicTableView *ignoreTable;
@property (nonatomic, nweak) IBOutlet NSOutlineView *navigationOutlineview;
@property (nonatomic, nweak) IBOutlet NSView *contentView;
@property (nonatomic,strong) IBOutlet NSView *addressBookContentView;
@property (nonatomic,strong) IBOutlet NSView *autojoinContentView;
@property (nonatomic,strong) IBOutlet NSView *connectCommandsContentView;
@property (nonatomic,strong) IBOutlet NSView *contentEncodingContentView;
@property (nonatomic,strong) IBOutlet NSView *disconnectMessagesContentView;
@property (nonatomic,strong) IBOutlet NSView *floodControlContentView;
@property (nonatomic,strong) IBOutlet NSView *floodControlContentViewToolView;
@property (nonatomic,strong) IBOutlet NSView *generalContentView;
@property (nonatomic,strong) IBOutlet NSView *highlightsContentView;
@property (nonatomic,strong) IBOutlet NSView *identityContentView;
@property (nonatomic,strong) IBOutlet NSView *networkSocketContentView;
@property (nonatomic,strong) IBOutlet NSView *proxyServerContentView;
@property (nonatomic,strong) IBOutlet NSView *sslCertificateContentView;
@property (nonatomic,strong) IBOutlet NSView *zncBouncerContentView;
@property (nonatomic, uweak) IBOutlet NSTextView *loginCommandsField;
@property (nonatomic, strong) TDChannelSheet *channelSheet;
@property (nonatomic, strong) TDCAddressBookSheet *ignoreSheet;
@property (nonatomic, strong) TDCHighlightEntrySheet *highlightSheet;

- (void)start:(TDCServerSheetNavigationSelection)viewToken withContext:(NSString *)context;

- (void)close;

- (IBAction)floodControlChanged:(id)sender;
- (IBAction)proxyTypeChanged:(id)sender;
- (IBAction)serverAddressChanged:(id)sender;
- (IBAction)toggleAdvancedEncodings:(id)sender;
- (IBAction)toggleAdvancedSettings:(id)sender;

#ifdef TEXTUAL_BUILT_WITH_ICLOUD_SUPPORT
- (IBAction)toggleCloudSyncExclusion:(id)sender;
#endif

- (IBAction)addChannel:(id)sender;
- (IBAction)editChannel:(id)sender;
- (IBAction)deleteChannel:(id)sender;

- (IBAction)addHighlight:(id)sender;
- (IBAction)editHighlight:(id)sender;
- (IBAction)deleteHighlight:(id)sender;

- (IBAction)addIgnore:(id)sender;
- (IBAction)editIgnore:(id)sender;
- (IBAction)deleteIgnore:(id)sender;

- (IBAction)showAddIgnoreMenu:(id)sender;

- (IBAction)useSSLCheckChanged:(id)sender;

- (IBAction)onSSLCertificateResetRequested:(id)sender;
- (IBAction)onSSLCertificateChangeRequested:(id)sender;
- (IBAction)onSSLCertificateFingerprintSHA1CopyRequested:(id)sender;
- (IBAction)onSSLCertificateFingerprintMD5CopyRequested:(id)sender;
@end
