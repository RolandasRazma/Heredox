//
//  RRDefaultScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/20/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRDefaultScene.h"
#import "RRDefaultLayer.h"


@implementation RRDefaultScene


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self addChild: [RRDefaultLayer node]];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onEnter {
    [super onEnter];

    [[RRAudioEngine sharedEngine] replayEffect:@"RRDefaultScene.mp3"];
}


@end
