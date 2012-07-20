//
//  RRRulesLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRRulesLayer.h"
#import "UDSpriteButton.h"
#import "RRMenuScene.h"


@implementation RRRulesLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:(isDeviceIPad()?@"RRBackground~ipad.png":@"RRBackground.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonCherubHome.png"];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        
        
        // Device layout
        if( isDeviceIPad() ){
            [buttonHome setPosition:CGPointMake(winSize.width -135, winSize.height -90)];
        }else{
            [buttonHome setScale:0.8f];
            [buttonHome setPosition:CGPointMake(winSize.width -60, winSize.height -40)];
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark RRRulesLayer


- (void)showMenu {
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
}


@end
