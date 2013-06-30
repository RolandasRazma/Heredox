//
//  RRGameMenuLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
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

#import "RRGameMenuLayer.h"
#import "UDSpriteButton.h"
#import "RRMenuScene.h"


static BOOL RRGameMenuLayerVisible = NO;


@implementation RRGameMenuLayer


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return -99;
}


- (void)onEnter {
    [super onEnter];
    
    if( RRGameMenuLayerVisible ){
        [self setVisible:NO];
        [self removeFromParentAndCleanup:YES];
        return;
    }
    
    RRGameMenuLayerVisible = YES;
    
    [[RRAudioEngine sharedEngine] replayEffect:@"RRGameMenuIn.mp3"];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_menu setPosition:CGPointMake(winSize.width /2, winSize.height +_menu.boundingBox.size.height)];

    [_colorBackground setOpacity:0];
    
    [_colorBackground runAction: [CCFadeTo actionWithDuration:0.27f opacity:190]];
    [_menu runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2 -_menu.boundingBox.size.height *0.1f)],
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2)],
                      nil]];
}


- (void)onExit {
    [super onExit];
    
    RRGameMenuLayerVisible = NO;
}


#pragma mark -
#pragma mark CCLayerColor


- (id)init {
    if( (self = [super init]) ){
        [self setUserInteractionEnabled:YES];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(0, 0)];
        
        _colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:_colorBackground];

        
        _menu = [CCSprite spriteWithSpriteFrameName:@"RRMenuBG.png"];
        [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:_menu];
        
        __weak RRGameMenuLayer *weakSelf = self;
        
        // RRButtonResume
        UDSpriteButton *buttonResume = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonResume.png" highliteSpriteFrameName:@"RRButtonResumeSelected.png"];
        [buttonResume addBlock: ^{
            [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"];
            [_delegate gameMenuLayer:weakSelf didSelectButtonAtIndex:0];
        } forControlEvents: UDButtonEventTouchUpInsideD];
        [_menu addChild:buttonResume];
        
        // RRButtonRestart
        _buttonRestart = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonRestart.png" highliteSpriteFrameName:@"RRButtonRestartSelected.png"];
        [_buttonRestart addBlock: ^{
            [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"];
            [_delegate gameMenuLayer:weakSelf didSelectButtonAtIndex:1];
        } forControlEvents: UDButtonEventTouchUpInsideD];
        [_menu addChild:_buttonRestart];
        
        // RRButtonQuit
        UDSpriteButton *buttonQuit = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonQuit.png" highliteSpriteFrameName:@"RRButtonQuitSelected.png"];
        [buttonQuit addBlock: ^{
            [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"];
            [_delegate gameMenuLayer:weakSelf didSelectButtonAtIndex:2];
        } forControlEvents: UDButtonEventTouchUpInsideD];
        [_menu addChild:buttonQuit];
        
        CCSprite *textVolume = [CCSprite spriteWithSpriteFrameName:@"RRTextVolume.png"];
        [_menu addChild:textVolume];

        CCSprite *sliderBG = [CCSprite spriteWithSpriteFrameName:@"RRSliderBG.png"];
        [_menu addChild:sliderBG];
        
        // Sound slider
        _sliderSound = [CCSprite spriteWithSpriteFrameName:@"RRButtonSlider.png"];
        [_menu addChild:_sliderSound];
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonResume setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 570)];
            [_buttonRestart setPosition:CGPointMake(_menu.boundingBox.size.width /2, 450)];
            [buttonQuit setPosition:CGPointMake(_menu.boundingBox.size.width /2, 330)];
            [textVolume setPosition:CGPointMake(_menu.boundingBox.size.width /2, 185)];

            [sliderBG setPosition:CGPointMake(_menu.boundingBox.size.width /2, 100)];
            [_sliderSound setPosition:CGPointMake(_menu.boundingBox.size.width /2, 100)];
            
            _sliderEdgeLeft = 145;
            _sliderWidth    = 335.0f;
        } else {
            [buttonResume setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 260)];
            [_buttonRestart setPosition:CGPointMake(_menu.boundingBox.size.width /2, 205)];
            [buttonQuit setPosition:CGPointMake(_menu.boundingBox.size.width /2, 150)];
            [textVolume setPosition:CGPointMake(_menu.boundingBox.size.width /2, 85)];
            
            [sliderBG setPosition:CGPointMake(_menu.boundingBox.size.width /2, 45)];
            [_sliderSound setPosition:CGPointMake(_menu.boundingBox.size.width /2, 45)];
            
            _sliderEdgeLeft = 72.0f;
            _sliderWidth    = 166.0f;
        }
        
        CGFloat levelSound = [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSoundLevel"];
        [_sliderSound setPosition:CGPointMake(_sliderWidth *levelSound +_sliderEdgeLeft, _sliderSound.position.y)];

    }
    return self;
}


#pragma mark -
#pragma mark RRGameMenuLayer


- (void)disableRestartButton {
    [_buttonRestart setUserInteractionEnabled:NO];
    [_buttonRestart setOpacity:100];
}


- (void)dismiss {
    [_colorBackground stopAllActions];
    [_menu stopAllActions];
    
    [_colorBackground runAction:[CCFadeOut actionWithDuration:0.31f]];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
    
    [_menu runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height +_menu.boundingBox.size.height)],
                      [UDActionDestroy actionWithTarget:self],
                      nil]];
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    location = [_sliderSound.parent convertToNodeSpace:location];
    
    if( CGRectContainsPoint(_sliderSound.boundingBox, location) ){
        CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"RRButtonSliderSelected.png"];
        
        [_sliderSound setTexture:spriteFrame.texture];
        [_sliderSound setTextureRect:spriteFrame.rect];
        
        _sliderActive = YES;
    }

    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    if( !_sliderActive ) return;
    
    location = [_sliderSound.parent convertToNodeSpace:location];
    
    location.x = MIN(MAX(_sliderEdgeLeft, location.x), _sliderWidth +_sliderEdgeLeft);
    [_sliderSound setPosition:CGPointMake(location.x, _sliderSound.position.y)];
    
    float sliderValue = (float)((_sliderSound.position.x -_sliderEdgeLeft) /_sliderWidth);
    [[NSUserDefaults standardUserDefaults] setFloat:sliderValue forKey: @"RRHeredoxSFXLevel"];
    [[NSUserDefaults standardUserDefaults] setFloat:sliderValue forKey: @"RRHeredoxSoundLevel"];
    
    [[RRAudioEngine sharedEngine] setBackgroundMusicVolume: sliderValue];
    [[RRAudioEngine sharedEngine] setEffectsVolume:         sliderValue];
}


- (void)touchEndedAtLocation:(CGPoint)location {

    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"RRButtonSlider.png"];
    
    [_sliderSound setTexture:spriteFrame.texture];
    [_sliderSound setTextureRect:spriteFrame.rect];
    
    
    _sliderActive = NO;
}


@synthesize delegate=_delegate;
@end
