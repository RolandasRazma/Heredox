//
//  UDGameScene.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "CCScene.h"


@interface RRGameScene : CCScene {
    uint  _numberOfPlayers;
}

+ (id)sceneWithGameMode:(RRGameMode)gameMode numberOfPlayers:(uint)numberOfPlayers firstPlayerColor:(RRPlayerColor)playerColor;
- (id)initWithGameMode:(RRGameMode)gameMode numberOfPlayers:(uint)numberOfPlayers playerColor:(RRPlayerColor)playerColor;

@end
