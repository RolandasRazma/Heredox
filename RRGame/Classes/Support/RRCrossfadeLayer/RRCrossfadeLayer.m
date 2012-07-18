//
//  RRCrossfadeLayer.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRCrossfadeLayer.h"


@implementation RRCrossfadeLayer


- (BOOL)fadeToSpriteWithTag:(NSInteger)tag duration:(CGFloat)duration {
    if( self.children.count < 2  ) return NO;
    
    CCSprite *fadeToSprite = (CCSprite *)[self getChildByTag:tag];
    
    if( !fadeToSprite) return NO;

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
