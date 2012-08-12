//
//  UDGKManager.m
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDGKManager.h"
#import "UDGKPlayer.h"


NSString * const UDGKManagerPlayerGotInviteNotification     = @"UDGKManagerPlayerGotInviteNotification";
NSString * const UDGKManagerAllPlayersConnectedNotification = @"UDGKManagerAllPlayersConnectedNotification";


@implementation UDGKManager


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        _players        = [[NSMutableDictionary alloc] initWithCapacity:5];
        _packetObservers= [[NSMutableDictionary alloc] initWithCapacity:5];
        _playerObservers= [[NSMutableDictionary alloc] initWithCapacity:5];
        
        [self addPacketObserver:self forType:UDGKPacketTypePickHost];

#if __IPHONE_OS_VERSION_MAX_ALLOWED
            [[NSNotificationCenter defaultCenter] addObserver: self
                                                     selector: @selector(applicationWillTerminateNotification)
                                                         name: UIApplicationWillTerminateNotification
                                                       object: nil];
#endif
    
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(playerAuthenticationDidChangeNotification)
                                                     name: GKPlayerAuthenticationDidChangeNotificationName
                                                   object: nil];
    }
    return self;
}


#pragma mark -
#pragma mark UDGKManager


+ (UDGKManager *)sharedManager {
    static UDGKManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[UDGKManager alloc] init];
    });
    return _sharedManager;
}


- (void)applicationWillTerminateNotification {
    [self setMatch:nil];
}


- (void)playerAuthenticationDidChangeNotification {
    if ( [[GKLocalPlayer localPlayer] isAuthenticated] ) {
        [[GKMatchmaker sharedMatchmaker] setInviteHandler: ^(GKInvite *acceptedInvite, NSArray *playersToInvite) {

            [[NSNotificationCenter defaultCenter] postNotificationName: UDGKManagerPlayerGotInviteNotification
                                                                object: self
                                                              userInfo: @{ @"acceptedInvite": acceptedInvite, @"playersToInvite": playersToInvite}];
            
        }];
    }else{
        [[GKMatchmaker sharedMatchmaker] setInviteHandler: NULL];
    }
}


- (void)authenticateInGameCenterWithCompletionHandler:(void(^)(NSError *error))completionHandler {

    if ( ![[GKLocalPlayer localPlayer] isAuthenticated] ) {
        if( !completionHandler ){
            completionHandler = ^(NSError *error){
                if( error ){
                    [GKNotificationBanner showBannerWithTitle: [error localizedDescription]
                                                      message: nil
                                            completionHandler: NULL];
                }
            };
        }
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: completionHandler];
    }else if( completionHandler ){
        completionHandler(nil);
    }
    
}


- (BOOL)isHost {
    return ((!_match && !_session) || [self.playerID isEqualToString:self.hostPlayerID]);
}


- (NSString *)playerID {

    if( _match && [[GKLocalPlayer localPlayer] isAuthenticated] ){
        return [[GKLocalPlayer localPlayer] playerID];
#if __IPHONE_OS_VERSION_MAX_ALLOWED
    }else if( _session ){
        return [_session peerID];
#endif
    }else{
        return nil;
    }
    
}


- (void)setMatch:(GKMatch *)match {
    
    if ( ![_match isEqual:match] ) {
        if( match && _session ) [self setSession:nil];
        
        // Disconnect players
        for( NSString *playerID in [[_players allKeys] reverseObjectEnumerator] ){
            [self playerID:playerID didChangeState:GKPlayerStateDisconnected];
        }
        
        // Remove host
        [_hostPlayerID release], _hostPlayerID = nil;
        
        // Destroy match
        [_match setDelegate:nil];
        [_match disconnect];
        [_match release], _match = nil;

        // Set new match
        if( match ){
            _match = [match retain];
            
            // If match already have connected players
            [self playerID:[self playerID] didChangeState:GKPlayerStateConnected];
            for( NSString *playerID in [_match playerIDs] ){
                [self match:_match player:playerID didChangeState:GKPlayerStateConnected];
            }

            [_match setDelegate:self];
        }
    }
    
}


