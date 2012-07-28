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
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:(isDeviceIPad()?@"RRBackgroundRules~ipad.png":@"RRBackgroundRules.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMenu.png" highliteSpriteFrameName:@"RRButtonMenuSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        
        // Add WWW button
        UDSpriteButton *buttonWWW = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonWWW.png" highliteSpriteFrameName:@"RRButtonWWWSelected.png"];
        [buttonWWW addBlock: ^{ [self goToWWW]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonWWW];
        
        
        // Device layout
        if( isDeviceIPad() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
            [buttonWWW setPosition:CGPointMake(winSize.width /2, 160)];
        }else{

        }
    }
    
    return self;
}


#pragma mark -
#pragma mark RRRulesLayer


- (void)showMenu {
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
}


- (void)goToWWW {
    
#ifdef __CC_PLATFORM_IOS
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://heredox.com/"]];
#elif defined(__CC_PLATFORM_MAC)
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://heredox.com/"]];
#endif
    
}


@end
