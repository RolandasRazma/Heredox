//
//  RRMenuMultiplayerLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"


@protocol RRMenuMultiplayerLayerDelegate;


@interface RRMenuMultiplayerLayer : UDLayer {
    id <RRMenuMultiplayerLayerDelegate> _delegate;
}

@property (nonatomic, assign) id <RRMenuMultiplayerLayerDelegate>delegate;

@end


@protocol RRMenuMultiplayerLayerDelegate <NSObject>

@end