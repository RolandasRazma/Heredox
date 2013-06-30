//
//  UDGKManager.h
//
//  Created by Rolandas Razma on 11/08/2012.
//
//  Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
