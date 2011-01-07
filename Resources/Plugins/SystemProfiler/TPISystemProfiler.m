// Created by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import "TPISystemProfiler.h"
#import "TPI_SP_SysInfo.h"

@implementation TPISystemProfiler

- (NSArray*)pluginSupportsUserInputCommands
{
	return [NSArray arrayWithObjects:@"sysinfo", @"memory", @"uptime",
			@"netstats", @"msgcount", @"diskspace", @"theme", @"screens", nil];
}

- (void)messageSentByUser:(IRCClient*)client
				  message:(NSString*)messageString
				  command:(NSString*)commandString
{
	if ([client isConnected]) {
		NSString *channelName = [[[client world] selectedChannel] name];
		
		if ([channelName length] >= 1) {
			if ([commandString isEqualToString:@"SYSINFO"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo compiledOutput]];
			} else if ([commandString isEqualToString:@"MEMORY"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo applicationMemoryUsage]];
			} else if ([commandString isEqualToString:@"UPTIME"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo applicationAndSystemUptime]];
			} else if ([commandString isEqualToString:@"NETSTATS"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo getNetworkStats]];
			} else if ([commandString isEqualToString:@"MSGCOUNT"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo getBandwidthStats:[client world]]];
			} else if ([commandString isEqualToString:@"DISKSPACE"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo getAllVolumesAndSizes]];
			} else if ([commandString isEqualToString:@"THEME"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo getCurrentThemeInUse:[client world]]];
			} else if ([commandString isEqualToString:@"SCREENS"]) {
				[[client invokeOnMainThread] sendPrivmsgToSelectedChannel:[TPI_SP_SysInfo getAllScreenResolutions]];
			}
		}
	}
}

@end