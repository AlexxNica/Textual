// Created by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

@implementation TextualPluginItem

@synthesize pluginBundle;
@synthesize pluginPrimaryClass;

- (void)initWithPluginClass:(Class)primaryClass 
				  andBundle:(NSBundle *)bundle
				andIRCWorld:(IRCWorld *)world
		  withUserInputDict:(NSMutableDictionary *)newUserDict
		withServerInputDict:(NSMutableDictionary *)newServerDict
	  withUserInputDictRefs:(NSMutableDictionary **)userDict
	withServerInputDictRefs:(NSMutableDictionary **)serverDict
{
	pluginPrimaryClass = [primaryClass new];
	
	if (pluginPrimaryClass) {
		if (pluginPrimaryClass) {
			// User Input
			if ([pluginPrimaryClass respondsToSelector:@selector(messageSentByUser:message:command:)]) {
				if ([pluginPrimaryClass respondsToSelector:@selector(pluginSupportsUserInputCommands)]) {
					NSArray *spdcmds = [pluginPrimaryClass pluginSupportsUserInputCommands];
					
					if (NSObjectIsNotEmpty(spdcmds)) {
						for (NSString *cmd in spdcmds) {
							cmd = [cmd uppercaseString];
							
							NSArray *cmdDict = [newUserDict objectForKey:cmd];
							
							if (NSObjectIsEmpty(cmdDict)) {
								[newUserDict setObject:[[NSMutableArray new] autorelease] forKey:cmd];
							}
							
							if ([cmdDict containsObject:bundle] == NO) {
								[[newUserDict objectForKey:cmd] addObject:self];
							}
						}
					}
				}
			}
			
			// Server Input
			if ([pluginPrimaryClass respondsToSelector:@selector(messageReceivedByServer:sender:message:)]) {
				if ([pluginPrimaryClass respondsToSelector:@selector(pluginSupportsServerInputCommands)]) {
					NSArray *spdcmds = [pluginPrimaryClass pluginSupportsServerInputCommands];
					
					if (NSObjectIsNotEmpty(spdcmds)) {
						for (NSString *cmd in spdcmds) {
							cmd = [cmd uppercaseString];
							
							NSArray *cmdDict = [newServerDict objectForKey:cmd];
							
							if (NSObjectIsEmpty(cmdDict)) {
								[newServerDict setObject:[[NSMutableArray new] autorelease] forKey:cmd];
							}
							
							if ([cmdDict containsObject:bundle] == NO) {
								[[newServerDict objectForKey:cmd] addObject:self];
							}
						}
					}
				}
			}
			
			if ([pluginPrimaryClass respondsToSelector:@selector(pluginLoadedIntoMemory:)]) {
				[pluginPrimaryClass pluginLoadedIntoMemory:world];
			}
			
			*userDict = newUserDict;
			*serverDict = newServerDict;
		}
	}
}

- (void)dealloc
{
	if ([pluginPrimaryClass respondsToSelector:@selector(pluginUnloadedFromMemory)]) {
		[pluginPrimaryClass pluginUnloadedFromMemory];
	}
	
	[pluginPrimaryClass drain];
	[pluginBundle drain];
	
	[super dealloc];
}

@end