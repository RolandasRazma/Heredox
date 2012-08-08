//
//  UDMenuScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "RRMenuScene.h"
#import "RRMenuLayer.h"


@implementation RRMenuScene


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self addChild: [RRMenuLayer node]];
    }
    return self;
}


@end