#if __IPHONE_OS_VERSION_MAX_ALLOWED
- (void)setSession:(GKSession *)session {
    
    if ( ![_session isEqual:session] ) {
        if( session && _match ) [self setMatch:nil];
        
        // Disconnect players
        for( NSString *playerID in [[_players allKeys] reverseObjectEnumerator] ){
            [self playerID:playerID didChangeState:GKPlayerStateDisconnected];
        }
        
        // Remove host
        [_hostPlayerID release], _hostPlayerID = nil;
        
        // Destroy session
        [_session setDelegate:nil];
        [_session disconnectFromAllPeers];
        [_session setAvailable:NO];
        [_session setDataReceiveHandler:nil withContext:NULL];
        [_session release], _session = nil;

        if( session ){
            _session = [session retain];

            // Session already have connected players
            [self playerID:[self playerID] didChangeState:GKPlayerStateConnected];
            
            [_session setDataReceiveHandler:self withContext:NULL];
            [_session setDelegate:self];
        }
    }
    
}
#endif


- (void)packet:(const void *)packet fromPlayerID:(NSString *)playerID {
    id <UDGKPlayerProtocol>player = [_players valueForKey:playerID];
    
    NSAssert1(player, @"No player for playerID: %@", playerID);

    NSSet *observers = [_packetObservers objectForKey: @((*(UDGKPacket *)packet).type)];
    @synchronized( observers ){
        for( id <UDGKManagerPacketObserving>observer in observers ){
            [observer observePacket:packet fromPlayer:player];
        }
    }
}


- (BOOL)sendPacketToAllPlayers:(const void *)packet length:(NSUInteger)length {
    if( !_match && !_session ) return NO;
    
    [self packet:packet fromPlayerID: [self playerID]];
    
    if( _match ){
        return [_match sendDataToAllPlayers: [NSData dataWithBytes:packet length:length]
                               withDataMode: GKMatchSendDataReliable
                                      error: NULL];
#if __IPHONE_OS_VERSION_MAX_ALLOWED
    }else if( _session ){
        return [_session sendDataToAllPeers: [NSData dataWithBytes:packet length:length]
                               withDataMode: GKMatchSendDataReliable
                                      error: NULL];
#endif
    }
    
    return NO;
}


- (BOOL)sendPacket:(const void *)packet length:(NSUInteger)length toPlayers:(NSArray *)playerIDs {
    if( !_match && !_session ) return NO;
    
    if ( [playerIDs containsObject: self.playerID] ) {
        [self packet:packet fromPlayerID: self.playerID];
        
        playerIDs = [playerIDs mutableCopy];
        [(NSMutableArray *)playerIDs removeObject:self.playerID];
    }
    
    if( _match ){
        return [_match sendData: [NSData dataWithBytes:packet length:length]
                      toPlayers: playerIDs
                   withDataMode: GKMatchSendDataReliable
                          error: NULL];
#if __IPHONE_OS_VERSION_MAX_ALLOWED
    }else if( _session ){
        return [_session sendData: [NSData dataWithBytes:packet length:length]
                          toPeers: playerIDs
                     withDataMode: GKMatchSendDataReliable
                            error: NULL];
#endif
    }
    return NO;
}


