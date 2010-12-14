@interface TPI_SP_SysInfo : NSObject 

+ (NSString *)compiledOutput;
+ (NSString *)model;
+ (NSString *)processor;
+ (NSNumber *)processorCount;
+ (NSString *)processorL2CacheSize;
+ (NSString *)processorL3CacheSize;
+ (NSString *)processorClockSpeed;
+ (NSString *)physicalMemorySize;
+ (NSString *)loadAverages;
+ (NSString *)systemUptime;
+ (NSString *)diskInfo;
+ (NSString *)getNetworkStats;
+ (NSString *)graphicsCardInfo;
+ (NSString *)getAllVolumesAndSizes;
+ (NSString *)applicationMemoryUsage;
+ (NSString *)applicationAndSystemUptime;
+ (NSString *)getBandwidthStats:(IRCWorld *)world;
+ (NSString *)getCurrentThemeInUse:(IRCWorld *)world;

+ (NSString *)formattedDiskSize:(TXFSLongInt)size;
+ (NSString *)formattedCPUFrequency:(double)rate;

@end