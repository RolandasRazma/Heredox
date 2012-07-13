//
//  UDButton.h
//  UDGame
//
//  Created by Rolandas Razma on 1/26/11.
//  Copyright 2011 UD7. All rights reserved.
//

#import "CCSprite.h"
#import "CCTouchDelegateProtocol.h"


enum {
    UDButtonEventTouchDown          = 1 <<  0,
    UDButtonEventTouchDownRepeat    = 1 <<  1,
    UDButtonEventTouchDragInside    = 1 <<  2,
    UDButtonEventTouchDragOutside   = 1 <<  3,
    UDButtonEventTouchUpInside      = 1 <<  4,
    UDButtonEventTouchUpOutside     = 1 <<  5,
    UDButtonEventTouchHold          = 1 <<  6,
};
typedef NSUInteger UDButtonEvents;


@interface UDButton : CCSprite <CCTargetedTouchDelegate>

+ (id)buttonWithSpriteFile:(NSString *)fileName;
- (id)initWithSpriteFile:(NSString *)fileName;

- (void)addBlock:(BasicBlock)block forControlEvents:(UDButtonEvents)controlEvents;

- (void)setTitle:(NSString *)title;

@end
