//
//  UDActionDestroy.m
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "UDActionDestroy.h"


@implementation UDActionDestroy


+ (id)action {
	return [[[self alloc] initWithDuration:0.0f] autorelease];
}


- (void)update:(ccTime)t {
    /*
    if( duration_ == 0.0f || duration_ == FLT_EPSILON || elapsed_ >= duration_ ){
        [target_ removeFromParentAndCleanup:YES];
    }
    */
}


- (void)stop {
    [target_ removeFromParentAndCleanup:YES];
    [super stop];
}


@end
