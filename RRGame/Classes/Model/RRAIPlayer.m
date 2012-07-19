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


@implementation RRAIPlayer {
    RRAILevel _dificultyLevel;
}


#pragma mark -
#pragma mark RRPlayer


- (id)initWithPlayerColor:(RRPlayerColor)playerColor {
    if( (self = [super initWithPlayerColor:playerColor]) ){
        _dificultyLevel = RRAILevelDeacon;
    }
    return self;
}


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
            // UDLog(@"x +1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x +1, positionInGrid.y)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x -1, positionInGrid.y)] ){
            // UDLog(@"x -1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x -1, positionInGrid.y)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y +1)] ){
            // UDLog(@"y +1");

            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y +1)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
        if( [gameBoard canPlaceTileAtGridLocation:CGPointMake(positionInGrid.x, positionInGrid.y -1)] ){
            // UDLog(@"y -1");
            
            RRTileMove bestMove = [self bestMoveOnGameBoard:gameBoard positionInGrid:CGPointMake(positionInGrid.x, positionInGrid.y -1)];
            if( bestMove.score >= tileMove.score ){
                tileMove = bestMove;
            }
        }
        
    }
    
    [activeTile setPosition:activeTilePosition];
    [activeTile setRotation:0];
    
    UDLog(@"!move to: {%.f, %.f} at angle: %.f confidence: %.2f", tileMove.positionInGrid.x, tileMove.positionInGrid.y, tileMove.rotation, tileMove.score);
    
    return tileMove;
}


- (RRTileMove)bestMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    RRTileMove tileMove = RRTileMoveZero;
    RRTile *activeTile = gameBoard.activeTile;
    
    [activeTile setPositionInGrid:positionInGrid];

    // TODO: padaryti tailu cauntinga. Ar tai kanors duoda?
    
    CGFloat edgeBlockModifyer = [self edgeBlockModifyerForMoveOnGameBoard:gameBoard positionInGrid:positionInGrid];
    
    for( NSUInteger angle=0; angle<=270; angle += 90 ){
        [activeTile setRotation:angle];
        
        UDLog(@"--- Calculate for %@ angle: %i color: %@", NSStringFromCGPoint(positionInGrid), angle, (self.playerColor==RRPlayerColorBlack?@"RRPlayerColorBlack":@"RRPlayerColorWhite"));
        
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
                moveValue += 0.3f;
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnTop.edgeBottom != RRTileEdgeNone 
               && tileOnTop.edgeBottom != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeTop == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeTop == self.playerColor
               && (RRPlayerColor)tileOnTop.edgeBottom != self.playerColor ){
                moveValue -= 0.5f;
            }
        }
        
        
        if( (tileOnRight = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x +1, positionInGrid.y)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnRight.edgeLeft == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeRight != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeRight != self.playerColor ){
                moveValue += 0.3f;
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnRight.edgeLeft != RRTileEdgeNone 
               && tileOnRight.edgeLeft != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeRight == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeRight == self.playerColor
               && (RRPlayerColor)tileOnRight.edgeLeft != self.playerColor ){
                moveValue -= 0.5f;
            }
        }
        
        
        if( (tileOnBottom = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x, positionInGrid.y -1)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnBottom.edgeTop == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeBottom != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeBottom != self.playerColor ){
                moveValue += 0.3f;
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnBottom.edgeTop != RRTileEdgeNone 
               && tileOnBottom.edgeTop != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeBottom == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeBottom == self.playerColor
               && (RRPlayerColor)tileOnBottom.edgeTop  != self.playerColor ){
                moveValue -= 0.5f;
            }
        }
        
        
        if( (tileOnLeft = [gameBoard tileAtGridPosition:CGPointMake(positionInGrid.x -1, positionInGrid.y)]) ) {
            
            // jaigu above yra tuscia ir su juo galiu uzdaryti active tile white +
            if(   tileOnLeft.edgeRight == RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeLeft != RRTileEdgeNone 
               && (RRPlayerColor)activeTile.edgeLeft != self.playerColor ){
                moveValue += 0.3f;
            }
            
            // jeigu above yra white ir galiu uzdaryti su active tusciu +
            if(   tileOnLeft.edgeRight != RRTileEdgeNone 
               && tileOnLeft.edgeRight != (RRTileEdge)self.playerColor 
               && (RRPlayerColor)activeTile.edgeLeft == RRTileEdgeNone ){
                moveValue += 0.3f;
            }
            
            // jeigu as blokuoju savo spalva su virsutiniu -
            if(   (RRPlayerColor)activeTile.edgeLeft  == self.playerColor
               && (RRPlayerColor)tileOnLeft.edgeRight != self.playerColor ){
                moveValue -= 0.5f;
            }
        }

        // TODO: calculate how much i will loose if next player end board size

        if( _dificultyLevel > RRAILevelNovice ){
            moveValue += [self activeTileEdgeBlockModifyerForMoveOnGameBoard:gameBoard positionInGrid:positionInGrid];
            if( _dificultyLevel > RRAILevelDeacon ){
                moveValue += edgeBlockModifyer;
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


- (CGFloat)edgeBlockModifyerForMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    CGFloat edgeBlockModifyer = 0.0f;
    
    UDLog(@"edgeBlockModifyerForMoveOnGameBoard:positionInGrid: %@", NSStringFromCGPoint(positionInGrid));
    
    if( gameBoard.gridBounds.size.height == 3 ){
        
        NSInteger upperGridBoundY = gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height -1;
        NSInteger lowerGridBoundY = gameBoard.gridBounds.origin.y;
        
        if( positionInGrid.y > upperGridBoundY ){
            UDLog(@"Check what we block on Bottom edge");
            
            for( NSInteger x=gameBoard.gridBounds.origin.x; x<gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width; x++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(x, lowerGridBoundY)];
                
                if( edgeTile.edgeBottom == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                    UDLog(@"-= 0.5f");
                }else if( edgeTile.edgeBottom != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                    UDLog(@"+= 0.3f");
                }
            }
            
        }else if( positionInGrid.y < lowerGridBoundY ){
            UDLog(@"Check what we block on Top edge");
            
            for( NSInteger x=gameBoard.gridBounds.origin.x; x<gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width; x++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(x,upperGridBoundY)];
                
                if( edgeTile.edgeTop == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                    UDLog(@"-= 0.5f");
                }else if( edgeTile.edgeTop != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                    UDLog(@"+= 0.3f");
                }
            }
            
        }
    }
    
    if( gameBoard.gridBounds.size.width == 3 ){
        
        NSInteger leftGridBoundX = gameBoard.gridBounds.origin.x;
        NSInteger rightGridBoundX = gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width -1;
        
        if( positionInGrid.x < leftGridBoundX ){
            UDLog(@"Check what we block on Right edge");
            
            for( NSInteger y=gameBoard.gridBounds.origin.y; y<gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height; y++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(rightGridBoundX, y)];
                
                if( edgeTile.edgeRight == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                    UDLog(@"-= 0.5f");
                }else if( edgeTile.edgeRight != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                    UDLog(@"+= 0.3f");
                }
            }     
            
        }else if( positionInGrid.x > rightGridBoundX ){
            UDLog(@"Check what we block on Left edge");
            
            for( NSInteger y=gameBoard.gridBounds.origin.y; y<gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height; y++ ){
                RRTile *edgeTile = [gameBoard tileAtGridPosition:CGPointMake(leftGridBoundX, y)];
                
                if( edgeTile.edgeLeft == (RRTileEdge)self.playerColor ){
                    edgeBlockModifyer -= 0.5f;
                    UDLog(@"-= 0.5f");
                }else if( edgeTile.edgeLeft != RRTileEdgeNone ){
                    edgeBlockModifyer += 0.3f;
                    UDLog(@"+= 0.3f");
                }
            } 
            
        }
    }
    
    return edgeBlockModifyer;
}


