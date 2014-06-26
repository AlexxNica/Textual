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

#import "IRCTreeItem.h" // superclass

#import "TVCLogLine.h"			// typedef enum
#import "TLOGrowlController.h"	// typedef enum

typedef enum IRCClientConnectMode : NSInteger {
	IRCClientConnectNormalMode,
	IRCClientConnectRetryMode,
	IRCClientConnectReconnectMode,
	IRCClientConnectBadSSLCertificateMode,
} IRCClientConnectMode;

typedef enum IRCClientDisconnectMode : NSInteger {
	IRCClientDisconnectNormalMode,
	IRCClientDisconnectTrialPeriodMode,
	IRCClientDisconnectComputerSleepMode,
	IRCClientDisconnectBadSSLCertificateMode,
	IRCClientDisconnectReachabilityChangeMode,
	IRCClientDisconnectServerRedirectMode,
} IRCClientDisconnectMode;

typedef enum IRCClientIdentificationWithSASLMechanism : NSInteger {
	IRCClientIdentificationWithSASLNoMechanism,
	IRCClientIdentificationWithSASLPlainTextMechanism,
	IRCClientIdentificationWithSASLExternalMechanism,
} IRCClientIdentificationWithSASLMechanism;

typedef enum ClientIRCv3SupportedCapacities : NSInteger {
	ClientIRCv3SupportedCapacityAwayNotify				= 1 << 0, // YES if away-notify CAP supported.
	ClientIRCv3SupportedCapacityIdentifyCTCP			= 1 << 1, // YES if identify-ctcp CAP supported.
	ClientIRCv3SupportedCapacityIdentifyMsg				= 1 << 2, // YES if identify-msg CAP supported.
	ClientIRCv3SupportedCapacityMultiPreifx				= 1 << 3, // YES if multi-prefix CAP supported.
	ClientIRCv3SupportedCapacityServerTime				= 1 << 4, // YES if server-time CAP supported.
	ClientIRCv3SupportedCapacityUserhostInNames			= 1 << 5, // YES if userhost-in-names CAP supported.
	ClientIRCv3SupportedCapacityWatchCommand			= 1 << 6, // YES if the WATCH command is supported.
	ClientIRCv3SupportedCapacityZNCPlaybackModule		= 1 << 7, // YES if the ZNC vendor specific playback CAP supported.
	ClientIRCv3SupportedCapacityIsInSASLNegotiation		= 1 << 8, // YES if in SASL CAP authentication request, else NO.
	ClientIRCv3SupportedCapacityIsIdentifiedWithSASL	= 1 << 9, // YES if SASL authentication was successful, else NO.
} ClientIRCv3SupportedCapacities;

