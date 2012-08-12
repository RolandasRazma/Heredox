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
#import "RRTransitionGame.h"


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


- (void)onEnter {
    [super onEnter];
    
    [_gameBoardLayer addObserver:self forKeyPath:@"symbolsBlack" options:NSKeyValueObservingOptionNew context:NULL];
    [_gameBoardLayer addObserver:self forKeyPath:@"symbolsWhite" options:NSKeyValueObservingOptionNew context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver: self 
                                             selector: @selector(tileMovedToValidLocation) 
                                                 name: RRGameBoardLayerTileMovedToValidLocationNotification 
                                               object: nil];
    // If its a network multiplayer
    if( [[UDGKManager sharedManager] match] ){
        [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypeEnterScene];
        [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypeTileMove];
        [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypeResetGame];
        
        [[UDGKManager sharedManager] addPlayerObserver:self forConnectionState:GKPlayerStateDisconnected];
    }
}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    if( [[UDGKManager sharedManager] match] ){
        UDGKPacketEnterScene packet = UDGKPacketEnterSceneMake( 3 );
        [[UDGKManager sharedManager] sendPacketToAllPlayers: &packet
                                                     length: sizeof(UDGKPacketEnterScene)];
    }else{
        [self resetGame];
    }
    
}


- (void)onExitTransitionDidStart {
    [super onExitTransitionDidStart];
    
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsBlack"];
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsWhite"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RRGameBoardLayerTileMovedToValidLocationNotification object:nil];

    [[UDGKManager sharedManager] removePacketObserver:self];
    [[UDGKManager sharedManager] removePlayerObserver:self];
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
        _firstPlayerColor   = _playerColor = playerColor;
        
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
        [buttonHome addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
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
        
        // Do we need to wait for players?
        _allPlayersInScene = ([[UDGKManager sharedManager] match] == nil);
        [self setUserInteractionEnabled:_allPlayersInScene];
        
        if( !_allPlayersInScene ){
            _bannerWaitingForPlayer = [CCSprite spriteWithSpriteFrameName:@"RRBannerWaitingForPlayer.png"];
            [_bannerWaitingForPlayer setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
            [self addChild:_bannerWaitingForPlayer z: 100];
        }
    }
	return self;
}


- (void)resetGame {
    [self resetGameWithSeed:time(NULL)];
}


- (void)resetGameWithSeed:(NSUInteger)gameSeed {
    [self setUserInteractionEnabled:NO];
    
    [self resetDeckForGameMode:_gameMode withSeed:gameSeed];
    
    @synchronized( self ){
        _playerColor = _firstPlayerColor;
        
        [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:0.0f];

        [_resetGameButton stopAllActions];
        [_resetGameButton removeFromParentAndCleanup:YES];
        _resetGameButton = nil;
        
        [_gameBoardLayer resetBoardForGameMode: _gameMode];
    }
    
    if( [[UDGKManager sharedManager] isHost] ){
        UDGKPacketResetGame newPacket = UDGKPacketResetGameMake( gameSeed );
        [[UDGKManager sharedManager] sendPacketToAllPlayers: &newPacket
                                                     length: sizeof(UDGKPacketResetGame)];
    }
    
    [self newTurn];
}


- (void)resetDeckForGameMode:(RRGameMode)gameMode withSeed:(NSUInteger)gameSeed {
    @synchronized( self ){
        _gameSeed = gameSeed;
        
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

        [_deck shuffleWithSeed:_gameSeed];

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
        [_buttonEndTurn setOpacity:0];
    }
}


- (void)showMenu {
    [self setUserInteractionEnabled:NO];
    
    RRGameMenuLayer *gameMenuLayer = [RRGameMenuLayer node];
    [gameMenuLayer setDelegate:self];
    [self addChild:gameMenuLayer z:1000];
    
}


- (RRPlayer *)currentPlayer {
    return ((_player1.playerColor == _playerColor)?_player1:_player2);
}


- (void)endTurn {

    if( ![_gameBoardLayer canPlaceTileAtGridLocation:CGPointRound(_gameBoardLayer.activeTile.positionInGrid)] ){
        [[RRAudioEngine sharedEngine] replayEffect:@"RRPlaceTileError.mp3"];
    }else {
        RRTileMove tileMove;
        tileMove.positionInGrid = _gameBoardLayer.activeTile.positionInGrid;
        tileMove.rotation       = _gameBoardLayer.activeTile.rotation;
        tileMove.score          = 1;
        
        if( [_gameBoardLayer haltTilePlaces] ){
            
            if(     [[UDGKManager sharedManager] match]
               &&   [self.currentPlayer.playerID isEqualToString: [[UDGKManager sharedManager] playerID]] ){
                UDGKPacketTileMove packet = UDGKPacketTileMoveMake( tileMove );
                [[UDGKManager sharedManager] sendPacketToAllPlayers: &packet
                                                             length: sizeof(UDGKPacketTileMove)];
            }
            
            if( _deck.count > 0 ){
                if( _playerColor == RRPlayerColorBlack ){
                    _playerColor = RRPlayerColorWhite;
                    
                    [_backgroundLayer fadeToSpriteWithTag: RRPlayerColorWhite duration:0.7f];
                }else{
                    _playerColor = RRPlayerColorBlack;
                    
                    [_backgroundLayer fadeToSpriteWithTag: RRPlayerColorBlack duration:0.7f];
                }
                
                [self newTurn];
            }else{
                [_buttonEndTurn runAction: [CCFadeOut actionWithDuration:0.3f]];
                [_playerNameLabel runAction: [CCFadeOut actionWithDuration:0.3f]];
                
                RRGameWictoryLayer *gameWictoryLayer;
                if( _scoreLayer.scoreBlack == _scoreLayer.scoreWhite ){
                    gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousNo];
                }else if( _scoreLayer.scoreBlack > _scoreLayer.scoreWhite ){
                    gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousBlack];
                }else{
                    gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousWhite];
                }
                [gameWictoryLayer setDelegate:self];
                [self addChild:gameWictoryLayer z:1000];
            }
        }
        
    }
    
}


