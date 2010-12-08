#import "MemberListViewCell.h"

#define MARK_LEFT_MARGIN	2
#define MARK_RIGHT_MARGIN	2

static NSInteger markWidth;

@implementation MemberListViewCell

@synthesize member;
@synthesize theme;
@synthesize nickStyle;
@synthesize markStyle;
@synthesize rawHostmask;
@synthesize hostmask;

- (id)init
{
	if ((self = [super init])) {
		markStyle = [NSMutableParagraphStyle new];
		[markStyle setAlignment:NSCenterTextAlignment];
		
		nickStyle = [NSMutableParagraphStyle new];
		[nickStyle setAlignment:NSLeftTextAlignment];
		[nickStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	return self;
}

- (void)dealloc
{
	[nickStyle release];
	[markStyle release];
	[member release];
	[rawHostmask release];
	[hostmask release];
	[super dealloc];
}

- (id)copyWithZone:(NSZone *)zone
{
	MemberListViewCell* c = [[MemberListViewCell allocWithZone:zone] init];
	c.font = self.font;
	c.member = member;
	return c;
}

- (void)calculateMarkWidth
{
	markWidth = 0;
	
	NSDictionary* style = [NSDictionary dictionaryWithObject:self.font forKey:NSFontAttributeName];
	NSArray* marks = [NSArray arrayWithObjects:@"~", @"&", @"@", @"%", @"+", @"!", nil];
	
	for (NSString* s in marks) {
		NSSize size = [s sizeWithAttributes:style];
		NSInteger width = ceil(size.width);
		if (markWidth < width) {
			markWidth = width;
		}
	}
}

+ (MemberListViewCell*)initWithTheme:(id)aTheme
{
	MemberListViewCell* cell = [[MemberListViewCell alloc] init];
	cell.theme = aTheme;
	return [cell autorelease];
}

- (void)themeChanged
{
	[self calculateMarkWidth];
}

- (NSAttributedString *)tooltipValue
{
	if (member.address && member.username) {
		NSString *fullhost = [NSString stringWithFormat:@"%@%@\n%@%@\n%@%@", TXTLS(@"USER_HOSTMASK_HOVER_TOOLTIP_NICKNAME"), member.nick, 
																			 TXTLS(@"USER_HOSTMASK_HOVER_TOOLTIP_USERNAME"), member.username, 
																			 TXTLS(@"USER_HOSTMASK_HOVER_TOOLTIP_HOSTMASK"), member.address];
		
		if (hostmask) {
			if ([fullhost isEqualToString:rawHostmask]) {
				return hostmask;
			} else {
				[hostmask release];
				hostmask = nil;
			}
		}
		
		if (rawHostmask) {
			[rawHostmask release];
			rawHostmask = nil;
		}
		
		rawHostmask = [fullhost retain];
		
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Lucida Grande" size:12], NSFontAttributeName, 
							   [NSColor whiteColor], NSForegroundColorAttributeName, nil];
		
		NSFont *boldFont = [[NSFontManager sharedFontManager] fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:1.0 size:12];
		
		NSMutableAttributedString *atrsTooltip = [[NSMutableAttributedString alloc] initWithString:fullhost attributes:attrs];
		
		[atrsTooltip addAttribute:NSFontAttributeName value:boldFont range:[fullhost rangeOfString:TXTLS(@"USER_HOSTMASK_HOVER_TOOLTIP_NICKNAME")]];
		[atrsTooltip addAttribute:NSFontAttributeName value:boldFont range:[fullhost rangeOfString:TXTLS(@"USER_HOSTMASK_HOVER_TOOLTIP_USERNAME")]];
		[atrsTooltip addAttribute:NSFontAttributeName value:boldFont range:[fullhost rangeOfString:TXTLS(@"USER_HOSTMASK_HOVER_TOOLTIP_HOSTMASK")]];
			
		hostmask = atrsTooltip;
		
		return hostmask;
	}
	
	return nil;
}

- (NSRect)expansionFrameWithFrame:(NSRect)cellFrame inView:(NSView *)view
{
	NSAttributedString *tooltip = [self tooltipValue];
	
	if (tooltip) {
		NSSize hostTextSize = [tooltip size];
		
		if (hostTextSize.width < cellFrame.size.width){
			return NSZeroRect;
		}
		
		return NSMakeRect((cellFrame.origin.x + 5), 
						  (cellFrame.origin.y + 5), 
						  (hostTextSize.width + 31), 
						  (hostTextSize.height + 12));	
	} else {
		return NSZeroRect;
	}
}

- (void)drawWithExpansionFrame:(NSRect)cellFrame inView:(NSView *)view
{
	NSAttributedString *tooltip = [self tooltipValue];
	
	if (tooltip) {   
		[[NSColor clearColor] set];
		NSRectFill([view frame]);
		
		NSSize hostTextSize = [tooltip size];
					 
		[[NSColor blackColor] setStroke];
		[[NSColor darkGrayColor] setFill];
		
		NSRect rect = NSMakeRect((cellFrame.origin.x + 1), 
								 (cellFrame.origin.y + 1), 
								 (hostTextSize.width + 30), 
								 (hostTextSize.height + 10));
		
		NSBezierPath* path = [NSBezierPath bezierPath];
		[path appendBezierPathWithRoundedRect:rect xRadius:10 yRadius:10];
		[path setLineWidth:2];
		[path stroke];
		[path fill];
		
		[tooltip drawAtPoint:NSMakePoint((cellFrame.origin.x + 5), 
											 (cellFrame.origin.y + 5))];
	} else {
		[super drawWithExpansionFrame:cellFrame inView:view];
	}
}

- (void)drawWithFrame:(NSRect)frame inView:(NSView*)view
{
	NSWindow* window = view.window;
	NSColor* color = nil;
	
	if ([self isHighlighted]) {
		if (window && [window isMainWindow] && [window firstResponder] == view) {
			color = [theme memberListSelColor] ?: [NSColor alternateSelectedControlTextColor];
		} else {
			color = [theme memberListSelColor] ?: [NSColor selectedControlTextColor];
		}
	} else if ([member isOp]) {
		color = [theme memberListOpColor];
	} else {
		color = [theme memberListColor];
	}
	
	NSMutableDictionary* style = [NSMutableDictionary dictionary];
	[style setObject:markStyle forKey:NSParagraphStyleAttributeName];
	[style setObject:self.font forKey:NSFontAttributeName];
	
	if (color) {
		[style setObject:color forKey:NSForegroundColorAttributeName];
	}
	
	NSRect rect = frame;
	rect.origin.x += MARK_LEFT_MARGIN;
	rect.size.width = markWidth;
	
	char mark = [member mark];
	if (mark != ' ') {
		NSString* markStr = [NSString stringWithFormat:@"%C", mark];
		[markStr drawInRect:rect withAttributes:style];
	}
	
	[style setObject:nickStyle forKey:NSParagraphStyleAttributeName];
	
	NSInteger offset = MARK_LEFT_MARGIN + markWidth + MARK_RIGHT_MARGIN;
	
	rect = frame;
	rect.origin.x += offset;
	rect.size.width -= offset;
	
	NSString* nick = [member nick];
	[nick drawInRect:rect withAttributes:style];
}

@end