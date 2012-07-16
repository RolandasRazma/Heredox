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
    RRTileMove tileMove = RRTileMoveZero;
    CGFloat tileMoveScore = 0.0f;
    
    RRTile *activeTile = gameBoard.activeTile;
    

    

    for ( RRTile *tile in gameBoard.children ) {
        if( [tile isEqual:activeTile] ) continue;
        
        CGPoint positionInGrid = tile.positionInGrid;

        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x +1, positionInGrid.y)] ){
            NSLog(@"x +1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x +1, positionInGrid.y)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x -1, positionInGrid.y)] ){
            NSLog(@"x -1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x -1, positionInGrid.y)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y +1)] ){
            NSLog(@"y +1");

            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y +1)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y -1)] ){
            NSLog(@"y -1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y -1)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
    }
    
    NSLog(@"!move to: {%f, %f} at angle: %.f confidence: %.2f", tileMove.positionInGrid.x, tileMove.positionInGrid.y, tileMove.rotation, tileMove.score);
    
    return tileMove;
}


- (RRTileMove)bestMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    RRTileMove tileMove = RRTileMoveZero;
    RRTile *activeTile = gameBoard.activeTile;
    
    [activeTile setPositionInGrid:positionInGrid];
    
    // TODO: padaryti tikrinima ar nenusuka savo spalvos uz ekrano ribu arba i siena
    
    for( NSUInteger angle=0; angle<=270; angle += 90 ){
        [activeTile setRotation:angle];
        
        NSUInteger white, black;
        [gameBoard countSymbolsAtTile:activeTile white:&white black:&black];
        
        CGFloat moveValue;
        if( self.playerColor == RRPlayerColorBlack ){
            moveValue = (float)black -white;
        }else if( self.playerColor == RRPlayerColorWhite ){
            moveValue = (float)white -black;
        }
        
        
        RRTile *tileOnTop, *tileOnRight, *tileOnBottom, *tileOnLeft;
        if( (tileOnTop = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x, positionInGrid.y +1)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnTop.edgeBottom == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeTop != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeTop != self.playerColor ){
                moveValue += 0.3f;
                NSLog(@"blocking active tile top with empty upper tile");
            }
            
            // jeigu above yra white ir galiu uzdaryti su savo tusciu +
            if(   tileOnTop.edgeBottom != RRTileEdgeNone 
               && tileOnTop.edgeBottom != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeTop == RRTileEdgeNone ){
                moveValue += 0.3f;
                NSLog(@"blocking upper tile bottom with empty upper tile");
            }
            
            
            

/*            
            if( tileOnTop.edgeBottom != RRTileEdgeNone && (RRPlayerColor)tileOnTop.edgeBottom != self.playerColor ){
                moveValue += 0.3f;
                NSLog(@"blocking oponent above");
            }
            
            if( activeTile.edgeTop != RRTileEdgeNone && (RRPlayerColor)activeTile.edgeTop != self.playerColor ){
                moveValue += 0.3f;
                NSLog(@"blocking oponent top");
            }
*/
        }
        
        if( moveValue >= tileMove.score ){
            tileMove.score    = moveValue;
            tileMove.rotation = angle;
            tileMove.positionInGrid = activeTile.positionInGrid;
        }
    }
    
    return tileMove;
}


@end
