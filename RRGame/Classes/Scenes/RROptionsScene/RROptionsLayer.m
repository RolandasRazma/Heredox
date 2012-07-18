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
    UDSpriteButton *_buttonNovice;
    UDSpriteButton *_buttonDeacon;
    UDSpriteButton *_buttonAbbot;
    
    UDSpriteButton *_buttonSliderSound;
    UDSpriteButton *_buttonSliderSFX;
}


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        
        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:@"RRBackgroundOptions.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonCherubHome.png"];
        [buttonHome setPosition:CGPointMake(635, 935)];
        [buttonHome addBlock: ^{ [self showMenu]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:buttonHome];
        
        
        // Dificulty buttons
        _buttonNovice = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonNovice.png" highliteSpriteFrameName:@"RRButtonNoviceSelected.png"];
        [_buttonNovice setPosition:CGPointMake(190, 280)];
        [_buttonNovice addBlock: ^{ [self setDificultyLevel:RRAILevelNovice]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonNovice];
        
        _buttonDeacon = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonDeacon.png" highliteSpriteFrameName:@"RRButtonDeaconSelected.png"];
        [_buttonDeacon setPosition:CGPointMake(390, 280)];
        [_buttonDeacon addBlock: ^{ [self setDificultyLevel:RRAILevelDeacon]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonDeacon];
        
        _buttonAbbot = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonAbbot.png" highliteSpriteFrameName:@"RRButtonAbbotSelected.png"];
        [_buttonAbbot setPosition:CGPointMake(620, 280)];
        [_buttonAbbot addBlock: ^{ [self setDificultyLevel:RRAILevelAbbot]; } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonAbbot];
        
        [self setDificultyLevel: [[NSUserDefaults standardUserDefaults] integerForKey:@"RRAILevel"]];
        
        
        // Sound buttons
        _buttonSliderSound = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonSlider.png"];
        [_buttonSliderSound setPosition:CGPointMake(406, 662)];
        [_buttonSliderSound addBlock: ^{ } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonSliderSound];
        
        _buttonSliderSFX = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonSlider.png"];
        [_buttonSliderSFX setPosition:CGPointMake(406, 517)];
        [_buttonSliderSFX addBlock: ^{ } forControlEvents: UDButtonEventTouchUpInside];
        [self addChild:_buttonSliderSFX];

    }
    return self;
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
    
    [[NSUserDefaults standardUserDefaults] setInteger:dificultyLevel forKey:@"RRAILevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end
