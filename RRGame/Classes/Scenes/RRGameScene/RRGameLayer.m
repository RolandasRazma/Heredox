//
//  UDGameLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameLayer.h"
#import "RRTile.h"
#import "UDSpriteButton.h"
#import "RRGameBoardLayer.h"
#import "RRAIPlayer.h"
#import "RRMenuScene.h"
#import "RRCrossfadeLayer.h"
#import "RRScoreLayer.h"


@implementation RRGameLayer {
    RRGameMode          _gameMode;
    
    NSMutableArray      *_deck;
    RRGameBoardLayer    *_gameBoardLayer;
    
    RRPlayerColor       _playerColor;
    RRPlayerColor       _firstPlayerColor;

    UDSpriteButton      *_buttonEndTurn;
    
    RRPlayer            *_player1;
    RRPlayer            *_player2;
    
    RRCrossfadeLayer    *_backgroundLayer;
    RRScoreLayer        *_scoreLayer;
    UDSpriteButton      *_resetGameButton;
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
    [self takeNewTile];
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
        
        _gameMode           = gameMode;
        _firstPlayerColor   = playerColor;
        _playerColor        = RRPlayerColorWhite;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        // Add background
        _backgroundLayer = [RRCrossfadeLayer node];
        [self addChild:_backgroundLayer z:-10];
        
        CCSprite *backgroundBlackSprite = [CCSprite spriteWithFile:@"RRBackgroundBlack.png"];
        [backgroundBlackSprite setAnchorPoint:CGPointZero];
        [_backgroundLayer addChild:backgroundBlackSprite z:0 tag:RRPlayerColorBlack];

        CCSprite *backgroundWhiteSprite = [CCSprite spriteWithFile:@"RRBackgroundWhite.png"];
        [backgroundWhiteSprite setAnchorPoint:CGPointZero];
        [_backgroundLayer addChild:backgroundWhiteSprite z:0 tag:RRPlayerColorWhite];
        
        [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:0.0f];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonHome.png"];
        [buttonHome setPosition:CGPointMake(655, 915)];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        
        
        // Add End Turn
        _buttonEndTurn = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonDone.png"];
        [_buttonEndTurn addBlock: ^{ [self endTurn]; } forControlEvents: UDButtonEventTouchUpInside];
        [_buttonEndTurn setPosition:CGPointMake(winSize.width -[RRTile tileSize] /1.5f, [RRTile tileSize] /1.5f)];
        [self addChild:_buttonEndTurn z:-2];
        
        // Add score labels
        _scoreLayer = [RRScoreLayer node];
        [self addChild:_scoreLayer];
        
        // Add board layer
        _gameBoardLayer = [[RRGameBoardLayer alloc] initWithGameMode: _gameMode];
        [self addChild:_gameBoardLayer];
        [_gameBoardLayer release];
        
        
        // Reset deck
        [self resetDeckForGameMode:gameMode];
    }
	return self;
}


- (void)showMenu {

	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];

}


- (void)endTurn {
    NSLog(@"-- endTurn --");
    
    if( [_gameBoardLayer haltTilePlaces] ){
#if TARGET_IPHONE_SIMULATOR
        if( _gameBoardLayer.gridBounds.size.width == 4 || _gameBoardLayer.gridBounds.size.height == 4 ) return;
#endif
        if( _deck.count > 0 ){
            if( _playerColor == RRPlayerColorBlack ){
                _playerColor = RRPlayerColorWhite;

                [_backgroundLayer fadeToSpriteWithTag: RRPlayerColorWhite duration:0.7f];
            }else{
                _playerColor = RRPlayerColorBlack;
                
                [_backgroundLayer fadeToSpriteWithTag: RRPlayerColorBlack duration:0.7f];
            }
            
            [self takeNewTile];
            [self newTurn];
        }else{
            if( !_resetGameButton ){
                _resetGameButton = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonHeredox.png"];
                [_resetGameButton setPosition:CGPointMake(405, 66)];
                [_resetGameButton setOpacity:0];
                [_resetGameButton addBlock: ^{ [self resetGame]; } forControlEvents: UDButtonEventTouchUpInside];
                [self addChild:_resetGameButton];
            }

            [_resetGameButton runAction:[CCFadeIn actionWithDuration:0.3f]];
            [_buttonEndTurn runAction: [CCFadeOut actionWithDuration:0.3f]];
        }
        
    }
    
}


