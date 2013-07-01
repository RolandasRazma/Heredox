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


- (GKTurnBasedParticipant *)nextParticipant {
    NSUInteger currentParticipantIndex = [self.participants indexOfObject:self.currentParticipant];
    return [self.participants objectAtIndex: (currentParticipantIndex +1) %self.participants.count];
}


- (BOOL)isMyTurn {
    
    if( [[GKLocalPlayer localPlayer] isAuthenticated] ){
        return [self.currentParticipant.playerID isEqualToString: [[GKLocalPlayer localPlayer] playerID]];
    }else{
        return NO;
    }
    
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


- (BOOL)addTileMove:(RRTileMove)tileMove byParticipant:(GKTurnBasedParticipant *)participant {
    if( ![participant isEqual:self.currentParticipant] ) return NO;

    RRMatchData matchRepresentation = self.matchRepresentation;

    matchRepresentation.tileMoves[matchRepresentation.totalTileMoves] = tileMove;
    matchRepresentation.totalTileMoves++;

    [self setMatchRepresentation: matchRepresentation];
    
    return YES;
}


- (NSData *)transitMatchData {
    NSData *transitMatchData = objc_getAssociatedObject(self, @selector(transitMatchData));
    return (transitMatchData.length?transitMatchData:self.matchData);
}


- (void)invalidateMatchRepresentation {
    objc_setAssociatedObject( self, @selector(transitMatchData), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
