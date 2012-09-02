//
//  UDGameDelegate.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "cocos2d.h"
#import "RRGameDelegate.h"
#import "RRDefaultScene.h"


@implementation RRGameDelegate {
	UIWindow                *_window;
	UINavigationController  *_navigationController;
	CCDirectorIOS           *_director;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
	[_window release];
	[_navigationController release];
    
	[super dealloc];
}


#pragma mark -
#pragma mark UIApplicationDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
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
	if( ![_director enableRetinaDisplay:YES] )
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
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-hd"];                     // Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
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


@end
