//  HAXView.m
//  Created by Kocsis Olivér on 2014-05-12
//  Copyright 2014 Joinect Technologies

#import "HAXView.h"
#import "HAXElement+Protected.h"
#import "NSScreen+HAXPointConvert.h"


@implementation HAXView

-(BOOL)isFullscreen
{
    BOOL isFullScreen = NO;
    NSArray * sceenArray = [NSScreen screens];
    
    for (NSScreen * screenI in sceenArray)
    {
        NSRect screenFrame;
        screenFrame = [screenI frame];
        NSRect windowFrame = self.frame;
        
        if(NSEqualRects(screenFrame, windowFrame))
        {
            isFullScreen = YES;
            break;
        }
    }
    return isFullScreen;
}

-(NSScreen *)screen
{
    NSScreen *fullscreenScreen = nil;
    for (NSScreen * screenI in [NSScreen screens])
    {
        if(NSEqualRects([screenI frame], self.frame))
        {
            fullscreenScreen = screenI;
            break;
        }
    }
    return fullscreenScreen;
}

-(CGPoint)carbonOrigin
{
	CGPoint origin = {0};
	CFTypeRef originRef = [self copyAttributeValueForKey:(__bridge NSString *)kAXPositionAttribute error:NULL];
	if(originRef)
    {
		AXValueGetValue(originRef, kAXValueCGPointType, &origin);
		CFRelease(originRef);
		originRef = NULL;
	}
	return origin;
}

-(CGPoint)origin
{
    return [NSScreen hax_cocoaScreenFrameFromCarbonScreenFrame:self.carbonFrame].origin;
}

-(void)setCarbonOrigin:(CGPoint)carbonOrigin
{
	AXValueRef originRef = AXValueCreate(kAXValueCGPointType, &carbonOrigin);
	[self setAttributeValue:originRef forKey:(__bridge NSString *)kAXPositionAttribute error:NULL];
	CFRelease(originRef);
}

-(NSSize)size
{
	CGSize size = {0};
	CFTypeRef sizeRef = [self copyAttributeValueForKey:(__bridge NSString *)kAXSizeAttribute error:NULL];
	if(sizeRef)
    {
		AXValueGetValue(sizeRef, kAXValueCGSizeType, &size);
		CFRelease(sizeRef);
		sizeRef = NULL;
	}
	return size;
}

-(void)setSize:(NSSize)size
{
	AXValueRef sizeRef = AXValueCreate(kAXValueCGSizeType, &size);
	[self setAttributeValue:sizeRef forKey:(__bridge NSString *)kAXSizeAttribute error:NULL];
	CFRelease(sizeRef);
}

-(CGRect)carbonFrame
{
	return (CGRect){ .origin = self.carbonOrigin, .size = self.size };
}

-(NSRect)frame
{
    return [NSScreen hax_cocoaScreenFrameFromCarbonScreenFrame:self.carbonFrame];
}

-(void)setCarbonFrame:(CGRect)carbonFrame
{
	self.carbonOrigin = carbonFrame.origin;
	self.size = carbonFrame.size;
}

-(NSString *)title
{
	return CFBridgingRelease([self copyAttributeValueForKey:(__bridge NSString *)kAXTitleAttribute error:NULL]);
}

@end
