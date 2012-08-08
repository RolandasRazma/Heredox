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


@implementation RRGameLayer


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_deck release];
    [_player1 release];
    [_player2 release];
    
    [super dealloc];
}


- (id)init {
    if( (self = [self initWithGameMode:RRGameModeClosed firstPlayerColor:RRPlayerColorWhite]) ){
        
    }
    return self;
}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    [self resetGame];
}


- (void)onEnter {
    [super onEnter];
    
    [_gameBoardLayer addObserver:self forKeyPath:@"symbolsBlack" options:NSKeyValueObservingOptionNew context:NULL];
    [_gameBoardLayer addObserver:self forKeyPath:@"symbolsWhite" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(tileMovedToValidLocation) 
                                                 name: RRGameBoardLayerTileMovedToValidLocationNotification 
                                               object: nil];
}


- (void)onExit {
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsBlack"];
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsWhite"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RRGameBoardLayerTileMovedToValidLocationNotification object:nil];
    
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
        
        CCSprite *backgroundBlackSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundBlack~ipad.png":@"RRBackgroundBlack.png")];
        [backgroundBlackSprite setAnchorPoint:CGPointZero];
        [_backgroundLayer addChild:backgroundBlackSprite z:0 tag:RRPlayerColorBlack];

        CCSprite *backgroundWhiteSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundWhite~ipad.png":@"RRBackgroundWhite.png")];
        [backgroundWhiteSprite setAnchorPoint:CGPointZero];
        [_backgroundLayer addChild:backgroundWhiteSprite z:0 tag:RRPlayerColorWhite];
        
        [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:0.0f];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMenu.png" highliteSpriteFrameName:@"RRButtonMenuSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [[RRHeredox sharedInstance] playEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        

        // Add End Turn
        _buttonEndTurn = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonDone.png"];
        [_buttonEndTurn setOpacity:0];
        [_buttonEndTurn addBlock: ^{ [self endTurn]; } forControlEvents: UDButtonEventTouchUpInside];
        [_buttonEndTurn setPosition:CGPointMake(winSize.width -[RRTile tileSize] /1.5f, [RRTile tileSize] /1.5f)];
        [self addChild:_buttonEndTurn z:-2];
        
        // Add scores
        _scoreLayer = [RRScoreLayer node];
        [self addChild:_scoreLayer];
        
        // Add board layer
        _gameBoardLayer = [[RRGameBoardLayer alloc] initWithGameMode: _gameMode];
        [self addChild:_gameBoardLayer z:1];
        [_gameBoardLayer release];
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
        }else{
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
        }        
    }
	return self;
}


- (void)showMenu {

    RRGameMenuLayer *gameMenuLayer = [RRGameMenuLayer node];
    [gameMenuLayer setDelegate:self];
    [gameMenuLayer showInLayer:self];
}


- (void)endTurn {

    if( [_gameBoardLayer haltTilePlaces] ){

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
            [_buttonEndTurn runAction: [CCFadeOut actionWithDuration:0.3f]];
            
            
            RRGameWictoryLayer *gameWictoryLayer;
            if( _scoreLayer.scoreBlack == _scoreLayer.scoreWhite ){
                gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousNo];
            }else if( _scoreLayer.scoreBlack > _scoreLayer.scoreWhite ){
                gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousBlack];
            }else{
                gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousWhite];
            }
            [gameWictoryLayer setDelegate:self];
            [gameWictoryLayer showInLayer:self];
        }
        
    }
    
}


