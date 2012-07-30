//
//  RRHeredox.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRHeredox.h"
#import "RRAIPlayer.h"

const RRTileMove RRTileMoveZero = (RRTileMove){ (CGPoint){CGFLOAT_MAX, CGFLOAT_MAX}, 0.0f, (float)NSIntegerMin };


@implementation RRHeredox {
    NSMutableDictionary *_effectsCache;
}


+ (RRHeredox *)sharedInstance {
    static RRHeredox *_heredoxSharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _heredoxSharedInstance = [[RRHeredox alloc] init];
    });
    return _heredoxSharedInstance;
}


- (id)init {
    if( (self = [super init]) ){
        if( ![[NSUserDefaults standardUserDefaults] boolForKey:@"RRHeredoxOptionsSet"] ){
            [self initUserDefaults];
        }
        _effectsCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)initUserDefaults {
    [[NSUserDefaults standardUserDefaults] setBool:YES                  forKey:@"RRHeredoxOptionsSet"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.5f                forKey:@"RRHeredoxSFXLevel"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.5f                forKey:@"RRHeredoxSoundLevel"];
    [[NSUserDefaults standardUserDefaults] setInteger:RRAILevelDeacon   forKey:@"RRHeredoxAILevel"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (ALuint)playEffect:(NSString *)filePath {
    [self stopEffect:filePath];
    ALuint effectID = [[SimpleAudioEngine sharedEngine] playEffect:filePath];
    
    [_effectsCache setObject:[NSNumber numberWithUnsignedInteger:effectID] forKey:filePath];
    
    return effectID;
}


- (void)stopEffect:(NSString *)filePath {
    
    NSLog(@"%@ %@", _effectsCache, filePath);
    
    NSNumber *effectID = nil;
    if( (effectID = [_effectsCache objectForKey:filePath]) ){
        [[SimpleAudioEngine sharedEngine] stopEffect:[effectID unsignedIntegerValue]];
        [_effectsCache removeObjectForKey:filePath];
    }
}


@end
