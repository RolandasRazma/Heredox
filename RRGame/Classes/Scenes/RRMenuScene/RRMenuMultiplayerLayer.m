//
//  RRMenuMultiplayerLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
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
        [buttonLocal addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:0]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [_menu addChild:buttonLocal];

        // GameCenter
        UDSpriteButton *buttonGameCenter = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMultiplayerGameCenter.png" highliteSpriteFrameName:@"RRButtonMultiplayerGameCenterSelected.png"];
        [buttonGameCenter addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:2]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [_menu addChild:buttonGameCenter];
        
        // RRButtonBack2
        UDSpriteButton *buttonQuit = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonBack2.png" highliteSpriteFrameName:@"RRButtonBack2Selected.png"];
        [buttonQuit addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate menuMultiplayerLayer:self didSelectButtonAtIndex:3]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [_menu addChild:buttonQuit];
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [buttonLocal setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 540)];
            [buttonGameCenter setPosition:CGPointMake(_menu.boundingBox.size.width /2, 380)];
            
            [buttonQuit setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 100)];            
        } else {
            [buttonLocal setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 250)];
            [buttonGameCenter setPosition:CGPointMake(_menu.boundingBox.size.width /2, 180)];
            
            [buttonQuit setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 55)];
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
