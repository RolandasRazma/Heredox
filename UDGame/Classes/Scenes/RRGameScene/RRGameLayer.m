//
//  UDGameLayer.m
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameLayer.h"
#import "RRTile.h"
#import "UDSpriteButton.h"
#import "RRGameBoardLayer.h"
#import "UDActionDestroy.h"
#import "RRAI.h"


@implementation RRGameLayer {
    RRGameMode          _gameMode;
    
    NSMutableArray      *_deck;
    RRGameBoardLayer    *_gameBoardLayer;
    
    RRPlayerColor       _playerColor;
    
    CCLabelTTF          *_symbolsBlackLabel;
    CCLabelTTF          *_symbolsWhiteLabel;
    UDSpriteButton      *_buttonEndTurn;
    
    RRAI                *_AI;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_deck release];

    [super dealloc];
}


- (id)init {
    if( (self = [self initWithGameMode:RRGameModeClosed firstPlayerColor:RRPlayerColorWhite]) ){
        
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


+ (id)layerWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor {
    return [[[self alloc] initWithGameMode:gameMode firstPlayerColor:playerColor] autorelease];
}


- (id)initWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor {
	if( (self = [super init]) ) {
        [self setUserInteractionEnabled:YES];
        
        _gameMode   = gameMode;
        _playerColor= playerColor;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"UDBackground.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];

        // Add End Turn
        _buttonEndTurn = [UDSpriteButton spriteWithSpriteFrameName:@"UDButtonDone.png"];
        [_buttonEndTurn addBlock: ^{ [self endTurn]; } forControlEvents: UDButtonEventTouchUpInside];
        if( isDeviceIPad() ){
            [_buttonEndTurn setPosition:CGPointMake(100, 100)];
        }else{
            [_buttonEndTurn setPosition:CGPointMake(50, 50)];
        }
        [self addChild:_buttonEndTurn];
        

        // Add score labels
        _symbolsBlackLabel = [CCLabelTTF labelWithString:@"Black: 0" fontName:@"Courier" fontSize: (isDeviceIPad()?40:20)];
        [_symbolsBlackLabel setAnchorPoint:CGPointMake(0, 1)];
        [_symbolsBlackLabel setPosition:CGPointMake(5, winSize.height)];
        [_symbolsBlackLabel setColor:ccBLACK];
        [self addChild:_symbolsBlackLabel];
        
        _symbolsWhiteLabel = [CCLabelTTF labelWithString:@"White: 0" fontName:@"Courier" fontSize: (isDeviceIPad()?40:20)];
        [_symbolsWhiteLabel setAnchorPoint:CGPointMake(1, 1)];
        [_symbolsWhiteLabel setPosition:CGPointMake(winSize.width -5, winSize.height)];
        [_symbolsWhiteLabel setColor:ccBLACK];
        [self addChild:_symbolsWhiteLabel];
        
        
        // Add board layer
        _gameBoardLayer = [[RRGameBoardLayer alloc] initWithGameMode: _gameMode];
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
            if( _playerColor == RRPlayerColorBlack ){
                _playerColor = RRPlayerColorWhite;
                playerSprite = [CCSprite spriteWithSpriteFrameName:@"UDTileWhite.png"];
            }else{
                _playerColor = RRPlayerColorBlack;
                playerSprite = [CCSprite spriteWithSpriteFrameName:@"UDTileBlack.png"];                
            }
            
            CGSize winSize = [[CCDirector sharedDirector] winSize];
            [playerSprite setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
            [self addChild:playerSprite];
            
            [playerSprite runAction: [CCSequence actions:
                                      [CCCallBlock actionWithBlock:^{ [_gameBoardLayer setUserInteractionEnabled:NO]; }],
                                      [CCScaleTo actionWithDuration:0.1f scale:1.2f],
                                      [CCDelayTime actionWithDuration:0.7f],
                                      [CCCallFunc actionWithTarget:self selector:@selector(takeNewTile)],
                                      [CCDelayTime actionWithDuration:0.5f],
                                      [CCScaleTo actionWithDuration:0.3f scale:1.0f],
                                      [CCFadeOut actionWithDuration:0.3f],
                                      [CCCallBlock actionWithBlock:^{ [_gameBoardLayer setUserInteractionEnabled:YES]; }],
                                      [CCCallFunc actionWithTarget:self selector:@selector(newTurn)],
                                      [UDActionDestroy action], nil]];
        }else{
            [_buttonEndTurn runAction: [CCFadeOut actionWithDuration:0.3f]];
        }
        
    }
}


- (void)newTurn {
    
    if( _AI && _AI.playerColor == _playerColor ){
        [_gameBoardLayer setUserInteractionEnabled:NO];
        
        RRTileMove tileMove = [_AI bestMoveOnBoard:_gameBoardLayer];
        [_gameBoardLayer.activeTile setPositionInGrid:tileMove.positionInGrid];
        [_gameBoardLayer.activeTile setRotation:tileMove.rotation];
        
        [_gameBoardLayer setUserInteractionEnabled:YES];
        
        [self endTurn];
    }
    
}


- (void)takeNewTile {
    
    RRTile *newTile = [self takeTopTile];
    [newTile setPosition:CGPointMake(newTile.position.x -_gameBoardLayer.position.x, newTile.position.y -_gameBoardLayer.position.y)];
    
    [_gameBoardLayer addTile: newTile
                    animated: YES];
    
}


- (void)resetDeckForGameMode:(RRGameMode)gameMode {
    [_deck release];
    _deck = [[NSMutableArray alloc] initWithCapacity:16];
    
    // 2x RRTileEdgeWhite RRTileEdgeNone RRTileEdgeBlack RRTileEdgeNone
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeNone bottom:RRTileEdgeBlack right:RRTileEdgeNone]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeNone bottom:RRTileEdgeBlack right:RRTileEdgeNone]];
    
    // 3x RRTileEdgeWhite RRTileEdgeNone RRTileEdgeNone RRTileEdgeBlack
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeNone bottom:RRTileEdgeNone right:RRTileEdgeBlack]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeNone bottom:RRTileEdgeNone right:RRTileEdgeBlack]];    
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeNone bottom:RRTileEdgeNone right:RRTileEdgeBlack]];

    // 3x RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeNone RRTileEdgeNone
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeBlack bottom:RRTileEdgeNone right:RRTileEdgeNone]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeBlack bottom:RRTileEdgeNone right:RRTileEdgeNone]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeBlack bottom:RRTileEdgeNone right:RRTileEdgeNone]];

    // 4x RRTileEdgeWhite RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeBlack
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeWhite bottom:RRTileEdgeBlack right:RRTileEdgeBlack]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeWhite bottom:RRTileEdgeBlack right:RRTileEdgeBlack]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeWhite bottom:RRTileEdgeBlack right:RRTileEdgeBlack]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeWhite bottom:RRTileEdgeBlack right:RRTileEdgeBlack]];
    
    // 4x RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeWhite RRTileEdgeBlack
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeBlack bottom:RRTileEdgeWhite right:RRTileEdgeBlack]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeBlack bottom:RRTileEdgeWhite right:RRTileEdgeBlack]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeBlack bottom:RRTileEdgeWhite right:RRTileEdgeBlack]];
    [_deck addObject: [RRTile tileWithEdgeTop:RRTileEdgeWhite left:RRTileEdgeBlack bottom:RRTileEdgeWhite right:RRTileEdgeBlack]];
    
    [_deck shuffleWithSeed:time(NULL)];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    for( RRTile *tile in [_deck reverseObjectEnumerator] ){
        [tile setBackSideVisible: (gameMode == RRGameModeClosed)];
        [tile setPosition:CGPointMake(winSize.width -tile.textureRect.size.width /1.5, tile.textureRect.size.height /1.5)];
        [self addChild:tile z:-1];
    }
}


- (RRTile *)takeTopTile {
    if( _deck.count == 0 ) return nil;
    
    RRTile *tile = [[_deck objectAtIndex:0] retain];
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
        [_symbolsBlackLabel setString:[NSString stringWithFormat:@"Black: %i", _gameBoardLayer.symbolsBlack]];
        
        [_symbolsBlackLabel runAction: [CCSequence actions:
                                        [CCScaleTo actionWithDuration:0.3f scale:1.1f],
                                        [CCScaleTo actionWithDuration:0.3f scale:1.0f], nil]];
    }else if( [keyPath isEqualToString:@"symbolsWhite"] ){
        [_symbolsWhiteLabel setString:[NSString stringWithFormat:@"White: %i", _gameBoardLayer.symbolsWhite]];
        
        [_symbolsWhiteLabel runAction: [CCSequence actions:
                                        [CCScaleTo actionWithDuration:0.3f scale:1.1f],
                                        [CCScaleTo actionWithDuration:0.3f scale:1.0f], nil]];
    }
    
}


@synthesize AI=_AI;
@end