//
//  UDPickColorLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDPickColorLayer.h"
#import "UDSpriteButton.h"
#import "UDGameScene.h"


@implementation UDPickColorLayer {
    NSUInteger _numberOfPlayers;
}


#pragma mark -
#pragma mark UDPickColorLayer


+ (id)layerWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    return [[[self alloc] initWithNumberOfPlayers:numberOfPlayers] autorelease];
}


- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    if( (self = [self init]) ){
        _numberOfPlayers = numberOfPlayers;
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"UDBackground.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add buttons
        UDSpriteButton *buttonColorWhite = [UDSpriteButton spriteWithSpriteFrameName:@"UDTileWhite.png"];
        [buttonColorWhite setScale: 0.5f];
        [buttonColorWhite addBlock: ^{ [self startGameWithFirstPlayerColor:UDPlayerColorWhite]; } forControlEvents: UDButtonEventTouchUpInside];
        [buttonColorWhite setPosition:CGPointMake(110, 300)];
        [self addChild:buttonColorWhite];
        
        UDSpriteButton *buttonColorBlack = [UDSpriteButton spriteWithSpriteFrameName:@"UDTileBlack.png"];
        [buttonColorBlack setScale: 0.5f];
        [buttonColorBlack addBlock: ^{ [self startGameWithFirstPlayerColor:UDPlayerColorBlack]; } forControlEvents: UDButtonEventTouchUpInside];
        [buttonColorBlack setPosition:CGPointMake(210, 300)];
        [self addChild:buttonColorBlack];
        
        if( isDeviceIPad() ){
            [buttonColorWhite setPosition:CGPointMake(210, 600)];
            [buttonColorBlack setPosition:CGPointMake(410, 600)];
        }
    }
    return self;
}


- (void)startGameWithFirstPlayerColor:(UDPlayerColor)playerColor {
 
    UDGameScene *gameScene = [[UDGameScene alloc] initWithGameMode:UDGameModeClosed numberOfPlayers:_numberOfPlayers firstPlayerColor:playerColor];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInR transitionWithDuration:0.7f scene:gameScene]];
    [gameScene release];
    
}


@end