- (void)newTurn {
    [self flipTopTileFromDeck];
    
    RRPlayer *currentPlayer = [self currentPlayer];
    
    if( [currentPlayer isKindOfClass:[RRAIPlayer class]] ){
        [self makeMove:[(RRAIPlayer *)currentPlayer bestMoveOnBoard:_gameBoardLayer]];
    }else if( [[UDGKManager sharedManager] match] ){
        [self setUserInteractionEnabled: (_allPlayersInScene && [self.currentPlayer.playerID isEqualToString: [[UDGKManager sharedManager] playerID]])];
        
        if( !_playerNameLabel ){
            _playerNameLabel = [CCLabelTTF labelWithString:@"" fontName:@"Papyrus" fontSize:20];
            [_playerNameLabel setAnchorPoint:CGPointMake(0.5f, 0)];
            [self addChild:_playerNameLabel z:10];
        }
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        GKPlayer *player = [[[UDGKManager sharedManager] players] objectForKey:self.currentPlayer.playerID];
        
        [_playerNameLabel stopAllActions];
        [_playerNameLabel setString:player.alias];
        [_playerNameLabel setPosition:CGPointMake(winSize.width /2, 5)];
        [_playerNameLabel setOpacity:255];
        
    }else{
        [self setUserInteractionEnabled:YES];
    }
    
}


