//
//  RRScoreLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRScoreLayer.h"


@implementation RRScoreLayer {
    NSUInteger _scoreWhite;
    NSUInteger _scoreBlack;
}


- (void)setScoreBlack:(NSUInteger)scoreBlack {
    NSInteger pointsToAdd = scoreBlack -_scoreBlack;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if( scoreBlack == 0 ){
        CCSprite *sprite;
        while( (sprite = (CCSprite *)[self getChildByTag:RRPlayerColorBlack]) ){
            [self removeChild:sprite cleanup:YES];
        }
    }else if( pointsToAdd > 0 ){
        for( NSUInteger i=0; i<pointsToAdd; i++ ){
            CCSprite *pointSprite = [CCSprite spriteWithSpriteFrameName:@"RRPointBlack.png"];
            [pointSprite setScale:0.5f];
            [pointSprite setPosition:CGPointMake((pointSprite.boundingBox.size.width +5) *(_scoreBlack +i +1), winSize.height -pointSprite.boundingBox.size.height *2)];
            [self addChild:pointSprite z:0 tag:RRPlayerColorBlack];
        }
    }else if( pointsToAdd < 0 ){

    }
    
    // RRPointBlack
    
    _scoreBlack = scoreBlack;
}


- (void)setScoreWhite:(NSUInteger)scoreWhite {
    NSInteger pointsToAdd = scoreWhite -_scoreWhite;
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    if( scoreWhite == 0 ){
        CCSprite *sprite;
        while( (sprite = (CCSprite *)[self getChildByTag:RRPlayerColorWhite]) ){
            [self removeChild:sprite cleanup:YES];
        }
    }else if( pointsToAdd > 0 ){
        for( NSUInteger i=0; i<pointsToAdd; i++ ){
            CCSprite *pointSprite = [CCSprite spriteWithSpriteFrameName:@"RRPointWhite.png"];
            [pointSprite setScale:0.5f];
            [pointSprite setPosition:CGPointMake((pointSprite.boundingBox.size.width +5) *(_scoreWhite +i +1), winSize.height -pointSprite.boundingBox.size.height)];
            [self addChild:pointSprite z:0 tag:RRPlayerColorWhite];
        }
    }else if( pointsToAdd < 0 ){
        
    }
    
    _scoreWhite = scoreWhite;
}



/*
 _symbolsBlackLabel = [CCLabelTTF labelWithString:@"Black: 0" fontName:@"Courier" fontSize: (isDeviceIPad()?40:20)];
 [_symbolsBlackLabel setAnchorPoint:CGPointMake(0, 1)];
 [_symbolsBlackLabel setPosition:CGPointMake(5, winSize.height)];
 [_symbolsBlackLabel setColor:ccBLACK];
 [self addChild:_symbolsBlackLabel];
 
 _symbolsWhiteLabel = [CCLabelTTF labelWithString:@"White: 0" fontName:@"Courier" fontSize: (isDeviceIPad()?40:20)];
 [_symbolsWhiteLabel setAnchorPoint:CGPointMake(1, 1)];
 [_symbolsWhiteLabel setPosition:CGPointMake(winSize.width -5, winSize.height)];
 [_symbolsWhiteLabel setColor:ccBLACK];
 [self addChild:_symbolsWhiteLabel];
 
 [_symbolsBlackLabel setString:[NSString stringWithFormat:@"Black: %i", _gameBoardLayer.symbolsBlack]];
 
 [_symbolsBlackLabel runAction: [CCSequence actions:
 [CCScaleTo actionWithDuration:0.3f scale:1.1f],
 [CCScaleTo actionWithDuration:0.3f scale:1.0f], nil]];
 */



@synthesize scoreWhite=_scoreWhite, scoreBlack=_scoreBlack;
@end
