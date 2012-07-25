//
//  RRDifficultyLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/25/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRDifficultyLayer.h"
#import "UDSpriteButton.h"
#import "RRPickColorScene.h"


@implementation RRDifficultyLayer {
    RRGameMode      _gameMode;
    RRPlayerColor   _playerColor;
}


#pragma mark -
#pragma mark RRDifficultyLayer


+ (id)layerWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)playerColor {
    return [[[self alloc] initWithGameMode:gameMode playerColor:playerColor] autorelease];
}


- (id)initWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)playerColor {
    if( (self = [super init]) ){
        _gameMode       = gameMode;
        _playerColor    = playerColor;
    
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:(isDeviceIPad()?@"RRBackgroundDifficulty~ipad.png":@"RRBackgroundDifficulty.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMenu.png" highliteSpriteFrameName:@"RRButtonMenuSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
     
        // Device layout
        if( isDeviceIPad() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
        }else{
            
        }
    }
    return self;
}


- (void)showMenu {
    
    RRPickColorScene *pickColorScene = [[RRPickColorScene alloc] initWithNumberOfPlayers:1];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:pickColorScene backwards:YES]];
    [pickColorScene release];
    
}


@end
