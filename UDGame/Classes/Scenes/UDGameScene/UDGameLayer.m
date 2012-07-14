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
#import "UDGameBoardLayer.h"


@implementation UDGameLayer {
    UDGameMode          _gameMode;
    NSMutableArray      *_deck;
    UDGameBoardLayer    *_gameBoardLayer;
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
        [self setUserInteractionEnabled:YES];
        
        _gameMode = gameMode;

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"UDBackground.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite];

        UDButton *buttonDone = [UDButton spriteWithSpriteFrameName:@"UDButtonDone.png"];
        [buttonDone addBlock: ^{ [self endTurn]; } forControlEvents: UDButtonEventTouchUpInside];
        [buttonDone setPosition:CGPointMake(50, 50)];
        [self addChild:buttonDone];
        
        // Add board layer
        _gameBoardLayer = [[UDGameBoardLayer alloc] initWithGameMode: _gameMode];
        [self addChild:_gameBoardLayer z:1];
        [_gameBoardLayer release];
        
        
        // Reset deck
        [self resetDeckForGameMode:gameMode];
        
        // Make first player move as it makes no sense
        [_gameBoardLayer addTile: [self takeTopTile] 
                        asActive: YES];
        [self endTurn];
    }
	return self;
}


- (void)endTurn {
    if( [_gameBoardLayer haltTilePlaces] ){
        
        if( _deck.count > 0 ){
            UDTile *newTile = [self takeTopTile];
            [newTile setPosition:CGPointMake(newTile.position.x -_gameBoardLayer.position.x, newTile.position.y -_gameBoardLayer.position.y)];
            
            [_gameBoardLayer addTile: newTile
                            asActive: YES];
        }
        
    }
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
    for( UDTile *tile in [_deck reverseObjectEnumerator] ){
        [tile setBackSideVisible: (gameMode == UDGameModeClosed)];
        [tile setPosition:CGPointMake(winSize.width -tile.textureRect.size.width /1.5, tile.textureRect.size.height /1.5)];
        [self addChild:tile];
    }
}


- (UDTile *)takeTopTile {
    if( _deck.count == 0 ) return nil;
    
    UDTile *tile = [[_deck objectAtIndex:0] retain];
    [tile setRotation:0.0f];
    [tile setBackSideVisible:NO];
    [_deck removeObject:tile];
    
    [self removeChild:tile cleanup:NO];

    return [tile autorelease];
}


@end