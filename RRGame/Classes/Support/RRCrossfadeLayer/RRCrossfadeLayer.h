//
//  RRCrossfadeLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/18/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"


@interface RRCrossfadeLayer : CCLayer

- (BOOL)fadeToSpriteWithTag:(NSInteger)tag duration:(CGFloat)duration;

@end
