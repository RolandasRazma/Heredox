//
//  UDGameLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//
//  Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "RRGameLayer.h"
#import "RRTile.h"
#import "RRAIPlayer.h"
#import "RRMenuScene.h"
#import "RRCrossfadeLayer.h"
#import "RRScoreLayer.h"
#import "RRPopupLayer.h"


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

    // If its a network multiplayer
    if( [[UDGKManager sharedManager] isNetworkPlayActive] ){
        [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypeEnterScene];
        [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypeTileMove];
        [[UDGKManager sharedManager] addPacketObserver:self forType:UDGKPacketTypeResetGame];
        
        [[UDGKManager sharedManager] addPlayerObserver:self forConnectionState:GKPlayerStateDisconnected];
    }
}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    if( [[UDGKManager sharedManager] isNetworkPlayActive] ){
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
        _winsBlack = _winsWhite = _winsDraw = 0;
        
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
        [buttonHome addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonHome];
        

        // Add End Turn
        _buttonEndTurn = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonDone.png"];
        [_buttonEndTurn setOpacity:0];
        [_buttonEndTurn addBlock: ^{ [self endTurn]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [_buttonEndTurn setPosition:CGPointMake(winSize.width -[RRTile tileSize] /1.5f, [RRTile tileSize] /1.5f)];
        [self addChild:_buttonEndTurn z:-2];
        
        // Add scores
        _scoreLayer = [RRScoreLayer node];
        [self addChild:_scoreLayer];
        
        // Add board layer
        _gameBoardLayer = [[RRBoardLayer alloc] initWithGameMode: _gameMode];
        [_gameBoardLayer setDelegate:self];
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
        _allPlayersInScene = ![[UDGKManager sharedManager] isNetworkPlayActive];
        [self setUserInteractionEnabled:_allPlayersInScene];
        
        if( !_allPlayersInScene ){
            _bannerWaitingForPlayer = [RRPopupLayer layerWithMessage: @"RRTextWaitingForOtherPlayer"];
            [self addChild:_bannerWaitingForPlayer z:1000];
        }
    }
	return self;
}


- (void)resetGame {
    [self resetGameWithSeed:(unsigned int)time(NULL)];
}


- (void)resetGameWithSeed:(unsigned int)gameSeed {
    [self setUserInteractionEnabled:NO];
    
    [self resetDeckForGameMode:_gameMode withSeed:gameSeed];
    [_gameBoardLayer resetBoardForGameMode: _gameMode];
    
    _playerColor = _firstPlayerColor;
    
    [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:0.0f];
    
    [_resetGameButton stopAllActions];
    [_resetGameButton runAction:[UDActionDestroy action]];
    _resetGameButton = nil;
    
    if( [[UDGKManager sharedManager] isHost] && [[UDGKManager sharedManager] isNetworkPlayActive] ){
        UDGKPacketResetGame newPacket = UDGKPacketResetGameMake( gameSeed );
        [[UDGKManager sharedManager] sendPacketToAllPlayers: &newPacket
                                                     length: sizeof(UDGKPacketResetGame)];
    }
    
    // AI vs AI
    if( [_player1 isKindOfClass:[RRAIPlayer class]] && [_player2 isKindOfClass:[RRAIPlayer class]] ){
        [_backgroundLayer setVisible:NO];
    }
    
    [self newTurn];
}


- (void)resetDeckForGameMode:(RRGameMode)gameMode withSeed:(unsigned int)gameSeed {
    @synchronized( self ){
        _gameSeed = gameSeed;
        
        for( RRTile *tile in _deck ){
            [self removeChild:tile cleanup:YES];
        }
        
        [_deck release];
        _deck = [[NSMutableArray alloc] initWithCapacity:16];
        
        // 2x RRTileEdgeWhite RRTileEdgeNone RRTileEdgeBlack RRTileEdgeNone
        [_deck addObject: [RRTile tileWithType:RRTileTypeWNBN]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWNBN]];
        
        // 3x RRTileEdgeWhite RRTileEdgeNone RRTileEdgeNone RRTileEdgeBlack
        [_deck addObject: [RRTile tileWithType:RRTileTypeWNNB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWNNB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWNNB]];
        
        // 3x RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeNone RRTileEdgeNone
        [_deck addObject: [RRTile tileWithType:RRTileTypeWBNN]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWBNN]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWBNN]];
        
        // 4x RRTileEdgeWhite RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeBlack
        [_deck addObject: [RRTile tileWithType:RRTileTypeWWBB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWWBB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWWBB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWWBB]];
        
        // 4x RRTileEdgeWhite RRTileEdgeBlack RRTileEdgeWhite RRTileEdgeBlack
        [_deck addObject: [RRTile tileWithType:RRTileTypeWBWB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWBWB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWBWB]];
        [_deck addObject: [RRTile tileWithType:RRTileTypeWBWB]];

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
        RRTileMove tileMove = _gameBoardLayer.activeTile.tileMove;
        
        if( [_gameBoardLayer haltTilePlaces] ){
            
            if( [[UDGKManager sharedManager] isNetworkPlayActive] && [self.currentPlayer.playerID isEqualToString: [[UDGKManager sharedManager] playerID]] ){
                UDGKPacketTileMove packet = UDGKPacketTileMoveMake( tileMove, true );
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
                    _winsDraw++;
                    gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousNo    blackWins:_winsBlack whiteWins:_winsWhite draws:_winsDraw];
                }else if( _scoreLayer.scoreBlack > _scoreLayer.scoreWhite ){
                    _winsBlack++;
                    gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousBlack blackWins:_winsBlack whiteWins:_winsWhite draws:_winsDraw];
                }else{
                    _winsWhite++;
                    gameWictoryLayer = [RRGameWictoryLayer layerForColor:RRPlayerColorWictoriousWhite blackWins:_winsBlack whiteWins:_winsWhite draws:_winsDraw];
                }
                [gameWictoryLayer setDelegate:self];
                [self addChild:gameWictoryLayer z:1000];
                
                // AI vs AI
                if( [_player1 isKindOfClass:[RRAIPlayer class]] && [_player2 isKindOfClass:[RRAIPlayer class]] ){
                    if( _winsDraw +_winsBlack +_winsWhite < 100 ){
                        [self gameWictoryLayer:gameWictoryLayer didSelectButtonAtIndex:0];
                        [self resetGame];
                    }
                }
            }
        }
        
    }
    
}


