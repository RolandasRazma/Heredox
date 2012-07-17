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
    RRTile *activeTile = gameBoard.activeTile;
    CGPoint activeTilePosition = activeTile.position;
    
    
    for ( RRTile *tile in gameBoard.children ) {
        if( [tile isEqual:activeTile] ) continue;
        
        [tile setColor:ccWHITE];
        
        CGPoint positionInGrid = tile.positionInGrid;

        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x +1, positionInGrid.y)] ){
            // NSLog(@"x +1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x +1, positionInGrid.y)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x -1, positionInGrid.y)] ){
            // NSLog(@"x -1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x -1, positionInGrid.y)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y +1)] ){
            // NSLog(@"y +1");

            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y +1)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y -1)] ){
            // NSLog(@"y -1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y -1)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
    }
    
    [activeTile setPosition:activeTilePosition];
    [activeTile setRotation:0];
    
    NSLog(@"!move to: {%.f, %.f} at angle: %.f confidence: %.2f", tileMove.positionInGrid.x, tileMove.positionInGrid.y, tileMove.rotation, tileMove.score);
    
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

        // Count how much points you gain
        CGFloat moveValue;
        if( self.playerColor == RRPlayerColorBlack ){
            moveValue = (float)black -(float)white;
        }else if( self.playerColor == RRPlayerColorWhite ){
            moveValue = (float)white -(float)black;
        }

        // Count how bad this move is in other means
        RRTile *tileOnTop, *tileOnRight, *tileOnBottom, *tileOnLeft;
        if( (tileOnTop = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x, positionInGrid.y +1)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnTop.edgeBottom == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeTop != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeTop != self.playerColor ){
                moveValue += 0.5f;
                // NSLog(@"UP blocking active tile top with empty upper tile at {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnTop.edgeBottom != RRTileEdgeNone 
               && tileOnTop.edgeBottom != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeTop == RRTileEdgeNone ){
                moveValue += 0.5f;
                // NSLog(@"UP blocking upper tile bottom with empty upper tile at {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeTop == self.playerColor
               && (RRPlayerColor)tileOnTop.edgeBottom != self.playerColor ){
                moveValue -= 0.5f;
                // NSLog(@"UP if im blocking my upper tile at {%.f, %.f} - substract points", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
        }
        
        
        if( (tileOnRight = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x +1, positionInGrid.y)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnRight.edgeLeft == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeRight != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeRight != self.playerColor ){
                moveValue += 0.5f;
                // NSLog(@"RIGHT #1 {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnRight.edgeLeft != RRTileEdgeNone 
               && tileOnRight.edgeLeft != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeRight == RRTileEdgeNone ){
                moveValue += 0.5f;
                // NSLog(@"RIGHT #2 {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeRight == self.playerColor
               && (RRPlayerColor)tileOnRight.edgeLeft != self.playerColor ){
                moveValue -= 0.5f;
                // NSLog(@"RIGHT #3 {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
        }
        
        
        if( (tileOnBottom = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x, positionInGrid.y -1)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnBottom.edgeTop == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeBottom != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeBottom != self.playerColor ){
                moveValue += 0.5f;
                // NSLog(@"DOWN blocking active tile bottom with empty lower tile at {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnBottom.edgeTop != RRTileEdgeNone 
               && tileOnBottom.edgeTop != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeBottom == RRTileEdgeNone ){
                moveValue += 0.5f;
                // NSLog(@"DOWN blocking bottom tile top with empty bottom tile at {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeBottom == self.playerColor
               && (RRPlayerColor)tileOnBottom.edgeTop  != self.playerColor ){
                moveValue -= 0.5f;
                // NSLog(@"DOWN if im blocking my bottom tile at {%.f, %.f} - substract points", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
        }
        
        
        if( (tileOnLeft = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x -1, positionInGrid.y)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnLeft.edgeRight == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeLeft != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeLeft != self.playerColor ){
                moveValue += 0.5f;
                // NSLog(@"LEFT #1 {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnLeft.edgeRight != RRTileEdgeNone 
               && tileOnLeft.edgeRight != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeLeft == RRTileEdgeNone ){
                moveValue += 0.5f;
                // NSLog(@"LEFT #2 {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeLeft  == self.playerColor
               && (RRPlayerColor)tileOnLeft.edgeRight != self.playerColor ){
                moveValue -= 0.5f;
                // NSLog(@"LEFT #3 {%.f, %.f}", activeTile.positionInGrid.x, activeTile.positionInGrid.y);
            }
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
