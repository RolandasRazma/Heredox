//
//  RRDifficultyScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/25/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRDifficultyScene.h"
#import "RRDifficultyLayer.h"


@implementation RRDifficultyScene


#pragma mark -
#pragma mark UDGameScene


+ (id)sceneWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)firstPlayerColor {
    return [[[self alloc] initWithGameMode:gameMode playerColor:firstPlayerColor] autorelease];
}


- (id)initWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)firstPlayerColor {
    if( (self = [self init]) ){
        [self addChild: [RRDifficultyLayer layerWithGameMode:gameMode playerColor:firstPlayerColor]];
    }
    return self;
}


@end
