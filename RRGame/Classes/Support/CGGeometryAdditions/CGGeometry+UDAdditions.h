//
//  CGGeometry+UDAdditions.h
//  UDGame
//
//  Created by Rolandas Razma on 2/3/11.
//  Copyright 2011 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>


static inline CGRect CGRectMakeFromCGPointAndCGSize(CGPoint origin, CGSize size){
    return (CGRect){ origin, size };
}

static inline CGRect CGRectMakeWithSize(CGSize size){
    return (CGRect){ CGPointZero, size };
}

static inline CGPoint CGPointRound(CGPoint point){
    point.x = roundf(point.x);
    point.y = roundf(point.y);
    return point;
}

static inline CGSize CGSizeRound(CGSize size){
    size.width = roundf(size.width);
    size.height= roundf(size.height);
    return size;
}

static inline CGPoint CGPointIntegral(CGPoint point) {
    point.x = floorf(point.x);
    point.y = floorf(point.y);
    return point;
}