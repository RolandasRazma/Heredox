//
//  RRAI.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/16/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>


@class UDGameBoardLayer;


@interface RRAI : NSObject

@property (nonatomic, readonly) RRPlayerColor playerColor;

+ (id)AIWithPlayerColor:(RRPlayerColor)playerColor;
- (id)initWithPlayerColor:(RRPlayerColor)playerColor;
- (RRTileMove)bestMoveOnBoard:(UDGameBoardLayer *)gameBoard;

@end
