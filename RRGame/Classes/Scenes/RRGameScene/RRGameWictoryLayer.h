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


typedef enum RRPlayerColorWictorious : unsigned int {
    RRPlayerColorWictoriousNo       = RRPlayerColorUndefined,
    RRPlayerColorWictoriousBlack    = RRPlayerColorBlack,
    RRPlayerColorWictoriousWhite    = RRPlayerColorWhite,
} RRPlayerColorWictorious;


@interface RRGameWictoryLayer : UDLayer {
    id <RRPlayerColorWictoriousDelegate>_delegate;
    CCLayerColor            *_colorBackground;
    CCSprite                *_menu;
    RRPlayerColorWictorious _playerColorWictorious;
}

@property (nonatomic, assign) id <RRPlayerColorWictoriousDelegate>delegate;

+ (id)layerForColor:(RRPlayerColorWictorious)playerColorWictorious blackWins:(uint)blackWins whiteWins:(uint)whiteWins draws:(uint)draws;
- (id)initWithColor:(RRPlayerColorWictorious)playerColorWictorious blackWins:(uint)blackWins whiteWins:(uint)whiteWins draws:(uint)draws;

- (void)dismiss;

@end


@protocol RRPlayerColorWictoriousDelegate <NSObject>

- (void)gameWictoryLayer:(RRGameWictoryLayer *)gameMenuLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex;

@end