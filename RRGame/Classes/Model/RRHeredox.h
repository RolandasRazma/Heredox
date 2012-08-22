//
//  RRHeredox.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum RRGameMode : unsigned int {
    RRGameModeClosed    = 0,
    RRGameModeOpen      = 1,
} RRGameMode;


typedef enum RRPlayerColor : unsigned int {
    RRPlayerColorUndefined  = 0,
    RRPlayerColorBlack      = 1,
    RRPlayerColorWhite      = 2,
} RRPlayerColor;


typedef struct RRTileMove {
    int gridX;
    int gridY;
    int rotation;
    float score;
} RRTileMove;


extern const RRTileMove RRTileMoveZero;

CG_INLINE RRTileMove RRTileMoveMake(int x, int y, int rotation, float score) {
    return (RRTileMove){ x, y, rotation, score };
}


@interface RRHeredox : NSObject

+ (RRHeredox *)sharedInstance;

@end
