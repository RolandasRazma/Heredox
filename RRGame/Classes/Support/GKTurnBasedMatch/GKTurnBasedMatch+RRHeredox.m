//
//  GKTurnBasedMatch+RRHeredox.m
//  RRHeredox
//
//  Created by Rolandas Razma on 30/06/2013.
//  Copyright (c) 2013 UD7. All rights reserved.
//

#import "GKTurnBasedMatch+RRHeredox.h"
#import <objc/runtime.h>


@implementation GKTurnBasedMatch (RRHeredox)


- (BOOL)isMyTurn {
    
    if( [[GKLocalPlayer localPlayer] isAuthenticated] ){
        return [self.currentParticipant.playerID isEqualToString: [[GKLocalPlayer localPlayer] playerID]];
    }else{
        return NO;
    }
    
}


- (GKTurnBasedParticipant *)nextParticipant {
    NSUInteger currentParticipantIndex = [self.participants indexOfObject:self.currentParticipant];
    return [self.participants objectAtIndex: (currentParticipantIndex +1) %self.participants.count];
}


- (void)setMatchRepresentation:(RRMatchData)matchRepresentation {
    NSData *data = [NSData dataWithBytes:&matchRepresentation length:sizeof(RRMatchData)];
    objc_setAssociatedObject( self, @selector(transitMatchData), data, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


- (RRMatchData)matchRepresentation {
    RRMatchData matchRepresentation;
    
    if( self.transitMatchData.length == 0 ){
        // create new matchRepresentation
        matchRepresentation = (RRMatchData){
            .firstParticipantColor  = RRPlayerColorUndefined,
            .seed                   = 0,
            .totalTileMoves         = 0
        };
    }else{
        matchRepresentation = *(RRMatchData *)[self.transitMatchData bytes];
    }

    return matchRepresentation;
}


- (NSData *)transitMatchData {
    NSData *transitMatchData = objc_getAssociatedObject(self, @selector(transitMatchData));
    return (transitMatchData.length?transitMatchData:self.matchData);
}


- (void)invalidateMatchRepresentation {
    objc_setAssociatedObject( self, @selector(transitMatchData), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end


@implementation GKTurnBasedMatch (RRMatchData)


- (void)setGameSeed:(NSUInteger)gameSeed {
    RRMatchData matchRepresentation = self.matchRepresentation;
    matchRepresentation.seed = gameSeed;
    
    [self setMatchRepresentation:matchRepresentation];

}


- (NSUInteger)gameSeed {
    RRMatchData matchRepresentation = self.matchRepresentation;
    return matchRepresentation.seed;
}


- (void)addTileMove:(RRTileMove)tileMove {
    RRMatchData matchRepresentation = self.matchRepresentation;
    
    matchRepresentation.tileMoves[matchRepresentation.totalTileMoves] = tileMove;
    matchRepresentation.totalTileMoves++;
    
    [self setMatchRepresentation: matchRepresentation];
}


- (GKTurnBasedParticipant *)participantForColor:(RRPlayerColor)playerColor {
    RRMatchData matchRepresentation = self.matchRepresentation;
    
    if( playerColor == matchRepresentation.firstParticipantColor ){
        return [self.participants objectAtIndex:0];
    }else{
        return [self.participants objectAtIndex:1];
    }
    
}


@end