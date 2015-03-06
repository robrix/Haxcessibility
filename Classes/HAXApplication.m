// HAXApplication.m
// Created by Rob Rix on 2011-01-06
// Copyright 2011 Rob Rix

#import "HAXApplication.h"
#import "HAXElement+Protected.h"
#import "HAXWindow.h"

@implementation HAXApplication

+(instancetype)applicationWithPID:(pid_t)pid {
	AXUIElementRef app = AXUIElementCreateApplication(pid);
	id result = nil;
	if (app) {
		result = [self elementWithElementRef:app];
		CFRelease(app);
	}
	return result;
}

-(HAXWindow *)focusedWindow {
	return [self elementOfClass:[HAXWindow class] forKey:(NSString *)kAXFocusedWindowAttribute error:nil];
}

-(NSArray *)windows {
	NSArray *axWindowObjects = [self getAttributeValueForKey:(NSString *)kAXWindowsAttribute error:nil];
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:[axWindowObjects count]];
	for (id axObject in axWindowObjects) {
		[result addObject:[HAXWindow elementWithElementRef:(AXUIElementRef)axObject]];
	}
	return result;
}

-(NSString *)localizedName {
	return [self getAttributeValueForKey:(NSString *)kAXTitleAttribute error:NULL];
}

-(pid_t)processIdentifier {
	pid_t processIdentifier = 0;
	AXUIElementGetPid(self.elementRef, &processIdentifier);
	return processIdentifier;
}

@end
