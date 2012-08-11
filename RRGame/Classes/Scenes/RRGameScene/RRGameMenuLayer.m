//
//  RRGameMenuLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameMenuLayer.h"
#import "UDSpriteButton.h"
#import "RRMenuScene.h"


@implementation RRGameMenuLayer


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return -99;
}


- (void)onEnter {
    [super onEnter];
    
    [[RRHeredox sharedInstance] playEffect:@"RRGameMenuIn.mp3"];

    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_menu setPosition:CGPointMake(winSize.width /2, winSize.height +_menu.boundingBox.size.height)];

    [_colorBackground setOpacity:0];
    
    
    [_colorBackground runAction: [CCFadeTo actionWithDuration:0.27f opacity:190]];
    [_menu runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2 -_menu.boundingBox.size.height *0.1f)],
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2)],
                      nil]];
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
        
        
        // RRButtonResume
        UDSpriteButton *buttonResume = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonResume.png" highliteSpriteFrameName:@"RRButtonResumeSelected.png"];
        [buttonResume addBlock: ^{ [[RRHeredox sharedInstance] playEffect:@"RRButtonClick.mp3"]; [_delegate gameMenuLayer:self didSelectButtonAtIndex:0]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonResume];
        
        
        // RRButtonRestart
        UDSpriteButton *buttonRestart = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonRestart.png" highliteSpriteFrameName:@"RRButtonRestartSelected.png"];
        [buttonRestart addBlock: ^{ [[RRHeredox sharedInstance] playEffect:@"RRButtonClick.mp3"]; [_delegate gameMenuLayer:self didSelectButtonAtIndex:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonRestart];
        
        
        // RRButtonQuit
        UDSpriteButton *buttonQuit = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonQuit.png" highliteSpriteFrameName:@"RRButtonQuitSelected.png"];
        [buttonQuit addBlock: ^{ [[RRHeredox sharedInstance] playEffect:@"RRButtonClick.mp3"]; [_delegate gameMenuLayer:self didSelectButtonAtIndex:2]; } forControlEvents: UDButtonEventTouchUpInside];
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
            [buttonRestart setPosition:CGPointMake(_menu.boundingBox.size.width /2, 450)];
            [buttonQuit setPosition:CGPointMake(_menu.boundingBox.size.width /2, 330)];
            [textVolume setPosition:CGPointMake(_menu.boundingBox.size.width /2, 185)];

            [sliderBG setPosition:CGPointMake(_menu.boundingBox.size.width /2, 100)];
            [_sliderSound setPosition:CGPointMake(_menu.boundingBox.size.width /2, 100)];
            
            _sliderEdgeLeft = 145;
            _sliderWidth    = 335.0f;
        } else {
            [buttonResume setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 260)];
            [buttonRestart setPosition:CGPointMake(_menu.boundingBox.size.width /2, 205)];
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
    }

    return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    location = [_sliderSound.parent convertToNodeSpace:location];
    
    location.x = MIN(MAX(_sliderEdgeLeft, location.x), _sliderWidth +_sliderEdgeLeft);
    [_sliderSound setPosition:CGPointMake(location.x, _sliderSound.position.y)];
    
    CGFloat sliderValue = (_sliderSound.position.x -_sliderEdgeLeft) /_sliderWidth;
    [[NSUserDefaults standardUserDefaults] setFloat:sliderValue forKey: @"RRHeredoxSFXLevel"];
    [[NSUserDefaults standardUserDefaults] setFloat:sliderValue forKey: @"RRHeredoxSoundLevel"];
    
    [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: sliderValue];
    [[SimpleAudioEngine sharedEngine] setEffectsVolume:         sliderValue];
}


- (void)touchEndedAtLocation:(CGPoint)location {

    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"RRButtonSlider.png"];
    
    [_sliderSound setTexture:spriteFrame.texture];
    [_sliderSound setTextureRect:spriteFrame.rect];
    
}


@synthesize delegate=_delegate;
@end
