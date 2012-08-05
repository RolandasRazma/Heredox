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
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundPlayerColor~ipad.png":@"RRBackgroundPlayerColor.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite];

        
        CCSprite *titleTextSprite = [CCSprite spriteWithSpriteFrameName:((numberOfPlayers==1)?@"RRTextChooseYourAllegiance.png":@"RRTextWhoMakesTheFirstMove.png")];
        [self addChild:titleTextSprite];
        
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
        
        CGFloat leftBottomY;    // From bottom
        CGFloat rightTopY;      // From top
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
            [titleTextSprite setPosition:CGPointMake(315, 920)];

            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake(165, 702)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(594, 185)];
            
            leftBottomY = 210;
            rightTopY   = 400;
        }else{
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
            [titleTextSprite setPosition:CGPointMake(130, 435)];
            [titleTextSprite setScale:0.9f];
            
            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake(63, 326)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(242, 93)];
            
            leftBottomY = 100;
            rightTopY   = 200;
        }
        
        _upperRect     = CGRectMake(0, winSize.height -rightTopY, winSize.width, rightTopY);
        _upperTriangle = UDTriangleMake( CGPointMake(0, leftBottomY), CGPointMake(winSize.width, winSize.height -rightTopY), CGPointMake(0, winSize.height -rightTopY) );
        
        _lowerRect     = CGRectMake(0, 0, winSize.width, leftBottomY);
        _lowerTriangle = UDTriangleMake( CGPointMake(0, leftBottomY), CGPointMake(winSize.width, leftBottomY), CGPointMake(winSize.width, winSize.height -rightTopY) );
    }
    return self;
}


- (void)startGameWithFirstPlayerColor:(RRPlayerColor)playerColor {

    [[RRHeredox sharedInstance] playEffect: [NSString stringWithFormat:@"RRPlayerColor%u.mp3", playerColor]];
    
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

    [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
    [_backgroundPlayerBlackSelectedSprite setVisible:NO];
}


@end
