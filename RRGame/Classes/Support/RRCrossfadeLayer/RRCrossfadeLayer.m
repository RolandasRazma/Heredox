//
//  RRCrossfadeLayer.m
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

#import "RRCrossfadeLayer.h"


@implementation RRCrossfadeLayer


- (BOOL)fadeToSpriteWithTag:(NSInteger)tag duration:(CGFloat)duration {
    if( self.children.count < 2  ) return NO;

    // Cancel all actions and reset opacity
    for( CCSprite *child in self.children ){
        [child stopAllActions];
        [child setOpacity:255];
    }

    
    CCSprite *fadeToSprite;
    if( !(fadeToSprite= (CCSprite *)[self getChildByTag:tag]) ) return NO;

    
    [self reorderChild:fadeToSprite z:NSUIntegerMax];
    
    [fadeToSprite setVisible:YES];
    
    
    // No animation
    if( duration == 0.0f ){
        [self hideSpritesExcept: fadeToSprite];
        
        return YES;
    }
    
    
    [fadeToSprite setOpacity:0];
    [fadeToSprite runAction: [CCSequence actions: 
                              [CCFadeIn actionWithDuration:duration],
                              [CCCallFuncN actionWithTarget:self selector:@selector(hideSpritesExcept:)],
                              nil]];

    return YES;
}


- (void)hideSpritesExcept:(CCSprite *)sprite {
    for( CCSprite *child in self.children ){
        if( [child isEqual:sprite] ) continue;
        
        [child setVisible:NO];
        [child setOpacity:255];
    }
}


@end