@interface IRCClient : IRCTreeItem
@property (nonatomic, copy) IRCClientConfig *config;
@property (nonatomic, copy) IRCISupportInfo *isupport;
@property (nonatomic, assign) IRCClientConnectMode connectType;
@property (nonatomic, assign) IRCClientDisconnectMode disconnectType;
@property (nonatomic, assign) NSInteger connectDelay;
@property (nonatomic, assign) BOOL inUserInvokedJoinRequest;
@property (nonatomic, assign) BOOL inUserInvokedNamesRequest;
@property (nonatomic, assign) BOOL inUserInvokedWhoRequest;
@property (nonatomic, assign) BOOL inUserInvokedWhowasRequest;
@property (nonatomic, assign) BOOL inUserInvokedWatchRequest;
@property (nonatomic, assign) BOOL inUserInvokedModeRequest;
@property (nonatomic, assign) BOOL autojoinInProgress;			// YES if autojoin is running, else NO.
@property (nonatomic, assign) BOOL hasIRCopAccess;				// YES if local user is IRCOp, else NO.
@property (nonatomic, assign) BOOL isAutojoined;				// YES if autojoin has been completed, else NO.
@property (nonatomic, assign) BOOL isAway;						// YES if Textual has knowledge of local user being away, else NO.
@property (nonatomic, assign) BOOL isConnected;					// YES if socket is connected, else NO.
@property (nonatomic, assign) BOOL isConnecting;				// YES if socket is connecting, else, NO. Set to NO on raw numeric 001.
@property (nonatomic, assign) BOOL isIdentifiedWithNickServ;	// YES if NickServ identification was successful, else NO.
@property (nonatomic, assign) BOOL isLoggedIn;					// YES if connected to server, else NO. Set to YES on raw numeric 001.
@property (nonatomic, assign) BOOL isQuitting;					// YES if connection to IRC server is being quit, else NO.
@property (nonatomic, assign) BOOL isWaitingForNickServ;		// YES if NickServ identification is pending, else NO.
@property (nonatomic, assign) BOOL isZNCBouncerConnection;		// YES if Textual detected that this connection is ZNC based.
@property (nonatomic, assign) BOOL rawModeEnabled;				// YES if sent & received data should be logged to console, else NO.
@property (nonatomic, assign) BOOL reconnectEnabled;			// YES if reconnection is allowed, else NO.
@property (nonatomic, assign) BOOL serverHasNickServ;			// YES if NickServ service was found on server, else NO.
@property (nonatomic, assign) ClientIRCv3SupportedCapacities CAPAcceptedCaps;
@property (nonatomic, assign) ClientIRCv3SupportedCapacities CAPPendingCaps;
@property (nonatomic, assign) ClientIRCv3SupportedCapacities capacities;
@property (nonatomic, copy) NSArray *channels;
@property (nonatomic, copy) NSArray *highlights;
@property (nonatomic, strong) IRCChannel *lastSelectedChannel;
@property (nonatomic, copy) NSString *preAwayNickname; // Nickname before away was set.
@property (nonatomic, assign) NSTimeInterval lastMessageReceived;			// The time at which the last of any incoming data was received.
@property (nonatomic, assign) NSTimeInterval lastMessageServerTime;			// The time of the last message received that contained a server-time CAP.
@property (nonatomic, copy) NSString *serverRedirectAddressTemporaryStore; // Temporary store for RPL_BOUNCE (010) redirects.
@property (nonatomic, assign) NSInteger serverRedirectPortTemporaryStore; // Temporary store for RPL_BOUNCE (010) redirects.

- (void)setup:(id)seed;

- (void)updateConfig:(IRCClientConfig *)seed;
- (void)updateConfig:(IRCClientConfig *)seed fromTheCloud:(BOOL)isCloudUpdate withSelectionUpdate:(BOOL)reloadSelection;

- (IRCClientConfig *)storedConfig;

- (NSMutableDictionary *)dictionaryValue;
- (NSMutableDictionary *)dictionaryValue:(BOOL)isCloudDictionary;

- (NSString *)uniqueIdentifier;

- (NSString *)networkName; // Only returns the actual network name.
- (NSString *)altNetworkName; // Will return the configured name if the actual name is not available.
- (NSString *)networkAddress;

- (NSString *)localNickname;
- (NSString *)localHostmask;

- (void)enableCapacity:(ClientIRCv3SupportedCapacities)capacity;
- (void)disableCapacity:(ClientIRCv3SupportedCapacities)capacity;

- (BOOL)isCapacityEnabled:(ClientIRCv3SupportedCapacities)capacity;

- (NSInteger)channelCount;

- (void)addChannel:(IRCChannel *)channel;
- (void)removeChannel:(IRCChannel *)channel;

- (void)selectFirstChannelInChannelList;

- (void)addHighlightInChannel:(IRCChannel *)channel withLogLine:(TVCLogLine *)logLine;

/* Returns the value of _lastMessageServerTime which is the value of the last message
 received server-time capacity value. If logging is enabled in Textual, then it is 
 possible that the value returned is cached from previous session. If you want the 
 value without any cache, then access -lastMessageServerTime itself. */
