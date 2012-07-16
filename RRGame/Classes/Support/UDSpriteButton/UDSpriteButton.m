//
//  UDSpriteButton.m
//
//  Created by Rolandas Razma on 7/15/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDSpriteButton.h"
#import "CCTouchDispatcher.h"
#import "cocos2d.h"
#import "BlocksAdditions.h"


@interface UDSpriteButton ()

- (void)invokeControlEvent:(UDButtonEvents)controlEvent;

@end


@implementation UDSpriteButton {
    BOOL                _touchActiveInside;
    NSMutableDictionary *_allBlocks;
    BOOL                _touchActive;
    BOOL                _userInteractionEnabled;
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


- (id)initWithTexture:(CCTexture2D *)texture rect:(CGRect)rect {
    if( (self = [super initWithTexture:texture rect:rect]) ){
        [self setUserInteractionEnabled: YES];
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


- (void)setUserInteractionEnabled:(BOOL)enabled {
    if( [self isUserInteractionEnabled] == enabled ) return;

    _userInteractionEnabled = enabled;
    
#ifdef __CC_PLATFORM_IOS
    if( isRunning_ ){
        if( enabled ){
            [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate: (id <CCTargetedTouchDelegate>)self 
                                                                    priority: 0 
                                                             swallowsTouches: YES];
        }else{
            [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
        }
    }
#elif defined(__CC_PLATFORM_MAC)
    if( isRunning_ ) {
        if( enabled ) {
            [[CCDirector sharedDirector].eventDispatcher addMouseDelegate: (id <CCMouseEventDelegate>)self
                                                                 priority: 0];
        } else {
            [[CCDirector sharedDirector].eventDispatcher removeMouseDelegate:self];
        }
    }
#endif
}


- (BOOL)touchBeganAtLocation:(CGPoint)location {
    if( !CGRectContainsPoint(self.boundingBox, location) ) return NO;
    
    [self invokeControlEvent: UDButtonEventTouchDown];

    _touchActiveInside = YES;
    
	return YES;
}


- (void)touchMovedToLocation:(CGPoint)location {
    if ( CGRectContainsPoint(self.boundingBox, location) ) {
        _touchActiveInside = YES;
        [self invokeControlEvent: UDButtonEventTouchDragInside];
    }else{
        _touchActiveInside = NO;
        [self invokeControlEvent: UDButtonEventTouchDragOutside];        
    }
}


- (void)touchEndedAtLocation:(CGPoint)location {
	if ( CGRectContainsPoint(self.boundingBox, location) ) {
        [self invokeControlEvent: UDButtonEventTouchUpInside];        
    }else{
        [self invokeControlEvent: UDButtonEventTouchUpOutside];
    }
    
    _touchActiveInside = NO;
}


#pragma mark -
#pragma mark CCNode


- (void)update:(ccTime)dt {

    if( _touchActiveInside ){
        [self invokeControlEvent:UDButtonEventTouchHold];
    }
    
}


#ifdef __CC_PLATFORM_IOS


- (void)onEnter {
    if( [self isUserInteractionEnabled] ){
        [[CCDirector sharedDirector].touchDispatcher addTargetedDelegate: (id <CCTargetedTouchDelegate>)self
                                                                priority: 0
                                                         swallowsTouches: YES];
    }
    [super onEnter];
}


- (void)onExit {
    [[CCDirector sharedDirector].touchDispatcher removeDelegate:self];
    [super onExit];
}


#pragma mark -
#pragma mark CCTargetedTouchDelegate


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if( !visible_ ) return NO;
	
	for( CCNode *c = self.parent; c != nil; c = c.parent ){
		if( c.visible == NO ) return NO;
    }

    _touchActive = [self touchBeganAtLocation: [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]]];
    return _touchActive;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
    [self touchMovedToLocation: [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]]];
}


- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    [self touchEndedAtLocation: [[CCDirector sharedDirector] convertToGL: [touch locationInView: [touch view]]]];
}


#elif defined(__CC_PLATFORM_MAC)


- (void)onEnter {
    if( [self isUserInteractionEnabled] ){
        [[CCDirector sharedDirector].eventDispatcher addMouseDelegate: (id <CCMouseEventDelegate>)self
                                                             priority: 0];
    }
    [super onEnter];
}


- (void)onExit {
    [[CCDirector sharedDirector].eventDispatcher removeMouseDelegate:self];
    [super onExit];
}


#pragma mark -
#pragma mark CCMouseEventDelegate


- (BOOL)ccMouseDown:(NSEvent *)event {
    if( !visible_ ) return NO;

    _touchActive = [self touchBeganAtLocation: [(CCDirectorMac *)[CCDirector sharedDirector] convertEventToGL:event]];
    return _touchActive;
}


- (BOOL)ccMouseDragged:(NSEvent *)event {
    if( !visible_ || !_touchActive ) return NO;
    
    [self touchMovedToLocation: [(CCDirectorMac *)[CCDirector sharedDirector] convertEventToGL:event]];
    return YES;
}


- (BOOL)ccMouseUp:(NSEvent *)event {
    if( !visible_ || !_touchActive ) return NO;
    
    [self touchEndedAtLocation: [(CCDirectorMac *)[CCDirector sharedDirector] convertEventToGL:event]];
    _touchActive = NO;
    return YES;
}


#endif


@synthesize userInteractionEnabled=_userInteractionEnabled;
@end
