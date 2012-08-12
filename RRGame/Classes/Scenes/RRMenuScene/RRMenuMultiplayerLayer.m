//
//  RRMenuMultiplayerLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRMenuMultiplayerLayer.h"

static BOOL RRMenuMultiplayerLayerVisible = NO;

@implementation RRMenuMultiplayerLayer


#pragma mark -
#pragma mark NSObject


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

        // Local
        UDSpriteButton *buttonLocal = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMultiplayerHotseat.png" highliteSpriteFrameName:@"RRButtonMultiplayerHotseatSelected.png"];
        [buttonLocal addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:0]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonLocal];
        
        // Bluetooth
        UDSpriteButton *buttonBluetooth = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMultiplayerBluetooth.png" highliteSpriteFrameName:@"RRButtonMultiplayerBluetoothSelected.png"];
        [buttonBluetooth addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonBluetooth];
        
        // GameCenter
        UDSpriteButton *buttonGameCenter = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMultiplayerGameCenter.png" highliteSpriteFrameName:@"RRButtonMultiplayerGameCenterSelected.png"];
        [buttonGameCenter addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:2]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonGameCenter];
        
        // RRButtonQuit
        UDSpriteButton *buttonQuit = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonQuit.png" highliteSpriteFrameName:@"RRButtonQuitSelected.png"];
        [buttonQuit addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:3]; } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonQuit];
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonLocal setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 570)];
            [buttonBluetooth setPosition:CGPointMake(_menu.boundingBox.size.width /2, 450)];
            [buttonGameCenter setPosition:CGPointMake(_menu.boundingBox.size.width /2, 330)];
            
            [buttonQuit setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 80)];
            
            if( isDeviceMac() ){
                [buttonGameCenter setPosition:buttonBluetooth.position];
                [buttonBluetooth removeFromParentAndCleanup:YES];
            }
        } else {
            [buttonLocal setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 260)];
            [buttonBluetooth setPosition:CGPointMake(_menu.boundingBox.size.width /2, 205)];
            [buttonGameCenter setPosition:CGPointMake(_menu.boundingBox.size.width /2, 150)];
            
            [buttonQuit setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 45)];
        }
    }
    
    return self;
}


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return -99;
}


- (void)onEnter {
    [super onEnter];

    if( RRMenuMultiplayerLayerVisible ){
        [self setVisible:NO];
        [self removeFromParentAndCleanup:YES];
        return;
    }
    
    RRMenuMultiplayerLayerVisible = YES;
    
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
    
    RRMenuMultiplayerLayerVisible = NO;
}


#pragma mark -
#pragma mark RRMenuMultiplayerLayer


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
    return YES;
}


@synthesize delegate=_delegate;
@end