/* The cached value is only asked for one time by this method so it is fast as possible. */
- (NSTimeInterval)lastMessageServerTimeWithCachedValue;

- (void)reachabilityChanged:(BOOL)reachable;

- (void)autoConnect:(NSInteger)delay afterWakeUp:(BOOL)afterWakeUp;

- (void)prepareForApplicationTermination;
- (void)prepareForPermanentDestruction;

- (void)closeDialogs;
- (void)preferencesChanged;

- (BOOL)isReconnecting;

- (void)postEventToViewController:(NSString *)eventToken;
- (void)postEventToViewController:(NSString *)eventToken forChannel:(IRCChannel *)channel;

- (IRCAddressBookEntry *)checkIgnoreAgainstHostmask:(NSString *)host withMatches:(NSArray *)matches;

- (BOOL)encryptOutgoingMessage:(NSString **)message channel:(IRCChannel *)channel;
- (void)decryptIncomingMessage:(NSString **)message channel:(IRCChannel *)channel;

- (BOOL)outputRuleMatchedInMessage:(NSString *)raw inChannel:(IRCChannel *)chan withLineType:(TVCLogLineType)type;

- (void)sendFile:(NSString *)nickname port:(NSInteger)port filename:(NSString *)filename filesize:(TXUnsignedLongLong)totalFilesize token:(NSString *)transferToken;

- (void)connect;
- (void)connect:(IRCClientConnectMode)mode;
- (void)connect:(IRCClientConnectMode)mode preferringIPv6:(BOOL)preferIPv6;

- (void)disconnect;
- (void)quit;
- (void)quit:(NSString *)comment;
- (void)cancelReconnect;

- (void)sendNextCap;
- (void)pauseCap;
- (void)resumeCap;
- (BOOL)isCapAvailable:(NSString *)cap;
- (void)cap:(NSString *)cap result:(BOOL)supported;

- (void)joinChannel:(IRCChannel *)channel;
- (void)joinChannel:(IRCChannel *)channel password:(NSString *)password;
- (void)joinUnlistedChannel:(NSString *)channel;
- (void)joinUnlistedChannel:(NSString *)channel password:(NSString *)password;
- (void)forceJoinChannel:(NSString *)channel password:(NSString *)password;
- (void)partChannel:(IRCChannel *)channel;
- (void)partChannel:(IRCChannel *)channel withComment:(NSString *)comment;
- (void)partUnlistedChannel:(NSString *)channel;
- (void)partUnlistedChannel:(NSString *)channel withComment:(NSString *)comment;

- (void)sendWhois:(NSString *)nick;
- (void)changeNick:(NSString *)newNick;
- (void)kick:(IRCChannel *)channel target:(NSString *)nick;
- (void)sendCTCPQuery:(NSString *)target command:(NSString *)command text:(NSString *)text;
- (void)sendCTCPReply:(NSString *)target command:(NSString *)command text:(NSString *)text;
- (void)sendCTCPPing:(NSString *)target;

- (void)toggleAwayStatus:(BOOL)setAway;
- (void)toggleAwayStatus:(BOOL)setAway withReason:(NSString *)reason;

- (void)createChannelListDialog;
- (void)createChanBanListDialog;
- (void)createChanBanExceptionListDialog;
- (void)createChanInviteExceptionListDialog;

- (void)sendCommand:(id)str;
- (void)sendCommand:(id)str completeTarget:(BOOL)completeTarget target:(NSString *)targetChannelName;
- (void)sendText:(NSAttributedString *)str command:(NSString *)command channel:(IRCChannel *)channel;
- (void)sendText:(NSAttributedString *)str command:(NSString *)command channel:(IRCChannel *)channel withEncryption:(BOOL)encryptChat;
- (void)inputText:(id)str command:(NSString *)command;

- (void)sendLine:(NSString *)str;
- (void)send:(NSString *)str, ...;

- (NSInteger)indexOfFirstPrivateMessage;