- (CGFloat)activeTileEdgeBlockModifyerForMoveOnGameBoard:(RRGameBoardLayer *)gameBoard positionInGrid:(CGPoint)positionInGrid {
    RRTile *activeTile = gameBoard.activeTile;
    CGFloat edgeBlockModifyer = 0.0f;
    
    UDLog(@"activeTileEdgeBlockModifyerForMoveOnGameBoard:positionInGrid: %@ at angle: %.f", NSStringFromCGPoint(positionInGrid), activeTile.rotation);
    
    // Active tile blocking after move
    if( gameBoard.gridBounds.size.height == 3 ){
        
        NSInteger upperGridBoundY = gameBoard.gridBounds.origin.y +gameBoard.gridBounds.size.height -1;
        NSInteger lowerGridBoundY = gameBoard.gridBounds.origin.y;
        
        if( positionInGrid.y > upperGridBoundY ){
            UDLog(@"Check what we block on top of activeTile %@", NSStringFromCGPoint(positionInGrid));
            
            if( activeTile.edgeTop == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
                UDLog(@"-= 0.5f");
            }else if( activeTile.edgeTop != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
                UDLog(@"+= 0.3f");
            }
        }else if( positionInGrid.y < lowerGridBoundY ){
            UDLog(@"Check what we block on bottom of activeTile %@", NSStringFromCGPoint(positionInGrid));
            
            if( activeTile.edgeBottom == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
                UDLog(@"-= 0.5f");
            }else if( activeTile.edgeBottom != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
                UDLog(@"+= 0.3f");
            }
        }
    }
    
    
    if( gameBoard.gridBounds.size.width == 3 ){
        
        NSInteger leftGridBoundX = gameBoard.gridBounds.origin.x;
        NSInteger rightGridBoundX = gameBoard.gridBounds.origin.x +gameBoard.gridBounds.size.width -1;
        
        if( positionInGrid.x < leftGridBoundX ){
            UDLog(@"Check what we block on left of activeTile %@", NSStringFromCGPoint(positionInGrid));
            
            if( activeTile.edgeLeft == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
                UDLog(@"-= 0.5f");
            }else if( activeTile.edgeLeft != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
                UDLog(@"+= 0.3f");
            }
        }else if( positionInGrid.x > rightGridBoundX ){
            UDLog(@"Check what we block on right of activeTile %@", NSStringFromCGPoint(positionInGrid));
            
            if( activeTile.edgeRight == (RRTileEdge)self.playerColor ){
                edgeBlockModifyer -= 0.5f;
                UDLog(@"-= 0.5f");
            }else if( activeTile.edgeRight != RRTileEdgeNone ){
                edgeBlockModifyer += 0.3f;
                UDLog(@"+= 0.3f");
            }
        }
    }
    
    
    return edgeBlockModifyer;
}


@synthesize dificultyLevel=_dificultyLevel;
@end
