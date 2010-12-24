//
//  BWHyperlinkButton.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "BWHyperlinkButton.h"
#import "BWHyperlinkButtonCell.h"

@implementation BWHyperlinkButton

@synthesize urlString;

-(void)awakeFromNib
{
	[self setTarget:self];
	[self setAction:@selector(openURLInBrowser:)];
}

- (void)openURLInBrowser:(id)sender
{
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:self.urlString]];
}

- (void)resetCursorRects 
{
	[self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

- (void)dealloc
{
	[urlString release];
	[super dealloc];
}

@end