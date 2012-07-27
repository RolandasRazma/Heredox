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
	return -1000;
}


#pragma mark -
#pragma mark CCLayerColor


- (id)init {
    if( (self = [super init]) ){
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        
        CCLayerColor *colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 180)];
        [colorBackground setAnchorPoint:CGPointMake(0.5f, 0.5f)];
        [colorBackground setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:colorBackground];

        return self;
        
        CCSprite *menuBG = [CCSprite spriteWithSpriteFrameName:@"RRMenuBG.png"];
        [menuBG setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:menuBG];
        
        
        // RRButtonResume
        UDSpriteButton *buttonResume = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonResume.png" highliteSpriteFrameName:@"RRButtonResumeSelected.png"];
        [buttonResume addBlock: ^{ [self gameResume]; } forControlEvents: UDButtonEventTouchUpInside];
        [menuBG addChild:buttonResume];
        
        
        // RRButtonRestart
        UDSpriteButton *buttonRestart = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonRestart.png" highliteSpriteFrameName:@"RRButtonRestartSelected.png"];
        [buttonRestart addBlock: ^{ [self gameRestart]; } forControlEvents: UDButtonEventTouchUpInside];
        [menuBG addChild:buttonRestart];
        
        
        // RRButtonQuit
        UDSpriteButton *buttonQuit = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonQuit.png" highliteSpriteFrameName:@"RRButtonQuitSelected.png"];
        [buttonQuit addBlock: ^{ [self gameQuit]; } forControlEvents: UDButtonEventTouchUpInside];
        [menuBG addChild:buttonQuit];
        
        CCSprite *textVolume = [CCSprite spriteWithSpriteFrameName:@"RRTextVolume.png"];
        [menuBG addChild:textVolume];

        CCSprite *sliderBG = [CCSprite spriteWithSpriteFrameName:@"RRSliderBG.png"];
        [menuBG addChild:sliderBG];
        
        // RRButtonQuit
        UDSpriteButton *buttonSlider = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonSlider.png" highliteSpriteFrameName:@"RRButtonSliderSelected.png"];
        [menuBG addChild:buttonSlider];
        
        // Device layout
        if( isDeviceIPad() ){
            [buttonResume setPosition:CGPointMake(menuBG.boundingBox.size.width  /2, 570)];
            [buttonRestart setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 450)];
            [buttonQuit setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 330)];
            [textVolume setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 185)];

            [sliderBG setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 100)];
            [buttonSlider setPosition:CGPointMake(menuBG.boundingBox.size.width /2, 100)];
        }else{
            
        }

    }
    return self;
}


#pragma mark -
#pragma mark RRGameMenuLayer


- (void)gameResume {
    [self removeFromParentAndCleanup:YES];
}


- (void)gameRestart {

}


- (void)gameQuit {
	
    [[CCDirector sharedDirector] replaceScene: [CCTransitionPageTurn transitionWithDuration:0.7f scene:[RRMenuScene node] backwards:YES]];
    
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    return YES;
}


@end
