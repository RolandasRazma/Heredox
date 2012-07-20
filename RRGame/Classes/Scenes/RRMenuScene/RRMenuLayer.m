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
#import "RROptionsScene.h"
#import "RRAboutScene.h"


@implementation RRMenuLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:(isDeviceIPad()?@"Default-Portrait~ipad.png":@"Default.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add buttons
        UDSpriteButton *buttonPlayers1 = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonPlayers1.png"];
        [buttonPlayers1 addBlock: ^{ [self startGameWithNumberOfPlayers:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonPlayers1];

        UDSpriteButton *buttonPlayers2 = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonPlayers2.png"];
        [buttonPlayers2 addBlock: ^{ [self startGameWithNumberOfPlayers:2]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonPlayers2];
        
        
        UDSpriteButton *buttonRules = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonRules.png"];
        [buttonRules addBlock: ^{ [self showRules]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonRules];
        
        UDSpriteButton *buttonOptions = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonOptions.png"];
        [buttonOptions addBlock: ^{ [self showOptions]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonOptions];

        UDSpriteButton *buttonAbout = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonAbout.png"];
        [buttonAbout addBlock: ^{ [self showAbout]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonAbout];

        
        // Device layout
        if( isDeviceIPad() ){
            [buttonPlayers1 setPosition:CGPointMake(winSize.width /2, 535)];
            [buttonPlayers2 setPosition:CGPointMake(winSize.width /2, 465)];
            
            [buttonRules setPosition:CGPointMake(winSize.width /2, 360)];
            [buttonOptions setPosition:CGPointMake(winSize.width /2, 280)];
            [buttonAbout setPosition:CGPointMake(winSize.width /2, 210)];
        }else{
            [buttonPlayers1 setPosition:CGPointMake(winSize.width /2, 250)];
            [buttonPlayers2 setPosition:CGPointMake(winSize.width /2, 215)];
            
            [buttonRules setPosition:CGPointMake(winSize.width /2, 165)];
            [buttonOptions setPosition:CGPointMake(winSize.width /2, 128)];
            [buttonAbout setPosition:CGPointMake(winSize.width /2, 95)];
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


- (void)showOptions {

    [[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RROptionsScene node]]];
    
}


- (void)showAbout {
    
    [[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRAboutScene node]]];
    
}


@end
