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
    [_alias release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark UDGKPlayer


+ (id)playerWithPlayerID:(NSString *)playerID alias:(NSString *)alias {
    return [[self alloc] initWithPlayerID:playerID alias:alias];
}


- (id)initWithPlayerID:(NSString *)playerID alias:(NSString *)alias {
    if( (self = [super init]) ){
        NSAssert(playerID, @"No playerID");
        
        _playerID = [playerID retain];
        _alias    = [alias copy];
    }
    return self;
}


@end
