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


@implementation RRGameMenuLayer {
    CCSprite    *_sliderSound;
    CGFloat     _sliderEdgeLeft;
    CGFloat     _sliderWidth;
    id <RRGameMenuDelegate>_delegate;
}


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return -99;
}


#pragma mark -
#pragma mark CCLayerColor


- (id)init {
    if( (self = [super init]) ){
        [self setUserInteractionEnabled:YES];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(0, 0)];
        
        CCLayerColor *colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 180)];
        [self addChild:colorBackground];

        
        CCSprite *menuBG = [CCSprite spriteWithSpriteFrameName:@"RRMenuBG.png"];
        [menuBG setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:menuBG];
        
        
        // RRButtonResume
        UDSpriteButton *buttonResume = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonResume.png" highliteSpriteFrameName:@"RRButtonResumeSelected.png"];
        [buttonResume addBlock: ^{ [_delegate gameMenuLayer:self didSelectButtonAtIndex:0]; } forControlEvents: UDButtonEventTouchUpInside];
        [menuBG addChild:buttonResume];
        
        
        // RRButtonRestart
        UDSpriteButton *buttonRestart = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonRestart.png" highliteSpriteFrameName:@"RRButtonRestartSelected.png"];
        [buttonRestart addBlock: ^{ [_delegate gameMenuLayer:self didSelectButtonAtIndex:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [menuBG addChild:buttonRestart];
        
        
        // RRButtonQuit
        UDSpriteButton *buttonQuit = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonQuit.png" highliteSpriteFrameName:@"RRButtonQuitSelected.png"];
        [buttonQuit addBlock: ^{ [_delegate gameMenuLayer:self didSelectButtonAtIndex:2]; } forControlEvents: UDButtonEventTouchUpInside];
        [menuBG addChild:buttonQuit];
        
        CCSprite *textVolume = [CCSprite spriteWithSpriteFrameName:@"RRTextVolume.png"];
        [menuBG addChild:textVolume];

        CCSprite *sliderBG = [CCSprite spriteWithSpriteFrameName:@"RRSliderBG.png"];
        [menuBG addChild:sliderBG];
        
        // RRButtonQuit
        _sliderSound = [CCSprite spriteWithSpriteFrameName:@"RRButtonSlider.png"];
        [menuBG addChild:_sliderSound];
        
        // Device layout
        if( isDeviceIPad() ){
            [buttonResume setPosition:CGPointMake(menuBG.boundingBox.size.width  /2, 570)];
            [buttonRestart setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 450)];
            [buttonQuit setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 330)];
            [textVolume setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 185)];

            [sliderBG setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 100)];
            [_sliderSound setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 100)];
            
            _sliderEdgeLeft = 145;
            _sliderWidth    = 335.0f;
        }else{
            
        }
        
        CGFloat levelSound = [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSoundLevel"];
        [_sliderSound setPosition:CGPointMake(_sliderWidth *levelSound +_sliderEdgeLeft, _sliderSound.position.y)];

    }
    return self;
}


#pragma mark -
#pragma mark UDLayerc


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
}


- (void)touchEndedAtLocation:(CGPoint)location {

    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"RRButtonSlider.png"];
    
    [_sliderSound setTexture:spriteFrame.texture];
    [_sliderSound setTextureRect:spriteFrame.rect];
    
}


@synthesize delegate=_delegate;
@end
