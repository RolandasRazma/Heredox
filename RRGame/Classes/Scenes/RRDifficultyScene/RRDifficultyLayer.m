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
#import "RRAIPlayer.h"
#import "RRGameScene.h"
#import "RRTransitionGame.h"


@implementation RRDifficultyLayer


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
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundDifficulty~ipad.png":@"RRBackgroundDifficulty.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonBack.png" highliteSpriteFrameName:@"RRButtonBackSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        
        
        // Add start game button
        UDSpriteButton *buttonStartGame = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonStartGame.png" highliteSpriteFrameName:@"RRButtonStartGameSelected.png"];
        [buttonStartGame addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self startGame]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonStartGame];
     
        
        // Dificulty buttons
        _buttonNovice = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAILevelNovice.png" highliteSpriteFrameName:@"RRButtonAILevelNoviceSelected.png"];
        [_buttonNovice addBlock: ^{ [self setDificultyLevel:RRAILevelNovice]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonNovice];
        
        _buttonDeacon = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAILevelDeacon.png" highliteSpriteFrameName:@"RRButtonAILevelDeaconSelected.png"];
        [_buttonDeacon addBlock: ^{ [self setDificultyLevel:RRAILevelDeacon]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonDeacon];
        
        _buttonAbbot = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAILevelAbbot.png" highliteSpriteFrameName:@"RRButtonAILevelAbbotSelected.png"];
        [_buttonAbbot addBlock: ^{ [self setDificultyLevel:RRAILevelAbbot]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonAbbot];
        
        [self setDificultyLevel: [[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"]];

        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
            [buttonStartGame setPosition:CGPointMake(winSize.width /2, 100)];
            
            [_buttonNovice setPosition:CGPointMake(180, 460)];
            [_buttonDeacon setPosition:CGPointMake(winSize.width /2, 445)];
            [_buttonAbbot setPosition:CGPointMake(620, 445)];
        }else{
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
            
            [buttonStartGame setPosition:CGPointMake(winSize.width /2, 45)];
            
            [_buttonNovice setPosition:CGPointMake(75, 210)];
            [_buttonNovice setScale:0.9f];
            
            [_buttonDeacon setPosition:CGPointMake(winSize.width /2, 205)];
            [_buttonDeacon setScale:0.9f];
            
            [_buttonAbbot setPosition:CGPointMake(265, 205)];
            [_buttonAbbot setScale:0.9f];
        }
    }
    return self;
}


- (void)showMenu {

    RRPickColorScene *pickColorScene = [[RRPickColorScene alloc] initWithNumberOfPlayers:1];
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionWithDuration:0.7f scene:pickColorScene backwards:YES]];
    [pickColorScene release];

}


- (void)setDificultyLevel:(RRAILevel)dificultyLevel {
    NSUInteger oldDificultyLevel = [[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"];

    if( oldDificultyLevel != dificultyLevel ){
        [[RRAudioEngine sharedEngine] stopEffect:[NSString stringWithFormat:@"RRAILevel%i.mp3", oldDificultyLevel]];
        [[RRAudioEngine sharedEngine] replayEffect:[NSString stringWithFormat:@"RRAILevel%i.mp3", dificultyLevel]];
    }
    
    [_buttonNovice setSelected:(dificultyLevel==RRAILevelNovice)];
    [_buttonDeacon setSelected:(dificultyLevel==RRAILevelDeacon)];
    [_buttonAbbot setSelected: (dificultyLevel==RRAILevelAbbot)];
    
    [[NSUserDefaults standardUserDefaults] setInteger:dificultyLevel forKey:@"RRHeredoxAILevel"];
}


- (void)startGame {

    RRGameScene *gameScene = [[RRGameScene alloc] initWithGameMode:RRGameModeClosed numberOfPlayers:1 playerColor:_playerColor];
    [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionWithDuration:0.7f scene:gameScene]];
    [gameScene release];
    
}


@end
