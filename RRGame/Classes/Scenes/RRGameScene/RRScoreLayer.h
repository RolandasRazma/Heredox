//
//  RRScoreLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"


@interface RRScoreLayer : CCLayer {
    NSUInteger _scoreWhite;
    NSUInteger _scoreBlack;
}

@property (nonatomic, assign) NSUInteger scoreWhite;
@property (nonatomic, assign) NSUInteger scoreBlack;

@end
