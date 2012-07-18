//
//  RRHeredox.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum RRGameMode : NSUInteger {
    RRGameModeClosed    = 0,
    RRGameModeOpen      = 1,
} RRGameMode;


typedef enum RRPlayerColor : NSUInteger {
    RRPlayerColorUndefined  = 0,
    RRPlayerColorBlack      = 1,
    RRPlayerColorWhite      = 2,
} RRPlayerColor;


typedef struct RRTileMove {
    CGPoint positionInGrid;
    CGFloat rotation;
    CGFloat score;
} RRTileMove;


extern const RRTileMove RRTileMoveZero;


@interface RRHeredox : NSObject

+ (RRHeredox *)sharedInstance;

@end
