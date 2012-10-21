//
//  UDSpriteButton.h
//
//  Created by Rolandas Razma on 7/15/12.
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

#import "CCSprite.h"
#import "CCTouchDelegateProtocol.h"


enum {
    UDButtonEventTouchDown          = 1 <<  0,
    UDButtonEventTouchDownRepeat    = 1 <<  1,
    UDButtonEventTouchDragInside    = 1 <<  2,
    UDButtonEventTouchDragOutside   = 1 <<  3,
    UDButtonEventTouchUpInside      = 1 <<  4,
    UDButtonEventTouchUpOutside     = 1 <<  5,
    UDButtonEventTouchHold          = 1 <<  6,
    UDButtonEventTouchUpInsideD     = 1 <<  7
};
typedef NSUInteger UDButtonEvents;


@interface UDSpriteButton : CCSprite {
    BOOL                _touchActiveInside;
    NSMutableDictionary *_allBlocks;
    BOOL                _touchActive;
    BOOL                _userInteractionEnabled;
    BOOL                _selected;
    
    NSString            *_spriteFrameName;
    NSString            *_highliteSpriteFrameName;
}

@property(nonatomic, getter=isUserInteractionEnabled) BOOL userInteractionEnabled;
@property(nonatomic, getter = isSelected) BOOL selected;

+ (id)buttonWithSpriteFile:(NSString *)fileName;
+ (id)buttonWithSpriteFrameName:(NSString *)spriteFrameName highliteSpriteFrameName:(NSString *)highliteSpriteFrameName;
- (id)initWithSpriteFile:(NSString *)fileName;
- (id)initWithSpriteFrameName:(NSString *)spriteFrameName highliteSpriteFrameName:(NSString *)highliteSpriteFrameName;

- (void)addBlock:(void (^)(void))block forControlEvents:(UDButtonEvents)controlEvents;

@end