- (void)makeMove:(RRTileMove)tileMove {
    [self setUserInteractionEnabled:NO];
    
    NSMutableArray *actions = [NSMutableArray array];
    [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
    [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
    [actions addObject: [CCMoveTo actionWithDuration:0.4f position:CGPointMake(tileMove.positionInGrid.x *[RRTile tileSize] +[RRTile tileSize] /2,
                                                                               tileMove.positionInGrid.y *[RRTile tileSize] +[RRTile tileSize] /2)]];
    [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
    [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];
    
    
    for( NSUInteger rotation=0; rotation<tileMove.rotation; rotation += 90 ){
        [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
        [actions addObject:[CCCallBlock actionWithBlock:^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRTileTurn.mp3"]; }]];
        [actions addObject: [CCRotateBy actionWithDuration:0.2f angle:90]];
        [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];
        [actions addObject: [CCDelayTime actionWithDuration:0.2f]];
    }
    
    [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
    [actions addObject: [CCCallBlock actionWithBlock:^{
        [self setUserInteractionEnabled:YES];
    }]];
    [actions addObject: [CCCallFunc actionWithTarget: self selector:@selector(endTurn)]];
    
    [_gameBoardLayer.activeTile runAction:[CCSequence actionsWithArray: actions]];
}


- (RRTile *)flipTopTileFromDeck {
    if( _deck.count == 0 ) return nil;
    
    RRTile *tile = [[_deck objectAtIndex:0] retain];
    [tile stopAllActions];
    [tile setOpacity:255];
    [tile setRotation:0.0f];
    [tile setBackSideVisible:NO];
    
    [_deck removeObject:tile];
    [self removeChild:tile cleanup:NO];
    
    [tile setPosition:CGPointMake(tile.position.x -_gameBoardLayer.position.x, tile.position.y -_gameBoardLayer.position.y)];
    
    [_gameBoardLayer addTile:tile animated:YES];
    [tile release];
    
    if( _deck.count ){
        [(RRTile *)[_deck objectAtIndex:0] showEndTurnTextAnimated:YES];
    }else{
        [_buttonEndTurn stopAllActions];
        [_buttonEndTurn setOpacity:255];
    }
    
    return tile;
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
        if( _gameBoardLayer.symbolsBlack ){
            NSInteger pointsGained = MIN(2, _gameBoardLayer.symbolsBlack -_scoreLayer.scoreBlack);
            soundEffext = [NSString stringWithFormat: @"RRPlayerColor1-points%i-s%i.mp3", pointsGained, (UDTrueWithPossibility(0.5f)?1:2)];
        }
        
        [_scoreLayer setScoreBlack: _gameBoardLayer.symbolsBlack];
    }else if( [keyPath isEqualToString:@"symbolsWhite"] ){
        if( _gameBoardLayer.symbolsWhite ){
            NSInteger pointsGained = MIN(2, _gameBoardLayer.symbolsWhite -_scoreLayer.scoreWhite);
            soundEffext = [NSString stringWithFormat: @"RRPlayerColor2-points%i-s%i.mp3", pointsGained, (UDTrueWithPossibility(0.5f)?1:2)];
        }
        
        [_scoreLayer setScoreWhite: _gameBoardLayer.symbolsWhite];
    }
    
    if( soundEffext ){
        [[RRAudioEngine sharedEngine] playEffect:soundEffext];
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
            [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
            break;
        }
    }
    
}


#pragma mark -
#pragma mark RRGameWictoryDelegate


- (void)gameWictoryLayer:(RRGameWictoryLayer *)gameMenuLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex {
    [gameMenuLayer dismiss];
    
    if( [[UDGKManager sharedManager] isHost] ){
        if( !_resetGameButton ){
            _resetGameButton = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonReplay.png" highliteSpriteFrameName:@"RRButtonReplaySelected.png"];
            [_resetGameButton setPosition:_buttonEndTurn.position];
            [_resetGameButton addBlock: ^{
                [[RRAudioEngine sharedEngine] stopAllEffects];
                [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"];
                
                [self resetGame];
            } forControlEvents: UDButtonEventTouchUpInside];
            [self addChild:_resetGameButton z:-2];
        }
    }
}


#pragma mark -
#pragma mark UDLayer


- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];

    [_buttonEndTurn setUserInteractionEnabled:userInteractionEnabled];
    [_gameBoardLayer setUserInteractionEnabled:userInteractionEnabled];
}


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( _deck.count == 0 ) return NO;
    return CGRectContainsPoint([(RRTile *)[_deck objectAtIndex:0] boundingBox], location);
}


- (void)touchEndedAtLocation:(CGPoint)location {

    if( CGRectContainsPoint([(RRTile *)[_deck objectAtIndex:0] boundingBox], location) ){
        [self endTurn];
    }
    
}


#pragma mark -
#pragma mark UDGKManagerPacketObserving


- (void)observePacket:(const void *)packet fromPlayer:(GKPlayer *)player {
    if( [player.playerID isEqualToString: [[UDGKManager sharedManager] playerID]] ) return;
    
    UDGKPacketType packetType = (*(UDGKPacket *)packet).type;
    
    if( packetType == UDGKPacketTypeEnterScene && !_allPlayersInScene ){
        UDGKPacketEnterScene newPacket = *(UDGKPacketEnterScene *)packet;
        
        if( newPacket.sceneID == 3 ){
            _allPlayersInScene = YES;
            
            [[UDGKManager sharedManager] sendPacketToAllPlayers: &newPacket
                                                         length: sizeof(UDGKPacketEnterScene)];

            [_bannerWaitingForPlayer removeFromParentAndCleanup:YES];
            _bannerWaitingForPlayer = nil;
            
            if( [[UDGKManager sharedManager] isHost] ){
                [self resetGame];
            }
        }
    }else if ( packetType == UDGKPacketTypeResetGame ){
        [self resetGameWithSeed:(*(UDGKPacketResetGame *)packet).seed];
    }else if ( packetType == UDGKPacketTypeTileMove ){
        [self makeMove: (*(UDGKPacketTileMove *)packet).move];
    }
    
}


#pragma mark -
#pragma mark UDGKManagerPlayerObserving


- (void)observePlayer:(GKPlayer *)player state:(GKPlayerConnectionState)state {
    
    if( state == GKPlayerStateDisconnected ){
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Remote player disconnected"
                                                            message: nil
                                                           delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
        [alertView show];
        [alertView release];
    }
    
}


#pragma mark -
#pragma mark UIAlertViewDelegate


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
}


@end