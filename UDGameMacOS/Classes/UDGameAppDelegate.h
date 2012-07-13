//
//  UDGameAppDelegate.h
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright UD7 2012. All rights reserved.
//


@interface UDGameAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet NSWindow	*_window;
	IBOutlet CCGLView	*_glView;
    CCDirectorMac       *_director;
}

- (IBAction)toggleFullScreen:(id)sender;

@end
