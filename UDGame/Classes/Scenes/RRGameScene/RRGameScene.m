//
//  UDGameScene.m
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "RRGameScene.h"
#import "RRGameLayer.h"
#import "RRAI.h"


@implementation RRGameScene


#pragma mark -
#pragma mark UDGameScene


+ (id)sceneWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor {
    return [[[self alloc] initWithGameMode:gameMode numberOfPlayers:numberOfPlayers firstPlayerColor:playerColor] autorelease];
}


- (id)initWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor {
    if( (self = [self init]) ){
        RRGameLayer *gameLayer = [RRGameLayer layerWithGameMode:gameMode firstPlayerColor:playerColor];
        if( numberOfPlayers == 1 ){
            [gameLayer setAI: [RRAI AIWithPlayerColor: ((playerColor == RRPlayerColorBlack)?RRPlayerColorWhite:RRPlayerColorBlack)]];
        }
        [self addChild: gameLayer];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


#if DEBUG && __CC_PLATFORM_IOS
- (void)draw {
    glPushGroupMarkerEXT(0, "-[UDGameScene draw]");
    
	[super draw];
    
	glPopGroupMarkerEXT();
}
#endif


@end
