//
//  RRTransitionGame.m
//  RRHeredox
//
//  Created by Rolandas Razma on 08/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRTransitionGame.h"


@implementation RRTransitionGame


#pragma mark -
#pragma mark RRTransitionGame


+ (id)transitionToScene:(CCScene *)scene {
    return [[[self alloc] initWithDuration:0.7f scene:scene backwards:NO] autorelease];
}


+ (id)transitionToScene:(CCScene *)scene backwards:(BOOL)backwards {
    return [[[self alloc] initWithDuration:0.7f scene:scene backwards:backwards] autorelease];
}


#pragma mark -
#pragma mark CCNode


- (void)onEnter {
	if( back_ ){
        [[RRAudioEngine sharedEngine] replayEffect:@"RRSceneTransitionBack.mp3"];
    }else{
        [[RRAudioEngine sharedEngine] replayEffect:@"RRSceneTransition.mp3"];
    }
    
	[super onEnter];
}


@end
