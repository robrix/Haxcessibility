//
//  NSScreen+PointConvert.h
//  Sopreso
//
//  Created by Kocsis Olivér on 2014.05.05..
//  Copyright (c) 2014 Joinect Technologies. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSScreen (PointConvert)
- (NSRect)frameCarbon;
+ (NSScreen*) screenWithPoint: (NSPoint) p;
+ (NSRect)cocoaScreenFrameFromCarbonScreenFrame:(CGRect)carbonPoint;
+ (CGPoint)carbonScreenPointFromCocoaScreenPoint:(NSPoint)cocoaPoint;

@end
