//
//  RRPlayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/16/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRPlayer.h"


@implementation RRPlayer


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_playerID release];
    [super dealloc];
}


- (BOOL)isEqual:(id)object {
    if( [object isKindOfClass:[GKTurnBasedParticipant class]] && [[(GKTurnBasedParticipant *)object playerID] isEqualToString:_playerID] ) return YES;
    if( [object isKindOfClass:[RRPlayer class]] && [[(RRPlayer *)object playerID] isEqualToString:_playerID] ) return YES;
    
    return (self == object);
}


#pragma mark -
#pragma mark RRPlayer


+ (id)playerWithPlayerColor:(RRPlayerColor)playerColor {
    return [[[self alloc] initWithPlayerColor:playerColor] autorelease];
}


- (id)initWithPlayerColor:(RRPlayerColor)playerColor {
    if( (self = [super init]) ){
        _playerColor = playerColor;
    }
    return self;
}


@synthesize playerColor=_playerColor;
@end
