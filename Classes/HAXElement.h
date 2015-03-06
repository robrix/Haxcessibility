// HAXElement.h
// Created by Rob Rix on 2011-01-06
// Copyright 2011 Rob Rix

#import <Foundation/Foundation.h>

@protocol HAXElementDelegate;

@interface HAXElement : NSObject

@property (nonatomic, weak) id<HAXElementDelegate> delegate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *role;
@property (nonatomic, readonly) BOOL hasChildren;
@property (nonatomic, readonly) NSArray *children;
@property (nonatomic, readonly) NSArray *attributeNames;

-(bool)isEqualToElement:(HAXElement *)other;
-(NSArray *) buttons;

@end

@protocol HAXElementDelegate <NSObject>

@optional
-(void)elementWasDestroyed:(HAXElement *)element;

@end
