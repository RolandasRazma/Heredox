//
//  UDGameBoardLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGameBoardLayer.h"
#import "UDTile.h"


@implementation UDGameBoardLayer {
    UDGameMode          _gameMode;
    
    NSUInteger          _symbolsBlack;
    NSUInteger          _symbolsWhite;
    
    CGPoint             _activeTileLastPosition;
    
    UDTile              *_activeTile;
    CGPoint             _activeTileTouchOffset;
    BOOL                _activeTileMoved;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {

    [super dealloc];
}


#pragma mark -
#pragma mark CCNode


#if DEBUG && __CC_PLATFORM_IOS
- (void)draw {
    glPushGroupMarkerEXT(0, "-[UDGameScene draw]");
    
	[super draw];
    
    /*
    ccDrawColor4B(255, 0, 0, 255);

    for( NSInteger x=-1056; x<=1000; x+=76 ){
        for( NSInteger y=-1056; y<=1000; y+=76 ){
            ccDrawLine(CGPointMake(x, y), CGPointMake(x +76, y));
            ccDrawLine(CGPointMake(x, y), CGPointMake(x, y +76));
        }
    }
    */

	glPopGroupMarkerEXT();
}
#endif


#pragma mark -
#pragma mark UDGameBoardLayer


- (id)initWithGameMode:(UDGameMode)gameMode {
	if( (self = [super init]) ) {
        [self setUserInteractionEnabled:YES];
                                      
        _gameMode = gameMode;
        
        // Reset board
        [self resetBoardForGameMode:gameMode];
    }
    
    return self;
}


- (CGPoint)snapPoint:(CGPoint)point toGridWithTolerance:(CGFloat)tolerance {

    // Tile size
    const CGFloat tileSize = [UDTile tileSize];
    
    // Snaping
    CGFloat kHGridOffset = tileSize /2 +8;
    CGFloat kVGridOffset = tileSize /2 +8;
    
    CGFloat kHGridSpacing = tileSize;
    CGFloat kVGridSpacing = tileSize;
    
    CGPoint snapedPosition;
    snapedPosition.x = floor((point.x -kHGridOffset) /kHGridSpacing +0.5f) *kHGridSpacing +kHGridOffset;
    snapedPosition.y = floor((point.y -kVGridOffset) /kVGridSpacing +0.5f) *kVGridSpacing +kVGridOffset;
    
    if( abs(snapedPosition.x -point.x) <= tolerance ){
        point.x = snapedPosition.x;
    }
    
    if( abs(snapedPosition.y -point.y) <= tolerance ){
        point.y = snapedPosition.y;
    }
    
    return point;
}


- (BOOL)canPlaceTileAtGridLocation:(CGPoint)gridLocation {
    if( self.children.count < 2 ) return YES;
    
    NSInteger minX = NSIntegerMax;
    NSInteger minY = NSIntegerMax;
    NSInteger maxX = NSIntegerMin;
    NSInteger maxY = NSIntegerMin;
    BOOL foundTouchPoint = NO;
    
    for( UDTile *tile in self.children ){
        CGPoint positionInGrid = tile.positionInGrid;
        if ( ![tile isEqual:_activeTile] && CGPointEqualToPoint(positionInGrid, gridLocation) ) return NO;

        if( foundTouchPoint == NO ){
            foundTouchPoint = 
                    (positionInGrid.x +1 == gridLocation.x && positionInGrid.y == gridLocation.y)
                ||  (positionInGrid.x -1 == gridLocation.x && positionInGrid.y == gridLocation.y)
                ||  (positionInGrid.y +1 == gridLocation.y && positionInGrid.x == gridLocation.x)
                ||  (positionInGrid.y -1 == gridLocation.y && positionInGrid.x == gridLocation.x);
        }
        
        minX = MIN(minX, positionInGrid.x);
        minY = MIN(minY, positionInGrid.y);
        
        maxX = MAX(maxX, positionInGrid.x);
        maxY = MAX(maxY, positionInGrid.y);
    }
    
    if( foundTouchPoint == NO ) return NO;

    if( (maxX -minX +1) > 4 ) return NO;
    if( (maxY -minY +1) > 4 ) return NO;

    return YES;
}


- (void)resetBoardForGameMode:(UDGameMode)gameMode {
    [self removeAllChildrenWithCleanup:YES];
    
    _symbolsBlack = _symbolsWhite = 0;
}


- (void)addTile:(UDTile *)tile animated:(BOOL)animated {
    _activeTile = tile;
    [self addChild:tile];
    
    if( animated ){
        [tile setOpacity:0];
        [tile runAction:[CCFadeIn actionWithDuration:0.3f]];
    }
}


- (BOOL)haltTilePlaces {
    [_activeTile setPosition: [self snapPoint:_activeTile.position toGridWithTolerance: CGFLOAT_MAX]];
    
    if( [self canPlaceTileAtGridLocation:_activeTile.positionInGrid] ){
        [self checkForSymbolsAtTile:_activeTile];
        
        _activeTile = nil;
        
        [self centerBoardAnimated:(self.children.count >1)];        
        
        return YES;
    }

    return NO;
}


- (void)checkForSymbolsAtTile:(UDTile *)tile {
    CGPoint gridLocation = _activeTile.positionInGrid;
    
    for( UDTile *tile in self.children ){
        if( [tile isEqual:_activeTile] ) continue;
        
        CGPoint positionInGrid = tile.positionInGrid;
        
        if( positionInGrid.x +1 == gridLocation.x && positionInGrid.y == gridLocation.y ){
            if( _activeTile.edgeLeft == tile.edgeRight && _activeTile.edgeLeft != UDTileEdgeNone ){
                // | <-
                [self addPointForEdge:_activeTile.edgeLeft];
            }
        }
        
        if( positionInGrid.x -1 == gridLocation.x && positionInGrid.y == gridLocation.y ){
            if( _activeTile.edgeRight == tile.edgeLeft && _activeTile.edgeRight != UDTileEdgeNone ){
                // -> |
                [self addPointForEdge:_activeTile.edgeRight];
            }
        }
        
        if( positionInGrid.y +1 == gridLocation.y && positionInGrid.x == gridLocation.x ){
            if( _activeTile.edgeBottom == tile.edgeTop && _activeTile.edgeBottom != UDTileEdgeNone ){
                // __
                [self addPointForEdge:_activeTile.edgeBottom];
            }                            
        }
        
        if( positionInGrid.y -1 == gridLocation.y && positionInGrid.x == gridLocation.x ){
            if( _activeTile.edgeTop == tile.edgeBottom && _activeTile.edgeTop != UDTileEdgeNone ){
                // ^^
                [self addPointForEdge:_activeTile.edgeTop];
            }
        }
    }
}


- (void)addPointForEdge:(UDTileEdge)tileEdge {
    
    if( tileEdge == UDTileEdgeBlack ){
        [self willChangeValueForKey: @"symbolsBlack"];
        _symbolsBlack++;
        [self didChangeValueForKey: @"symbolsBlack"];
    }else if( tileEdge == UDTileEdgeWhite ){
        [self willChangeValueForKey: @"symbolsWhite"];
        _symbolsWhite++;
        [self didChangeValueForKey: @"symbolsWhite"];
    }

}


- (void)centerBoardAnimated:(BOOL)animated {
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    CGPoint newPosition;
    
    if( self.children.count == 0 ) {
        newPosition = CGPointMake(winSize.width /2, winSize.height /2);
    }else{
        CGRect tileBounds = CGRectMake(CGFLOAT_MAX, CGFLOAT_MAX, CGFLOAT_MIN, CGFLOAT_MIN);
        
        for( UDTile *tile in self.children ){
            if ( [tile isEqual:_activeTile] ) continue;
            
            tileBounds.origin.x     = MIN(tileBounds.origin.x, tile.position.x -tile.boundingBox.size.width  /2);
            tileBounds.origin.y     = MIN(tileBounds.origin.y, tile.position.y -tile.boundingBox.size.height /2);
            
            tileBounds.size.width   = MAX(tileBounds.size.width,  tile.position.x +tile.boundingBox.size.width  /2);
            tileBounds.size.height  = MAX(tileBounds.size.height, tile.position.y +tile.boundingBox.size.height /2);
        }
        
        tileBounds.size.width  -= tileBounds.origin.x;
        tileBounds.size.height -= tileBounds.origin.y;
        
        newPosition = CGPointMake((winSize.width  -tileBounds.size.width)  /2 -tileBounds.origin.x, 
                                  (winSize.height -tileBounds.size.height) /2 -tileBounds.origin.y);
    }

    // Offset
    newPosition.y += 30;
    
    if( animated ){
        [self runAction: [CCMoveTo actionWithDuration:0.3f position:newPosition]];
    }else{
        [self setPosition:newPosition];
    }
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( !_activeTile || [_activeTile numberOfRunningActions] || !CGRectContainsPoint(_activeTile.boundingBox, [self convertToNodeSpace:location])) return NO;
    
    [_activeTile setScale:1.1f];
    
    _activeTileMoved        = NO;
    _activeTileTouchOffset  = ccpRotateByAngle([_activeTile convertToNodeSpaceAR:location], CGPointZero, -CC_DEGREES_TO_RADIANS(_activeTile.rotation));
    _activeTileLastPosition = CGPointMake(location.x -_activeTileTouchOffset.x *_activeTile.scaleX, 
                                          location.y -_activeTileTouchOffset.y *_activeTile.scaleY);
    
    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    location = [self convertToNodeSpace:location];
    
    CGPoint newPosition = CGPointMake(location.x -_activeTileTouchOffset.x *_activeTile.scaleX, 
                                      location.y -_activeTileTouchOffset.y *_activeTile.scaleY);
    
    if( ccpDistance(_activeTileLastPosition, newPosition) >= 10 ){
        _activeTileMoved = YES;
    }
    
    if( [self canPlaceTileAtGridLocation:_activeTile.positionInGrid] ){
        newPosition = [self snapPoint: newPosition toGridWithTolerance: 10];
    }
    
    // Move tile
    [_activeTile setPosition: newPosition];    
}


- (void)touchEndedAtLocation:(CGPoint)location {
    
    if( !_activeTileMoved ){
        [_activeTile setScale:1.0f];
        
        [_activeTile runAction: [CCRotateBy actionWithDuration:0.2f angle:90]];
    }else if( [self canPlaceTileAtGridLocation:_activeTile.positionInGrid] ){
        [_activeTile setScale:1.0f];
        
        CGPoint snapPosition = [self snapPoint: _activeTile.position toGridWithTolerance: _activeTile.boundingBox.size.width];
        [_activeTile setPosition: snapPosition];  
    }
    
}


@synthesize symbolsBlack=_symbolsBlack, symbolsWhite=_symbolsWhite;
@end
