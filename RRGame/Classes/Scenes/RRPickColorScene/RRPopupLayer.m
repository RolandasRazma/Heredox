//
//  RRPopupLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 13/08/2012.
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

#import "RRPopupLayer.h"


@implementation RRPopupLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self setUserInteractionEnabled:YES];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(0, 0)];
        
        CCLayerColor *colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 100)];
        [self addChild:colorBackground];
        
        _menu = [CCSprite spriteWithSpriteFrameName:@"RRPopupBG.png"];
        [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:_menu];
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

    [_menu setScale:0.9f];
    [_menu runAction:[CCSequence actions:
                      [CCScaleTo actionWithDuration:0.1f scale:1.1f],
                      [CCScaleTo actionWithDuration:0.1f scale:1.0f],
                      nil]];
}


#pragma mark -
#pragma mark RRPopupLayer


+ (id)layerWithMessage:(NSString *)message {
    return [[self alloc] initWithMessage:message cancelButtonName:nil cancelButtonAction:nil];
}


+ (id)layerWithMessage:(NSString *)message cancelButtonName:(NSString *)cancelButtonName cancelButtonAction:(void (^)(void))block {
    return [[self alloc] initWithMessage:message cancelButtonName:cancelButtonName cancelButtonAction:block];
}


- (id)initWithMessage:(NSString *)message cancelButtonName:(NSString *)cancelButtonName cancelButtonAction:(void (^)(void))block {
    if( (self = [self init]) ){
        CCSprite *messageLabel = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", message]];
        [_menu addChild:messageLabel];
        
        if( cancelButtonName ){
            [messageLabel setAnchorPoint:CGPointMake(0.5f, 0.2f)];
            [messageLabel setPosition:CGPointMake(_menu.boundingBox.size.width /2, _menu.boundingBox.size.height /2)];
            
            UDSpriteButton *cancelButton = [UDSpriteButton buttonWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", cancelButtonName] highliteSpriteFrameName:[NSString stringWithFormat:@"%@Selected.png", cancelButtonName]];
            [cancelButton setAnchorPoint:CGPointMake(0.5f, -0.4f)];
            [cancelButton setPosition:CGPointMake(_menu.boundingBox.size.width /2, 0)];
            if( block ){
                [cancelButton addBlock:block forControlEvents:UDButtonEventTouchUpInsideD];
            }else{
                [cancelButton addBlock:^{
                    [self removeFromParentAndCleanup:YES];
                } forControlEvents:UDButtonEventTouchUpInsideD];
            }
            [_menu addChild:cancelButton];
        }else{
            [messageLabel setPosition:CGPointMake(_menu.boundingBox.size.width /2, _menu.boundingBox.size.height /2)];
        }
    }
    return self;
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    return YES;
}


@end
