//
//  UDPickColorLayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 7/14/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "CCLayer.h"
#import "UDLayer.h"


@interface RRPickColorLayer : UDLayer

+ (id)layerWithNumberOfPlayers:(NSUInteger)numberOfPlayers;
- (id)initWithNumberOfPlayers:(NSUInteger)numberOfPlayers;

@end
