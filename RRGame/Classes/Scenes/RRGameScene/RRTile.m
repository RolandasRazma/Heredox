//
//  UDTile.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRTile.h"


@implementation RRTile


#pragma mark -
#pragma mark NSObject


- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ = %08X | rotation = %.f | positionInGrid = {%.f, %.f}>",
            [self class],
            self,
            self.rotation,
            self.positionInGrid.x, self.positionInGrid.y];
}


#pragma mark -
#pragma mark CCSprite


- (void)setOpacity:(GLubyte)opacity {
    [super setOpacity:opacity];
    for( CCSprite *child in self.children ){
        [child setOpacity: opacity];
    }
}


- (void)setRotation:(float)rotation {
    if( rotation >= 360.0f ) rotation -= 360.0f;
    if( rotation <= -360.0f) rotation += 360.0f;

    [_debugLabel setRotation: -rotation];
    
    if( (rotation >= 0.0f && rotation <= 45.0f) || (rotation >= -45.0f && rotation <= 0.0f) || (rotation >= 315.0f && rotation <= 360.0f) || (rotation <= -315.0f && rotation >= -360.0f) ){
        [_look3DSprite setRotation:0];
    }else if( (rotation >= 45.0f && rotation <= 135.0f) || (rotation <= -225.0f && rotation >= -315.0f) ){
        [_look3DSprite setRotation:-90];
    }else if( (rotation >= 135.0f && rotation <= 225.0f) || (rotation <= -135.0f && rotation >= -225.0f) ){
        [_look3DSprite setRotation:-180];
    }else if( (rotation >= 225.0f && rotation <= 315.0f) || (rotation <= -45 && rotation >= -90.0f) ){
        [_look3DSprite setRotation:-270];
    }

    [super setRotation:rotation];
    
#if TARGET_IPHONE_SIMULATOR
    [_debugLabel setString: [NSString stringWithFormat:@"%.f/%.f/%.f", self.positionInGrid.x, self.positionInGrid.y, self.rotation]];
#endif
}


#if TARGET_IPHONE_SIMULATOR
- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    [_debugLabel setString: [NSString stringWithFormat:@"%.f/%.f/%.f", self.positionInGrid.x, self.positionInGrid.y, self.rotation]];
}
#endif


#pragma mark -
#pragma mark UDTile


+ (const CGFloat)tileSize {
    return ((isDeviceIPad()||isDeviceMac())?76.0f *2.0f:76.0f);
}


+ (id)tileWithType:(RRTileType)tileType {
    return [[[self alloc] initWithType:tileType] autorelease];
}


