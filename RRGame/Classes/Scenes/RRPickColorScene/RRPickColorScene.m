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


+ (id)sceneWithNumberOfPlayers:(uint)numberOfPlayers {
    return [[[self alloc] initWithNumberOfPlayers:numberOfPlayers] autorelease];
}


- (id)initWithNumberOfPlayers:(uint)numberOfPlayers {
    if( (self = [self init]) ){
        [self addChild: [RRPickColorLayer layerWithNumberOfPlayers:numberOfPlayers]];
    }
    return self;
}


@end
