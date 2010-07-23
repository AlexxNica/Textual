#import "NSWindowHelper.h"
#import "NSRectHelper.h"

@implementation NSWindow (NSWindowHelper)

- (void)centerOfWindow:(NSWindow*)window
{
	NSPoint p = NSRectCenter(window.frame);
	NSRect frame = self.frame;
	NSSize size = frame.size;
	p.x -= size.width/2;
	p.y -= size.height/2;
	
	NSScreen* screen = window.screen;
	if (screen) {
		NSRect screenFrame = [screen visibleFrame];
		NSRect r = frame;
		r.origin = p;
		if (!NSContainsRect(screenFrame, r)) {
			r = NSRectAdjustInRect(r, screenFrame);
			p = r.origin;
		}
	}
	
	[self setFrameOrigin:p];
}

- (void)centerWindow
{
	NSScreen* screen = [NSScreen mainScreen];
	
	if (screen) {
		NSRect rect = [screen visibleFrame];
		NSPoint p = NSMakePoint(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
		NSInteger w = self.frame.size.width;
		NSInteger h = self.frame.size.height;
		rect = NSMakeRect(p.x - w/2, p.y - h/2, w, h);
		[self setFrame:rect display:YES];
	}	
}

- (BOOL)isOnCurrentWorkspace
{
	if ([self respondsToSelector:@selector(isOnActiveSpace)]) {
		return (BOOL)[self performSelector:@selector(isOnActiveSpace)];
	}
	
	return YES;
}

@end