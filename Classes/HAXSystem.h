// HAXSystem.h
// Created by Rob Rix on 2011-01-06
// Copyright 2011 Rob Rix

#import "HAXElement.h"

@class HAXApplication;

@interface HAXSystem : HAXElement

+(instancetype)system;

@property (nonatomic, readonly) HAXApplication *focusedApplication;

@end
