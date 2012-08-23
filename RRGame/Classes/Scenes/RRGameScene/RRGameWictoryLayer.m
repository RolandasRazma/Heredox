//
//  RRGameWictoryLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameWictoryLayer.h"
#import "UDSpriteButton.h"


static BOOL RRGameWictoryLayerVisible = NO;


@implementation RRGameWictoryLayer


#pragma mark -
#pragma mark CCNode


- (NSInteger)mouseDelegatePriority {
	return -99;
}


- (void)onEnter {
    [super onEnter];

    if( RRGameWictoryLayerVisible ){
        [self setVisible:NO];
        [self removeFromParentAndCleanup:YES];
        return;
    }
    
    RRGameWictoryLayerVisible = YES;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    [_menu setPosition:CGPointMake(winSize.width /2, winSize.height +_menu.boundingBox.size.height)];
    
    [_colorBackground setOpacity:0];

    
    [_colorBackground runAction: [CCFadeTo actionWithDuration:0.27f opacity:190]];
    [_menu runAction:[CCSequence actions:
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2 -_menu.boundingBox.size.height *0.1f)],
                      [CCMoveTo actionWithDuration:0.2f position:CGPointMake(winSize.width /2, winSize.height /2)],
                      nil]];
    
    
    [[RRAudioEngine sharedEngine] stopAllEffects];
    [[RRAudioEngine sharedEngine] replayEffect:[NSString stringWithFormat:@"RRPlayerColorWictorious%u.mp3", _playerColorWictorious]];
}


- (void)onExit {
    [super onExit];
    
    RRGameWictoryLayerVisible = NO;
}


#pragma mark -
#pragma mark CCLayer


+ (id)layerForColor:(RRPlayerColorWictorious)playerColorWictorious blackWins:(uint)blackWins whiteWins:(uint)whiteWins draws:(uint)draws {
    return [[(RRGameWictoryLayer *)[self alloc] initWithColor: playerColorWictorious blackWins:blackWins whiteWins:whiteWins draws:draws] autorelease];
}


- (id)initWithColor:(RRPlayerColorWictorious)playerColorWictorious blackWins:(uint)blackWins whiteWins:(uint)whiteWins draws:(uint)draws {

    if( (self = [self init]) ){
        [self setUserInteractionEnabled:YES];
        
        _playerColorWictorious = playerColorWictorious;
        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        
        [self setPosition:CGPointMake(0, 0)];
        
        _colorBackground = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
        [self addChild:_colorBackground];
        
        
        _menu = [CCSprite spriteWithSpriteFrameName:@"RRMenuBG.png"];
        [_menu setPosition:CGPointMake(winSize.width /2, winSize.height /2)];
        [self addChild:_menu];
       
        
        // RRButtonQuit
        UDSpriteButton *buttonContinue = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonContinue.png" highliteSpriteFrameName:@"RRButtonContinueSelected.png"];
        [buttonContinue addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate gameWictoryLayer:self didSelectButtonAtIndex:0];  } forControlEvents: UDButtonEventTouchUpInsideD];
        [_menu addChild:buttonContinue];

        // Winning banner
        CCSprite *winningBanner = [CCSprite spriteWithSpriteFrameName: ((playerColorWictorious==RRPlayerColorBlack)?@"RRBannerWinBlack.png":((playerColorWictorious==RRPlayerColorWhite)?@"RRBannerWinWhite.png":@"RRBannerWinNo.png"))];
        [_menu addChild:winningBanner];

        
        CCSprite *scoreBlack = [self spriteForConsecutivelyWin:blackWins ofColor:RRPlayerColorBlack textColor:RRPlayerColorWictoriousBlack];
        [_menu addChild:scoreBlack];

        CCSprite *scoreDraw = [self spriteForConsecutivelyWin:draws ofColor:RRPlayerColorUndefined textColor:((playerColorWictorious==RRPlayerColorWictoriousNo)?((whiteWins>blackWins)?RRPlayerColorWictoriousWhite:RRPlayerColorWictoriousBlack):playerColorWictorious)];
        [_menu addChild:scoreDraw];
        
        CCSprite *scoreWhite = [self spriteForConsecutivelyWin:whiteWins ofColor:RRPlayerColorWhite textColor:RRPlayerColorWictoriousWhite];
        [_menu addChild:scoreWhite];
        
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [winningBanner setPosition:CGPointMake(_menu.boundingBox.size.width /2, _menu.boundingBox.size.height /2 +80)];
            
            [scoreBlack setPosition:CGPointMake(100, 180)];
            [scoreDraw setPosition:CGPointMake(scoreBlack.position.x +165, scoreBlack.position.y)];
            [scoreWhite setPosition:CGPointMake(scoreDraw.position.x +165, scoreDraw.position.y)];
            
            [buttonContinue setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 80)];
        }else{
            [winningBanner setPosition:CGPointMake(_menu.boundingBox.size.width  /2, _menu.boundingBox.size.height /2 +40)];

            [scoreBlack setPosition:CGPointMake(50, 95)];
            [scoreDraw setPosition:CGPointMake(scoreBlack.position.x +85, scoreBlack.position.y)];
            [scoreWhite setPosition:CGPointMake(scoreDraw.position.x +85, scoreDraw.position.y)];
            
            [buttonContinue setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 45)];
        }

    }
    return self;
}


#pragma mark -
#pragma mark RRGameWictoryLayer


- (CCSprite *)spriteForConsecutivelyWin:(uint)winTimes ofColor:(RRPlayerColorWictorious)color textColor:(RRPlayerColorWictorious)textColor {

    NSString *colorKey = ((textColor == RRPlayerColorWictoriousWhite)?@"W":@"B");
    NSString *text = [NSString stringWithFormat:@"%@%u", ((winTimes && winTimes < 10)?@"0":@""), winTimes];
    CCSprite *numbersSprite = nil;
    CGFloat offsetX = 0;
    CCSprite *characterSprite = nil;

    for( NSUInteger charIndex = 0; charIndex<text.length; charIndex++ ){
        characterSprite = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"RRChar%@%@.png", colorKey, [text substringWithRange:NSMakeRange(charIndex, 1)]]];
        if( numbersSprite ){
            [numbersSprite addChild:characterSprite];
            [characterSprite setAnchorPoint:CGPointZero];
            [characterSprite setPosition:CGPointMake(offsetX, 0)];
        }else{
            numbersSprite = characterSprite;
        }

        offsetX += characterSprite.textureRect.size.width *0.5f;
    }

    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat:@"RRScore%u.png", color]];
    [numbersSprite setAnchorPoint:CGPointMake(0.25f, 0.5f)];
    [numbersSprite setPosition:CGPointMake(sprite.boundingBox.size.width, sprite.boundingBox.size.height /2)];
    [sprite addChild:numbersSprite];

    return sprite;
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
