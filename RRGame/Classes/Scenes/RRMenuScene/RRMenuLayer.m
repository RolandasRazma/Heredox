//
//  UDMenuLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "RRMenuLayer.h"
#import "UDSpriteButton.h"
#import "RRPickColorScene.h"


@implementation RRMenuLayer


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){

        // Add background
        CCSprite *backgroundSprite = [CCSprite spriteWithSpriteFrameName:@"RRBackground.png"];
        [backgroundSprite setAnchorPoint:CGPointZero];
        [self addChild:backgroundSprite z:-1];
        
        // Add buttons
        UDSpriteButton *buttonPlayers1 = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonPlayers1.png"];
        [buttonPlayers1 addBlock: ^{ [self startGameWithNumberOfPlayers:1]; } forControlEvents: UDButtonEventTouchUpInside];
        [buttonPlayers1 setPosition:CGPointMake(110, 300)];
        [self addChild:buttonPlayers1];

        UDSpriteButton *buttonPlayers2 = [UDSpriteButton spriteWithSpriteFrameName:@"RRButtonPlayers2.png"];
        [buttonPlayers2 addBlock: ^{ [self startGameWithNumberOfPlayers:2]; } forControlEvents: UDButtonEventTouchUpInside];
        [buttonPlayers2 setPosition:CGPointMake(210, 300)];
        [self addChild:buttonPlayers2];
        

        if( isDeviceIPad() ){
            [buttonPlayers1 setPosition:CGPointMake(210, 600)];
            [buttonPlayers2 setPosition:CGPointMake(410, 600)];
        }
        
    }
    return self;
}


#pragma mark -
#pragma mark UDMenuLayer


- (void)startGameWithNumberOfPlayers:(NSUInteger)numberOfPlayers {

    RRPickColorScene *pickColorScene = [[RRPickColorScene alloc] initWithNumberOfPlayers:numberOfPlayers];
	[[CCDirector sharedDirector] replaceScene: [CCTransitionSlideInR transitionWithDuration:0.7f scene:pickColorScene]];
    [pickColorScene release];
    
}


@end
