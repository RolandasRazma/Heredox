//
//  RRHeredox.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
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
