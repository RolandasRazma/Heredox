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


@interface RRTile : CCSprite {
    BOOL        _backSideVisible;
    BOOL        _wasLifted;
    BOOL        _lookIs3D;
    CCSprite    *_look3DSprite;
    
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
@property (nonatomic, readonly) RRTileEdge edgeTop;
@property (nonatomic, readonly) RRTileEdge edgeLeft;
@property (nonatomic, readonly) RRTileEdge edgeBottom;
@property (nonatomic, readonly) RRTileEdge edgeRight;
@property (nonatomic, readonly) BOOL isPlaced;
@property (nonatomic, readonly) BOOL wasLifted;

+ (const CGFloat)tileSize;
+ (id)tileWithEdgeTop:(RRTileEdge)top left:(RRTileEdge)left bottom:(RRTileEdge)bottom right:(RRTileEdge)right;
- (id)initWithEdgeTop:(RRTileEdge)top left:(RRTileEdge)left bottom:(RRTileEdge)bottom right:(RRTileEdge)right;

- (void)liftTile;
- (void)placeTile;

- (void)showEndTurnTextAnimated:(BOOL)animated;

@end
