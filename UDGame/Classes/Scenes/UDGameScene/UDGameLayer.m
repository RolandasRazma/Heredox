//
//  UDGameLayer.m
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGameLayer.h"
#import "UDTile.h"
#import "UDButton.h"


@implementation UDGameLayer {
    UDGameMode      _gameMode;
    NSMutableArray  *_deck;
    
    CGPoint         _activeTileLastPosition;
    
    UDTile          *_activeTile;
    CGPoint         _activeTileTouchOffset;
    BOOL            _activeTileMoved;
    BOOL            _activeTileFlipped;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_deck release];
    
    [super dealloc];
}


- (id)init {
    if( (self = [self initWithGameMode:UDGameModeClosed]) ){
        
    }
    return self;
}


#pragma mark -
#pragma mark UDGameLayer


- (id)initWithGameMode:(UDGameMode)gameMode {
	if( (self = [super init]) ) {
        _gameMode = gameMode;
        
        [self setUserInteractionEnabled:YES];
                
        [self resetDeckForGameMode:gameMode];

        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"UDBackground.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite];

        CGSize tileSize = [(UDTile *)[_deck objectAtIndex:0] textureRect].size;
        

        UDButton *buttonDone = [UDButton spriteWithSpriteFrameName:@"UDButtonDone.png"];
        [buttonDone addBlock: ^{ [self endTurn]; } forControlEvents: UDButtonEventTouchUpInside];
        [buttonDone setPosition:CGPointMake(tileSize.width /1.5, tileSize.height /1.5)];
        [self addChild:buttonDone];
    }
	return self;
}


- (void)endTurn {
    _activeTile = nil;
}


- (void)resetDeckForGameMode:(UDGameMode)gameMode {
    [_deck release];
    _deck = [[NSMutableArray alloc] initWithCapacity:16];
    
    // 2x UDTileEdgeWhite UDTileEdgeNone UDTileEdgeBlack UDTileEdgeNone
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeNone bottom:UDTileEdgeBlack right:UDTileEdgeNone]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeNone bottom:UDTileEdgeBlack right:UDTileEdgeNone]];
    
    // 3x UDTileEdgeWhite UDTileEdgeNone UDTileEdgeNone UDTileEdgeBlack
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeNone bottom:UDTileEdgeNone right:UDTileEdgeBlack]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeNone bottom:UDTileEdgeNone right:UDTileEdgeBlack]];    
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeNone bottom:UDTileEdgeNone right:UDTileEdgeBlack]];

    // 3x UDTileEdgeWhite UDTileEdgeBlack UDTileEdgeNone UDTileEdgeNone
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeBlack bottom:UDTileEdgeNone right:UDTileEdgeNone]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeBlack bottom:UDTileEdgeNone right:UDTileEdgeNone]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeBlack bottom:UDTileEdgeNone right:UDTileEdgeNone]];

    // 4x UDTileEdgeWhite UDTileEdgeWhite UDTileEdgeBlack UDTileEdgeBlack
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeWhite bottom:UDTileEdgeBlack right:UDTileEdgeBlack]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeWhite bottom:UDTileEdgeBlack right:UDTileEdgeBlack]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeWhite bottom:UDTileEdgeBlack right:UDTileEdgeBlack]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeWhite bottom:UDTileEdgeBlack right:UDTileEdgeBlack]];
    
    // 4x UDTileEdgeWhite UDTileEdgeBlack UDTileEdgeWhite UDTileEdgeBlack
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeBlack bottom:UDTileEdgeWhite right:UDTileEdgeBlack]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeBlack bottom:UDTileEdgeWhite right:UDTileEdgeBlack]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeBlack bottom:UDTileEdgeWhite right:UDTileEdgeBlack]];
    [_deck addObject: [UDTile tileWithEdgeTop:UDTileEdgeWhite left:UDTileEdgeBlack bottom:UDTileEdgeWhite right:UDTileEdgeBlack]];
    
    [_deck shuffleWithSeed:time(NULL)];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    //CGFloat rotation = 0.0f;
    for( UDTile *tile in _deck ){
        [tile setBackSideVisible: (gameMode == UDGameModeClosed)];
        [tile setPosition:CGPointMake(winSize.width -tile.textureRect.size.width /1.5, tile.textureRect.size.height /1.5)];
        //[tile setRotation:rotation];
        [self addChild:tile z:1];
        
        //rotation += 1.0f;
    }
}


- (UDTile *)takeTopTile {
    UDTile *tile = [_deck objectAtIndex:0];
    [tile setRotation:0.0f];
    [tile setBackSideVisible:NO];
    [_deck removeObject:tile];
    
    [self reorderChild:tile z:1];

    return tile;
}


#pragma mark -
#pragma mark UDLayer


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


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( _activeTile && !CGRectContainsPoint(_activeTile.boundingBox, location) ) return NO;
    if( [_activeTile numberOfRunningActions] ) return NO;
    
    _activeTileFlipped = NO;
    
    if( !_activeTile && CGRectContainsPoint([(UDTile *)[_deck objectAtIndex:0] boundingBox], location) ){
        _activeTile         = [self takeTopTile];
        _activeTileFlipped  = YES;
    }
    
    if( !_activeTile ) return NO;
    
    _activeTileMoved        = NO;
    _activeTileTouchOffset  = ccpRotateByAngle([_activeTile convertToNodeSpaceAR: location], CGPointZero, -CC_DEGREES_TO_RADIANS(_activeTile.rotation));
    _activeTileLastPosition = CGPointMake(location.x -_activeTileTouchOffset.x *_activeTile.scaleX, location.y -_activeTileTouchOffset.y *_activeTile.scaleY);
    
    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {

    CGPoint newPosition = CGPointMake(location.x -_activeTileTouchOffset.x *_activeTile.scaleX, location.y -_activeTileTouchOffset.y *_activeTile.scaleY);

    if( ccpDistance(_activeTileLastPosition, newPosition) >= 10 ){
        _activeTileMoved = YES;
    }
    
    newPosition = [self snapPoint: newPosition toGridWithTolerance: 10];

    // Move tile
    [_activeTile setPosition: newPosition];    
}


- (void)touchEndedAtLocation:(CGPoint)location {
    if( !_activeTileMoved && !_activeTileFlipped ){
        [_activeTile runAction:[CCRotateBy actionWithDuration:0.3f angle:90]];
    }else{
        [_activeTile setPosition: [self snapPoint: _activeTile.position toGridWithTolerance: _activeTile.boundingBox.size.width]];
    }
}


@end