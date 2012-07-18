//
//  UDActionScaleTo.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"
#import "CCActionInterval.h"


@interface UDActionScaleTo : CCActionInterval <NSCopying> {
	float _scale;
	float _startScale;
	float _endScale;
	float _delta;
}

/** creates the action with the same scale factor for X and Y */
+ (id)actionWithDuration:(ccTime)duration scale:(float)scale;

/** initializes the action with the same scale factor for X and Y */
- (id)initWithDuration:(ccTime)duration scale:(float)scale;

@end