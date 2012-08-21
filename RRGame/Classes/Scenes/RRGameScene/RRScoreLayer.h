//
//  RRScoreLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"


@interface RRScoreLayer : CCLayer {
    uint _scoreWhite;
    uint _scoreBlack;
}

@property (nonatomic, assign) uint scoreWhite;
@property (nonatomic, assign) uint scoreBlack;

@end
