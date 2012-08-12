//
//  UDGKPlayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGKPlayer.h"


@implementation UDGKPlayer


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_playerID release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark UDGKPlayer


+ (id)playerWithPlayerID:(NSString *)playerID {
    return [[self alloc] initWithPlayerID:playerID];
}


- (id)initWithPlayerID:(NSString *)playerID {
    if( (self = [super init]) ){
        _playerID = [playerID copy];
    }
    return self;
}


@end
