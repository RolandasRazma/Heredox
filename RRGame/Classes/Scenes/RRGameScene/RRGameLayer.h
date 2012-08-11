//
//  UDGameLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"
#import "RRGameMenuLayer.h"
#import "RRGameWictoryLayer.h"


@class RRPlayer, RRGameBoardLayer, UDSpriteButton, RRCrossfadeLayer, RRScoreLayer;


@interface RRGameLayer : UDLayer <RRGameMenuDelegate, RRPlayerColorWictoriousDelegate, UDGKManagerPacketObserving> {
    RRGameMode          _gameMode;
    
    NSMutableArray      *_deck;
    RRGameBoardLayer    *_gameBoardLayer;
    
    RRPlayerColor       _playerColor;
    RRPlayerColor       _firstPlayerColor;
    
    UDSpriteButton      *_buttonEndTurn;
    
    RRPlayer            *_player1;
    RRPlayer            *_player2;
    
    RRCrossfadeLayer    *_backgroundLayer;
    RRScoreLayer        *_scoreLayer;
    UDSpriteButton      *_resetGameButton;
    
    BOOL                _allPlayersInScene;
    NSUInteger          _gameSeed;
}

@property (nonatomic, retain) RRPlayer *player1;
@property (nonatomic, retain) RRPlayer *player2;

+ (id)layerWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor;
- (id)initWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor;

@end
