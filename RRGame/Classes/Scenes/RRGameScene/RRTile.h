//
//  UDTile.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCSprite.h"


typedef enum RRTileEdge : NSUInteger {
    RRTileEdgeNone  = 0,
    RRTileEdgeBlack = 1,
    RRTileEdgeWhite = 2,
} RRTileEdge;


typedef enum RRTileType : NSUInteger {
    RRTileTypeNNNN  = 0,        // RRTileEdgeNone  RRTileEdgeNone  RRTileEdgeNone  RRTileEdgeNone
    RRTileTypeWNBN  = 1 << 0,   // RRTileEdgeWhite RRTileEdgeNone  RRTileEdgeBlack RRTileEdgeNone
    RRTileTypeWNNB  = 1 << 1,   // RRTileEdgeWhite RRTileEdgeNone  RRTileEdgeNone  RRTileEdgeBlack
    RRTileTypeWBNN  = 1 << 2,   // RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeNone  RRTileEdgeNone
    RRTileTypeWWBB  = 1 << 3,   // RRTileEdgeWhite RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeBlack
    RRTileTypeWBWB  = 1 << 4,   // RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeWhite RRTileEdgeBlack
} RRTileType;


@interface RRTile : CCSprite {
    BOOL        _backSideVisible;
    BOOL        _wasLifted;
    BOOL        _lookIs3D;
    CCSprite    *_look3DSprite;
    
    RRTileType  _tileType;
    RRTileEdge  _edgeTop;
    RRTileEdge  _edgeLeft;
    RRTileEdge  _edgeBottom;
    RRTileEdge  _edgeRight;
    
    CCSprite    *_endTurnSprite;
    
    CCLabelTTF  *_debugLabel;
}

@property (nonatomic, assign, getter = isBackSideVisible) BOOL backSideVisible;
@property (nonatomic, assign, getter = isLookIs3D) BOOL lookIs3D;
@property (nonatomic, assign) CGPoint positionInGrid;
@property (nonatomic, readonly) RRTileType tileType;
@property (nonatomic, readonly) RRTileEdge edgeTop;
@property (nonatomic, readonly) RRTileEdge edgeLeft;
@property (nonatomic, readonly) RRTileEdge edgeBottom;
@property (nonatomic, readonly) RRTileEdge edgeRight;
@property (nonatomic, readonly) BOOL isPlaced;
@property (nonatomic, readonly) BOOL wasLifted;
@property (nonatomic, readonly) RRTileMove tileMove;

+ (const CGFloat)tileSize;
+ (id)tileWithType:(RRTileType)tileType;
- (id)initWithType:(RRTileType)tileType;

- (void)liftTile;
- (void)placeTile;

- (void)showEndTurnTextAnimated:(BOOL)animated;

@end
