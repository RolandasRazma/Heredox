//
//  UDButton.m
//  UDGame
//
//  Created by Rolandas Razma on 1/26/11.
//  Copyright 2011 UD7. All rights reserved.
//

#import "UDButton.h"
#import "CCTouchDispatcher.h"
#import "cocos2d.h"
#import "BlocksAdditions.h"


@interface UDButton ()

- (BOOL)containsTouchLocation:(UITouch *)touch;
- (CGRect)rectInPixels;
- (void)invokeControlEvent:(UDButtonEvents)controlEvent;

@end


@implementation UDButton {
    BOOL                _touchActiveInside;
    NSMutableDictionary *_allBlocks;
}


#pragma mark NSObject


- (void)dealloc {
    [_allBlocks release];
    [super dealloc];
}


#pragma mark -
#pragma mark UDSpriteButton


+ (id)buttonWithSpriteFile:(NSString *)fileName {
    return [[[self alloc] initWithSpriteFile:fileName] autorelease];
}


- (id)initWithSpriteFile:(NSString *)fileName {
    if( (self = [super initWithFile:fileName]) ){
        
    }
    return self;
}


- (void)addBlock:(BasicBlock)block forControlEvents:(UDButtonEvents)controlEvents {
    if( !_allBlocks ){
        _allBlocks = [[NSMutableDictionary alloc] initWithCapacity:2];
    }
    
    for (NSUInteger bit = 1; controlEvents >= bit; bit *= 2) {
        if ( controlEvents & bit ) {
            NSMutableArray *blocks;
            if( !(blocks = [_allBlocks objectForKey:[NSNumber numberWithInt:bit]]) ){
                blocks = [NSMutableArray arrayWithCapacity:2];
                [_allBlocks setObject:blocks forKey: [NSNumber numberWithInt:bit]];
            }
            [blocks addObject: [[block copy] autorelease]];
        }
    }

    if( controlEvents & UDButtonEventTouchHold ){
        [self unscheduleUpdate];
        [self scheduleUpdate];
    }
}


- (void)invokeControlEvent:(UDButtonEvents)controlEvent {
    NSMutableArray *blocks = [_allBlocks objectForKey:[NSNumber numberWithInt:controlEvent]];
    for( BasicBlock block in blocks ){
        block();
    }
}


- (CGRect)rectInPixels {
	CGSize s = [texture_ contentSizeInPixels];
	return CGRectMake( -s.width *[self anchorPoint].x, -s.height *[self anchorPoint].y, s.width, s.height );
}


- (void)setTitle:(NSString *)title {
    CCLabelTTF *titleLabel = [CCLabelTTF labelWithString:title fontName:@"Arial" fontSize:18];
    [titleLabel setPosition:CGPointMake([self textureRect].size.width /2, [self textureRect].size.height /2)];
    [self addChild: titleLabel];
}


#pragma mark -
#pragma mark CCNode


- (void)onEnter {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}


- (void)onExit {
	[[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
	[super onExit];
}	


- (void)update:(ccTime)dt {

    if( _touchActiveInside ){
        [self invokeControlEvent:UDButtonEventTouchHold];
    }
    
}


#pragma mark -
#pragma mark CCTargetedTouchDelegate


- (BOOL)containsTouchLocation:(UITouch *)touch {
    CGRect boundingBox = [self boundingBox];
    boundingBox.origin = CGPointZero;
    
	return CGRectContainsPoint(boundingBox, [self convertTouchToNodeSpace:touch]);
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if ( ![self containsTouchLocation:touch] ) {
        return NO;   
    }
    
    [self invokeControlEvent: UDButtonEventTouchDown];
    
    if( [touch tapCount] > 1 ){
        [self invokeControlEvent: UDButtonEventTouchDownRepeat];
    }
    
    _touchActiveInside = YES;
    
	return YES;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    if ( [self containsTouchLocation:touch] ) {
        _touchActiveInside = YES;
        [self invokeControlEvent: UDButtonEventTouchDragInside];
    }else{
        _touchActiveInside = NO;
        [self invokeControlEvent: UDButtonEventTouchDragOutside];        
    }
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

	if ( [self containsTouchLocation:touch] ) {
        [self invokeControlEvent: UDButtonEventTouchUpInside];        
    }else{
        [self invokeControlEvent: UDButtonEventTouchUpOutside];
    }
    
    _touchActiveInside = NO;
}


@end
