//
//  UDTile.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCSprite.h"


typedef enum UDTileEdge : NSUInteger {
    UDTileEdgeNone  = 0,
    UDTileEdgeBlack = 1,
    UDTileEdgeWhite = 2,
} UDTileEdge;


@interface UDTile : CCSprite

@property (nonatomic, assign, getter = isBackSideVisible) BOOL backSideVisible;
@property (nonatomic, readonly) CGPoint positionInGrid;

+ (id)tileWithEdgeTop:(UDTileEdge)top left:(UDTileEdge)left bottom:(UDTileEdge)bottom right:(UDTileEdge)right;
- (id)initWithEdgeTop:(UDTileEdge)top left:(UDTileEdge)left bottom:(UDTileEdge)bottom right:(UDTileEdge)right;

@end
