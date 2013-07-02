//
//  UDGameAppDelegate.m
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

#import "RRGameAppDelegate.h"
#import "cocos2d.h"
#import "RRDefaultScene.h"
#import "RRMenuScene.h"
#import "RRGameScene.h"


@implementation RRGameAppDelegate


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    CC_DIRECTOR_END();

}


#pragma mark -
#pragma mark NSApplicationDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    _director = (CCDirectorMac *)[CCDirector sharedDirector];

	// enable FPS and SPF
	[_director setDisplayStats:NO];
	
	// connect the OpenGL view with the director
	[_director setView:_glView];
    [_director setOriginalWinSize:CGSizeMake(768, 1024)];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[_director setResizeMode:kCCDirectorResize_AutoScale];
	
    // 2D projection
	[_director setProjection:kCCDirectorProjection2D];
    
	// Enable "moving" mouse event. Default no.
	[_window setAcceptsMouseMovedEvents:NO];
    
    // Lock resizing
    [_window setContentAspectRatio:NSSizeFromCGSize(_director.originalWinSize)];
    
	// Center main window
	[_window center];


    // Suffixes
	CCFileUtils *fileUtils = [CCFileUtils sharedFileUtils];
    [[fileUtils suffixesDict] setObject:@"@2x" forKey:kCCFileUtilsMac];
    [[fileUtils suffixesDict] setObject:@"@2x" forKey:kCCFileUtilsMacHD];

    // Init RRHeredox
    [RRHeredox sharedInstance];

    // Show windows
    [_window makeKeyAndOrderFront:nil];
    
    // Push First Scene
    [_director pushScene: [RRDefaultScene node]];

    // Start animation
    [_director startAnimation];
}


- (void)applicationDidBecomeActive:(NSNotification *)notification {

    [[GKLocalPlayer localPlayer] registerListener:self];
    
    if ( ![[GKLocalPlayer localPlayer] isAuthenticated] ) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            if( error ){
                [GKNotificationBanner showBannerWithTitle: [error localizedDescription]
                                                  message: nil
                                        completionHandler: NULL];
            }
        }];
    }
    
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}


#pragma mark -
#pragma mark UDGameAppDelegate


- (IBAction)toggleFullScreen:(id)sender {
	[_director setFullScreen: ![_director isFullScreen]];
}


#pragma mark -
#pragma mark GKLocalPlayerListener


- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite {
    NSLog(@"didRequestMatchWithPlayers: %@", playerIDsToInvite);
}


#pragma mark -
#pragma mark GKTurnBasedEventListener


- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive {
    
    if( !didBecomeActive ){
        didBecomeActive = ([_director.runningScene isKindOfClass: [RRDefaultScene class]] || [_director.runningScene isKindOfClass: [RRMenuScene class]]);
    }
    
    if( didBecomeActive ){
        
        // If we still loading give it some time to finish.
        if( [_director.runningScene isKindOfClass: [RRDefaultScene class]] ){
            RunAfterDelay(1.0f, ^{
                [self player:player receivedTurnEventForMatch:match didBecomeActive:didBecomeActive];
            });
            return;
        }
        
        // Load data first
        [match loadMatchDataWithCompletionHandler: ^(NSData *matchData, NSError *error) {
            if( error ) return;

            RunOnMainThreadAsync(^{
                // Start game
                RRGameScene *gameScene = [[RRGameScene alloc] initWithMatch:match];
                [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:gameScene]];
            });
        }];
    }
    
}


@end
