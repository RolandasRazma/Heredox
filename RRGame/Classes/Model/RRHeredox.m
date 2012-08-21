//
//  RRHeredox.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRHeredox.h"
#import "RRAIPlayer.h"


const RRTileMove RRTileMoveZero = (RRTileMove){ 0, 0, 0, (float)NSIntegerMin };


@implementation RRHeredox


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

        [[RRAudioEngine sharedEngine] setBackgroundMusicVolume: [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSoundLevel"]];
        [[RRAudioEngine sharedEngine] setEffectsVolume:         [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSFXLevel"]];
    }
    return self;
}


- (void)initUserDefaults {
    [[NSUserDefaults standardUserDefaults] setBool:YES                  forKey:@"RRHeredoxOptionsSet"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.5f                forKey:@"RRHeredoxSoundLevel"];
    [[NSUserDefaults standardUserDefaults] setFloat:0.5f                forKey:@"RRHeredoxSFXLevel"];
    [[NSUserDefaults standardUserDefaults] setInteger:RRAILevelDeacon   forKey:@"RRHeredoxAILevel"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
