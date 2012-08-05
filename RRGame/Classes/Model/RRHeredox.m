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


- (void)playBackgroundMusic:(NSString *)filePath {
    CGFloat soundLevel = [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSoundLevel"];

    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:1.0f *soundLevel];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:filePath];
}


- (ALuint)playEffect:(NSString *)filePath {
    return [self playEffect: filePath withoutStopingPrevious:NO];
}


- (ALuint)playEffect:(NSString *)filePath withoutStopingPrevious:(BOOL)withoutStopingPrevious {
    @synchronized( _effectsCache ){
        if( withoutStopingPrevious == NO ){
            [self stopEffect:filePath];
        }
        
        CGFloat soundLevel = [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSoundLevel"];
        
        ALuint effectID = [[SimpleAudioEngine sharedEngine] playEffect:filePath pitch:1.0f pan:0.0f gain:1.0f *soundLevel];
        
        [_effectsCache setObject:[NSNumber numberWithUnsignedInteger:effectID] forKey:filePath];
        
        if( effectID == CD_NO_SOURCE ){
#if TARGET_IPHONE_SIMULATOR
            NSAssert1(NO, @"No source for sound file %@", filePath);
#endif
            NSLog(@"No source for sound file %@", filePath);
        }
        
        return effectID;
    }
}


- (void)stopEffect:(NSString *)filePath {
    @synchronized( _effectsCache ){
        NSNumber *effectID = nil;
        if( (effectID = [_effectsCache objectForKey:filePath]) ){
            [[SimpleAudioEngine sharedEngine] stopEffect: (ALuint)[effectID unsignedIntegerValue]];
            [_effectsCache removeObjectForKey:filePath];
        }
    }
}


- (void)stopAllEffects {
    @synchronized( _effectsCache ){
        for( NSNumber *effect in [_effectsCache allValues] ){
            [[SimpleAudioEngine sharedEngine] stopEffect: (ALuint)[effect unsignedIntegerValue]];
        }
        [_effectsCache removeAllObjects];
    }
}


@end
