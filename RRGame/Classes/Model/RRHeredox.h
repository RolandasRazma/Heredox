//
//  RRHeredox.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//
//  Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>


typedef enum RRGameMode : unsigned int {
    RRGameModeClosed    = 0,
    RRGameModeOpen      = 1
} RRGameMode;


typedef enum RRPlayerColor : unsigned int {
    RRPlayerColorUndefined  = 0,
    RRPlayerColorBlack      = 1,
    RRPlayerColorWhite      = 2
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

CG_INLINE RRPlayerColor RRPlayerColorInverse( RRPlayerColor playerColor ){
    return ((playerColor == RRPlayerColorUndefined)?RRPlayerColorUndefined:((playerColor == RRPlayerColorBlack)?RRPlayerColorWhite:RRPlayerColorBlack));
}

@interface RRHeredox : NSObject

+ (RRHeredox *)sharedInstance;

@end
