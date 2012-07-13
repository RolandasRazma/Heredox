//
//  UDGameLayer.h
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDLayer.h"


typedef enum UDGameMode : NSUInteger {
    UDGameModeClosed    = 0,
    UDGameModeOpen      = 1,
} UDGameMode;


@interface UDGameLayer : UDLayer

- (id)initWithGameMode:(UDGameMode)gameMode;

@end
