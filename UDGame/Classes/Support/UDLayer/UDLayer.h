//
//  UDLayer.h
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2011 UD7. All rights reserved.
//

#import "CCLayer.h"


@interface UDLayer : CCLayer {
    BOOL _touchActive;
}

@property(nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;

- (BOOL)touchBeganAtLocation:(CGPoint)location;
- (void)touchMovedToLocation:(CGPoint)location;
- (void)touchEndedAtLocation:(CGPoint)location;

@end
