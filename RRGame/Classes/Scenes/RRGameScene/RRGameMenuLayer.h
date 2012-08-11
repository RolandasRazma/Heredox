//
//  RRGameMenuLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"
#import "UDLayer.h"


@protocol RRGameMenuDelegate;


@interface RRGameMenuLayer : UDLayer {
    CCSprite    *_sliderSound;
    CGFloat     _sliderEdgeLeft;
    CGFloat     _sliderWidth;
    
    id <RRGameMenuDelegate> _delegate;
    CCLayerColor            *_colorBackground;
    CCSprite                *_menu;
}

@property (nonatomic, assign) id <RRGameMenuDelegate>delegate;

- (void)dismiss;

@end


@protocol RRGameMenuDelegate <NSObject>

- (void)gameMenuLayer:(RRGameMenuLayer *)gameMenuLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex;

@end
