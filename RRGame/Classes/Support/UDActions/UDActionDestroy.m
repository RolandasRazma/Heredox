//
//  UDActionDestroy.m
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
