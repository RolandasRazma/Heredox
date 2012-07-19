//
//  UDActionCallFunc.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/19/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCActionInstant.h"


@interface UDActionCallFunc : CCCallFunc

+ (id)actionWithSelector:(SEL)selector;
- (id)initWithSelector:(SEL)selector;

@end
