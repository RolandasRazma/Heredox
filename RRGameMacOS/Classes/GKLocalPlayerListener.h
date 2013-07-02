//
//  GKLocalPlayerListener.h
//  RRHeredox
//
//  Created by Rolandas Razma on 02/07/2013.
//  Copyright (c) 2013 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol GKInviteEventListener
@optional

- (void)player:(GKPlayer *)player didAcceptInvite:(GKInvite *)invite;
- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite;

@end


@protocol GKTurnBasedEventListener
@optional

- (void)player:(GKPlayer *)player didRequestMatchWithPlayers:(NSArray *)playerIDsToInvite;
- (void)player:(GKPlayer *)player receivedTurnEventForMatch:(GKTurnBasedMatch *)match didBecomeActive:(BOOL)didBecomeActive;
- (void)player:(GKPlayer *)player matchEnded:(GKTurnBasedMatch *)match;

@end

@protocol GKLocalPlayerListener <GKInviteEventListener, GKTurnBasedEventListener>
@end


@interface GKLocalPlayer (RRiOS7Backport)

- (void)registerListener:(id <GKLocalPlayerListener>)listener;

- (void)unregisterListener:(id <GKLocalPlayerListener>)listener;

- (void)unregisterAllListeners;

@end