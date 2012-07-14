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
    
    ccDrawColor4B(255, 0, 0, 255);
    
    for( NSInteger x=-1056; x<=1000; x+=76 ){
        for( NSInteger y=-1056; y<=1000; y+=76 ){
            ccDrawLine(CGPointMake(x, y), CGPointMake(x +76, y));
            ccDrawLine(CGPointMake(x, y), CGPointMake(x, y +76));
        }
    }

	glPopGroupMarkerEXT();
}
#endif


- (void)addTile:(UDTile *)tile {
    [self addChild:tile];
    
}


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
    
    // Snaping
    CGFloat kHGridOffset = 76 /2 +8;
    CGFloat kVGridOffset = 76 /2 +8;
    
    CGFloat kHGridSpacing = 76;
    CGFloat kVGridSpacing = 76;
    
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

/*
- (CGPoint)gridLocationFromPosition:(CGPoint)position {
    
}


- (BOOL)canPlaceTileAtGridLocation:(CGPoint)gridLocation {
//    for( UDTile *tile in _board ){
//        if( CGPointEqualToPoint(tile.gridLocation, gridLocation) ) return NO;
 //   }
    return YES;
} */


- (void)resetBoardForGameMode:(UDGameMode)gameMode {
    [self removeAllChildrenWithCleanup:YES];
    
    //[_board release];
    //_board = [[NSMutableArray alloc] initWithCapacity:16];
}


- (void)addTile:(UDTile *)tile asActive:(BOOL)asActive {
    if( asActive ){
        [self haltTilePlaces];
        _activeTile = tile;
    }
    [self addChild:tile];
}


- (void)haltTilePlaces {
    [_activeTile setPosition: [self snapPoint:_activeTile.position toGridWithTolerance: CGFLOAT_MAX]];
    _activeTile = nil;
    
    [self centerBoardAnimated:(self.children.count >1)];
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

    if( animated ){
        [self runAction: [CCMoveTo actionWithDuration:0.3f position:newPosition]];
    }else{
        [self setPosition:newPosition];
    }
}



/*
 - (void)showGuides {
 CCSprite *guideSprite = [CCSprite spriteWithSpriteFrameName:@"UDBoardGuide.png"];
 [guideSprite setAnchorPoint:CGPointZero];
 [self addChild:guideSprite];  
 } */




#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( !_activeTile || [_activeTile numberOfRunningActions] || !CGRectContainsPoint(_activeTile.boundingBox, [self convertToNodeSpace:location])) return NO;
    
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
    
    newPosition = [self snapPoint: newPosition toGridWithTolerance: 10];
    
    // Move tile
    [_activeTile setPosition: newPosition];    
}


- (void)touchEndedAtLocation:(CGPoint)location {
    if( !_activeTileMoved ){
        [_activeTile runAction:[CCRotateBy actionWithDuration:0.3f angle:90]];
    }else{
        [_activeTile setPosition: [self snapPoint: _activeTile.position toGridWithTolerance: _activeTile.boundingBox.size.width]];
    }
}


@end
