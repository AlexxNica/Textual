// Created by Codeux Software <support AT codeux DOT com> <https://github.com/codeux/Textual>
// You can redistribute it and/or modify it under the new BSD license.

#import "AboutPanel.h"
#import "Preferences.h"

@implementation AboutPanel

@synthesize delegate;
@synthesize versionInfo;

- (id)init
{
	if ((self = [super init])) {
		[NSBundle loadNibNamed:@"AboutPanel" owner:self];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)show
{	
	[versionInfo setStringValue:[NSString stringWithFormat:TXTLS(@"ABOUT_WINDOW_BUILD_NUMBER"), 
								 [[Preferences textualInfoPlist] objectForKey:@"CFBundleVersion"],
								 [[Preferences textualInfoPlist] objectForKey:@"Build Number"]]];	
	
	[self.window center];
	[self.window makeKeyAndOrderFront:nil];
}

- (void)windowWillClose:(NSNotification*)note
{
	if ([delegate respondsToSelector:@selector(aboutPanelWillClose:)]) {
		[delegate aboutPanelWillClose:self];
	}
}

@end