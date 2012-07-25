//
//  UDPickColorLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRPickColorLayer.h"
#import "UDSpriteButton.h"
#import "RRGameScene.h"
#import "RRMenuScene.h"
#import "RRDifficultyScene.h"


@implementation RRPickColorLayer {
    NSUInteger _numberOfPlayers;
    
    CGRect     _upperRect;
    UDTriangle _upperTriangle;
    CGRect     _lowerRect;
    UDTriangle _lowerTriangle;
    
    CCSprite    *_backgroundPlayerWhiteSelectedSprite;
    CCSprite    *_backgroundPlayerBlackSelectedSprite;
}


#pragma mark -
#pragma mark UDPickColorLayer


+ (id)layerWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    return [[[self alloc] initWithNumberOfPlayers:numberOfPlayers] autorelease];
}


- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    if( (self = [self init]) ){
        [self setUserInteractionEnabled:YES];
        
        _numberOfPlayers = numberOfPlayers;

        CGSize winSize = [[CCDirector sharedDirector] winSize];

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:(isDeviceIPad()?@"RRBackgroundPlayerColor~ipad.png":@"RRBackgroundPlayerColor.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];

        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMenu.png" highliteSpriteFrameName:@"RRButtonMenuSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        
        
        // Selected images
        _backgroundPlayerWhiteSelectedSprite = [CCSprite spriteWithSpriteFrameName:@"RRBackgroundPlayerWhiteSelected.png"];
        [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
        [self addChild:_backgroundPlayerWhiteSelectedSprite];
        
        _backgroundPlayerBlackSelectedSprite = [CCSprite spriteWithSpriteFrameName:@"RRBackgroundPlayerBlackSelected.png"];
        [_backgroundPlayerBlackSelectedSprite setVisible:NO];
        [self addChild:_backgroundPlayerBlackSelectedSprite];
        

        // Device layout
        if( isDeviceIPad() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
            
            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake(165, 702)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(594, 185)];
            
            _upperRect     = CGRectMake(0, winSize.height -400, winSize.width, 400);
            _upperTriangle = UDTriangleMake( CGPointMake(0, 210), CGPointMake(winSize.width, winSize.height -400), CGPointMake(0, winSize.height -400) );
            
            _lowerRect     = CGRectMake(0, 0, winSize.width, 210);
            _lowerTriangle = UDTriangleMake( CGPointMake(0, 210), CGPointMake(winSize.width, 210), CGPointMake(winSize.width, winSize.height -400) );
        }else{

        }
    }
    return self;
}


- (void)startGameWithFirstPlayerColor:(RRPlayerColor)playerColor {
 
    if( _numberOfPlayers == 1 ){
        RRDifficultyScene *difficultyScene = [[RRDifficultyScene alloc] initWithGameMode:RRGameModeClosed playerColor:playerColor];
        [[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:difficultyScene]];
        [difficultyScene release];
    }else{
        RRGameScene *gameScene = [[RRGameScene alloc] initWithGameMode:RRGameModeClosed numberOfPlayers:_numberOfPlayers firstPlayerColor:playerColor];
        [[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:gameScene]];
        [gameScene release];
    }
    
}


- (void)showMenu {
    
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
    
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    [self touchMovedToLocation:location];
    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
    [_backgroundPlayerBlackSelectedSprite setVisible:NO];
    
    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [_backgroundPlayerWhiteSelectedSprite setVisible:YES];
    }else if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [_backgroundPlayerBlackSelectedSprite setVisible:YES];
    }
    
}


- (void)touchEndedAtLocation:(CGPoint)location {

    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [self startGameWithFirstPlayerColor: RRPlayerColorWhite];
        return;
    }
    if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [self startGameWithFirstPlayerColor: RRPlayerColorBlack];
        return;
    }

}


@end
