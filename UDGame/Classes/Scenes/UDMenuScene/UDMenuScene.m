//
//  UDMenuScene.m
//  UDHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright 2012 UD7. All rights reserved.
//

#import "UDMenuScene.h"
#import "UDMenuLayer.h"


@implementation UDMenuScene


#pragma mark -
#pragma mark NSObject


- (id)init {
    if( (self = [super init]) ){
        [self addChild: [UDMenuLayer node]];
    }
    return self;
}


@end
