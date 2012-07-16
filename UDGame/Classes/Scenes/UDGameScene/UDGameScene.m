//
//  UDGameScene.m
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "UDGameScene.h"
#import "UDGameLayer.h"
#import "RRAI.h"


@implementation UDGameScene


#pragma mark -
#pragma mark UDGameScene


+ (id)sceneWithGameMode:(UDGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(UDPlayerColor)playerColor {
    return [[[self alloc] initWithGameMode:gameMode numberOfPlayers:numberOfPlayers firstPlayerColor:playerColor] autorelease];
}


- (id)initWithGameMode:(UDGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(UDPlayerColor)playerColor {
    if( (self = [self init]) ){
        UDGameLayer *gameLayer = [UDGameLayer layerWithGameMode:gameMode firstPlayerColor:playerColor];
        if( numberOfPlayers == 1 ){
            [gameLayer setAI: [RRAI AIWithPlayerColor: ((playerColor == UDPlayerColorBlack)?UDPlayerColorWhite:UDPlayerColorBlack)]];
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
