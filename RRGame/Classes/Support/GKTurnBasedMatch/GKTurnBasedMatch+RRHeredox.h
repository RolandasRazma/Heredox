//
//  GKTurnBasedMatch+RRHeredox.h
//  RRHeredox
//
//  Created by Rolandas Razma on 30/06/2013.
//  Copyright (c) 2013 UD7. All rights reserved.
//

#import <GameKit/GameKit.h>


typedef struct RRMatchData {
    RRPlayerColor   firstParticipantColor;
    unsigned int    seed;

    RRTileMove      tileMoves[16];
    int             totalTileMoves;
} RRMatchData;


@interface GKTurnBasedMatch (RRHeredox)

- (BOOL)isMyTurn;
- (GKTurnBasedParticipant *)nextParticipant;

- (RRMatchData)matchRepresentation;
- (void)setMatchRepresentation:(RRMatchData)matchRepresentation;

- (NSData *)transitMatchData;
- (void)invalidateMatchRepresentation;

- (void)endTurnWithNextParticipant:(GKTurnBasedParticipant *)nextParticipant completionHandler:(void(^)(NSError *error))completionHandler;

@end


@interface GKTurnBasedMatch (RRMatchData)

@property(nonatomic, assign)    unsigned int    gameSeed;
@property(nonatomic, assign)    RRPlayerColor   firstParticipantColor;

- (void)addTileMove:(RRTileMove)tileMove;
- (GKTurnBasedParticipant *)participantForColor:(RRPlayerColor)playerColor;

@end