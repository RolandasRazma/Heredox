//
//  RRPopupLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 13/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
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
#pragma mark RRMenuMultiplayerLayer


+ (id)layerWithMessage:(NSString *)message {
    return [[[self alloc] initWithMessage:message cancelButtonName:nil cancelButtonAction:nil] autorelease];
}


+ (id)layerWithMessage:(NSString *)message cancelButtonName:(NSString *)cancelButtonName cancelButtonAction:(void (^)(void))block {
    return [[[self alloc] initWithMessage:message cancelButtonName:cancelButtonName cancelButtonAction:block] autorelease];
}


- (id)initWithMessage:(NSString *)message cancelButtonName:(NSString *)cancelButtonName cancelButtonAction:(void (^)(void))block {
    if( (self = [self init]) ){
        CCLabelTTF *messageLabel = [CCLabelTTF labelWithString:message fontName:@"Washington Text" fontSize:((isDeviceIPad()||isDeviceMac())?45:22)];
        [messageLabel setColor:ccBLACK];
        [_menu addChild:messageLabel];
        
        if( cancelButtonName ){
            [messageLabel setAnchorPoint:CGPointMake(0.5f, 0.2f)];
            [messageLabel setPosition:CGPointMake(_menu.boundingBox.size.width /2, _menu.boundingBox.size.height /2)];
            
            UDSpriteButton *cancelButton = [UDSpriteButton buttonWithSpriteFrameName:[NSString stringWithFormat:@"%@.png", cancelButtonName] highliteSpriteFrameName:[NSString stringWithFormat:@"%@Selected.png", cancelButtonName]];
            [cancelButton setAnchorPoint:CGPointMake(0.5f, -0.3f)];
            [cancelButton setPosition:CGPointMake(_menu.boundingBox.size.width /2, 0)];
            if( block ){
                [cancelButton addBlock:block forControlEvents:UDButtonEventTouchUpInside];
            }else{
                [cancelButton addBlock:^{
                    [self removeFromParentAndCleanup:YES];
                } forControlEvents:UDButtonEventTouchUpInside];
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
