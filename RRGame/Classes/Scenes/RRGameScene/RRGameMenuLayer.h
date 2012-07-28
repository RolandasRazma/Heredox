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


@interface RRGameMenuLayer : UDLayer

@property (nonatomic, assign) id <RRGameMenuDelegate>delegate;

- (void)showInLayer:(CCLayer *)layer;
- (void)dismiss;

@end


@protocol RRGameMenuDelegate <NSObject>

- (void)gameMenuLayer:(RRGameMenuLayer *)gameMenuLayer didSelectButtonAtIndex:(NSUInteger)buttonIndex;

@end
