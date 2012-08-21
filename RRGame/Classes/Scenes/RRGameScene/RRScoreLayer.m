//
//  RRScoreLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRScoreLayer.h"


@implementation RRScoreLayer


- (void)setScoreBlack:(uint)scoreBlack {
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


- (void)setScoreWhite:(uint)scoreWhite {
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


@synthesize scoreWhite=_scoreWhite, scoreBlack=_scoreBlack;
@end
