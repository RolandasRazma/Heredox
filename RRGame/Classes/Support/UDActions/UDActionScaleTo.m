//
//  UDActionScaleTo.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDActionScaleTo.h"
#import "CCNode.h"


@implementation UDActionScaleTo


+ (id)actionWithDuration:(ccTime)duration scale:(float)scale {
    return [[[self alloc] initWithDuration:duration scale:scale] autorelease];
}


- (id)initWithDuration:(ccTime)duration scale:(float)scale {
	if( (self=[super initWithDuration:duration]) ) {
		_endScale = scale;
	}
	return self;
}


- (id)copyWithZone:(NSZone *)zone {
	return [[[self class] allocWithZone: zone] initWithDuration:[self duration] scale:_endScale];
}


- (void)startWithTarget:(CCNode *)aTarget {
	[super startWithTarget:aTarget];
	_startScale = [(CCNode *)target_ scale];
	_delta = _endScale - _startScale;
}


- (void)update:(ccTime)delta {
	[target_ setScale: (_startScale + _delta *delta ) ];
}


@end
