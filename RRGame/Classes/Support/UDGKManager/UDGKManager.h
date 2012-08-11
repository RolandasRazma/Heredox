//
//  UDGKManager.h
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGKPacket.h"
#import "UDGKPlayer.h"


extern NSString * const UDGKManagerGotInviteNotification;
extern NSString * const UDGKManagerAllPlayersConnectedNotification;


@protocol UDGKManagerPacketObserving <NSObject>
@required

- (void)observePacket:(const void *)packet fromPlayer:(UDGKPlayer *)player;

@end


@interface UDGKManager : NSObject <GKMatchDelegate, UDGKManagerPacketObserving> {
    GKMatch             *_match;
    NSString            *_hostPlayerID;
    NSMutableDictionary *_players;
    NSMutableDictionary *_packetObservers;
}

@property (nonatomic, readonly) NSString        *playerID;
@property (nonatomic, readonly) NSString        *hostPlayerID;
@property (nonatomic, readonly) BOOL            isHost;
@property (nonatomic, readonly) NSDictionary    *players;
@property (nonatomic, retain)   GKMatch         *match;

+ (UDGKManager *)sharedManager;

- (BOOL)sendPacketToAllPlayers:(const void *)packet length:(NSUInteger)length;
- (BOOL)sendPacket:(const void *)packet length:(NSUInteger)length toPlayers:(NSArray *)playerIDs;

- (void)addPacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType;
- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType;
- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer;

@end
