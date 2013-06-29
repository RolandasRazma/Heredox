//
//  RRDifficultyScene.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/25/12.
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

#import "RRDifficultyScene.h"
#import "RRDifficultyLayer.h"


@implementation RRDifficultyScene


#pragma mark -
#pragma mark UDGameScene


+ (id)sceneWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)firstPlayerColor {
    return [[self alloc] initWithGameMode:gameMode playerColor:firstPlayerColor];
}


- (id)initWithGameMode:(RRGameMode)gameMode playerColor:(RRPlayerColor)firstPlayerColor {
    if( (self = [self init]) ){
        [self addChild: [RRDifficultyLayer layerWithGameMode:gameMode playerColor:firstPlayerColor]];
    }
    return self;
}


@end
