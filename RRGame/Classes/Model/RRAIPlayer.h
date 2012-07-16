//
//  RRAI.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/16/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RRPlayer.h"

@class RRGameBoardLayer;


@interface RRAIPlayer : RRPlayer

- (RRTileMove)bestMoveOnBoard:(RRGameBoardLayer *)gameBoard;

@end
