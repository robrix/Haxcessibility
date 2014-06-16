//
//  HAXView.h
//  Sopreso
//
//  Created by Kocsis Olivér on 2014.05.12..
//  Copyright (c) 2014 Joinect Technologies. All rights reserved.
//

#import "HAXElement.h"

@interface HAXView : HAXElement
@property (nonatomic, assign) CGPoint originCarbon;
@property (nonatomic, assign, readonly) CGPoint originCocoa;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGRect frameCarbon;
@property (nonatomic, assign, readonly) CGRect frameCocoa;

@property (nonatomic, readonly) NSString *title;

@property (nonatomic, readonly) NSScreen *screen;

-(BOOL)isFullscreen;


@end
