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


+ (void)load {
    #define REPLACE_METHOD(__CLASS__, __ORIG_SELECTOR__, __NEW_SELECTOR__) {                                                                            \
        Method origInstanceMethod = class_getInstanceMethod(__CLASS__, __ORIG_SELECTOR__);                                                              \
        Method newInstanceMethod  = class_getInstanceMethod(__CLASS__, __NEW_SELECTOR__);                                                               \
        if( class_addMethod(__CLASS__, __ORIG_SELECTOR__, method_getImplementation(newInstanceMethod), method_getTypeEncoding(newInstanceMethod)) ){    \
            class_replaceMethod(__CLASS__, __NEW_SELECTOR__, method_getImplementation(origInstanceMethod), method_getTypeEncoding(origInstanceMethod)); \
        }else{                                                                                                                                          \
            method_exchangeImplementations(origInstanceMethod, newInstanceMethod);                                                                      \
        }                                                                                                                                               \
    }
    
    REPLACE_METHOD([GKTurnBasedMatch class], @selector(loadMatchDataWithCompletionHandler:), @selector(rr_loadMatchDataWithCompletionHandler:))
}


#pragma mark -
#pragma mark GKTurnBasedMatch


- (void)rr_loadMatchDataWithCompletionHandler:(void(^)(NSData *matchData, NSError *error))completionHandler {
    [self rr_loadMatchDataWithCompletionHandler:^(NSData *matchData, NSError *error) {
        [self invalidateMatchRepresentation];
        completionHandler(matchData, error);
    }];
}


#pragma mark -
#pragma mark GKTurnBasedMatch (RRHeredox)


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


- (void)endTurnWithNextParticipant:(GKTurnBasedParticipant *)nextParticipant completionHandler:(void(^)(NSError *error))completionHandler {
    
    [self endTurnWithNextParticipant: nextParticipant
                           matchData: self.transitMatchData
                   completionHandler: ^(NSError *error) {
                       [self invalidateMatchRepresentation];
                       
                       completionHandler( error );
                   }];
    
}


@end


@implementation GKTurnBasedMatch (RRMatchData)


- (RRPlayerColor)firstParticipantColor {
    RRMatchData matchRepresentation = self.matchRepresentation;
    
    return matchRepresentation.firstParticipantColor;
}


- (void)setFirstParticipantColor:(RRPlayerColor)firstParticipantColor {
    RRMatchData matchRepresentation = self.matchRepresentation;
    matchRepresentation.firstParticipantColor = firstParticipantColor;
    
    [self setMatchRepresentation:matchRepresentation];
}


- (NSUInteger)gameSeed {
    RRMatchData matchRepresentation = self.matchRepresentation;
    
    return matchRepresentation.seed;
}


- (void)setGameSeed:(NSUInteger)gameSeed {
    RRMatchData matchRepresentation = self.matchRepresentation;
    
    matchRepresentation.seed = gameSeed;
    
    [self setMatchRepresentation:matchRepresentation];
}


- (void)addTileMove:(RRTileMove)tileMove {
    RRMatchData matchRepresentation = self.matchRepresentation;
    
    matchRepresentation.tileMoves[matchRepresentation.totalTileMoves] = tileMove;
    matchRepresentation.totalTileMoves++;
    
    [self setMatchRepresentation: matchRepresentation];
}


- (GKTurnBasedParticipant *)participantForColor:(RRPlayerColor)playerColor {
    
    if( playerColor == self.firstParticipantColor ){
        return [self.participants objectAtIndex:0];
    }else{
        return [self.participants objectAtIndex:1];
    }
    
}


@end