- (void)playerID:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    NSAssert(playerID, @"Player Without ID");

    id <UDGKPlayerProtocol>player = nil;
    
    @synchronized( _players ){
        
        switch ( state ) {
            case GKPlayerStateConnected: {
                if( !(player = [_players objectForKey:playerID]) ){
                    if( _match ){
                        if( [playerID isEqualToString:self.playerID] ){
                            player = (id <UDGKPlayerProtocol>)[GKLocalPlayer localPlayer];
                        }else{
                            player = [UDGKPlayer playerWithPlayerID:playerID alias:nil];
                        }
#if __IPHONE_OS_VERSION_MAX_ALLOWED
                    }else if( _session ){
                        player = [UDGKPlayer playerWithPlayerID:playerID alias:[_session displayNameForPeer:playerID]];
#endif
                    }

                    [_players setObject:player forKey:playerID];
                }
                break;
            }
            case GKPlayerStateDisconnected: {
                if( (player = [_players objectForKey:playerID]) ){
                    [[player retain] autorelease];
                    [_players removeObjectForKey:playerID];
                }
                break;
            }
        }
        
    }
    
    // Push to observers
    NSSet *observers = [_playerObservers objectForKey:@(state)];
    @synchronized( observers ){
        for( id <UDGKManagerPlayerObserving>observer in observers ){
            [observer observePlayer:player state:state];
        }
    }

    // Do we expect any more players?
    if( state == GKPlayerStateConnected && [_match expectedPlayerCount] == 0 && ![playerID isEqualToString: [self playerID]] ){
        [self allPlayersConnected];
    }
}


- (void)allPlayersConnected {
    
    if( _match ){
        // Load GKPlayers
        [GKPlayer loadPlayersForIdentifiers: [_match playerIDs]
                      withCompletionHandler: ^(NSArray *players, NSError *error){
                          @synchronized( _players ){
                              for( GKPlayer *player in players ){
                                  [_players setObject:player forKey:[player playerID]];
                              }
                          }
                          
                          @synchronized( _hostPlayerID ){
                              if( _hostPlayerID ){
                                  [[NSNotificationCenter defaultCenter] postNotificationName:UDGKManagerAllPlayersConnectedNotification object:self];
                              }
                          }
                      }];
    }
    
    // Negotiate host
    NSArray *allPlayers = [[_players allKeys] sortedArrayUsingSelector:@selector(compare:)];
    if( [[allPlayers objectAtIndex:0] isEqualToString:self.playerID] ){
        
        UDGKPacketPickHost packet = UDGKPacketPickHostMake( arc4random() %allPlayers.count );
        [[UDGKManager sharedManager] sendPacketToAllPlayers: &packet
                                                     length: sizeof(UDGKPacketPickHost)];
        
    }
}


- (BOOL)isNetworkPlayActive {
    return (_match != nil || _session != nil);
}


#pragma mark -
#pragma mark Packet Observing


- (void)addPacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType {
    id packetTypeToObserver = @(packetType);
    
    NSMutableSet *observers = [_packetObservers objectForKey:packetTypeToObserver];
    
    if( observers ){
        @synchronized( observers ){
            [observers addObject:observer];
        }
    }else{
        [_packetObservers setObject:[NSMutableSet setWithObject:observer] forKey:packetTypeToObserver];
    }
}


- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer forType:(UDGKPacketType)packetType {
    id packetTypeToObserver = @(packetType);
    
    NSMutableSet *observers = [_packetObservers objectForKey:packetTypeToObserver];
    
    @synchronized( observers ){
        [observers removeObject:observer];
        if( ![observers count] ){
            [_packetObservers removeObjectForKey:packetTypeToObserver];
        }
    }
}


- (void)removePacketObserver:(id <UDGKManagerPacketObserving>)observer {
    for ( id packetType in [[_packetObservers allKeys] reverseObjectEnumerator] ) {
        [self removePacketObserver:observer forType: [packetType intValue]];
    }
}


#pragma mark -
#pragma mark Player Observing


- (void)addPlayerObserver:(id <UDGKManagerPlayerObserving>)observer forConnectionState:(GKPlayerConnectionState)connectionState {
    id connectionStateToObserver = @(connectionState);
    
    NSMutableSet *observers = [_playerObservers objectForKey:connectionStateToObserver];
    
    if( observers ){
        @synchronized( observers ){
            [observers addObject:observer];
        }
    }else{
        [_playerObservers setObject:[NSMutableSet setWithObject:observer] forKey:connectionStateToObserver];
    }
}