- (void)newTurn {

    if( _player1.playerColor == _playerColor ){
        if( [_player1 isKindOfClass:[RRAIPlayer class]] ){
            [_gameBoardLayer setUserInteractionEnabled:NO];
            
            RRTileMove tileMove = [(RRAIPlayer *)_player1 bestMoveOnBoard:_gameBoardLayer];

            [_gameBoardLayer.activeTile runAction:[CCSequence actions:
                                                   [UDActionCallFunc actionWithSelector:@selector(liftTile)],
                                                   [CCMoveTo actionWithDuration:0.3f position:CGPointMake(tileMove.positionInGrid.x *[RRTile tileSize] +[RRTile tileSize] /2, 
                                                                                                          tileMove.positionInGrid.y *[RRTile tileSize] +[RRTile tileSize] /2)],
                                                   [CCRotateTo actionWithDuration:0.2f angle:tileMove.rotation],
                                                   [UDActionCallFunc actionWithSelector:@selector(placeTile)],
                                                   
                                                   [CCCallBlock actionWithBlock:^{ [_gameBoardLayer setUserInteractionEnabled:YES]; }],
                                                   [CCCallFunc actionWithTarget: self selector:@selector(endTurn)],
                                                   nil]];
        }
    }else if( _player2.playerColor == _playerColor ){
        if( [_player2 isKindOfClass:[RRAIPlayer class]] ){
            [_gameBoardLayer setUserInteractionEnabled:NO];
            
            RRTileMove tileMove = [(RRAIPlayer *)_player2 bestMoveOnBoard:_gameBoardLayer];

            [_gameBoardLayer.activeTile runAction:[CCSequence actions:
                                                   [UDActionCallFunc actionWithSelector:@selector(liftTile)],
                                                   [CCMoveTo actionWithDuration:0.3f position:CGPointMake(tileMove.positionInGrid.x *[RRTile tileSize] +[RRTile tileSize] /2, 
                                                                                                          tileMove.positionInGrid.y *[RRTile tileSize] +[RRTile tileSize] /2)],
                                                   [CCRotateTo actionWithDuration:0.2f angle:tileMove.rotation],
                                                   [UDActionCallFunc actionWithSelector:@selector(placeTile)],
                                                   
                                                   [CCCallBlock actionWithBlock:^{ [_gameBoardLayer setUserInteractionEnabled:YES]; }],
                                                   [CCCallFunc actionWithTarget: self selector:@selector(endTurn)],
                                                   nil]];
        }
    }
    
}


- (void)takeNewTile {
    
    RRTile *newTile = [self takeTopTile];
    [newTile setPosition:CGPointMake(newTile.position.x -_gameBoardLayer.position.x, newTile.position.y -_gameBoardLayer.position.y)];
    
    [_gameBoardLayer addTile: newTile
                    animated: YES];
    
}


- (void)resetGame {
    [self resetDeckForGameMode:_gameMode];
    [_gameBoardLayer resetBoardForGameMode: _gameMode];
    
    _playerColor = _firstPlayerColor;
    
    [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:0.0f];
    [_resetGameButton runAction:[CCFadeOut actionWithDuration:0.3f]];
    
    // Make first player move as it makes no sense
    [_gameBoardLayer addTile: [self takeTopTile] 
                    animated: NO];
    [self endTurn];
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
    
    NSUInteger seed = time(NULL);
    //seed = 1342698277;
    UDLog(@"game seed: %u", seed);
    [_deck shuffleWithSeed:seed];

    CGFloat angle   = 0;
    CGFloat offsetY = 0;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    for( RRTile *tile in [_deck reverseObjectEnumerator] ){
        [tile setRotation:0];
        [tile setBackSideVisible: (gameMode == RRGameModeClosed)];
        [tile setPosition:CGPointMake(winSize.width -tile.textureRect.size.width /1.5f, tile.textureRect.size.height /1.5f +offsetY)];
        [self addChild:tile z:-1];
        
        offsetY += (isDeviceIPad()?6.0f:3.0f);
        
        [tile setRotation: CC_RADIANS_TO_DEGREES(sinf(++angle)) /20.0f];
    }
}


- (RRTile *)takeTopTile {
    if( _deck.count == 0 ) return nil;
    
    RRTile *tile = [[_deck objectAtIndex:0] retain];
    [tile stopAllActions];
    [tile setOpacity:255];
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
        [_scoreLayer setScoreBlack: _gameBoardLayer.symbolsBlack];
    }else if( [keyPath isEqualToString:@"symbolsWhite"] ){
        [_scoreLayer setScoreWhite: _gameBoardLayer.symbolsWhite];
    }
    
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( _deck.count == 0 ) return NO;
    return CGRectContainsPoint([[_deck objectAtIndex:0] boundingBox], location);
}


- (void)touchEndedAtLocation:(CGPoint)location {
    
    if( CGRectContainsPoint([[_deck objectAtIndex:0] boundingBox], location) ){
        [self endTurn];
    }
    
}


@synthesize player1=_player1, player2=_player2;
@end