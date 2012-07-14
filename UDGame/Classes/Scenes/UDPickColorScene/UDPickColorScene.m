//
//  UDPickColorScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDPickColorScene.h"
#import "UDPickColorLayer.h"


@implementation UDPickColorScene


#pragma mark -
#pragma mark UDPickColorScene


+ (id)sceneWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    return [[[self alloc] initWithNumberOfPlayers:numberOfPlayers] autorelease];
}


- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    if( (self = [self init]) ){
        [self addChild: [UDPickColorLayer layerWithNumberOfPlayers:numberOfPlayers]];
    }
    return self;
}


@end
