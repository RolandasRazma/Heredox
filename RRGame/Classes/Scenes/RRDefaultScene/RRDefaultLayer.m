//
//  RRDefaultLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/20/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRDefaultLayer.h"
#import "RRMenuScene.h"


@implementation RRDefaultLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"Default-Portrait~ipad.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onEnterTransitionDidFinish { 
    [super onEnterTransitionDidFinish];
    [self performSelector:@selector(loadAssets) withObject:nil afterDelay:0.1f];
}


#pragma mark -
#pragma mark RRDefaultLayer


- (void)loadAssets {

    // Load Textures
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"textures.plist"];
    
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node]]];
    
}


@end
