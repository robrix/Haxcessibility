// HAXElement.m
// Created by Rob Rix on 2011-01-06
// Copyright 2011 Rob Rix

#import "HAXElement+Protected.h"
#import "HAXButton.h"
@interface HAXElement ()
@property (nonatomic, strong) AXObserverRef observer __attribute__((NSObject));
@end

@implementation HAXElement

@synthesize elementRef = _elementRef;
-(BOOL)hasChildren
{
    NSError * error = nil;
    NSArray * result = nil;
    result = CFBridgingRelease([self copyAttributeValueForKey:(__bridge NSString *)kAXChildrenAttribute error:&error]);
    if (error || result == nil)
    {
        NSLog(@"role getter:: %@", [error debugDescription]);
        result = nil;
    }
	return result ? [result count] : NO;

}
-(NSArray *)children
{
    NSError * error = nil;
    NSArray * axUIElements = nil;
    axUIElements = CFBridgingRelease([self copyAttributeValueForKey:(__bridge NSString *)kAXChildrenAttribute error:&error]);
    if (error)
    {
        NSLog(@"childrenElementRefs getter:: %@", [error debugDescription]);
        
        axUIElements = nil;
    }
    NSMutableArray * result = [NSMutableArray arrayWithCapacity:[axUIElements count]];
    for (id elementI in axUIElements)
    {
        [result addObject:[HAXElement  elementWithElementRef:(AXUIElementRef)(elementI) ]];
    }
    return result;
}
-(NSString *)role
{
    NSError * error = nil;
    NSString * result = nil;
    result = CFBridgingRelease([self copyAttributeValueForKey:(__bridge NSString *)kAXRoleAttribute error:&error]);
    if (error || result == nil || [result isKindOfClass:[NSString class]] == NO )
    {
        NSLog(@"role getter:: %@", [error debugDescription]);
        result = nil;
    }
    return result;

}
-(NSArray *) buttons
{
	NSArray *axChildren = self.children;
    NSMutableArray *result = [NSMutableArray array];
    
    NSString * axRole;
    for (HAXElement * haxElementI in axChildren)
    {
        axRole = [haxElementI copyAttributeValueForKey:(__bridge NSString *)kAXRoleAttribute error:NULL];
        if ([axRole isEqualToString:(__bridge NSString *)kAXButtonRole])
        {
            HAXButton * haxView = [HAXButton elementWithElementRef:(AXUIElementRef)haxElementI.elementRef];
            [result addObject:haxView];
        }
    }
	return [result count] ? result : nil;
}

-(NSString *)title
{
    NSError * error = nil;
    NSString * result = nil;
    result = CFBridgingRelease([self copyAttributeValueForKey:NSAccessibilityTitleAttribute error:&error]);
    if (error || result == nil || [result isKindOfClass:[NSString class]] == NO )
    {
        NSLog(@"title getter:: %@", [error debugDescription]);
        result = nil;
    }
    return result;
}
-(NSArray *)attributeNames
{
    __block CFArrayRef attrNamesRef = NULL;
    NSArray *attrNames = nil;
    if ([NSThread isMainThread])
    {
        AXUIElementCopyAttributeNames(_elementRef, &attrNamesRef);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          AXUIElementCopyAttributeNames(_elementRef, &attrNamesRef);
                      });
    }
    attrNames = CFBridgingRelease(attrNamesRef);
    return attrNames;
}

+(instancetype)elementWithElementRef:(AXUIElementRef)elementRef
{
	return [[self alloc] initWithElementRef:elementRef];
}

-(instancetype)initWithElementRef:(AXUIElementRef)elementRef {
	if((self = [super init])) {
		_elementRef = CFRetain(elementRef);
	}
	return self;
}

-(void)dealloc {
	if (_observer) {
		[self removeAXObserver];
	}
	if (_elementRef) {
		CFRelease(_elementRef);
		_elementRef = NULL;
	}
}


-(bool)isEqualToElement:(HAXElement *)other {
	return
		[other isKindOfClass:self.class]
	&&	CFEqual(self.elementRef, other.elementRef);
}

-(BOOL)isEqual:(id)object {
	return [self isEqualToElement:object];
}

-(NSUInteger)hash {
	return CFHash(self.elementRef);
}


- (void)setDelegate:(id<HAXElementDelegate>)delegate;
{
	if (delegate && !_observer) {
		[self addAXObserver];
	}
	_delegate = delegate;
}


-(CFTypeRef)copyAttributeValueForKey:(NSString *)key error:(NSError **)error
{
	NSParameterAssert(key != nil);
	__block CFTypeRef attributeRef = NULL;
    __block AXError result = 0;
    if ([NSThread isMainThread])
    {
        result = AXUIElementCopyAttributeValue(self.elementRef, (__bridge CFStringRef)key, &attributeRef);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          result = AXUIElementCopyAttributeValue(self.elementRef, (__bridge CFStringRef)key, &attributeRef);
                      });
    }
	if((result != kAXErrorSuccess) && error) {
		*error = [NSError errorWithDomain:NSStringFromClass(self.class) code:result userInfo:@{
			@"key": key,
			@"elementRef": (id)self.elementRef}
		];
	}
	return attributeRef;
}

