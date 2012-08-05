//
//  UDPickColorLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"
#import "UDLayer.h"


@interface RRPickColorLayer : UDLayer {
    NSUInteger _numberOfPlayers;
    
    CGRect     _upperRect;
    UDTriangle _upperTriangle;
    CGRect     _lowerRect;
    UDTriangle _lowerTriangle;
    
    CCSprite    *_backgroundPlayerWhiteSelectedSprite;
    CCSprite    *_backgroundPlayerBlackSelectedSprite;
}

+ (id)layerWithNumberOfPlayers:(NSUInteger)numberOfPlayers;
- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers;

@end
