//
//  UDGameLayer.h
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"

@class RRAI;

@interface UDGameLayer : UDLayer

@property (nonatomic, retain) RRAI *AI;

+ (id)layerWithGameMode:(UDGameMode)gameMode firstPlayerColor:(UDPlayerColor)playerColor;
- (id)initWithGameMode:(UDGameMode)gameMode firstPlayerColor:(UDPlayerColor)playerColor;

@end
