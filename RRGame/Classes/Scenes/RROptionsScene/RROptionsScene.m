//
//  RROptionsScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RROptionsScene.h"
#import "RROptionsLayer.h"


@implementation RROptionsScene

#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self addChild:[RROptionsLayer node]];
    }
    return self;
}

@end
