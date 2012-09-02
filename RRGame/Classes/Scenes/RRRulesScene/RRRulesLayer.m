//
//  RRRulesLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRRulesLayer.h"
#import "RRMenuScene.h"


@implementation RRRulesLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundRules~ipad.png":@"RRBackgroundRules.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMenu.png" highliteSpriteFrameName:@"RRButtonMenuSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonHome];
        
        // Add WWW button
        UDSpriteButton *buttonWWW = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonWWW.png" highliteSpriteFrameName:@"RRButtonWWWSelected.png"];
        [buttonWWW addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self goToWWW]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonWWW];
        
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
            [buttonWWW setPosition:CGPointMake(winSize.width /2, 155)];
        }else{
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
            
            [buttonWWW setPosition:CGPointMake(winSize.width /2, 70)];
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark RRRulesLayer


- (void)showMenu {
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:[RRMenuScene node] backwards:YES]];
}


- (void)goToWWW {
    
#ifdef __CC_PLATFORM_IOS
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:@"http://www.clockworkquartet.com/"]];
#elif defined(__CC_PLATFORM_MAC)
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.clockworkquartet.com/"]];
#endif
    
}


@end
