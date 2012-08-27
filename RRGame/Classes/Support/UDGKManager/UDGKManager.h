//
//  UDGKManager.h
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGKPacket.h"
#import "UDGKPlayer.h"


extern NSString * const UDGKManagerPlayerGotInviteNotification;
extern NSString * const UDGKManagerAllPlayersConnectedNotification;


@protocol UDGKManagerPacketObserving <NSObject>
@required

- (void)observePacket:(const void *)packet fromPlayer:(id <UDGKPlayerProtocol>)player;

@end


@protocol UDGKManagerPlayerObserving <NSObject>
@required

- (void)observePlayer:(id <UDGKPlayerProtocol>)player state:(GKPlayerConnectionState)state;

@end


#if __IPHONE_OS_VERSION_MAX_ALLOWED
    #define UDGKManagerGKDelegates GKMatchDelegate, GKSessionDelegate
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
    #define UDGKManagerGKDelegates GKMatchDelegate
#endif


@interface UDGKManager : NSObject <UDGKManagerPacketObserving, UDGKManagerGKDelegates> {
    GKMatch             *_match;
#if __IPHONE_OS_VERSION_MAX_ALLOWED
    GKSession           *_session;
#else
    id                  _session;
#endif
    NSString            *_hostPlayerID;
    NSMutableDictionary *_players;
    NSMutableDictionary *_packetObservers;
    NSMutableDictionary *_playerObservers;
}

@property (nonatomic, readonly) NSString        *playerID;
@property (nonatomic, readonly) NSString        *hostPlayerID;
@property (nonatomic, readonly) BOOL            isHost;
@property (nonatomic, readonly) BOOL            isNetworkPlayActive;
@property (nonatomic, readonly) NSDictionary    *players;
@property (nonatomic, retain)   id              sessionProvider;    // GKMatch or GKSession
    
+ (UDGKManager *)sharedManager;
+ (const BOOL)isGameCenterAvailable;

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
