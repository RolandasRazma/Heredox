//
//  RRAudioEngine.m
//
// Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//
// This class is mostly copy of SimpleAudioEngine
// Copyright (c) 2010 Steve Oldmeadow
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "RRAudioEngine.h"


@implementation RRAudioEngine


+ (RRAudioEngine *)sharedEngine {
    static RRAudioEngine *_audioEngineSharedEngine;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audioEngineSharedEngine = [[RRAudioEngine alloc] init];
    });
    return _audioEngineSharedEngine;
}


- (id)init {
    if( (self = [super init]) ){
        _effectsCache = [[NSMutableDictionary alloc] init];
        
        _audioManager   = [CDAudioManager sharedManager];
        _bufferManager  = [[CDBufferManager alloc] initWithEngine:_audioManager.soundEngine];
        _mute           = NO;
        _enabled        = YES;
    }
    return self;
}


- (void)preloadEffect:(NSString *)filePath {
	int soundId = [_bufferManager bufferForFile:filePath create:YES];
	if ( soundId == kCDNoBuffer ) {
		CDLOG(@"Denshion::SimpleAudioEngine sound failed to preload %@", filePath);
	}
}


- (ALuint)replayEffect:(NSString *)filePath {
    [self stopEffect:filePath];
    return [self playEffect:filePath];
}


- (ALuint)playEffect:(NSString *)filePath {
	return [self playEffect:filePath pitch:1.0f pan:0.0f gain:1.0f];
}


- (ALuint)playEffect:(NSString *)filePath pitch:(Float32)pitch pan:(Float32)pan gain:(Float32)gain {
	int soundId = [_bufferManager bufferForFile:filePath create:YES];
    ALuint sourceID = CD_MUTE;
    
	if ( soundId != kCDNoBuffer ) {
		ALuint sourceID = [_audioManager.soundEngine playSound:soundId sourceGroupId:0 pitch:pitch pan:pan gain:gain loop:false];
        if( sourceID == CD_NO_SOURCE ){
#if TARGET_IPHONE_SIMULATOR
            NSAssert1(NO, @"No source for sound file %@", filePath);
#else
            NSLog(@"No source for sound file %@", filePath);
#endif
        }else{
            [_effectsCache setObject:@(sourceID) forKey:filePath];
        }
	}
    
    return sourceID;
}


- (void)stopEffect:(NSString *)filePath {
    @synchronized( _effectsCache ){
        NSNumber *soundId = nil;
        if( (soundId = [_effectsCache objectForKey:filePath]) ){
            [_audioManager.soundEngine stopSound: (ALuint)[soundId unsignedIntegerValue]];
            [_effectsCache removeObjectForKey:filePath];
        }
    }
}


- (void)stopAllEffects {
    @synchronized( _effectsCache ){
        for( NSNumber *soundId in [_effectsCache allValues] ){
            [_audioManager.soundEngine stopSound: (ALuint)[soundId unsignedIntegerValue]];
        }
        [_effectsCache removeAllObjects];
    }
}


- (void)playBackgroundMusic:(NSString *)filePath {
	[_audioManager playBackgroundMusic:filePath loop:TRUE];
}


- (float)backgroundMusicVolume {
	return _audioManager.backgroundMusic.volume;
}


- (void)setBackgroundMusicVolume:(float)volume {
	_audioManager.backgroundMusic.volume = volume;
}


- (float)effectsVolume {
	return _audioManager.soundEngine.masterGain;
}


- (void)setEffectsVolume:(float)volume {
	_audioManager.soundEngine.masterGain = volume;
}


@end
