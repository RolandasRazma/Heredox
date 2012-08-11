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
        
        RRGameLayer *gameLayer = [RRGameLayer layerWithGameMode:gameMode firstPlayerColor:(( _numberOfPlayers == 1 )?RRPlayerColorWhite:playerColor)];
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


- (id)initWithGameMode:(RRGameMode)gameMode match:(GKTurnBasedMatch *)match playerColor:(RRPlayerColor)playerColor {
    if( (self = [self init]) ){
        _numberOfPlayers= match.participants.count;

        RRGameLayer *gameLayer = [RRGameLayer layerWithGameMode:gameMode firstPlayerColor:playerColor];
        [gameLayer setMatch:match];
        
        for( GKTurnBasedParticipant *turnBasedParticipant in match.participants ){
            if( [turnBasedParticipant.playerID isEqualToString:[GKLocalPlayer localPlayer].playerID] ){
                RRPlayer *player = [RRPlayer playerWithPlayerColor: playerColor];
                [player setPlayerID:turnBasedParticipant.playerID];
                
                [gameLayer setPlayer1: player];
            }else{
                RRPlayer *player = [RRPlayer playerWithPlayerColor: ((playerColor == RRPlayerColorBlack)?RRPlayerColorWhite:RRPlayerColorBlack)];
                [player setPlayerID:turnBasedParticipant.playerID];
                
                [gameLayer setPlayer2: player];
            }
        }

        [self addChild: gameLayer];
        [gameLayer release];
        
        [[GKTurnBasedEventHandler sharedTurnBasedEventHandler] setDelegate:self];
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


#pragma mark -
#pragma mark GKTurnBasedEventHandlerDelegate


// If Game Center initiates a match the developer should create a GKTurnBasedMatch from playersToInvite and present a GKTurnbasedMatchmakerViewController.
- (void)handleInviteFromGameCenter:(NSArray *)playersToInvite {
    NSLog(@"handleInviteFromGameCenter");
}

// handleTurnEventForMatch is called when a turn is passed to another participant.  Note this may arise from one of the following events:
//      The local participant has accepted an invite to a new match
//      The local participant has been passed the turn for an existing match
//      Another participant has made a turn in an existing match
// The application needs to be prepared to handle this even while the participant might be engaged in a different match
- (void)handleTurnEventForMatch:(GKTurnBasedMatch *)match {
    NSLog(@"handleTurnEventForMatch");
}


// handleMatchEnded is called when the match has ended.
- (void)handleMatchEnded:(GKTurnBasedMatch *)match {
    NSLog(@"handleMatchEnded");
}


@end
