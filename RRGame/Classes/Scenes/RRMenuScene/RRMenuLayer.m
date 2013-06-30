//
//  UDMenuLayer.m
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

#import "RRMenuLayer.h"
#import "RRPickColorScene.h"
#import "RRRulesScene.h"
#import "RRPopupLayer.h"


@implementation RRMenuLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((isDeviceIPad()||isDeviceMac())?@"RRBackgroundMenu~ipad.png":@"RRBackgroundMenu.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add buttons
        UDSpriteButton *buttonPlayers1 = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonPlayers1.png" highliteSpriteFrameName:@"RRButtonPlayers1Selected.png"];
        [buttonPlayers1 addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self startGameWithNumberOfPlayers:1]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonPlayers1];

        UDSpriteButton *buttonPlayers2 = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonPlayers2.png" highliteSpriteFrameName:@"RRButtonPlayers2Selected.png"];
        [buttonPlayers2 addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self pickMultiplayerType]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonPlayers2];
        
        
        UDSpriteButton *buttonRules = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonHowToPlay.png" highliteSpriteFrameName:@"RRButtonHowToPlaySelected.png"];
        [buttonRules addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showRules]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonRules];
        
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonPlayers1 setPosition:CGPointMake(460, 505)];
            [buttonPlayers2 setPosition:CGPointMake(460, 400)];
            
            [buttonRules setPosition:CGPointMake(460, 240)];
        }else{
            [buttonPlayers1 setPosition:CGPointMake(195, 240)];
            [buttonPlayers1 setScale:0.8f];
            
            [buttonPlayers2 setPosition:CGPointMake(195, 185)];
            [buttonPlayers2 setScale:0.8f];
            
            [buttonRules setPosition:CGPointMake(195, 115)];
            [buttonRules setScale:0.8f];
        }
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onEnterTransitionDidFinish {
    [super onEnterTransitionDidFinish];

    [[UDGKManager sharedManager] setSessionProvider:nil];
    [[UDGKManager sharedManager] authenticateInGameCenterWithCompletionHandler:NULL];
}


- (void)onEnter {
    [super onEnter];

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(allPlayersConnectedNotification)
                                                 name: UDGKManagerAllPlayersConnectedNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(playerGotInviteNotification:)
                                                 name: UDGKManagerPlayerGotInviteNotification
                                               object: nil];
}


- (void)onExit {
    [super onExit];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -
#pragma mark UDMenuLayer


- (void)pickMultiplayerType {
    
    RRMenuMultiplayerLayer *menuMultiplayerLayer = [RRMenuMultiplayerLayer node];
    [menuMultiplayerLayer setDelegate: self];
    [self addChild:menuMultiplayerLayer z:1000];
    
}


- (void)startGameWithNumberOfPlayers:(NSUInteger)numberOfPlayers {

    RRPickColorScene *pickColorScene = [[RRPickColorScene alloc] initWithNumberOfPlayers:numberOfPlayers];
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:pickColorScene]];
    
}


- (void)allPlayersConnectedNotification {
    [self dismissMatchmakerViewController];
    
    RRPickColorScene *pickColorScene = [[RRPickColorScene alloc] initWithNumberOfPlayers:2];
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:pickColorScene]];

}


- (void)playerGotInviteNotification:(NSNotification *)notification {
    
    NSLog(@"playerGotInviteNotification");

    if ( [notification.userInfo objectForKey:@"acceptedInvite"] ) {

        #warning FIX ME
        NSAssert(NO, @"Invites not implemented");
        
        /*
        GKMatchmakerViewController *matchmakerViewController = [[GKMatchmakerViewController alloc] initWithInvite: [notification.userInfo objectForKey:@"acceptedInvite"]];
        [matchmakerViewController setMatchmakerDelegate:self];
        [self presentMatchmakerViewController:matchmakerViewController];
        */

    } else if ( [notification.userInfo objectForKey:@"playersToInvite"] ) {
        
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        [request setMinPlayers: 2];
        [request setMaxPlayers: 2];
        [request setPlayersToInvite: [notification.userInfo objectForKey:@"playersToInvite"]];
        
        GKTurnBasedMatchmakerViewController *matchmakerViewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
        [matchmakerViewController setTurnBasedMatchmakerDelegate:self];
        [self presentMatchmakerViewController:matchmakerViewController];
        
    }
    
}


- (void)showRules {
    
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:[RRRulesScene node]]];

}


- (void)presentMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)matchmakerViewController {
    
#if __CC_PLATFORM_IOS
    [[CCDirector sharedDirector].parentViewController presentModalViewController:matchmakerViewController animated:YES];
#elif defined(__CC_PLATFORM_MAC)
    _dialogController = [[GKDialogController alloc] init];
    [_dialogController setParentWindow: [[NSApplication sharedApplication] mainWindow]];
    [_dialogController presentViewController:matchmakerViewController];
#endif
    
    _matchmakerViewController = matchmakerViewController;
}


- (void)dismissMatchmakerViewController {
#if __CC_PLATFORM_IOS
    [[CCDirector sharedDirector].parentViewController dismissModalViewControllerAnimated:YES];
#elif defined(__CC_PLATFORM_MAC)
    [_dialogController dismiss:_matchmakerViewController];
    _dialogController = nil;
#endif
    
    _matchmakerViewController = nil;
}


#pragma mark -
#pragma mark RRMenuMultiplayerLayerDelegate


- (void)menuMultiplayerLayer:(RRMenuMultiplayerLayer *)menuMultiplayerLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex {
    
    if( buttonIndex == 0 ){
        [self startGameWithNumberOfPlayers:2];
        return;
    }else if( buttonIndex == 2 ){
        
        GKMatchRequest *request = [[GKMatchRequest alloc] init];
        [request setMinPlayers: 2];
        [request setMaxPlayers: 2];
        

        GKTurnBasedMatchmakerViewController *matchmakerViewController = [[GKTurnBasedMatchmakerViewController alloc] initWithMatchRequest:request];
        [matchmakerViewController setTurnBasedMatchmakerDelegate:self];
        [self presentMatchmakerViewController:matchmakerViewController];

    }
    
    [menuMultiplayerLayer dismiss];
}


#pragma mark -
#pragma mark GKTurnBasedMatchmakerViewControllerDelegate


- (void)turnBasedMatchmakerViewControllerWasCancelled:(GKTurnBasedMatchmakerViewController *)viewController {
    [self dismissMatchmakerViewController];
}


- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFailWithError:(NSError *)error {
    
    [self dismissMatchmakerViewController];
    
    RRPopupLayer *popupLayer = [RRPopupLayer layerWithMessage: @"RRTextGameCenterError"
                                             cancelButtonName: @"RRButtonContinue"
                                           cancelButtonAction: nil];
    [self addChild:popupLayer z:1000];

}


- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController didFindMatch:(GKTurnBasedMatch *)match {
    [[UDGKManager sharedManager] setSessionProvider:match];
}


// Called when a users chooses to quit a match and that player has the current turn.
// The developer should call playerQuitInTurnWithOutcome:nextPlayer:matchData:completionHandler: on the match passing in appropriate values.
// They can also update matchOutcome for other players as appropriate.
- (void)turnBasedMatchmakerViewController:(GKTurnBasedMatchmakerViewController *)viewController playerQuitForMatch:(GKTurnBasedMatch *)match {
    #warning TODO
}


@end
