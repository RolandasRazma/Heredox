//
//  RRScoreLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
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
        for( NSUInteger i=0; i<(NSUInteger)pointsToAdd; i++ ){
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
        for( NSUInteger i=0; i<(NSUInteger)pointsToAdd; i++ ){
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
