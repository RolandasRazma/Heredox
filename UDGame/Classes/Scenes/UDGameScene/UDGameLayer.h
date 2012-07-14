//
//  UDGameLayer.h
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"


@interface UDGameLayer : UDLayer

+ (id)layerWithGameMode:(UDGameMode)gameMode firstPlayerColor:(UDPlayerColor)playerColor;
- (id)initWithGameMode:(UDGameMode)gameMode firstPlayerColor:(UDPlayerColor)playerColor;

@end
