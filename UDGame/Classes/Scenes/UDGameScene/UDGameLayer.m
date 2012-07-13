//
//  UDGameLayer.m
//  UDBloodyFlight
//
//  Created by Rolandas Razma on 4/5/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGameLayer.h"


@implementation UDGameLayer


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [super dealloc];
}


- (id)init {
	if( (self=[super init]) ) {
        [self setUserInteractionEnabled:YES];
    }
	return self;
}


#pragma mark -
#pragma mark CCNode


#if DEBUG && __CC_PLATFORM_IOS
- (void)draw {
    glPushGroupMarkerEXT(0, "-[UDGameLayer draw]");
    
	[super draw];

	glPopGroupMarkerEXT();
}
#endif


#pragma mark -
#pragma mark UDGameLayer


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    // [_currentLine addSegmentToPoint: [_currentLine convertToNodeSpace:location]];    
}


- (void)touchEndedAtLocation:(CGPoint)location {
    
}


@end