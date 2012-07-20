//
//  UDGameScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "RRGameScene.h"
#import "RRGameLayer.h"
#import "RRAIPlayer.h"
#import "RRPlayer.h"


@implementation RRGameScene


#pragma mark -
#pragma mark UDGameScene


+ (id)sceneWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor {
    return [[[self alloc] initWithGameMode:gameMode numberOfPlayers:numberOfPlayers firstPlayerColor:playerColor] autorelease];
}


- (id)initWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor {
    if( (self = [self init]) ){
        RRGameLayer *gameLayer = [RRGameLayer layerWithGameMode:gameMode firstPlayerColor:playerColor];
        [gameLayer setPlayer1: [RRPlayer playerWithPlayerColor:playerColor]];

        if( numberOfPlayers == 1 ){
            RRAIPlayer *player = [RRAIPlayer playerWithPlayerColor: ((playerColor == RRPlayerColorBlack)?RRPlayerColorWhite:RRPlayerColorBlack)];
            [player setDificultyLevel: [[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"]];
            
            [gameLayer setPlayer2: player];
            
#if TARGET_IPHONE_SIMULATOR
            /*
            RRAIPlayer *player1 = [RRAIPlayer playerWithPlayerColor:playerColor];
            [player1 setDificultyLevel: [[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"]];
            [gameLayer setPlayer1: player1];
            */
#endif
        }
        
//        [(RRAIPlayer *)gameLayer.player1 setDificultyLevel: RRAILevelNovice];
//        [(RRAIPlayer *)gameLayer.player2 setDificultyLevel: RRAILevelAbbot];
        
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
