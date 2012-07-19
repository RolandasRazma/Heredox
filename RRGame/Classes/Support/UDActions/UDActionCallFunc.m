//
//  UDActionCallFunc.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/19/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDActionCallFunc.h"


@implementation UDActionCallFunc


+ (id)actionWithSelector:(SEL)selector {
	return [[[self alloc] initWithSelector: selector] autorelease];
}


- (id)initWithSelector:(SEL)selector {
	if( (self=[self initWithTarget:nil selector:selector]) ) {

	}
	return self;
}


- (void)execute {
    if( targetCallback_ ){
        [targetCallback_ performSelector:selector_];
    }else{
        [target_ performSelector:selector_];
    }
}


@end
