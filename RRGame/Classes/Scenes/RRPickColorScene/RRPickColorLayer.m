//
//  UDPickColorLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
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

#import "RRPickColorLayer.h"
#import "RRGameScene.h"
#import "RRMenuScene.h"
#import "RRDifficultyScene.h"
#import "RRPopupLayer.h"


@implementation RRPickColorLayer


#pragma mark -
#pragma mark UDPickColorLayer


+ (id)layerWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    return [[self alloc] initWithNumberOfPlayers:numberOfPlayers];
}


- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers {
    if( (self = [self init]) ){
        [self setUserInteractionEnabled:YES];
        
        _numberOfPlayers = numberOfPlayers;

        CGSize winSize = [[CCDirector sharedDirector] winSize];

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithFile:((IS_IPAD||IS_MAC)?@"RRBackgroundPlayerColor~ipad.png":@"RRBackgroundPlayerColor.png")];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite];

        CCSprite *titleTextSprite = [CCSprite spriteWithSpriteFrameName:((numberOfPlayers==1)?@"RRTextChooseYourAllegiance.png":@"RRTextWhoMakesTheFirstMove.png")];
        [self addChild:titleTextSprite];
        
        // Add menu button
        UDSpriteButton *buttonHome = [UDSpriteButton buttonWithSpriteFrameName:@"RRButtonMenu.png" highliteSpriteFrameName:@"RRButtonMenuSelected.png"];
        [buttonHome setAnchorPoint:CGPointMake(1.0f, 1.0f)];
        [buttonHome addBlock: ^{ [[RRAudioEngine sharedEngine] replayEffect:@"RRButtonClick.mp3"]; [self showMenu]; } forControlEvents: UDButtonEventTouchUpInsideD];
        [self addChild:buttonHome];
        
        
        // Selected images
        _backgroundPlayerWhiteSelectedSprite = [CCSprite spriteWithSpriteFrameName:@"RRBackgroundPlayerWhiteSelected.png"];
        [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
        [self addChild:_backgroundPlayerWhiteSelectedSprite];
        
        _backgroundPlayerBlackSelectedSprite = [CCSprite spriteWithSpriteFrameName:@"RRBackgroundPlayerBlackSelected.png"];
        [_backgroundPlayerBlackSelectedSprite setVisible:NO];
        [self addChild:_backgroundPlayerBlackSelectedSprite];
        
        CGFloat leftBottomY;    // From bottom
        CGFloat rightTopY;      // From top
        CGFloat topTopY;        // Offset from top of upper rect
        
        // Device layout
        if( IS_IPAD || IS_MAC ){
            [buttonHome setPosition:CGPointMake(winSize.width -15, winSize.height -15)];
            [titleTextSprite setPosition:CGPointMake(315, 920)];

            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake(165, 702)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(594, 185)];
            
            leftBottomY = 210;
            rightTopY   = 400;
            topTopY     = 170;
        }else if( IS_IPHONE_5 ){
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
            
            [titleTextSprite setPosition:CGPointMake(130, 520)];
            [titleTextSprite setScale:0.9f];
            
            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake( 63, 370)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(242, 137)];
            
            leftBottomY = 144;
            rightTopY   = 244;
            topTopY     = 80 ;
        }else{
            [buttonHome setPosition:CGPointMake(winSize.width -5, winSize.height -5)];
            [buttonHome setScale:0.9f];
            [titleTextSprite setPosition:CGPointMake(130, 435)];
            [titleTextSprite setScale:0.9f];
            
            [_backgroundPlayerWhiteSelectedSprite setPosition:CGPointMake(63, 326)];
            [_backgroundPlayerBlackSelectedSprite setPosition:CGPointMake(242, 93)];
            
            leftBottomY = 100;
            rightTopY   = 200;
            topTopY     = 80;
        }
        
        _upperRect     = CGRectMake(0, winSize.height -rightTopY, winSize.width, rightTopY -topTopY);
        _upperTriangle = UDTriangleMake( CGPointMake(0, leftBottomY), CGPointMake(winSize.width, winSize.height -rightTopY), CGPointMake(0, winSize.height -rightTopY) );
        
        _lowerRect     = CGRectMake(0, 0, winSize.width, leftBottomY);
        _lowerTriangle = UDTriangleMake( CGPointMake(0, leftBottomY), CGPointMake(winSize.width, leftBottomY), CGPointMake(winSize.width, winSize.height -rightTopY) );

    }
    return self;
}


- (void)startGameWithFirstPlayerColor:(RRPlayerColor)playerColor {

    [[RRAudioEngine sharedEngine] replayEffect: [NSString stringWithFormat:@"RRPlayerColor%u.mp3", playerColor]];

    if( _numberOfPlayers == 1 ){
        RRDifficultyScene *difficultyScene = [[RRDifficultyScene alloc] initWithGameMode:RRGameModeClosed playerColor:playerColor];
        [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:difficultyScene]];
    }else{
        RRGameScene *gameScene = [[RRGameScene alloc] initWithGameMode:RRGameModeClosed numberOfPlayers:_numberOfPlayers playerColor:playerColor];
        [[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:gameScene]];
    }
    
}


- (void)showMenu {
    
	[[CCDirector sharedDirector] replaceScene: [RRTransitionGame transitionToScene:[RRMenuScene node] backwards:YES]];
    
}


#pragma mark -
#pragma mark UDLayer


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [self touchMovedToLocation:location];
        return YES;
    }else if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [self touchMovedToLocation:location];
        return YES;
    }
    
    return NO;
}


- (void)touchMovedToLocation:(CGPoint)location {

    [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
    [_backgroundPlayerBlackSelectedSprite setVisible:NO];

    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [_backgroundPlayerWhiteSelectedSprite setVisible:YES];
    }else if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [_backgroundPlayerBlackSelectedSprite setVisible:YES];
    }
    
}


- (void)touchEndedAtLocation:(CGPoint)location {

    if( CGRectContainsPoint(_upperRect, location) || UDTriangleContainsPoint(_upperTriangle, location) ){
        [self startGameWithFirstPlayerColor: RRPlayerColorWhite];
        return;
    }
    if( CGRectContainsPoint(_lowerRect, location) || UDTriangleContainsPoint(_lowerTriangle, location) ){
        [self startGameWithFirstPlayerColor: RRPlayerColorBlack];
        return;
    }

    [_backgroundPlayerWhiteSelectedSprite setVisible:NO];
    [_backgroundPlayerBlackSelectedSprite setVisible:NO];
}


@end
