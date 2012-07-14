//
//  UDGameScene.h
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "CCScene.h"


@interface UDGameScene : CCScene

- (id)initWithGameMode:(UDGameMode)gameMode numberOfPlayers:(NSUInteger)numberOfPlayers firstPlayerColor:(UDPlayerColor)playerColor;

@end
