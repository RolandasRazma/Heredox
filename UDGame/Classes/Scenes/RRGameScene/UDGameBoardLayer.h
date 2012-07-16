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

@property (nonatomic, readonly) UDTile *activeTile;
@property (nonatomic, readonly) NSUInteger symbolsBlack;
@property (nonatomic, readonly) NSUInteger symbolsWhite;


- (id)initWithGameMode:(RRGameMode)gameMode;

- (void)addTile:(UDTile *)tile animated:(BOOL)animated;
- (BOOL)haltTilePlaces;
- (BOOL)canPlaceTileAtGridLocation:(CGPoint)gridLocation;
- (void)countSymbolsAtTile:(UDTile *)tile white:(NSUInteger *)white black:(NSUInteger *)black;

@end