- (void)newTurn {
    [self flipTopTileFromDeck];
    
    RRPlayer *currentPlayer = [self currentPlayer];
    
    if( [currentPlayer isKindOfClass:[RRAIPlayer class]] ){
        [self setUserInteractionEnabled:NO];
        
        // Non AI players can count what tiles left by looking at board.
        // This is just conveniant method to pass left tiles list so AI wouldn't need to count by looking at deck
        // Order of tiles is not used to not let AI cheat
        [(RRAIPlayer *)currentPlayer setTilesInDeck: [NSSet setWithArray:_deck]];
        
        [self makeMove: [(RRAIPlayer *)currentPlayer bestMoveOnBoard:_gameBoardLayer] andEndTurn:YES];
    }else if( [[UDGKManager sharedManager] isNetworkPlayActive] ){
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
        
        if( _allPlayersInScene ) {
        [GKNotificationBanner showBannerWithTitle: @"New turn"
                                          message: (self.userInteractionEnabled?@"Your turn":[NSString stringWithFormat:@"%@'s turn", player.alias])
                                completionHandler: NULL];
        }
    }else{
        [self setUserInteractionEnabled:YES];
    }
    
}


- (void)makeMove:(RRTileMove)tileMove andEndTurn:(BOOL)endTurn {
    [self setUserInteractionEnabled:NO];

    // Normalize rotation
    if( tileMove.rotation >= 360.0f ) tileMove.rotation -= 360.0f;
    
    const NSInteger RRTileMoveCCSequence = 27347;
    
    // Stop Old actions - this might happen if in multiplayer games
    [_gameBoardLayer.activeTile stopActionByTag:RRTileMoveCCSequence];
    
    
    NSMutableArray *actions = [NSMutableArray array];
    
    // Do we need to move tile?
    if( roundf(_gameBoardLayer.activeTile.positionInGrid.x) != tileMove.gridX || roundf(_gameBoardLayer.activeTile.positionInGrid.y) != tileMove.gridY ){
        [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
        [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
        [actions addObject: [CCMoveTo actionWithDuration:0.4f position:CGPointMake(tileMove.gridX *[RRTile tileSize] +[RRTile tileSize] /2,
                                                                                   tileMove.gridY *[RRTile tileSize] +[RRTile tileSize] /2)]];
        [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
        [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];
    }

    // Do we need to rotate tile?
    if( _gameBoardLayer.activeTile.rotation != tileMove.rotation ) {
        NSUInteger nextRotationAngle = _gameBoardLayer.activeTile.rotation -((int)_gameBoardLayer.activeTile.rotation %90);

        do{
            nextRotationAngle += 90;
            
            [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
            [actions addObject: [CCCallBlock actionWithBlock:^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRTileTurn.mp3"]; }]];
            [actions addObject: [CCRotateTo actionWithDuration:0.2f angle:nextRotationAngle]];
            [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];
            [actions addObject: [CCDelayTime actionWithDuration:0.2f]];
            
            if( nextRotationAngle >= 360 ) nextRotationAngle -= 360;
        } while ( nextRotationAngle != (int)tileMove.rotation );
    }
    
    // Is this the end of turn?
    if( endTurn ){
        [actions addObject: [CCCallFunc actionWithTarget: self selector:@selector(endTurn)]];
    }
    
    // AI vs AI
    if( [_player1 isKindOfClass:[RRAIPlayer class]] && [_player2 isKindOfClass:[RRAIPlayer class]] ){
        for( CCActionInstant *action in actions ){
            [action setDuration:0.0f];
        }
    }

    // Start actions if we have those
    if( actions.count ){
        CCSequence *sequence = [CCSequence actionWithArray: actions];
        [sequence setTag: RRTileMoveCCSequence];
        [_gameBoardLayer.activeTile runAction: sequence];
    }
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


#pragma mark -
#pragma mark RRBoardLayerDelegate


- (void)boardLayer:(RRBoardLayer *)gameBoardLayer movedActiveTile:(RRTileMove)tileMove {
    
    if( _deck.count ){
        [(RRTile *)[_deck objectAtIndex:0] showEndTurnTextAnimated:NO];
    }
    
    if( [[UDGKManager sharedManager] isNetworkPlayActive] && [self.currentPlayer.playerID isEqualToString: [[UDGKManager sharedManager] playerID]] ){
        UDGKPacketTileMove packet = UDGKPacketTileMoveMake( tileMove, false );
        [[UDGKManager sharedManager] sendPacketToAllPlayers: &packet
                                                     length: sizeof(UDGKPacketTileMove)];
    }
    
}


#pragma mark -
#pragma mark NSKeyValueObserving


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSString *soundEffext = nil;
    
    if( [keyPath isEqualToString:@"symbolsBlack"] ){
        if( _gameBoardLayer.symbolsBlack ){
            int pointsGained = MIN(2, _gameBoardLayer.symbolsBlack -_scoreLayer.scoreBlack);
            soundEffext = [NSString stringWithFormat: @"RRPlayerColor1-points%i-s%i.mp3", pointsGained, (UDTrueWithPossibility(0.5f)?1:2)];
        }
        
        [_scoreLayer setScoreBlack: _gameBoardLayer.symbolsBlack];
    }else if( [keyPath isEqualToString:@"symbolsWhite"] ){
        if( _gameBoardLayer.symbolsWhite ){
            int pointsGained = MIN(2, _gameBoardLayer.symbolsWhite -_scoreLayer.scoreWhite);
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
            [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:[RRMenuScene node] backwards:YES]];
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
            [self setUserInteractionEnabled:NO];
            
            _resetGameButton = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonReplay.png" highliteSpriteFrameName:@"RRButtonReplaySelected.png"];
            [_resetGameButton setPosition:_buttonEndTurn.position];
            [_resetGameButton addBlock: ^{
                [[RRAudioEngine sharedEngine] stopAllEffects];
                [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"];

                [self resetGame];
            } forControlEvents: UDButtonEventTouchUpInsideD];
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


- (void)observePacket:(const void *)packet fromPlayer:(id <UDGKPlayerProtocol>)player {
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
        UDGKPacketTileMove newPacket = *(UDGKPacketTileMove *)packet;
        
        [self makeMove: newPacket.move andEndTurn:newPacket.finite];
    }
    
}


#pragma mark -
#pragma mark UDGKManagerPlayerObserving


- (void)observePlayer:(id <UDGKPlayerProtocol>)player state:(GKPlayerConnectionState)state {
    
    if( state == GKPlayerStateDisconnected ){
        [_bannerWaitingForPlayer removeFromParentAndCleanup:YES];
        _bannerWaitingForPlayer = nil;
        
        RRPopupLayer *popupLayer = [RRPopupLayer layerWithMessage: @"RRTextPlayerDisconnected"
                                                 cancelButtonName: @"RRButtonEndGame"
                                               cancelButtonAction: ^{
                                                   [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:[RRMenuScene node] backwards:YES]];
                                               }];
        [self addChild:popupLayer z:1000];
    }
    
}


@synthesize player1=_player1, player2=_player2;
@end