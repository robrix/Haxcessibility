// HAXWindow.m
// Created by Rob Rix on 2011-01-06
// Copyright 2011 Rob Rix

#import "HAXWindow.h"
#import "HAXElement+Protected.h"
#import "HAXView.h"
#import "NSScreen+HAXPointConvert.h"

@implementation HAXWindow

-(BOOL)isFullscreen {
    BOOL isFullScreen = NO;
    NSArray * sceenArray = [NSScreen screens];

    for (NSScreen * screenI in sceenArray) {
        NSRect screenFrame;
        screenFrame = [screenI frame];
        NSRect windowFrame = self.frame;
        
        if(NSEqualRects(screenFrame, windowFrame)) {
            isFullScreen = YES;
            break;
        }
    }
    return isFullScreen;
}

-(NSScreen *)screen {
    NSScreen *fullscreenScreen = nil;
    for (NSScreen * screenI in [NSScreen screens]) {
        if(NSEqualRects([screenI frame], self.frame)) {
            fullscreenScreen = screenI;
            break;
        }
    }
    return fullscreenScreen;
}

-(CGPoint)carbonOrigin {
	CGPoint origin = {0};
	AXValueRef originRef = (AXValueRef)[self copyAttributeValueForKey:(__bridge NSString *)kAXPositionAttribute error:NULL];
	if(originRef) {
		AXValueGetValue(originRef, kAXValueCGPointType, &origin);
		CFRelease(originRef);
		originRef = NULL;
	}
	return origin;
}

-(CGPoint)origin {
    return [NSScreen hax_cocoaScreenFrameFromCarbonScreenFrame:self.frameCarbon].origin;
}

-(void)setCarbonOrigin:(CGPoint)carbonOrigin {
	AXValueRef originRef = AXValueCreate(kAXValueCGPointType, &carbonOrigin);
	[self setAttributeValue:originRef forKey:(__bridge NSString *)kAXPositionAttribute error:NULL];
	CFRelease(originRef);
}

-(NSSize)size {
	CGSize size = {0};
	AXValueRef sizeRef = (AXValueRef)[self copyAttributeValueForKey:(__bridge NSString *)kAXSizeAttribute error:NULL];
	if(sizeRef) {
		AXValueGetValue(sizeRef, kAXValueCGSizeType, &size);
		CFRelease(sizeRef);
		sizeRef = NULL;
	}
	return size;
}

-(void)setSize:(NSSize)size {
	AXValueRef sizeRef = AXValueCreate(kAXValueCGSizeType, &size);
	[self setAttributeValue:sizeRef forKey:(__bridge NSString *)kAXSizeAttribute error:NULL];
	CFRelease(sizeRef);
}

-(CGRect)frameCarbon {
	return (CGRect){ .origin = self.carbonOrigin, .size = self.size };
}
-(NSRect)frame {
    return [NSScreen hax_cocoaScreenFrameFromCarbonScreenFrame:self.frameCarbon];
}

-(void)setCarbonFrame:(CGRect)carbonFrame {
	self.carbonOrigin = carbonFrame.origin;
	self.size = carbonFrame.size;
}


-(NSString *)title {
	return [self getAttributeValueForKey:(__bridge NSString *)kAXTitleAttribute error:NULL];
}

-(NSArray *)views {
	NSArray *axChildren = self.children;
    NSMutableArray *result = [NSMutableArray array];
    
    NSString * axRole;
    for (HAXElement * haxElementI in axChildren) {
        axRole = [haxElementI getAttributeValueForKey:(__bridge NSString *)kAXRoleAttribute error:NULL];
        if ([axRole isEqualToString:@"AXView"]) {
            HAXView * haxView = [HAXView elementWithElementRef:(AXUIElementRef)haxElementI.elementRef];
            [result addObject:haxView];
        }
    }
	return result;
}


-(BOOL)raise {
	return [self performAction:(__bridge NSString *)kAXRaiseAction error:NULL];
}

-(BOOL)close {
	HAXElement *element = [self elementOfClass:[HAXElement class] forKey:(__bridge NSString *)kAXCloseButtonAttribute error:NULL];
	return [element performAction:(__bridge NSString *)kAXPressAction error:NULL];
}

@end
