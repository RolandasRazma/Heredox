//
//  RRDifficultyScene.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/25/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCScene.h"


@interface RRDifficultyScene : CCScene

+ (id)sceneWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)firstPlayerColor;
- (id)initWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)firstPlayerColor;

@end