- (void)removePlayerObserver:(id <UDGKManagerPlayerObserving>)observer forConnectionState:(GKPlayerConnectionState)connectionState {
    id connectionStateToObserver = @(connectionState);
    
    NSMutableSet *observers = [_playerObservers objectForKey:connectionStateToObserver];
    
    @synchronized( observers ){
        [observers removeObject:observer];
        if( ![observers count] ){
            [_playerObservers removeObjectForKey:connectionStateToObserver];
        }
    }
}


- (void)removePlayerObserver:(id <UDGKManagerPlayerObserving>)observer {
    for ( id state in [[_playerObservers allKeys] reverseObjectEnumerator] ) {
        [self removePlayerObserver:observer forConnectionState: [state intValue]];
    }
}


#pragma mark -
#pragma mark UDGKManagerPacketObserving


- (void)observePacket:(const void *)packet fromPlayer:(id <UDGKPlayerProtocol>)player {
    UDGKPacketType packetType = (*(UDGKPacket *)packet).type;

    if ( packetType == UDGKPacketTypePickHost ) {
        UDGKPacketPickHost newPacket = *(UDGKPacketPickHost *)packet;
        
        NSArray *allPlayers = [[_players allKeys] sortedArrayUsingSelector:@selector(compare:)];

        @synchronized( _hostPlayerID ){
            [_hostPlayerID release];
            _hostPlayerID = [[allPlayers objectAtIndex:newPacket.hostIndex] copy];
        }
        
        // Check if all pears got aliases
        BOOL playersWasUpdated = YES;
        if( _match ){
            @synchronized( _players ){
                for( id player in [_players allValues] ){
                    if( ![player isKindOfClass: [GKPlayer class]] ){
                        playersWasUpdated = NO;
                        break;
                    }
                }
            }
        }
        
        // If all pears got aliases
        if( playersWasUpdated ){
            [[NSNotificationCenter defaultCenter] postNotificationName:UDGKManagerAllPlayersConnectedNotification object:self];
        }
    }
    
}


#pragma mark -
#pragma mark GKMatchDelegate


- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID {
    [self packet:[data bytes] fromPlayerID:playerID];
}


- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state {
    [self playerID:playerID didChangeState:state];
}


- (void)match:(GKMatch *)match didFailWithError:(NSError *)error {
    UDLog(@"match:didFailWithError: %@", error);
    
    [GKNotificationBanner showBannerWithTitle: [error localizedDescription]
                                      message: nil
                            completionHandler: NULL];
}


- (BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID {
    return NO;
}


#pragma mark -
#pragma mark GKSessionDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context {
    [self packet:[data bytes] fromPlayerID:peer];
}


- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    UDLog(@"session:didChangeState:");
    switch ( state ) {
        case GKPeerStateAvailable: {    // not connected to session, but available for connectToPeer:withTimeout:
            
            break;
        }
        case GKPeerStateUnavailable: {  // no longer available
            
            break;
        }
        case GKPeerStateConnected: {    // connected to the session
            [self playerID:peerID didChangeState:GKPlayerStateConnected];
            break;
        }
        case GKPeerStateDisconnected: { // disconnected from the session
            [self playerID:peerID didChangeState:GKPlayerStateDisconnected];
            break;
        }
        case GKPeerStateConnecting: { // waiting for accept, or deny response
            
            break;
        }
    }
    
}


- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
    UDLog(@"session:connectionWithPlayerFailed:withError:%@", error);
    
    [GKNotificationBanner showBannerWithTitle: [error localizedDescription]
                                      message: nil
                            completionHandler: NULL];
}


- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
    UDLog(@"session:didFailWithError: %@", error);
    
    [GKNotificationBanner showBannerWithTitle: [error localizedDescription]
                                      message: nil
                            completionHandler: NULL];
}
#endif


@end
