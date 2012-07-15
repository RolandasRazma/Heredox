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
#import "UDActionDestroy.h"


@implementation UDGameLayer {
    UDGameMode          _gameMode;
    
    NSMutableArray      *_deck;
    UDGameBoardLayer    *_gameBoardLayer;
    
    UDPlayerColor       _playerColor;
    
    CCLabelTTF          *_symbolsBlackLabel;
    CCLabelTTF          *_symbolsWhiteLabel;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_deck release];

    [super dealloc];
}


- (id)init {
    if( (self = [self initWithGameMode:UDGameModeClosed firstPlayerColor:UDPlayerColorWhite]) ){
        
    }
    return self;
}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    // Make first player move as it makes no sense
    [self endTurn];
}


- (void)onEnter {
    [super onEnter];
    
    [_gameBoardLayer addObserver:self forKeyPath:@"symbolsBlack" options:NSKeyValueObservingOptionNew context:NULL];
    [_gameBoardLayer addObserver:self forKeyPath:@"symbolsWhite" options:NSKeyValueObservingOptionNew context:NULL];
}


- (void)onExit {
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsBlack"];
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsWhite"];
    
    [super onExit];
}


#pragma mark -
#pragma mark UDGameLayer


+ (id)layerWithGameMode:(UDGameMode)gameMode firstPlayerColor:(UDPlayerColor)playerColor {
    return [[[self alloc] initWithGameMode:gameMode firstPlayerColor:playerColor] autorelease];
}


- (id)initWithGameMode:(UDGameMode)gameMode firstPlayerColor:(UDPlayerColor)playerColor {
	if( (self = [super init]) ) {
        [self setUserInteractionEnabled:YES];
        
        _gameMode   = gameMode;
        _playerColor= playerColor;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"UDBackground.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];

        UDButton *buttonDone = [UDButton spriteWithSpriteFrameName:@"UDButtonDone.png"];
        [buttonDone addBlock: ^{ [self endTurn]; } forControlEvents: UDButtonEventTouchUpInside];
        if( isDeviceIPad() ){
            [buttonDone setPosition:CGPointMake(100, 100)];
        }else{
            [buttonDone setPosition:CGPointMake(50, 50)];
        }
        [self addChild:buttonDone];
        

        // Add score labels
        _symbolsBlackLabel = [CCLabelTTF labelWithString:@"symbolsBlack: 0" fontName:@"Thonburi" fontSize: (isDeviceIPad()?40:20)];
        [_symbolsBlackLabel setAnchorPoint:CGPointMake(0, 1)];
        [_symbolsBlackLabel setPosition:CGPointMake(5, winSize.height)];
        [_symbolsBlackLabel setColor:ccBLACK];
        [self addChild:_symbolsBlackLabel];
        
        _symbolsWhiteLabel = [CCLabelTTF labelWithString:@"symbolsWhite: 0" fontName:@"Thonburi" fontSize: (isDeviceIPad()?40:20)];
        [_symbolsWhiteLabel setAnchorPoint:CGPointMake(1, 1)];
        [_symbolsWhiteLabel setPosition:CGPointMake(winSize.width -5, winSize.height)];
        [_symbolsWhiteLabel setColor:ccBLACK];
        [self addChild:_symbolsWhiteLabel];
        
        
        // Add board layer
        _gameBoardLayer = [[UDGameBoardLayer alloc] initWithGameMode: _gameMode];
        [self addChild:_gameBoardLayer];
        [_gameBoardLayer release];
        
        
        // Reset deck
        [self resetDeckForGameMode:gameMode];
        
        
        // Make first player move as it makes no sense
        [_gameBoardLayer addTile: [self takeTopTile] 
                        animated: NO];
    }
	return self;
}


- (void)endTurn {
    if( [_gameBoardLayer haltTilePlaces] ){

        if( _deck.count > 0 ){
            CCSprite *playerSprite;
            if( _playerColor == UDPlayerColorBlack ){
                _playerColor = UDPlayerColorWhite;
                playerSprite = [CCSprite spriteWithSpriteFrameName:@"UDTileWhite.png"];
            }else{
                _playerColor = UDPlayerColorBlack;
                playerSprite = [CCSprite spriteWithSpriteFrameName:@"UDTileBlack.png"];                
            }
            
            CGSize winSize = [[CCDirector sharedDirector] winSize];
            [playerSprite setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
            [self addChild:playerSprite];
            
            [playerSprite runAction: [CCSequence actions:
                                      [CCCallBlock actionWithBlock:^{ [_gameBoardLayer setUserInteractionEnabled:NO]; }],
                                      [CCScaleTo actionWithDuration:0.3f scale:1.2f],
                                      [CCDelayTime actionWithDuration:1.0f],
                                      [CCCallFunc actionWithTarget:self selector:@selector(takeNewTile)],
                                      [CCScaleTo actionWithDuration:0.3f scale:1.0f],
                                      [CCFadeOut actionWithDuration:0.3f],
                                      [CCCallBlock actionWithBlock:^{ [_gameBoardLayer setUserInteractionEnabled:YES]; }],
                                      [UDActionDestroy action], nil]];
        }
        
    }
}


- (void)takeNewTile {
    
    UDTile *newTile = [self takeTopTile];
    [newTile setPosition:CGPointMake(newTile.position.x -_gameBoardLayer.position.x, newTile.position.y -_gameBoardLayer.position.y)];
    
    [_gameBoardLayer addTile: newTile
                    animated: YES];
    
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
        [self addChild:tile z:-1];
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


#pragma mark -
#pragma mark NSKeyValueObserving


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if( [keyPath isEqualToString:@"symbolsBlack"] ){
        [_symbolsBlackLabel setString:[NSString stringWithFormat:@"symbolsBlack: %i", _gameBoardLayer.symbolsBlack]];
    }else if( [keyPath isEqualToString:@"symbolsWhite"] ){
        [_symbolsWhiteLabel setString:[NSString stringWithFormat:@"symbolsWhite: %i", _gameBoardLayer.symbolsWhite]];
    }
    
}


@end