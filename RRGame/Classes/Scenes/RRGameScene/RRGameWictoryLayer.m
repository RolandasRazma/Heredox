//
//  RRGameWictoryLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 27/07/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRGameWictoryLayer.h"
#import "UDSpriteButton.h"


static RRPlayerColorWictorious lastPlayerWictoriousColor = RRPlayerColorWictoriousNo;
static NSUInteger lastPlayerWictoriousTimes = 1;
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


+ (id)layerForColor:(RRPlayerColorWictorious)playerColorWictorious {
    return [[(RRGameWictoryLayer *)[self alloc] initWithColor: playerColorWictorious] autorelease];
}


- (id)initWithColor:(RRPlayerColorWictorious)playerColorWictorious {

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
        [buttonContinue addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [_delegate gameWictoryLayer:self didSelectButtonAtIndex:0];  } forControlEvents: UDButtonEventTouchUpInside];
        [_menu addChild:buttonContinue];
        
        
        CCSprite *winningBanner;
        CCSprite *winningBanner2 = nil;
        switch ( playerColorWictorious ) {
            case RRPlayerColorWictoriousNo: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinNo.png"];
                break;
            }
            case RRPlayerColorWictoriousWhite: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinWhite.png"];
                if( lastPlayerWictoriousColor == playerColorWictorious ){
                    winningBanner2 = [self spriteForConsecutivelyWin:lastPlayerWictoriousTimes ofColor:playerColorWictorious];
                }else{
                    lastPlayerWictoriousTimes = 1;
                }
                break;
            }
            case RRPlayerColorWictoriousBlack: {
                winningBanner = [CCSprite spriteWithSpriteFrameName:@"RRBannerWinBlack.png"];
                if( lastPlayerWictoriousColor == playerColorWictorious ){
                    winningBanner2 = [self spriteForConsecutivelyWin:lastPlayerWictoriousTimes ofColor:playerColorWictorious];
                }else{
                    lastPlayerWictoriousTimes = 1;
                }
                break;
            }
        }
        [_menu addChild:winningBanner];
        
        lastPlayerWictoriousColor = playerColorWictorious;
        lastPlayerWictoriousTimes++;
        
        // Device layout
        if( isDeviceIPad() || isDeviceMac() ){
            [winningBanner setPosition:CGPointMake(_menu.boundingBox.size.width /2, _menu.boundingBox.size.height /2 +80)];
            if( winningBanner2 ){
                [_menu addChild:winningBanner2];
                [winningBanner2 setAnchorPoint:CGPointMake(0.5f, 0.5f)];
                [winningBanner2 setPosition:CGPointMake(winningBanner.position.x, winningBanner.position.y -winningBanner.boundingBox.size.height /2 -60)];
            }
            
            [buttonContinue setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 80)];
        }else{
            [winningBanner setPosition:CGPointMake(_menu.boundingBox.size.width  /2, _menu.boundingBox.size.height /2 +40)];
            if( winningBanner2 ){
                [_menu addChild:winningBanner2];
                [winningBanner2 setAnchorPoint:CGPointMake(0.5f, 0.5f)];
                [winningBanner2 setPosition:CGPointMake(winningBanner.position.x, winningBanner.position.y -winningBanner.boundingBox.size.height /2 -30)];
            }
            
            [buttonContinue setPosition:CGPointMake(_menu.boundingBox.size.width  /2, 45)];
        }

    }
    return self;
}


#pragma mark -
#pragma mark RRGameWictoryLayer


- (CCSprite *)spriteForConsecutivelyWin:(NSUInteger)winTimes ofColor:(RRPlayerColorWictorious)color {

    NSString *colorKey = ((color == RRPlayerColorWictoriousBlack)?@"B":@"W");
    NSString *text = [NSString stringWithFormat:@"%u", winTimes];
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

    CCSprite *sprite = [CCSprite spriteWithSpriteFrameName: [NSString stringWithFormat:@"RRTextWinConsecutively%@.png", colorKey]];
    [numbersSprite setAnchorPoint:CGPointZero];
    [numbersSprite setPosition:CGPointMake((sprite.boundingBox.size.width -(offsetX +characterSprite.textureRect.size.width *0.5f)) /2,
                                           characterSprite.boundingBox.size.height -characterSprite.boundingBox.size.height *0.2f)];
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
