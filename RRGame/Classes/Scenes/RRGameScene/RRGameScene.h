//
//  UDGameScene.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "CCScene.h"


@interface RRGameScene : CCScene <GKTurnBasedEventHandlerDelegate> {
    NSUInteger  _numberOfPlayers;
}

+ (id)sceneWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor;
- (id)initWithGameMode:(RRGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers playerColor:(RRPlayerColor)playerColor;
- (id)initWithGameMode:(RRGameMode)gameMode match:(GKTurnBasedMatch *)match playerColor:(RRPlayerColor)playerColor;

@end
