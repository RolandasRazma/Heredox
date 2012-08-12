//
//  RRTransitionGame.h
//  RRHeredox
//
//  Created by Rolandas Razma on 08/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRTransitionGame.h"


@interface RRTransitionGame : CCTransitionPageTurn

+ (id)transitionToScene:(CCScene *)scene;
+ (id)transitionToScene:(CCScene *)scene backwards:(BOOL)backwards;

@end
