//
//  UDPickColorScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRPickColorScene.h"
#import "RRPickColorLayer.h"


@implementation RRPickColorScene


#pragma mark -
#pragma mark UDPickColorScene


+ (id)sceneWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    return [[[self alloc] initWithNumberOfPlayers:numberOfPlayers] autorelease];
}


- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    if( (self = [self init]) ){
        [self addChild: [RRPickColorLayer layerWithNumberOfPlayers:numberOfPlayers]];
    }
    return self;
}


- (id)initWithMatch:(GKTurnBasedMatch *)match {
    if( (self = [self init]) ){
        RRPickColorLayer *pickColorLayer = [[RRPickColorLayer alloc] initWithMatch:match];
        [self addChild: pickColorLayer];
        [pickColorLayer release];
    }
    return self;
}


@end
