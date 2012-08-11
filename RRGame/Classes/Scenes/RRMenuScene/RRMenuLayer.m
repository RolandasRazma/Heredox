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
#import "RRTransitionGame.h"


@implementation RRMenuLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundMenu~ipad.png":@"RRBackgroundMenu.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add buttons
        UDSpriteButton *buttonPlayers1 = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonPlayers1.png" highliteSpriteFrameName:@"RRButtonPlayers1Selected.png"];
        [buttonPlayers1 addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self startGameWithNumberOfPlayers:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonPlayers1];

        UDSpriteButton *buttonPlayers2 = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonPlayers2.png" highliteSpriteFrameName:@"RRButtonPlayers2Selected.png"];
        [buttonPlayers2 addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self pickMultiplayerType]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonPlayers2];
        
        
        UDSpriteButton *buttonRules = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonHowToPlay.png" highliteSpriteFrameName:@"RRButtonHowToPlaySelected.png"];
        [buttonRules addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showRules]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonRules];
        
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonPlayers1 setPosition:CGPointMake(460, 505)];
            [buttonPlayers2 setPosition:CGPointMake(460, 400)];
            
            [buttonRules setPosition:CGPointMake(460, 240)];
        }else{
            [buttonPlayers1 setPosition:CGPointMake(195, 240)];
            [buttonPlayers1 setScale:0.8f];
            
            [buttonPlayers2 setPosition:CGPointMake(195, 185)];
            [buttonPlayers2 setScale:0.8f];
            
            [buttonRules setPosition:CGPointMake(195, 115)];
            [buttonRules setScale:0.8f];
        }
        
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    if( isGameCenterAvailable() ){
        if ( [[GKLocalPlayer localPlayer] isAuthenticated] == NO ) {
            [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:NULL];
        }
    }
}


#pragma mark -
#pragma mark UDMenuLayer


- (void)pickMultiplayerType {
    RRMenuMultiplayerLayer *menuMultiplayerLayer = [RRMenuMultiplayerLayer node];
    [menuMultiplayerLayer setDelegate: self];
    [self addChild:menuMultiplayerLayer];
    
    [self startGameWithNumberOfPlayers:2];
}


- (void)startGameWithNumberOfPlayers:(NSUInteger)numberOfPlayers {

    RRPickColorScene *pickColorScene = [[RRPickColorScene alloc] initWithNumberOfPlayers:numberOfPlayers];
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionWithDuration:0.7f scene:pickColorScene]];
    [pickColorScene release];
    
}


- (void)showRules {
    
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionWithDuration:0.7f scene:[RRRulesScene node]]];

}


@end
