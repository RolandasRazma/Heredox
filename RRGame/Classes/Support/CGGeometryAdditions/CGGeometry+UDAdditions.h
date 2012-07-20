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

struct UDTriangle {
    CGPoint a;
    CGPoint b;
    CGPoint c;
}; typedef struct UDTriangle UDTriangle;


static inline UDTriangle UDTriangleMake(CGPoint a, CGPoint b, CGPoint c) {
    return (UDTriangle){ a, b, c };
}


static inline float sign(CGPoint p1, CGPoint p2, CGPoint p3) { return (p1.x -p3.x) *(p2.y -p3.y) -(p2.x - p3.x) *(p1.y -p3.y); }

static inline bool UDTriangleContainsPoint(UDTriangle triangle, CGPoint point){
    bool b1, b2, b3;
    
    b1 = sign(point, triangle.a, triangle.b) < 0.0f;
    b2 = sign(point, triangle.b, triangle.c) < 0.0f;
    b3 = sign(point, triangle.c, triangle.a) < 0.0f;
    
    return ((b1 == b2) && (b2 == b3));
}


#if defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
static inline NSString *NSStringFromCGPoint(CGPoint point){
    return [NSString stringWithFormat:@"{%g, %g}", point.x, point.y];
}
#endif