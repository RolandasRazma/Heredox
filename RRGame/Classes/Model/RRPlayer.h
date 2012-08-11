//
//  RRPlayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/16/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RRPlayer : NSObject {
    RRPlayerColor   _playerColor;
    NSString        *_playerID;
}

@property (nonatomic, readonly) RRPlayerColor playerColor;
@property (nonatomic, retain) NSString *playerID;

+ (id)playerWithPlayerColor:(RRPlayerColor)playerColor;
- (id)initWithPlayerColor:(RRPlayerColor)playerColor;

@end
