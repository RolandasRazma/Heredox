//
//  RRDefaultLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/20/12.
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

#import "RRDefaultLayer.h"
#import "RRMenuScene.h"


@implementation RRDefaultLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((IS_IPAD||IS_MAC)?@"Default-Portrait~ipad.png":@"Default.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onEnterTransitionDidFinish { 
    [super onEnterTransitionDidFinish];
    [self performSelector:@selector(loadAssets) withObject:nil afterDelay:0.1f];
}


#pragma mark -
#pragma mark RRDefaultLayer


- (void)loadAssets {

    // Load Sounds
    [[RRAudioEngine sharedEngine] playBackgroundMusic:@"ambience.mp3"];
    
    [[RRAudioEngine sharedEngine] preloadEffect:@"RRMenuScene.mp3"];
    [[RRAudioEngine sharedEngine] preloadEffect:@"RRSceneTransition.mp3"];
    
    
    // Load Textures
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"textures.plist"];

    
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:[RRMenuScene node]]];
    
}


@end
