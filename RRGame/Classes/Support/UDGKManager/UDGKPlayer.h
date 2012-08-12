//
//  UDGKPlayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <GameKit/GameKit.h>


@protocol UDGKPlayerProtocol <NSObject>
@required

@property(nonatomic, readonly, retain)  NSString    *playerID;
@property(nonatomic, readonly, copy)    NSString    *alias;

@end


@interface UDGKPlayer : NSObject <UDGKPlayerProtocol> {
    NSString    *_playerID;
    NSString    *_alias;
}

@property(nonatomic, readonly, retain)  NSString    *playerID;
@property(nonatomic, readonly, copy)    NSString    *alias;

+ (id)playerWithPlayerID:(NSString *)playerID alias:(NSString *)alias;
- (id)initWithPlayerID:(NSString *)playerID alias:(NSString *)alias;

@end
