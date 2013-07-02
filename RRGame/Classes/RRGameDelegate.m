//
//  UDGameDelegate.m
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

#import "cocos2d.h"
#import "RRGameDelegate.h"
#import "RRDefaultScene.h"
#import "RRMenuScene.h"
#import "RRGameScene.h"
#import <Crashlytics/Crashlytics.h>


@implementation RRGameDelegate {
	UIWindow                *_window;
	UINavigationController  *_navigationController;
	CCDirectorIOS           *_director;
}


#pragma mark -
#pragma mark UIApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Setup Crashlytics
    [Crashlytics startWithAPIKey:@"a7cd0848a5a73e1d7c546e794480fdade0024696"];
    
	// Create the main window
	_window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame: [_window bounds]
								   pixelFormat: kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat: GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer: NO
									sharegroup: nil
								 multiSampling: NO
							   numberOfSamples: 0];

	_director = (CCDirectorIOS *)[CCDirector sharedDirector];

	[_director setWantsFullScreenLayout: YES];

	// Display FSP and SPF
	[_director setDisplayStats:NO];

	// set FPS at 60
	[_director setAnimationInterval:1.0f /60.0f];

	// attach the openglView to the director
	[_director setView:glView];

	// for rotation and other messages
	[_director setDelegate:self];

	// 2D projection
	[_director setProjection:kCCDirectorProjection2D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ![_director enableRetinaDisplay:!IS_IPAD] )
		CCLOG(@"Retina Display Not supported");

	// Create a Navigation Controller with the Director
	_navigationController = [[UINavigationController alloc] initWithRootViewController:_director];
	[_navigationController setNavigationBarHidden: YES];

	// set the Navigation Controller as the root view controller
//	[_window setRootViewController:_navigationController];
	[_window addSubview:_navigationController.view];

	// make main window visible
	[_window makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];     // Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils.suffixesDict setObject:@"@2x"      forKey:kCCFileUtilsiPhoneHD];
    [sharedFileUtils.suffixesDict setObject:@"@2x"      forKey:kCCFileUtilsiPad];
    [sharedFileUtils.suffixesDict setObject:@"@2x"      forKey:kCCFileUtilsiPadHD];
    [sharedFileUtils.suffixesDict setObject:@"-568h"    forKey:kCCFileUtilsiPhone5];
    [sharedFileUtils.suffixesDict setObject:@"-568h@2x" forKey:kCCFileUtilsiPhone5HD];
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

    // Init RRHeredox
    [RRHeredox sharedInstance];
    
    // Push First Scene
    [_director pushScene: [RRDefaultScene node]];
    
	return YES;
}


// getting a call, pause the game
- (void)applicationWillResignActive:(UIApplication *)application {
	if( [_navigationController visibleViewController] == _director )
		[_director pause];
}


// call got rejected
- (void)applicationDidBecomeActive:(UIApplication *)application {
	if( [_navigationController visibleViewController] == _director )
		[_director resume];

    [[GKLocalPlayer localPlayer] registerListener:self];
    
    if ( ![[GKLocalPlayer localPlayer] isAuthenticated] ) {
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: ^(NSError *error) {
            NSLog(@"authenticateWithCompletionHandler done");
            
            if( error ){
                [GKNotificationBanner showBannerWithTitle: [error localizedDescription]
                                                  message: nil
                                        completionHandler: NULL];
            }
        }];
    }
}


- (void)applicationDidEnterBackground:(UIApplication*)application {
	if( [_navigationController visibleViewController] == _director )
		[_director stopAnimation];
}


- (void)applicationWillEnterForeground:(UIApplication*)application {
	if( [_navigationController visibleViewController] == _director )
		[_director startAnimation];
}


// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application {
	CC_DIRECTOR_END();
}


// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[_director purgeCachedData];
}


// next delta time will be zero
- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[_director setNextDeltaTimeZero:YES];
}


#pragma mark -
#pragma mark CCDirectorDelegate


// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return UIInterfaceOrientationIsPortrait(interfaceOrientation);
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
