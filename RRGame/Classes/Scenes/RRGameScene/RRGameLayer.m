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
    if( _match ){
        // setup board
        RRMatchData matchRepresentation = _match.matchRepresentation;
        
        if( matchRepresentation.seed ){
            [self resetGameWithSeed:_match.gameSeed];

            for( int turnNo=0; turnNo < matchRepresentation.totalTileMoves -1; turnNo++ ){
                RRTileMove tileMove = matchRepresentation.tileMoves[turnNo];
                
                [self makeMove:tileMove animated:NO completionHandler:NULL];
                
                if( [_gameBoardLayer haltTilePlaces] ){
                    _playerColor = RRPlayerColorInverse(_playerColor);
                    
                    if( _deck.count > 0 ){
                        [self flipTopTileFromDeck];
                    }else{
                        #warning TODO
                        // End game?
                    }
                }
            }
            
            [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:0.0f];
        }else{
            [self resetGame];
        }
        
        [[GKLocalPlayer localPlayer] registerListener:self];
    }else{
        [self resetGame];
    }

}


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];
    
    if( _match ){
        RRMatchData matchRepresentation = _match.matchRepresentation;
        
        if( matchRepresentation.totalTileMoves ){
            RRTileMove tileMove = matchRepresentation.tileMoves[matchRepresentation.totalTileMoves -1];
            [self makeMove:tileMove animated:YES completionHandler:^{
                [self endTurnAnimated:YES endMatchTurn:NO];
            }];
        }else{
            [self setUserInteractionEnabled: [_match isMyTurn]];
        }
        
        if ( _match.status == GKTurnBasedMatchStatusEnded ) {
            // Match Ended
            [self setUserInteractionEnabled:NO];
        } else {
            // x players turn
        }
        
    }
    
}


- (void)onExitTransitionDidStart {
    [super onExitTransitionDidStart];
    
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsBlack"];
    [_gameBoardLayer removeObserver:self forKeyPath:@"symbolsWhite"];
    
    [[GKLocalPlayer localPlayer] unregisterListener:self];
}


#pragma mark -
#pragma mark UDGameLayer


+ (id)layerWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor {
    return [[self alloc] initWithGameMode:gameMode firstPlayerColor:playerColor];
}


- (id)initWithMatch:(GKTurnBasedMatch *)match {
    NSAssert(match, @"No match specifyed");
    
    if( (self = [self initWithGameMode:RRGameModeClosed firstPlayerColor:match.firstParticipantColor] ) ){
        _match = match;

        // First player
        RRPlayer *player1 = [RRPlayer playerWithPlayerColor: match.firstParticipantColor];
        [player1 setPlayerID: [[_match.participants objectAtIndex:0] playerID]];
        [self setPlayer1: player1];
        
        // Second player
        RRPlayer *player2 = [RRPlayer playerWithPlayerColor: RRPlayerColorInverse(match.firstParticipantColor)];
        [player2 setPlayerID: [[_match.participants objectAtIndex:1] playerID]];
        [self setPlayer2: player2];
    }

    return self;
}


