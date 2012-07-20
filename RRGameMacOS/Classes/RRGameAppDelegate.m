//
//  UDGameAppDelegate.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//

#import "RRGameAppDelegate.h"
#import "cocos2d.h"
#import "RRDefaultScene.h"


@implementation RRGameAppDelegate


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    CC_DIRECTOR_END();
    
	[_window release];
	[super dealloc];
}


#pragma mark -
#pragma mark NSApplicationDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
#if !DEBUG
    // [TestFlight setDeviceIdentifier:[UDDevice UUID]];
    // [TestFlight takeOff:@"44bb611ef55983c0e351fd6535fc314a_NzgxNDkyMDEyLTA0LTA1IDAyOjExOjU5LjMzNjY5Mw"];
#endif
    
    _director = (CCDirectorMac *)[CCDirector sharedDirector];

	// enable FPS and SPF
	[_director setDisplayStats:NO];
	
	// connect the OpenGL view with the director
	[_director setView:_glView];

	// EXPERIMENTAL stuff.
	// 'Effects' don't work correctly when autoscale is turned on.
	// Use kCCDirectorResize_NoScale if you don't want auto-scaling.
	[_director setResizeMode:kCCDirectorResize_AutoScale];
	
    // 2D projection
	[_director setProjection:kCCDirectorProjection2D];
    
	// Enable "moving" mouse event. Default no.
	[_window setAcceptsMouseMovedEvents:NO];
    
	// Center main window
	[_window center];

    // Init RRHeredox
    [RRHeredox sharedInstance];
    
    // Push First Scene
    [_director runWithScene: [RRDefaultScene node]];
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
	return YES;
}


#pragma mark -
#pragma mark UDGameAppDelegate


- (IBAction)toggleFullScreen:(id)sender {
	[_director setFullScreen: ![_director isFullScreen]];
}


@end
