//
//  RRAboutScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRAboutScene.h"
#import "RRAboutLayer.h"


@implementation RRAboutScene

#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self addChild:[RRAboutLayer node]];
    }
    return self;
}

@end
