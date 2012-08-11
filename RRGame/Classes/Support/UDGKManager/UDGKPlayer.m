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


- (void)setPlayerID:(NSString *)playerID {
    [_playerID release];
    _playerID = [playerID copy];
}


@end