-(bool)setAttributeValue:(CFTypeRef)value forKey:(NSString *)key error:(NSError **)error
{
	NSParameterAssert(value != nil);
	NSParameterAssert(key != nil);
	__block AXError result = 0;
    if ([NSThread isMainThread])
    {
        AXUIElementSetAttributeValue(self.elementRef, (__bridge CFStringRef)key, value);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          AXUIElementSetAttributeValue(self.elementRef, (__bridge CFStringRef)key, value);
                      });
    }
	
    if((result != kAXErrorSuccess) && error) {
		*error = [NSError errorWithDomain:NSStringFromClass(self.class) code:result userInfo:@{
			@"key": key,
			@"elementRef": (id)self.elementRef
		}];
	}
	return result == kAXErrorSuccess;
}

-(bool)performAction:(NSString *)action error:(NSError **)error
{
	NSParameterAssert(action != nil);
	__block AXError result = 0;
    if ([NSThread isMainThread])
    {
        AXUIElementPerformAction(self.elementRef, (__bridge CFStringRef)action);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          AXUIElementPerformAction(self.elementRef, (__bridge CFStringRef)action);
                      });
    }
    
	
    if ((result != kAXErrorSuccess) && error)
    {
		*error = [NSError errorWithDomain:NSStringFromClass(self.class) code:result userInfo:@{
			@"action": action,
			@"elementRef": (id)self.elementRef
		}];
	}

	return result == kAXErrorSuccess;
}


-(id)elementOfClass:(Class)klass forKey:(NSString *)key error:(NSError **)error
{
	AXUIElementRef subelementRef = (AXUIElementRef)[self copyAttributeValueForKey:key error:error];
	id result = nil;
	if (subelementRef)
    {
		result = [klass elementWithElementRef:subelementRef];
		CFRelease(subelementRef);
		subelementRef = NULL;
	}
	return result;
}


-(void)addAXObserver
{
	if (self.observer) { return; }
	
	__block AXObserverRef observer = NULL;
	__block AXError err = 0;
	__block pid_t pid = 0;
    
    if ([NSThread isMainThread])
    {
        err = AXUIElementGetPid(self.elementRef, &pid);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          err = AXUIElementGetPid(self.elementRef, &pid);
                      });
    }
    if (err != kAXErrorSuccess) { return; }
    
    if ([NSThread isMainThread])
    {
        err = AXObserverCreate(pid, axCallback, &observer);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          err = AXObserverCreate(pid, axCallback, &observer);
                      });
    }
	
    if (err != kAXErrorSuccess) { return; }
    if ([NSThread isMainThread])
    {
        err = AXObserverAddNotification(observer, self.elementRef, kAXUIElementDestroyedNotification, (__bridge void *)(self));
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          err = AXObserverAddNotification(observer, self.elementRef, kAXUIElementDestroyedNotification, (__bridge void *)(self));
                      });
    }

	if (err != kAXErrorSuccess) {
		CFRelease(observer);
		observer = NULL;
		return;
	}
    if ([NSThread isMainThread])
    {
         err = AXObserverAddNotification(observer, self.elementRef, kAXUIElementDestroyedNotification, (__bridge void *)(self));
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          err = AXObserverAddNotification(observer, self.elementRef, kAXUIElementDestroyedNotification, (__bridge void *)(self));
                      });
    }
    
	if (err != kAXErrorSuccess) {
		CFRelease(observer);
		observer = NULL;
		return;
	}
    if ([NSThread isMainThread])
    {
        CFRunLoopAddSource([[NSRunLoop mainRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), ^
                      {
                          CFRunLoopAddSource([[NSRunLoop mainRunLoop] getCFRunLoop], AXObserverGetRunLoopSource(observer), kCFRunLoopDefaultMode);
                      });
    }
    
    
	self.observer = observer;
	CFRelease(observer);
}

static void axCallback(AXObserverRef observer, AXUIElementRef element, CFStringRef notification, void *refcon)
{
	[(__bridge HAXElement *)refcon didObserveNotification:(__bridge NSString *)notification];
}

-(void)didObserveNotification:(NSString *)notification
{
	id<HAXElementDelegate> delegate = self.delegate;
	
	if ([notification isEqualToString:(__bridge NSString *)kAXUIElementDestroyedNotification] && [delegate respondsToSelector:@selector(elementWasDestroyed:)])
    {
		[delegate elementWasDestroyed:self];
	}
}

-(void)removeAXObserver
{
	if (!self.observer) { return; }
	
	(void)AXObserverRemoveNotification(self.observer, self.elementRef, kAXUIElementDestroyedNotification);
	
	CFRunLoopSourceRef observerRunLoopSource = AXObserverGetRunLoopSource(self.observer);
	if (observerRunLoopSource) {
		CFRunLoopRemoveSource([[NSRunLoop mainRunLoop] getCFRunLoop], observerRunLoopSource, kCFRunLoopDefaultMode);
	}
	
	self.observer = NULL;
}

@end
