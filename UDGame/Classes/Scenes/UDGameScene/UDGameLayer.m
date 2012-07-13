//
//  UDGameLayer.m
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGameLayer.h"
#import "UDTile.h"


@implementation UDGameLayer {
    UDGameMode      _gameMode;
    NSMutableArray  *_deck;
    
    UDTile          *_activeTile;
    CGPoint         _activeTileTouchOffset;
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
#pragma mark CCNode


#if DEBUG && __CC_PLATFORM_IOS
- (void)draw {
    glPushGroupMarkerEXT(0, "-[UDGameLayer draw]");
    
	[super draw];

	glPopGroupMarkerEXT();
}
#endif


#pragma mark -
#pragma mark UDGameLayer


- (id)initWithGameMode:(UDGameMode)gameMode {
	if( (self = [super init]) ) {
        _gameMode = gameMode;
        
        [self setUserInteractionEnabled:YES];
        
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"UDBackground.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite];
        
        [self resetDeckForGameMode:gameMode];
    }
	return self;
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
    for( UDTile *tile in _deck ){
        [tile setBackSideVisible: (gameMode == UDGameModeClosed)];
        [tile setPosition:CGPointMake(winSize.width -tile.textureRect.size.width /1.5, tile.textureRect.size.height /1.5)];
        [self addChild:tile];
    }
}


- (UDTile *)takeTopTile {
    UDTile *tile = [_deck objectAtIndex:0];
    [tile setBackSideVisible:NO];
    [_deck removeObject:tile];
    
    [self reorderChild:tile z:0];

    return tile;
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( _activeTile && !CGRectContainsPoint(_activeTile.boundingBox, location) ) return NO;
    
    if( !_activeTile && CGRectContainsPoint([(UDTile *)[_deck objectAtIndex:0] boundingBox], location) ){
        _activeTile = [self takeTopTile];
    }
    
    if( !_activeTile ) return NO;
    
    _activeTileTouchOffset = [_activeTile convertToNodeSpace: location];
    _activeTileTouchOffset = CGPointMake(_activeTileTouchOffset.x -_activeTile.textureRect.size.width  /2,
                                         _activeTileTouchOffset.y -_activeTile.textureRect.size.height /2);

    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    [_activeTile setPosition: CGPointMake(location.x -_activeTileTouchOffset.x *_activeTile.scaleX, location.y -_activeTileTouchOffset.y *_activeTile.scaleY)];
}


- (void)touchEndedAtLocation:(CGPoint)location {
    
}


@end