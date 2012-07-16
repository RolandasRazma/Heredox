//
//  RRAI.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/16/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRAIPlayer.h"
#import "RRGameBoardLayer.h"
#import "RRTile.h"


@implementation RRAIPlayer


#pragma mark -
#pragma mark RRAIPlayer


- (RRTileMove)bestMoveOnBoard:(RRGameBoardLayer *)gameBoard {
    RRTileMove tileMove;
    CGFloat tileMoveScore = 0.0f;
    
    RRTile *activeTile = gameBoard.activeTile;
    
    
    
    NSUInteger white, black;
    

    for ( RRTile *tile in gameBoard.children ) {
        if( [tile isEqual:activeTile] ) continue;
        
        CGPoint positionInGrid = tile.positionInGrid;
        
        // TODO: padaryti tikrinima ar nenusuka savo spalvos uz ekrano ribu arba i siena
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x +1, positionInGrid.y)] ){
            NSLog(@"x +1");
            
            [activeTile setPositionInGrid:CGPointMake(positionInGrid.x +1, positionInGrid.y)];
            
            for( NSUInteger angle=0; angle<=270; angle += 90 ){
                [activeTile setRotation:angle];
                [gameBoard countSymbolsAtTile:activeTile white:&white black:&black];
                
                CGFloat moveValue = (float)black -white;
                
                if( moveValue >= tileMoveScore ){
                    tileMoveScore    = moveValue;
                    tileMove.rotation = angle;
                    tileMove.positionInGrid = activeTile.positionInGrid;
                }
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x -1, positionInGrid.y)] ){
            NSLog(@"x -1");
            
            [activeTile setPositionInGrid:CGPointMake(positionInGrid.x -1, positionInGrid.y)];
            
            for( NSUInteger angle=0; angle<=270; angle += 90 ){
                [activeTile setRotation:angle];
                [gameBoard countSymbolsAtTile:activeTile white:&white black:&black];
                
                CGFloat moveValue = (float)black -white;
                
                if( moveValue >= tileMoveScore ){
                    tileMoveScore    = moveValue;
                    tileMove.rotation = angle;
                    tileMove.positionInGrid = activeTile.positionInGrid;
                }
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y +1)] ){
            NSLog(@"y +1");
            
            [activeTile setPositionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y +1)];
            
            for( NSUInteger angle=0; angle<=270; angle += 90 ){
                [activeTile setRotation:angle];
                [gameBoard countSymbolsAtTile:activeTile white:&white black:&black];
                
                CGFloat moveValue = (float)black -white;
                
                if( moveValue >= tileMoveScore ){
                    tileMoveScore    = moveValue;
                    tileMove.rotation = angle;
                    tileMove.positionInGrid = activeTile.positionInGrid;
                }
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y -1)] ){
            NSLog(@"y -1");
            
            [activeTile setPositionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y -1)];
            
            for( NSUInteger angle=0; angle<=270; angle += 90 ){
                [activeTile setRotation:angle];
                [gameBoard countSymbolsAtTile:activeTile white:&white black:&black];
                
                CGFloat moveValue = (float)black -white;
                
                if( moveValue >= tileMoveScore ){
                    tileMoveScore    = moveValue;
                    tileMove.rotation = angle;
                    tileMove.positionInGrid = activeTile.positionInGrid;
                }
            }
        }
        
    }
    
    NSLog(@"!move to: {%f, %f} at angle: %.f confidence: %.2f", tileMove.positionInGrid.x, tileMove.positionInGrid.y, tileMove.rotation, tileMoveScore);
    
    return tileMove;
}


@end
