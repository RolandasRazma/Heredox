//
//  UDActionDestroy.h
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "CCActionInterval.h"


@interface UDActionDestroy : CCActionInterval <NSCopying> {
    CCNode *otherTarget_;
}

/** creates the action */
+ (id)action;
+ (id)actionWithTarget:(CCNode *)target;
- (id)initWithTarget:(CCNode *)target;

@end