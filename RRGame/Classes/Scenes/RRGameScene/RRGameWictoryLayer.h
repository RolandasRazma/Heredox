//
//  RRGameWictoryLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"
#import "UDLayer.h"


@protocol RRPlayerColorWictoriousDelegate;


typedef enum RRPlayerColorWictorious : NSUInteger {
    RRPlayerColorWictoriousNo       = 0,
    RRPlayerColorWictoriousBlack    = 1,
    RRPlayerColorWictoriousWhite    = 2,
} RRPlayerColorWictorious;


@interface RRGameWictoryLayer : UDLayer {
    id <RRPlayerColorWictoriousDelegate>_delegate;
    CCLayerColor            *_colorBackground;
    CCSprite                *_menu;
    RRPlayerColorWictorious _playerColorWictorious;
}

@property (nonatomic, assign) id <RRPlayerColorWictoriousDelegate>delegate;

+ (RRPlayerColorWictorious)lastPlayerColorWictorious;
+ (id)layerForColor:(RRPlayerColorWictorious)playerColorWictorious;
- (id)initWithColor:(RRPlayerColorWictorious)playerColorWictorious;

- (void)showInLayer:(CCLayer *)layer;
- (void)dismiss;

@end


@protocol RRPlayerColorWictoriousDelegate <NSObject>

- (void)gameWictoryLayer:(RRGameWictoryLayer *)gameMenuLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex;

@end