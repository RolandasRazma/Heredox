//
//  UDGameBoardLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"

@class UDTile;


@interface UDGameBoardLayer : UDLayer

- (id)initWithGameMode:(UDGameMode)gameMode;

- (void)addTile:(UDTile *)tile animated:(BOOL)animated;
- (BOOL)haltTilePlaces;

@end
