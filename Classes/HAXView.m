//
//  HAXView.m
//  Sopreso
//
//  Created by Kocsis Olivér on 2014.05.12..
//  Copyright (c) 2014 Joinect Technologies. All rights reserved.
//

#import "HAXView.h"
#import "HAXElement+Protected.h"
@implementation HAXView
-(BOOL)isFullscreen
{
    BOOL isFullScreen = NO;
    NSArray * sceenArray = [NSScreen screens];
    
    for (NSScreen * screenI in sceenArray)
    {
        NSRect screenFrame;
        screenFrame = [screenI frame];
        NSRect windowFrame = self.frameCocoa;
        
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
        if(NSEqualRects([screenI frame], self.frameCocoa))
        {
            fullscreenScreen = screenI;
            break;
        }
    }
    return fullscreenScreen;
}
-(CGPoint)originCarbon
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
-(CGPoint)originCocoa
{
    return [NSScreen cocoaScreenFrameFromCarbonScreenFrame:self.frameCarbon].origin;
}

-(void)setOriginCarbon:(CGPoint)originCarbon
{
	AXValueRef originRef = AXValueCreate(kAXValueCGPointType, &originCarbon);
	[self setAttributeValue:originRef forKey:(__bridge NSString *)kAXPositionAttribute error:NULL];
	CFRelease(originRef);
}


-(CGSize)size
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

-(void)setSize:(CGSize)size
{
	AXValueRef sizeRef = AXValueCreate(kAXValueCGSizeType, &size);
	[self setAttributeValue:sizeRef forKey:(__bridge NSString *)kAXSizeAttribute error:NULL];
	CFRelease(sizeRef);
}


-(CGRect)frameCarbon
{
	return (CGRect){ .origin = self.originCarbon, .size = self.size };
}
-(CGRect)frameCocoa
{
    return [NSScreen cocoaScreenFrameFromCarbonScreenFrame:self.frameCarbon];
}

-(void)setFrameCarbon:(CGRect)frameCarbon
{
	self.originCarbon = frameCarbon.origin;
	self.size = frameCarbon.size;
}


-(NSString *)title
{
	return CFBridgingRelease([self copyAttributeValueForKey:(__bridge NSString *)kAXTitleAttribute error:NULL]);
}




@end
