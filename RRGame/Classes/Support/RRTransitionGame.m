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
        [[RRHeredox sharedInstance] playEffect:@"RRSceneTransitionBack.mp3"];
    }else{
        [[RRHeredox sharedInstance] playEffect:@"RRSceneTransition.mp3"];
    }
    
	[super onEnter];
}

@end
