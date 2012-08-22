//
//  RRBoardLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"

@class RRTile;
@protocol RRBoardLayerDelegate;


@interface RRBoardLayer : UDLayer {
    id<RRBoardLayerDelegate>_delegate;
    
    RRGameMode          _gameMode;
    
    uint                _symbolsBlack;
    uint                _symbolsWhite;
    
    CGPoint             _activeTileLastPosition;
    
    RRTile              *_activeTile;
    CGPoint             _activeTileTouchOffset;
    BOOL                _activeTileMoved;
    
    CGRect              _gridBounds;
    RRTile              *_emptyTile;
}

@property (nonatomic, readonly) RRTile *activeTile;
@property (nonatomic, readonly) uint symbolsBlack;
@property (nonatomic, readonly) uint symbolsWhite;
@property (nonatomic, readonly) CGRect gridBounds;
@property (nonatomic, assign)   id <RRBoardLayerDelegate>delegate;

- (id)initWithGameMode:(RRGameMode)gameMode;

- (void)addTile:(RRTile *)tile animated:(BOOL)animated;
- (BOOL)haltTilePlaces;
- (BOOL)canPlaceTileAtGridLocation:(CGPoint)gridLocation;
- (void)countSymbolsAtTile:(RRTile *)tile white:(NSUInteger *)white black:(NSUInteger *)black;
- (RRTile *)tileAtGridPosition:(CGPoint)gridPosition;
- (void)resetBoardForGameMode:(RRGameMode)gameMode;

@end


@protocol RRBoardLayerDelegate <NSObject>

- (void)boardLayer:(RRBoardLayer *)gameBoardLayer movedActiveTile:(RRTileMove)tileMove;

@end