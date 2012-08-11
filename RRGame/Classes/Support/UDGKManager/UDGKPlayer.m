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


@end