- (void)newTurn {

    if(   (_player1.playerColor == _playerColor && [_player1 isKindOfClass:[RRAIPlayer class]])
       || (_player2.playerColor == _playerColor && [_player2 isKindOfClass:[RRAIPlayer class]]) ){
        
        [_gameBoardLayer setUserInteractionEnabled:NO];
        
        RRTileMove tileMove = [(RRAIPlayer *)((_player1.playerColor == _playerColor)?_player1:_player2) bestMoveOnBoard:_gameBoardLayer];

        
        NSMutableArray *actions = [NSMutableArray array];
        [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
        [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
        [actions addObject: [CCMoveTo actionWithDuration:0.4f position:CGPointMake(tileMove.positionInGrid.x *[RRTile tileSize] +[RRTile tileSize] /2,
                                                                                   tileMove.positionInGrid.y *[RRTile tileSize] +[RRTile tileSize] /2)]];
        [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
        [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];

        
        for( NSUInteger rotation=0; rotation<tileMove.rotation; rotation += 90 ){
            [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
            [actions addObject:[CCCallBlock actionWithBlock:^{ [[RRHeredox sharedInstance] playEffect:@"RRTileTurn.mp3"]; }]];
            [actions addObject: [CCRotateBy actionWithDuration:0.2f angle:90]];
            [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];
            [actions addObject: [CCDelayTime actionWithDuration:0.2f]];
        }
        
        [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
        [actions addObject: [CCCallBlock actionWithBlock:^{ [_gameBoardLayer setUserInteractionEnabled:YES]; }]];
        [actions addObject: [CCCallFunc actionWithTarget: self selector:@selector(endTurn)]];
        
        [_gameBoardLayer.activeTile runAction:[CCSequence actionsWithArray: actions]];
    }
    
}


- (void)takeNewTile {
    
    RRTile *newTile = [self takeTopTile];
    [newTile setPosition:CGPointMake(newTile.position.x -_gameBoardLayer.position.x, newTile.position.y -_gameBoardLayer.position.y)];
    
    [_gameBoardLayer addTile:newTile animated:YES];
    
}


- (void)resetGame {
    [self resetDeckForGameMode:_gameMode];
    
    @synchronized( self ){
        _playerColor = _firstPlayerColor;
        
        [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:0.0f];
        
        [_resetGameButton stopAllActions];
        [_resetGameButton runAction:[CCSequence actions:[CCFadeOut actionWithDuration:0.3f], [UDActionDestroy action], nil]];
        _resetGameButton = nil;
        
        [_gameBoardLayer resetBoardForGameMode: _gameMode];
    }
    
    [self takeNewTile];
    [self newTurn];
}


- (void)resetDeckForGameMode:(RRGameMode)gameMode {
    @synchronized( self ){
        for( RRTile *tile in _deck ){
            [self removeChild:tile cleanup:YES];
        }
        
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
        [_deck shuffleWithSeed:seed];
        
        NSLog(@"Game Seed: %u", seed);
        
        // Place tiles on game board
        CGFloat angle   = 0;
        CGFloat offsetY = 0;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        for( RRTile *tile in [_deck reverseObjectEnumerator] ){
            [tile setRotation:0];
            [tile setBackSideVisible: (gameMode == RRGameModeClosed)];
            
            offsetY += ((isDeviceIPad()||isDeviceMac())?6.0f:3.0f);
            [tile setRotation: CC_RADIANS_TO_DEGREES(sinf(++angle)) /20.0f];
            
            [tile setPosition:CGPointMake(winSize.width /2,
                                          tile.textureRect.size.height /1.5f +offsetY)];
            [self addChild:tile z:-1];
        }
        
        [_buttonEndTurn stopAllActions];
        [_buttonEndTurn setPosition: [(RRTile *)[_deck objectAtIndex: _deck.count -1] position]];
        [_buttonEndTurn setOpacity:255];
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

    if( _deck.count ){
        [(RRTile *)[_deck objectAtIndex:0] showEndTurnTextAnimated:YES];
    }
    
    return [tile autorelease];
}


- (void)tileMovedToValidLocation {
    
    if( _deck.count ){
        [(RRTile *)[_deck objectAtIndex:0] showEndTurnTextAnimated:NO];
    }
    
}


#pragma mark -
#pragma mark NSKeyValueObserving


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSString *soundEffext = nil;
    
    if( [keyPath isEqualToString:@"symbolsBlack"] ){
        [_scoreLayer setScoreBlack: _gameBoardLayer.symbolsBlack];
        
        if( _scoreLayer.scoreBlack ){
            if( _gameBoardLayer.symbolsBlack -_scoreLayer.scoreBlack == 1 ){
                soundEffext = [NSString stringWithFormat: @"RRPlayerColor1-points1-s%i.mp3", (UDTrueWithPossibility(0.5f)?1:2)];
            }else{
                soundEffext = [NSString stringWithFormat:@"RRPlayerColor1-points2-s%i.mp3", (UDTrueWithPossibility(0.5f)?1:2)];
            }
        }
    }else if( [keyPath isEqualToString:@"symbolsWhite"] ){
        [_scoreLayer setScoreWhite: _gameBoardLayer.symbolsWhite];
        
        if( _scoreLayer.scoreWhite ){
            if( _gameBoardLayer.symbolsWhite -_scoreLayer.scoreWhite == 1 ){
                soundEffext = [NSString stringWithFormat: @"RRPlayerColor2-points1-s%i.mp3", (UDTrueWithPossibility(0.5f)?1:2)];
            }else{
                soundEffext = [NSString stringWithFormat:@"RRPlayerColor2-points2-s%i.mp3", (UDTrueWithPossibility(0.5f)?1:2)];
            }
        }
    }
    
    
    if( soundEffext ){
        [[RRHeredox sharedInstance] playEffect:soundEffext withoutStopingPrevious:YES];
    }
}


#pragma mark -
#pragma mark RRGameMenuDelegate


- (void)gameMenuLayer:(RRGameMenuLayer *)gameMenuLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex {

    switch ( buttonIndex ) {
        case 0: {
            [gameMenuLayer dismiss];
            break;
        }
        case 1: {
            [gameMenuLayer dismiss];
            
            [self resetGame];
            break;
        }
        case 2: {
            [[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
            break;
        }
    }
    
}


#pragma mark -
#pragma mark RRGameWictoryDelegate


- (void)gameWictoryLayer:(RRGameWictoryLayer *)gameMenuLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex {
    [gameMenuLayer dismiss];
    
    [self resetGame];
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( _deck.count == 0 ) return NO;
    return CGRectContainsPoint([(RRTile *)[_deck objectAtIndex:0] boundingBox], location);
}


- (void)touchEndedAtLocation:(CGPoint)location {

    if( CGRectContainsPoint([(RRTile *)[_deck objectAtIndex:0] boundingBox], location) ){
        [self endTurn];
    }
    
}


@synthesize player1=_player1, player2=_player2;
@end