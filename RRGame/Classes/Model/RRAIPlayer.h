//
//  RRAI.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/16/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRPlayer.h"

@class RRGameBoardLayer;


typedef enum RRAILevel : int {
    RRAILevelNovice = -1,
    RRAILevelDeacon = 0,
    RRAILevelAbbot  = 1,
} RRAILevel;


@interface RRAIPlayer : RRPlayer {
    RRAILevel   _dificultyLevel;
    NSSet       *_tilesInDeck;
}

@property (nonatomic, assign) RRAILevel dificultyLevel;
@property (nonatomic, assign) NSSet     *tilesInDeck;
@property (nonatomic, readonly) RRPlayerColor oponentColor;

- (RRTileMove)bestMoveOnBoard:(RRGameBoardLayer *)gameBoard;

@end
