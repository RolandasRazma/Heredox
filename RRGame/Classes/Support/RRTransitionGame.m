//
//  RRTransitionGame.m
//  RRHeredox
//
//  Created by Rolandas Razma on 08/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRTransitionGame.h"


@implementation RRTransitionGame

- (void)onEnter {
	if( back_ ){
        [[RRAudioEngine sharedEngine] replayEffect:@"RRSceneTransitionBack.mp3"];
    }else{
        [[RRAudioEngine sharedEngine] replayEffect:@"RRSceneTransition.mp3"];
    }
    
	[super onEnter];
}

@end
