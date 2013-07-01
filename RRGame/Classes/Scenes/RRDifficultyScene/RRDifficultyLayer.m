//
//  RRDifficultyLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/25/12.
//
//  Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "RRDifficultyLayer.h"
#import "RRPickColorScene.h"
#import "RRAIPlayer.h"
#import "RRGameScene.h"


@implementation RRDifficultyLayer


#pragma mark -
#pragma mark RRDifficultyLayer


+ (id)layerWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)playerColor {
    return [[self alloc] initWithGameMode:gameMode playerColor:playerColor];
}


- (id)initWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)playerColor {
    if( (self = [super init]) ){
        _gameMode       = gameMode;
        _playerColor    = playerColor;
    
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((IS_IPAD||IS_MAC)?@"RRBackgroundDifficulty~ipad.png":@"RRBackgroundDifficulty.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonBack.png" highliteSpriteFrameName:@"RRButtonBackSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonHome];
        
        
        // Add start game button
        UDSpriteButton *buttonStartGame = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonStartGame.png" highliteSpriteFrameName:@"RRButtonStartGameSelected.png"];
        [buttonStartGame addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self startGame]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonStartGame];
     
        
        // Dificulty buttons
        __weak RRDifficultyLayer *weakSelf = self;
        _buttonNovice = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAILevelNovice.png" highliteSpriteFrameName:@"RRButtonAILevelNoviceSelected.png"];
        [_buttonNovice addBlock: ^{ [weakSelf setDificultyLevel:RRAILevelNovice]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:_buttonNovice];
        
        _buttonDeacon = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAILevelDeacon.png" highliteSpriteFrameName:@"RRButtonAILevelDeaconSelected.png"];
        [_buttonDeacon addBlock: ^{ [weakSelf setDificultyLevel:RRAILevelDeacon]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:_buttonDeacon];
        
        _buttonAbbot = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAILevelAbbot.png" highliteSpriteFrameName:@"RRButtonAILevelAbbotSelected.png"];
        [_buttonAbbot addBlock: ^{ [weakSelf setDificultyLevel:RRAILevelAbbot]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:_buttonAbbot];
        
        [self setDificultyLevel: (RRAILevel)[[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"]];

        
        // Device layout
        if( IS_IPAD || IS_MAC ){
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
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:pickColorScene backwards:YES]];

}


- (void)setDificultyLevel:(RRAILevel)dificultyLevel {
    int oldDificultyLevel = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"];

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
    [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:gameScene]];
    
}


@end
