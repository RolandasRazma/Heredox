//
//  RRHeredox.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum UDGameMode : NSUInteger {
    UDGameModeClosed    = 0,
    UDGameModeOpen      = 1,
} UDGameMode;


typedef enum UDPlayerColor : NSUInteger {
    UDPlayerColorBlack = 1,
    UDPlayerColorWhite = 2,
} UDPlayerColor;


@interface RRHeredox : NSObject

@end
