//
//  UDActionDestroy.m
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "UDActionDestroy.h"


@implementation UDActionDestroy


#pragma mark -
#pragma mark CCActionInterval


+ (id)action {
	return [[[self alloc] initWithDuration:0.0f] autorelease];
}


+ (id)actionWithTarget:(CCNode *)target {
	return [[[self alloc] initWithTarget:target] autorelease];
}


- (id)initWithTarget:(CCNode *)target {
    if( (self = [super initWithDuration:0.0f]) ){
        otherTarget_ = target;
    }
    return self;
}


- (void)update:(ccTime)t {
    /*
    if( duration_ == 0.0f || duration_ == FLT_EPSILON || elapsed_ >= duration_ ){
        [target_ removeFromParentAndCleanup:YES];
    }
    */
}


- (void)stop {
    if( otherTarget_ ){
        [otherTarget_ removeFromParentAndCleanup:YES];
    }else{
        [target_ removeFromParentAndCleanup:YES];
    }
    [super stop];
}


@end