- (id)initWithType:(RRTileType)tileType {
    if( (self = [self initWithSpriteFrameName:@"RREmptyTile.png"]) ){

        switch ( tileType ) {
            case RRTileTypeNNNN: {
                _edgeTop = _edgeLeft = _edgeBottom = _edgeRight = RRTileEdgeNone;
                break;
            }
            case RRTileTypeWNBN: {
                _edgeTop    = RRTileEdgeWhite;
                _edgeLeft   = _edgeRight = RRTileEdgeNone;
                _edgeBottom = RRTileEdgeBlack;
                break;
            }
            case RRTileTypeWNNB: {
                _edgeTop    = RRTileEdgeWhite;
                _edgeLeft   = _edgeBottom = RRTileEdgeNone;
                _edgeRight = RRTileEdgeBlack;
                break;
            }

            case RRTileTypeWBNN: {
                _edgeTop    = RRTileEdgeWhite;
                _edgeLeft   = RRTileEdgeBlack;
                _edgeBottom = _edgeRight = RRTileEdgeNone;
                break;
            }
            case RRTileTypeWWBB: {
                _edgeTop    = _edgeLeft = RRTileEdgeWhite;
                _edgeBottom = _edgeRight= RRTileEdgeBlack;
                break;
            }
            case RRTileTypeWBWB: {
                _edgeTop  = _edgeBottom = RRTileEdgeWhite;
                _edgeLeft = _edgeRight  = RRTileEdgeBlack;
                break;
            }
        }
        
        _tileType   = tileType;
        _lookIs3D   = YES;
        
        if( _edgeTop != RRTileEdgeNone ){
            CCSprite *topSprite = [CCSprite spriteWithSpriteFrameName: ((_edgeTop == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [topSprite setRotation: -90];
            [topSprite setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height -topSprite.textureRect.size.width /2)];
            [self addChild:topSprite];
        }
        
        if( _edgeLeft != RRTileEdgeNone ){
            CCSprite *leftSprite = [CCSprite spriteWithSpriteFrameName: ((_edgeLeft == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [leftSprite setRotation: 180];
            [leftSprite setPosition:CGPointMake(leftSprite.textureRect.size.width /2, self.textureRect.size.height /2)];
            [self addChild:leftSprite];
        }
        
        if( _edgeBottom != RRTileEdgeNone ){
            CCSprite *bottomSprite = [CCSprite spriteWithSpriteFrameName: ((_edgeBottom == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [bottomSprite setRotation: 90];
            [bottomSprite setPosition:CGPointMake(self.textureRect.size.width /2, bottomSprite.textureRect.size.width /2)];
            [self addChild:bottomSprite];
        }
        
        if( _edgeRight != RRTileEdgeNone ){
            CCSprite *rightSprite = [CCSprite spriteWithSpriteFrameName: ((_edgeRight == RRTileEdgeBlack)?@"RRTileEdgeBlack.png":@"RRTileEdgeWhite.png")];
            [rightSprite setPosition:CGPointMake(self.textureRect.size.width -rightSprite.textureRect.size.width /2, self.textureRect.size.height /2)];
            [self addChild:rightSprite];
        }

        // 3D Look edge
        _look3DSprite = [CCSprite spriteWithSpriteFrameName:@"RREmptyTile3D.png"];
        [_look3DSprite setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height /2)];
        [_look3DSprite setAnchorPoint:CGPointMake(0.5f, (self.textureRect.size.height /2 +_look3DSprite.textureRect.size.height) /_look3DSprite.textureRect.size.height)];
        [_look3DSprite setVisible:_lookIs3D];
        [self addChild:_look3DSprite z:-1];
        
#if TARGET_IPHONE_SIMULATOR
        _debugLabel = [CCLabelTTF labelWithString:@"" fontName:@"Courier-Bold" fontSize: (isDeviceIPad()?26:13)];
        [_debugLabel setColor: ccGREEN];
        [_debugLabel setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height /2)];
        [self addChild:_debugLabel];
#endif
    }
    return self;
}


- (void)setBackSideVisible:(BOOL)backSideVisible {
    if( _backSideVisible == backSideVisible ) return;

    [_endTurnSprite stopAllActions];
    [self removeChild:_endTurnSprite cleanup:YES];
    _endTurnSprite = nil;
    
    for( CCSprite *child in self.children ){
        if( [child isEqual:_look3DSprite] ) continue;
        [child setVisible: !backSideVisible];
    }    
    
    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:((backSideVisible==YES)?@"RRTileBack.png":@"RREmptyTile.png")];

    [self setTexture:spriteFrame.texture];
    [self setTextureRect:spriteFrame.rect];

    
    CCSpriteFrame *look3DSpriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:((backSideVisible==YES)?@"RREmptyTile3DBack.png":@"RREmptyTile3D.png")];
    
    [_look3DSprite setTexture:look3DSpriteFrame.texture];
    [_look3DSprite setTextureRect:look3DSpriteFrame.rect];

    _backSideVisible = backSideVisible;
}


- (void)showEndTurnTextAnimated:(BOOL)animated {

    [_endTurnSprite stopAllActions];
    if( !_endTurnSprite ){
        _endTurnSprite = [CCSprite spriteWithSpriteFrameName:@"RRTextEndTurn.png"];
        [_endTurnSprite setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height /2 +7)];
        [self addChild:_endTurnSprite];
    }
    
    if( animated ){
        [_endTurnSprite setOpacity:0];
        [_endTurnSprite runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3], [CCFadeIn actionWithDuration:0.5f], nil]];
    }else{
        [_endTurnSprite setOpacity:255];
    }
    
}


- (CGPoint)positionInGrid {
    if( self.isBackSideVisible ) return CGPointMake(INT_MIN, INT_MIN);
    
    return CGPointMake((self.position.x -self.textureRect.size.width  /2) /self.textureRect.size.width,
                       (self.position.y -self.textureRect.size.height /2) /self.textureRect.size.height);
}


- (void)setPositionInGrid:(CGPoint)positionInGrid {
    [self setPosition: CGPointMake(positionInGrid.x *self.textureRect.size.width  +self.textureRect.size.width  /2,
                                   positionInGrid.y *self.textureRect.size.height +self.textureRect.size.height /2)];
}


- (RRTileEdge)edgeTop {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeTop;
        case -270:
        case   90: return _edgeLeft;
        case -180:
        case  180: return _edgeBottom;
        case  -90:
        case  270: return _edgeRight;
    }
    
    return RRTileEdgeNone;
}


- (RRTileEdge)edgeLeft {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeLeft;
        case -270:
        case   90: return _edgeBottom;
        case -180:
        case  180: return _edgeRight;
        case  -90:
        case  270: return _edgeTop;
    }
    
    return RRTileEdgeNone;
}


- (RRTileEdge)edgeBottom {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeBottom;
        case -270:
        case   90: return _edgeRight;
        case -180:
        case  180: return _edgeTop;
        case  -90:
        case  270: return _edgeLeft;
    }
    
    return RRTileEdgeNone;
}


- (RRTileEdge)edgeRight {
    switch ( (int)roundf(self.rotation) ) {
        case    0: return _edgeRight;
        case -270:
        case   90: return _edgeTop;
        case -180:
        case  180: return _edgeLeft;
        case  -90:
        case  270: return _edgeBottom;
    }
    
    return RRTileEdgeNone;
}


- (void)setLookIs3D:(BOOL)lookIs3D {
    if( _lookIs3D == lookIs3D ) return;
    [_look3DSprite setVisible:lookIs3D];
    _lookIs3D = lookIs3D;
}


- (void)liftTile {
    if( !self.isPlaced ) return;

    [self setScale:1.1f];
    [self setZOrder:NSIntegerMax];
    
    [[RRAudioEngine sharedEngine] replayEffect:@"RRLiftTile.mp3"];
    
    _wasLifted = YES;
}


- (void)placeTile {
    if( self.isPlaced ) return;
    
    [self setScale:1.0f];
    [self setZOrder: 1000 +(int)roundf(-self.position.y)];
    
    [[RRAudioEngine sharedEngine] replayEffect:@"RRPlaceTile.mp3"];
}


- (BOOL)isPlaced {
    return ( self.scale == 1.0f );
}

- (RRTileMove)tileMove {
    CGPoint positionInGrid = self.positionInGrid;
    return RRTileMoveMake(roundf(positionInGrid.x), roundf(positionInGrid.y), roundf(self.rotation), 0.0f);
}


@synthesize backSideVisible=_backSideVisible, lookIs3D=_lookIs3D, wasLifted=_wasLifted;
@end
