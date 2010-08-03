#import "TPISystemProfiler.h"
#import "TPI_SP_SysInfo.h"

@implementation TPISystemProfiler

- (NSArray*)pluginSupportsUserInputCommands
{
	return [NSArray arrayWithObjects:@"sysinfo", @"memory", nil];
}

- (void)messageSentByUser:(NSObject*)client
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
			}
		}
	}
}

@end