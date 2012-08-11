//
//  UDGameScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "RRGameScene.h"
#import "RRGameLayer.h"
#import "RRAIPlayer.h"
#import "RRPlayer.h"


@implementation RRGameScene


#pragma mark -
#pragma mark UDGameScene


+ (id)sceneWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor {
    return [[[self alloc] initWithGameMode:gameMode numberOfPlayers:numberOfPlayers playerColor:playerColor] autorelease];
}


- (id)initWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers playerColor:(RRPlayerColor)playerColor {
    if( (self = [self init]) ){
        _numberOfPlayers = numberOfPlayers;
        
        RRGameLayer *gameLayer = [RRGameLayer layerWithGameMode:gameMode firstPlayerColor:(( numberOfPlayers == 1 )?RRPlayerColorWhite:playerColor)];
        [gameLayer setPlayer1: [RRPlayer playerWithPlayerColor:playerColor]];

        if( numberOfPlayers == 1 ){
            RRAIPlayer *player = [RRAIPlayer playerWithPlayerColor: ((playerColor == RRPlayerColorBlack)?RRPlayerColorWhite:RRPlayerColorBlack)];
            [player setDificultyLevel: [[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"]];
            
            [gameLayer setPlayer2: player];
        }

        [self addChild: gameLayer];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onExitTransitionDidStart {
    [super onExitTransitionDidStart];
    
    [[RRAudioEngine sharedEngine] stopEffect: [NSString stringWithFormat:@"RRGameSceneNumberOfPlayers%u.mp3", _numberOfPlayers]];
}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [[RRAudioEngine sharedEngine] replayEffect: [NSString stringWithFormat:@"RRGameSceneNumberOfPlayers%u.mp3", _numberOfPlayers]];
}


@end
