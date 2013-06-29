//
//  CGGeometry+UDAdditions.h
//
//  Created by Rolandas Razma on 2/3/11.
//
//  Copyright (c) 2012 Rolandas Razma <rolandas@razma.lt>
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import <Foundation/Foundation.h>


static inline CGPoint CGPointRound(CGPoint point){
    point.x = round(point.x);
    point.y = round(point.y);
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


static inline float sign(CGPoint p1, CGPoint p2, CGPoint p3) { return (float)((p1.x -p3.x) *(p2.y -p3.y) -(p2.x - p3.x) *(p1.y -p3.y)); }


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