- (id)initWithGameMode:(RRGameMode)gameMode firstPlayerColor:(RRPlayerColor)playerColor {
	if( (self = [super init]) ) {
        [self setUserInteractionEnabled:YES];
        
        _gameMode           = gameMode;
        _firstPlayerColor   = _playerColor  = playerColor;
        _winsBlack          = _winsWhite    = _winsDraw = 0;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        // Add background
        _backgroundLayer = [RRCrossfadeLayer node];
        [self addChild:_backgroundLayer z:-10];
        
        CCSprite *backgroundBlackSprite = [CCSprite spriteWithFile:((IS_IPAD||IS_MAC)?@"RRBackgroundBlack~ipad.png":@"RRBackgroundBlack.png")];
        [backgroundBlackSprite setAnchorPoint:CGPointZero];
        [_backgroundLayer addChild:backgroundBlackSprite z:0 tag:RRPlayerColorBlack];

        CCSprite *backgroundWhiteSprite = [CCSprite spriteWithFile:((IS_IPAD||IS_MAC)?@"RRBackgroundWhite~ipad.png":@"RRBackgroundWhite.png")];
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
        [_buttonEndTurn setPosition:CGPointMake(winSize.width -[RRTile tileSize] /1.5f, [RRTile tileSize] /1.5f)];
        __weak RRGameLayer *_weakSelf = self;
        [_buttonEndTurn addBlock: ^{
            [_weakSelf endTurnAnimated:YES endMatchTurn:YES];
        } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:_buttonEndTurn z:-2];
        
        // Add scores
        _scoreLayer = [RRScoreLayer node];
        [self addChild:_scoreLayer];
        
        // Add board layer
        _gameBoardLayer = [[RRBoardLayer alloc] initWithGameMode: _gameMode];
        [_gameBoardLayer setDelegate:self];
        [self addChild:_gameBoardLayer z:1];
        
        // Device layout
        if( IS_IPAD || IS_MAC ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
        }else{
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
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
        float angle     = 0.0f;
        CGFloat offsetY = 0;
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        for( RRTile *tile in [_deck reverseObjectEnumerator] ){
            [tile setRotation:0];
            [tile setBackSideVisible: (gameMode == RRGameModeClosed)];
            
            offsetY += ((IS_IPAD||IS_MAC)?6.0f:3.0f);
            [tile setRotation: CC_RADIANS_TO_DEGREES(sinf(++angle)) /20.0f];
            
            [tile setPosition:CGPointMake(winSize.width /2,
                                          tile.textureRect.size.height /1.5f +offsetY)];
            [self addChild:tile z:-1];
        }
        
        [_buttonEndTurn stopAllActions];
        [_buttonEndTurn setPosition: [(RRTile *)[_deck objectAtIndex: _deck.count -1] position]];
        [_buttonEndTurn setOpacity:0];
        
        if( _match ){
            [_match setGameSeed: _gameSeed];
        }
    }
}


- (void)showMenu {

    RRGameMenuLayer *gameMenuLayer = [RRGameMenuLayer node];
    if( _match ){
        [gameMenuLayer disableRestartButton];
    }
    [gameMenuLayer setDelegate:self];
    [self addChild:gameMenuLayer z:1000];
    
}


- (RRPlayer *)currentPlayer {
    return ((_player1.playerColor == _playerColor)?_player1:_player2);
}


- (void)endTurnAnimated:(BOOL)animated endMatchTurn:(BOOL)endMatchTurn {

    if( ![_gameBoardLayer canPlaceTileAtGridLocation:CGPointRound(_gameBoardLayer.activeTile.positionInGrid)] ){
        [[RRAudioEngine sharedEngine] replayEffect:@"RRPlaceTileError.mp3"];
    }else {
        RRTileMove tileMove = _gameBoardLayer.activeTile.tileMove;
        
        if( [_gameBoardLayer haltTilePlaces] ){

            if( _match && [_match isMyTurn] && endMatchTurn ){
                [_match addTileMove:tileMove];
            }
            
            if( _deck.count > 0 ){
                
                // Give turn to another player
                if( _match && [_match isMyTurn] && endMatchTurn ){
                    [_match endTurnWithNextParticipant: _match.nextParticipant
                                     completionHandler: ^(NSError *error) {
                                         if( error ){
                                             NSLog(@"endTurnWithNextParticipant error: %@", error);
                                             
                                             RRPopupLayer *popupLayer = [RRPopupLayer layerWithMessage: @"RRTextGameCenterError"
                                                                                      cancelButtonName: @"RRButtonContinue"
                                                                                    cancelButtonAction: nil];
                                             [self addChild:popupLayer z:1000];
                                         }
                                     }];
                }
                
                _playerColor = RRPlayerColorInverse(_playerColor);
                [_backgroundLayer fadeToSpriteWithTag:_playerColor duration:(animated?0.7f:0.0f)];
                
                [self newTurn];
            }else{
                
                // match ended
                if( _match && [_match isMyTurn] && endMatchTurn ){
                    if( _scoreLayer.scoreBlack == _scoreLayer.scoreWhite ){
                        [[_match participantForColor:RRPlayerColorBlack] setMatchOutcome:GKTurnBasedMatchOutcomeTied];
                        [[_match participantForColor:RRPlayerColorWhite] setMatchOutcome:GKTurnBasedMatchOutcomeTied];
                    }else if( _scoreLayer.scoreBlack > _scoreLayer.scoreWhite ){
                        [[_match participantForColor:RRPlayerColorBlack] setMatchOutcome:GKTurnBasedMatchOutcomeWon];
                        [[_match participantForColor:RRPlayerColorWhite] setMatchOutcome:GKTurnBasedMatchOutcomeLost];
                    }else{
                        [[_match participantForColor:RRPlayerColorBlack] setMatchOutcome:GKTurnBasedMatchOutcomeLost];
                        [[_match participantForColor:RRPlayerColorWhite] setMatchOutcome:GKTurnBasedMatchOutcomeWon];
                    }

                    [_match endMatchInTurnWithMatchData: _match.transitMatchData
                                      completionHandler: ^(NSError *error) {
                                          NSLog(@"endMatchInTurnWithMatchData: %@", error);
                                      }];
                }
                
                [_buttonEndTurn   runAction: [CCFadeOut actionWithDuration:(animated?0.3f:0.0f)]];
                [_playerNameLabel runAction: [CCFadeOut actionWithDuration:(animated?0.3f:0.0f)]];
                
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
        
        [self makeMove:[(RRAIPlayer *)currentPlayer bestMoveOnBoard:_gameBoardLayer] animated:YES completionHandler:^{ [self endTurnAnimated:YES endMatchTurn:NO]; }];
    }else if( _match ){
        if( !_playerNameLabel ){
            _playerNameLabel = [CCLabelTTF labelWithString:@"" fontName:@"Papyrus" fontSize:20];
            [_playerNameLabel setAnchorPoint:CGPointMake(0.5f, 0)];
            [self addChild:_playerNameLabel z:10];
        }
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];

        NSString *turnForPlayer;
        if( [_match isMyTurn] ){
            turnForPlayer = @"Your turn";
        }else if( !currentPlayer.alias ){
            turnForPlayer = @"Waiting for opponent";
        }else{
            turnForPlayer = [NSString stringWithFormat:@"%@'s turn", currentPlayer.alias];
        }

        [_playerNameLabel stopAllActions];
        [_playerNameLabel setString:turnForPlayer];
        [_playerNameLabel setPosition:CGPointMake(winSize.width /2, 5)];
        [_playerNameLabel setOpacity:255];
        
        [GKNotificationBanner showBannerWithTitle: @"New turn"
                                          message: turnForPlayer
                                completionHandler: NULL];
        
        [self setUserInteractionEnabled: [_match isMyTurn]];
    }else{
        [self setUserInteractionEnabled:YES];
    }
    
}


- (void)makeMove:(RRTileMove)tileMove animated:(BOOL)animated completionHandler:(void (^)())completionHandler {
    [self setUserInteractionEnabled:NO];

    // Normalize rotation
    if( tileMove.rotation >= 360.0f ) tileMove.rotation -= 360.0f;
    
    const NSInteger RRTileMoveCCSequence = 27347;
    
    // Stop Old actions - this might happen if in multiplayer games
    [_gameBoardLayer.activeTile stopActionByTag:RRTileMoveCCSequence];
    
    if( animated ){
        
        NSMutableArray *actions = [NSMutableArray array];
        
        // Do we need to move tile?
        if( (int)round(_gameBoardLayer.activeTile.positionInGrid.x) != tileMove.gridX || (int)round(_gameBoardLayer.activeTile.positionInGrid.y) != tileMove.gridY ){
            [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
            [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
            [actions addObject: [CCMoveTo actionWithDuration:0.4f position:CGPointMake(tileMove.gridX *[RRTile tileSize] +[RRTile tileSize] /2,
                                                                                       tileMove.gridY *[RRTile tileSize] +[RRTile tileSize] /2)]];
            [actions addObject: [CCDelayTime actionWithDuration:0.3f]];
            [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];
        }
        
        // Do we need to rotate tile?
        if( _gameBoardLayer.activeTile.rotation != tileMove.rotation ) {
            NSInteger nextRotationAngle = (int)round(_gameBoardLayer.activeTile.rotation) -((int)_gameBoardLayer.activeTile.rotation %90);
            
            do{
                nextRotationAngle += 90;
                
                [actions addObject: [UDActionCallFunc actionWithSelector:@selector(liftTile)]];
                [actions addObject: [CCCallBlock actionWithBlock:^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRTileTurn.mp3"]; }]];
                [actions addObject: [CCRotateTo actionWithDuration:0.2f angle:nextRotationAngle]];
                [actions addObject: [UDActionCallFunc actionWithSelector:@selector(placeTile)]];
                [actions addObject: [CCDelayTime actionWithDuration:0.2f]];
                
                if( nextRotationAngle >= 360 ) nextRotationAngle -= 360;
            } while ( nextRotationAngle != (NSInteger)tileMove.rotation );
        }
        
        // Is this the end of turn?
        if( completionHandler ){
            [actions addObject: [CCCallBlock actionWithBlock:completionHandler]];
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
    }else{
        [_gameBoardLayer.activeTile liftTileWithSound:NO];
        [_gameBoardLayer.activeTile setPositionInGrid:CGPointMake(tileMove.gridX, tileMove.gridY)];
        [_gameBoardLayer.activeTile setRotation:tileMove.rotation];
        [_gameBoardLayer.activeTile placeTileWithSound:NO];
        
        // Is this the end of turn?
        if( completionHandler ){
            completionHandler();
        }   
    }
    
}


- (RRTile *)flipTopTileFromDeck {
    if( _deck.count == 0 ) return nil;
    
    RRTile *tile = [_deck objectAtIndex:0];
    [tile stopAllActions];
    [tile setOpacity:255];
    [tile setRotation:0.0f];
    [tile setBackSideVisible:NO];
    
    [_deck removeObject:tile];
    [self removeChild:tile cleanup:NO];
    
    [tile setPosition:CGPointMake(tile.position.x -_gameBoardLayer.position.x, tile.position.y -_gameBoardLayer.position.y)];
    
    [_gameBoardLayer addTile:tile animated:YES];

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

}


#pragma mark -
#pragma mark NSKeyValueObserving


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    NSString *soundEffext = nil;
    
    if( [keyPath isEqualToString:@"symbolsBlack"] ){
        if( _gameBoardLayer.symbolsBlack ){
            uint pointsGained = MIN((uint)2, _gameBoardLayer.symbolsBlack -_scoreLayer.scoreBlack);
            soundEffext = [NSString stringWithFormat: @"RRPlayerColor1-points%i-s%i.mp3", pointsGained, (UDTrueWithPossibility(0.5f)?1:2)];
        }
        
        [_scoreLayer setScoreBlack: _gameBoardLayer.symbolsBlack];
    }else if( [keyPath isEqualToString:@"symbolsWhite"] ){
        if( _gameBoardLayer.symbolsWhite ){
            uint pointsGained = MIN((uint)2, _gameBoardLayer.symbolsWhite -_scoreLayer.scoreWhite);
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
    
//    if( [[UDGKManager sharedManager] isHost] ){
//        if( !_resetGameButton ){
//            [self setUserInteractionEnabled:NO];
//            
//            _resetGameButton = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonReplay.png" highliteSpriteFrameName:@"RRButtonReplaySelected.png"];
//            [_resetGameButton setPosition:_buttonEndTurn.position];
//            __weak RRGameLayer *weakSeld = self;
//            [_resetGameButton addBlock: ^{
//                [[RRAudioEngine sharedEngine] stopAllEffects];
//                [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"];
//
//                [weakSeld resetGame];
//            } forControlEvents: UDButtonEventTouchUpInsideD];
//            [self addChild:_resetGameButton z:-2];
//        }
//    }
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
        [self endTurnAnimated:YES endMatchTurn:YES];
    }
    
}


#pragma mark -
#pragma mark GKLocalPlayerListener


- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {

    if( [match isEqual:_match] ){
        _match = match;
        [_match invalidateMatchRepresentation];
        
        RRMatchData matchRepresentation = match.matchRepresentation;
        RRTileMove tileMove = matchRepresentation.tileMoves[matchRepresentation.totalTileMoves -1];

        [self makeMove:tileMove animated:YES completionHandler: ^{ [self endTurnAnimated:YES endMatchTurn:NO]; }];
    }else{
        // notify user about other math
    }
    
}


- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match {
    
    if( [match isEqual:_match] ){
        _match = match;
        
        NSLog(@"player: %@ matchEnded: %@", player, match);
    }else{
        // notify user about other math
    }
    
}


@end