//
//  RRPopupLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 13/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"


@interface RRPopupLayer : UDLayer {
    CCSprite *_menu;
}

+ (id)layerWithMessage:(NSString *)message;
+ (id)layerWithMessage:(NSString *)message cancelButtonName:(NSString *)cancelButtonName cancelButtonAction:(void (^)(void))block;
- (id)initWithMessage:(NSString *)message cancelButtonName:(NSString *)cancelButtonName cancelButtonAction:(void (^)(void))block;

@end
