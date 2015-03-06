// HAXWindow.h
// Created by Rob Rix on 2011-01-06
// Copyright 2011 Rob Rix

#import <Cocoa/Cocoa.h>
#import <Haxcessibility/HAXElement.h>

@interface HAXWindow : HAXElement

@property (nonatomic, assign) CGPoint carbonOrigin;
@property (nonatomic, assign, readonly) NSPoint origin;
@property (nonatomic, assign) NSSize size;
@property (nonatomic, assign) CGRect frameCarbon;
@property (nonatomic, assign, readonly) NSRect frame;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSScreen *screen;
@property (nonatomic, readonly) NSArray *views;

-(BOOL)isFullscreen;
-(BOOL)isFullscreenWithEpsilon: (unsigned int) epsilon;
-(bool)raise;
-(bool)close;

@end
