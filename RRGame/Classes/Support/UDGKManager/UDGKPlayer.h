//
//  UDGKPlayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <GameKit/GameKit.h>


@interface UDGKPlayer : GKPlayer {
    NSString *_playerID;
}

+ (id)playerWithPlayerID:(NSString *)playerID;
- (id)initWithPlayerID:(NSString *)playerID;

@end
