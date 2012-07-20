//
//  RROptionsLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RROptionsLayer.h"
#import "UDSpriteButton.h"
#import "RRMenuScene.h"
#import "RRAIPlayer.h"


@implementation RROptionsLayer {
    UDSpriteButton  *_buttonNovice;
    UDSpriteButton  *_buttonDeacon;
    UDSpriteButton  *_buttonAbbot;
    
    CCSprite        *_sliderSound;
    CCSprite        *_sliderSFX;
    CCSprite        *_sliderActive;
    
    CGFloat         _sliderEdgeLeft;
    CGFloat         _sliderWidth;
}


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self setUserInteractionEnabled:YES];

        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:(isDeviceIPad()?@"RRBackgroundOptions~ipad.png":@"RRBackgroundOptions.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonCherubHome.png"];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        
        
        // Dificulty buttons
        _buttonNovice = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonNovice.png" highliteSpriteFrameName:@"RRButtonNoviceSelected.png"];
        [_buttonNovice addBlock: ^{ [self setDificultyLevel:RRAILevelNovice]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonNovice];
        
        _buttonDeacon = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonDeacon.png" highliteSpriteFrameName:@"RRButtonDeaconSelected.png"];
        [_buttonDeacon addBlock: ^{ [self setDificultyLevel:RRAILevelDeacon]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonDeacon];
        
        _buttonAbbot = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAbbot.png" highliteSpriteFrameName:@"RRButtonAbbotSelected.png"];
        [_buttonAbbot addBlock: ^{ [self setDificultyLevel:RRAILevelAbbot]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonAbbot];
        
        [self setDificultyLevel: [[NSUserDefaults standardUserDefaults] integerForKey:@"RRHeredoxAILevel"]];
        
        
        // Sound buttons
        _sliderSound = [CCSprite spriteWithSpriteFrameName:@"RRButtonSlider.png"];
        [self addChild:_sliderSound];
        
        _sliderSFX = [CCSprite spriteWithSpriteFrameName:@"RRButtonSlider.png"];
        [self addChild:_sliderSFX];
        
        
        // Device layout
        if( isDeviceIPad() ){
            [buttonHome setPosition:CGPointMake(winSize.width -135, winSize.height -90)];
            
            [_buttonNovice setPosition:CGPointMake(190, 280)];
            [_buttonDeacon setPosition:CGPointMake(390, 280)];
            [_buttonAbbot setPosition:CGPointMake(620, 280)];
            
            [_sliderSound setPosition:CGPointMake(406, 662)];
            [_sliderSFX setPosition:CGPointMake(406, 517)];
            
            
            _sliderEdgeLeft = 150;
            _sliderWidth    = 500.0f;
        }else{
            [buttonHome setScale:0.8f];
            [buttonHome setPosition:CGPointMake(winSize.width -60, winSize.height -40)];
            
            [_buttonNovice setPosition:CGPointMake(60,  122)];
            [_buttonDeacon setPosition:CGPointMake(150, 115)];
            [_buttonAbbot setPosition:CGPointMake(255,  115)];
            
            [_sliderSound setPosition:CGPointMake(160, 315)];
            [_sliderSFX setPosition:CGPointMake(160, 243)];
            
            
            _sliderEdgeLeft = 40;
            _sliderWidth    = 240.0f;
        }
        
        
        // Settings
        CGFloat levelSound = [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSoundLevel"];
        CGFloat levelSFX   = [[NSUserDefaults standardUserDefaults] floatForKey:@"RRHeredoxSFXLevel"];
        
        [_sliderSound setPosition:CGPointMake(_sliderWidth *levelSound +_sliderEdgeLeft, _sliderSound.position.y)];
        [_sliderSFX setPosition:CGPointMake(_sliderWidth *levelSFX +_sliderEdgeLeft, _sliderSFX.position.y)];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onExit {
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super onExit];
}


#pragma mark -
#pragma mark RROptionsLayer


- (void)showMenu {
	[[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
}


- (void)setDificultyLevel:(RRAILevel)dificultyLevel {
    
    [_buttonNovice setSelected:(dificultyLevel==RRAILevelNovice)];
    [_buttonDeacon setSelected:(dificultyLevel==RRAILevelDeacon)];
    [_buttonAbbot setSelected:(dificultyLevel==RRAILevelAbbot)];
    
    [[NSUserDefaults standardUserDefaults] setInteger:dificultyLevel forKey:@"RRHeredoxAILevel"];
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    
    if( CGRectContainsPoint(_sliderSound.boundingBox, location) ){
        _sliderActive = _sliderSound;
        return YES;
    }
    
    if( CGRectContainsPoint(_sliderSFX.boundingBox, location) ){
        _sliderActive = _sliderSFX;
        return YES;
    }
    
    return NO;
}


- (void)touchMovedToLocation:(CGPoint)location {
    
    location.x = MIN(MAX(_sliderEdgeLeft, location.x), _sliderWidth +_sliderEdgeLeft);
    [_sliderActive setPosition:CGPointMake(location.x, _sliderActive.position.y)];

    CGFloat sliderValue = (_sliderActive.position.x -_sliderEdgeLeft) /_sliderWidth;
    if( [_sliderActive isEqual:_sliderSFX] ){
        [[NSUserDefaults standardUserDefaults] setFloat:sliderValue forKey: @"RRHeredoxSFXLevel"];
    }else if( [_sliderActive isEqual:_sliderSound] ){
        [[NSUserDefaults standardUserDefaults] setFloat:sliderValue forKey: @"RRHeredoxSoundLevel"];
    }
}


- (void)touchEndedAtLocation:(CGPoint)location {
    _sliderActive = nil;
}


@end
