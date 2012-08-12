//
//  UDGKManager.h
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGKPacket.h"


extern NSString * const UDGKManagerPlayerGotInviteNotification;
extern NSString * const UDGKManagerAllPlayersConnectedNotification;


@protocol UDGKManagerPacketObserving <NSObject>
@required

- (void)observePacket:(const void *)packet fromPlayer:(GKPlayer *)player;

@end


@protocol UDGKManagerPlayerObserving <NSObject>
@required

- (void)observePlayer:(GKPlayer *)player state:(GKPlayerConnectionState)state;

@end


@interface UDGKManager : NSObject <GKMatchDelegate, UDGKManagerPacketObserving> {
    GKMatch             *_match;
    NSString            *_hostPlayerID;
    NSMutableDictionary *_players;
    NSMutableDictionary *_packetObservers;
    NSMutableDictionary *_playerObservers;
}

@property (nonatomic, readonly) NSString        *playerID;
@property (nonatomic, readonly) NSString        *hostPlayerID;
@property (nonatomic, readonly) BOOL            isHost;
@property (nonatomic, readonly) NSDictionary    *players;
@property (nonatomic, retain)   GKMatch         *match;

+ (UDGKManager *)sharedManager;

- (void)authenticateInGameCenterWithCompletionHandler:(void(^)(NSError *error))completionHandler;

- (BOOL)sendPacketToAllPlayers:(const void *)packet length:(NSUInteger)length;
- (BOOL)sendPacket:(const void *)packet length:(NSUInteger)length toPlayers:(NSArray *)playerIDs;

- (void)addPacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType;
- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType;
- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer;

- (void)addPlayerObserver:(id <UDGKManagerPlayerObserving>)observer forConnectionState:(GKPlayerConnectionState)connectionState;
- (void)removePlayerObserver:(id <UDGKManagerPlayerObserving>)observer forConnectionState:(GKPlayerConnectionState)connectionState;
- (void)removePlayerObserver:(id <UDGKManagerPlayerObserving>)observer;

@end
