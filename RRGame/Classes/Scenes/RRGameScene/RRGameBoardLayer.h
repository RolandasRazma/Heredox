//
//  UDGameBoardLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"

@class RRTile;

NSString * const RRGameBoardLayerTileMovedToValidLocationNotification;


@interface RRGameBoardLayer : UDLayer {
    RRGameMode          _gameMode;
    
    NSUInteger          _symbolsBlack;
    NSUInteger          _symbolsWhite;
    
    CGPoint             _activeTileLastPosition;
    
    RRTile              *_activeTile;
    CGPoint             _activeTileTouchOffset;
    BOOL                _activeTileMoved;
    
    CGRect              _gridBounds;
    RRTile              *_emptyTile;
}

@property (nonatomic, readonly) RRTile *activeTile;
@property (nonatomic, readonly) NSUInteger symbolsBlack;
@property (nonatomic, readonly) NSUInteger symbolsWhite;
@property (nonatomic, readonly) CGRect gridBounds;

- (id)initWithGameMode:(RRGameMode)gameMode;

- (void)addTile:(RRTile *)tile animated:(BOOL)animated;
- (BOOL)haltTilePlaces;
- (BOOL)canPlaceTileAtGridLocation:(CGPoint)gridLocation;
- (void)countSymbolsAtTile:(RRTile *)tile white:(NSUInteger *)white black:(NSUInteger *)black;
- (RRTile *)tileAtGridPosition:(CGPoint)gridPosition;
- (void)resetBoardForGameMode:(RRGameMode)gameMode;

@end
