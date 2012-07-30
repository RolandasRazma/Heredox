//
//  RRRulesScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRRulesScene.h"
#import "RRRulesLayer.h"


@implementation RRRulesScene


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self addChild:[RRRulesLayer node]];
    }
    return self;
}


#pragma mark -
#pragma mark CCNode


- (void)onExitTransitionDidStart {
    [super onExitTransitionDidStart];
    
    [[RRHeredox sharedInstance] playEffect:@"RRSceneTransition.mp3"];
}


@end