- (IRCChannel *)findChannel:(NSString *)name;
- (IRCChannel *)findChannelOrCreate:(NSString *)name;
- (IRCChannel *)findChannelOrCreate:(NSString *)name isPrivateMessage:(BOOL)isPM;

- (NSData *)convertToCommonEncoding:(NSString *)data;
- (NSString *)convertFromCommonEncoding:(NSData *)data;

- (NSString *)formatNick:(NSString *)nick channel:(IRCChannel *)channel;
- (NSString *)formatNick:(NSString *)nick channel:(IRCChannel *)channel formatOverride:(NSString *)forcedFormat;

- (void)sendPrivmsgToSelectedChannel:(NSString *)message;

- (BOOL)notifyEvent:(TXNotificationType)type lineType:(TVCLogLineType)ltype;
- (BOOL)notifyEvent:(TXNotificationType)type lineType:(TVCLogLineType)ltype target:(IRCChannel *)target nick:(NSString *)nick text:(NSString *)text;
- (BOOL)notifyText:(TXNotificationType)type lineType:(TVCLogLineType)ltype target:(IRCChannel *)target nick:(NSString *)nick text:(NSString *)text;

- (void)notifyFileTransfer:(TXNotificationType)type nickname:(NSString *)nickname filename:(NSString *)filename filesize:(TXUnsignedLongLong)totalFilesize;

- (void)populateISONTrackedUsersList:(NSMutableArray *)ignores;

#pragma mark -

/* ------ */
/* All print calls point to this single one: */
- (void)print:(id)chan											// An IRCChannel or nil for the console.
		 type:(TVCLogLineType)type								// The line type. See TVCLogLine.h
		 nick:(NSString *)nick									// The nickname associated with the print.
		 text:(NSString *)text									// The actual text being printed.
	encrypted:(BOOL)isEncrypted									// Is the text encrypted?
   receivedAt:(NSDate *)receivedAt								// The time the message was received at for the timestamp.
	  command:(NSString *)command								// Can be the actual command (PRIVMSG, NOTICE, etc.) or a raw numeric (001, 002, etc.) — … -100 = internal debug command.
	  message:(IRCMessage *)rawMessage							// Actual IRCMessage to associate with the print job. 
completionBlock:(void(^)(BOOL highlighted))completionBlock;		// A block to call when the actual print occurs.
/* ------ */

- (void)print:(id)chan type:(TVCLogLineType)type nick:(NSString *)nick text:(NSString *)text command:(NSString *)command;
- (void)print:(id)chan type:(TVCLogLineType)type nick:(NSString *)nick text:(NSString *)text receivedAt:(NSDate *)receivedAt command:(NSString *)command;
- (void)print:(id)chan type:(TVCLogLineType)type nick:(NSString *)nick text:(NSString *)text encrypted:(BOOL)isEncrypted receivedAt:(NSDate *)receivedAt command:(NSString *)command;
- (void)print:(id)chan type:(TVCLogLineType)type nick:(NSString *)nick text:(NSString *)text encrypted:(BOOL)isEncrypted receivedAt:(NSDate *)receivedAt command:(NSString *)command message:(IRCMessage *)rawMessage;

- (void)printReply:(IRCMessage *)m;
- (void)printUnknownReply:(IRCMessage *)m;

- (void)printDebugInformation:(NSString *)m;
- (void)printDebugInformation:(NSString *)m forCommand:(NSString *)command;

- (void)printDebugInformationToConsole:(NSString *)m;
- (void)printDebugInformationToConsole:(NSString *)m forCommand:(NSString *)command;

- (void)printDebugInformation:(NSString *)m channel:(IRCChannel *)channel;
- (void)printDebugInformation:(NSString *)m channel:(IRCChannel *)channel command:(NSString *)command;

- (void)printError:(NSString *)error forCommand:(NSString *)command;

- (void)printErrorReply:(IRCMessage *)m;
- (void)printErrorReply:(IRCMessage *)m channel:(IRCChannel *)channel;
@end
