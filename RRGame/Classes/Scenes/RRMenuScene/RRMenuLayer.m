//
//  UDMenuLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "RRMenuLayer.h"
#import "UDSpriteButton.h"
#import "RRPickColorScene.h"
#import "RRRulesScene.h"


@implementation RRMenuLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundMenu~ipad.png":@"RRBackgroundMenu.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add buttons
        UDSpriteButton *buttonPlayers1 = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonPlayers1.png" highliteSpriteFrameName:@"RRButtonPlayers1Selected.png"];
        [buttonPlayers1 addBlock: ^{ [self startGameWithNumberOfPlayers:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonPlayers1];

        UDSpriteButton *buttonPlayers2 = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonPlayers2.png" highliteSpriteFrameName:@"RRButtonPlayers2Selected.png"];
        [buttonPlayers2 addBlock: ^{ [self startGameWithNumberOfPlayers:2]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonPlayers2];
        
        
        UDSpriteButton *buttonRules = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonHowToPlay.png" highliteSpriteFrameName:@"RRButtonHowToPlaySelected.png"];
        [buttonRules addBlock: ^{ [self showRules]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonRules];
        
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonPlayers1 setPosition:CGPointMake(winSize.width /2, 540)];
            [buttonPlayers2 setPosition:CGPointMake(winSize.width /2, 465)];
            
            [buttonRules setPosition:CGPointMake(winSize.width /2, 345)];
        }else{
            [buttonPlayers1 setPosition:CGPointMake(winSize.width /2, 250)];
            [buttonPlayers2 setPosition:CGPointMake(winSize.width /2, 215)];
            
            [buttonRules setPosition:CGPointMake(winSize.width /2, 178)];
        }
        
    }
    return self;
}


#pragma mark -
#pragma mark UDMenuLayer


- (void)startGameWithNumberOfPlayers:(NSUInteger)numberOfPlayers {

    RRPickColorScene *pickColorScene = [[RRPickColorScene alloc] initWithNumberOfPlayers:numberOfPlayers];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:pickColorScene]];
    [pickColorScene release];
    
}


- (void)showRules {
    
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRRulesScene node]]];

}


@end
