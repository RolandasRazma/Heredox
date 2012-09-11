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

	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];                // Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setMacSuffix:@"-hd"];                          // Default on iMac is ""

    // Init RRHeredox
    [RRHeredox sharedInstance];

    // Show windows
    [_window makeKeyAndOrderFront:nil];
    
    // Push First Scene
    [_director pushScene: [RRDefaultScene node]];

    // Start animation
    [_director startAnimation];
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
