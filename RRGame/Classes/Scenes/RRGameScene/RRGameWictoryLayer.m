//
//  RRGameWictoryLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameWictoryLayer.h"
#import "UDSpriteButton.h"


@implementation RRGameWictoryLayer {
    id <RRPlayerColorWictoriousDelegate>_delegate;
    CCLayerColor            *_colorBackground;
    CCSprite                *_menu;
}


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return -99;
}


#pragma mark -
#pragma mark CCLayer


+ (id)layerForColor:(RRPlayerColorWictorious)playerColorWictorious {
    return [[(RRGameWictoryLayer *)[self alloc] initWithColor: playerColorWictorious] autorelease];
}


- (id)initWithColor:(RRPlayerColorWictorious)playerColorWictorious {

    if( (self = [self init]) ){
        [self setUserInteractionEnabled:YES];
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(0, 0)];
        
        _colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:_colorBackground];
        
        
        _menu = [CCSprite spriteWithSpriteFrameName:@"RRMenuBG.png"];
        [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:_menu];
       
        
        // RRButtonQuit
        UDSpriteButton *buttonContinue = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonContinue.png" highliteSpriteFrameName:@"RRButtonContinueSelected.png"];
        [buttonContinue addBlock: ^{ [_delegate gameWictoryLayer:self didSelectButtonAtIndex:0];  } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonContinue];
        
        
        CCSprite *winningBanner;
        switch ( playerColorWictorious ) {
            case RRPlayerColorWictoriousNo: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinNo.png"];
                break;
            }
            case RRPlayerColorWictoriousWhite: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinWhite.png"];
                break;
            }
            case RRPlayerColorWictoriousBlack: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinBlack.png"];
                break;
            }
        }
        [_menu addChild:winningBanner];
        
        
        // Device layout
        if( isDeviceIPad() ){
            [winningBanner setPosition:CGPointMake(_menu.boundingBox.size.width  /2, _menu.boundingBox.size.height /2 +20)];
            [buttonContinue setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 80)];
        }else{
            
        }

    }
    return self;
}


#pragma mark -
#pragma mark RRGameWictoryLayer


- (void)showInLayer:(CCLayer *)layer {
    [layer addChild:self z:1000];
    
    [_colorBackground setOpacity:0];
    [_colorBackground runAction:[CCFadeTo actionWithDuration:0.31f opacity:180]];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_menu setPosition:CGPointMake(winSize.width /2, winSize.height +_menu.boundingBox.size.height)];
    
    [_menu runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2 -_menu.boundingBox.size.height *0.1f)],
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2)],
                      nil]];
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
    return YES;
}


@synthesize delegate=_delegate;
@end
