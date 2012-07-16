//
//  UDTile.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDTile.h"


@implementation UDTile {
    BOOL        _backSideVisible;
    
    UDTileEdge  _edgeTop;
    UDTileEdge  _edgeLeft;
    UDTileEdge  _edgeBottom;
    UDTileEdge  _edgeRight;
    
    CCLabelTTF  *_debugLabel;
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

    [super setRotation:rotation];
}


- (void)setPosition:(CGPoint)position {
    [super setPosition:position];
    
    [_debugLabel setString: [NSString stringWithFormat:@"X:%.f Y:%.f", self.positionInGrid.x, self.positionInGrid.y]];
}


#pragma mark -
#pragma mark UDTile


+ (const CGFloat)tileSize {
    return ((isDeviceIPad())?76.0f *2.0f:76.0f);
}


+ (id)tileWithEdgeTop:(UDTileEdge)top left:(UDTileEdge)left bottom:(UDTileEdge)bottom right:(UDTileEdge)right {
    return [[[self alloc] initWithEdgeTop:top left:left bottom:bottom right:right] autorelease];
}


- (id)initWithEdgeTop:(UDTileEdge)top left:(UDTileEdge)left bottom:(UDTileEdge)bottom right:(UDTileEdge)right {
    if( (self = [self initWithSpriteFrameName:@"UDEmptyTile.png"]) ){

        _edgeTop    = top;
        _edgeLeft   = left;
        _edgeBottom = bottom;
        _edgeRight  = right;
        
        if( top != UDTileEdgeNone ){
            CCSprite *topSprite = [CCSprite spriteWithSpriteFrameName: ((top == UDTileEdgeBlack)?@"UDTileEdgeBlack.png":@"UDTileEdgeWhite.png")];
            [topSprite setRotation: -90];
            [topSprite setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height -topSprite.textureRect.size.width /2)];
            [self addChild:topSprite];
        }
        
        if( left != UDTileEdgeNone ){
            CCSprite *leftSprite = [CCSprite spriteWithSpriteFrameName: ((left == UDTileEdgeBlack)?@"UDTileEdgeBlack.png":@"UDTileEdgeWhite.png")];
            [leftSprite setRotation: 180];
            [leftSprite setPosition:CGPointMake(leftSprite.textureRect.size.width /2, self.textureRect.size.height /2)];
            [self addChild:leftSprite];
        }
        
        if( bottom != UDTileEdgeNone ){
            CCSprite *bottomSprite = [CCSprite spriteWithSpriteFrameName: ((bottom == UDTileEdgeBlack)?@"UDTileEdgeBlack.png":@"UDTileEdgeWhite.png")];
            [bottomSprite setRotation: 90];
            [bottomSprite setPosition:CGPointMake(self.textureRect.size.width /2, bottomSprite.textureRect.size.width /2)];
            [self addChild:bottomSprite];
        }
        
        if( right != UDTileEdgeNone ){
            CCSprite *rightSprite = [CCSprite spriteWithSpriteFrameName: ((right == UDTileEdgeBlack)?@"UDTileEdgeBlack.png":@"UDTileEdgeWhite.png")];
            [rightSprite setPosition:CGPointMake(self.textureRect.size.width -rightSprite.textureRect.size.width /2, self.textureRect.size.height /2)];
            [self addChild:rightSprite];
        }
        
        _debugLabel = [CCLabelTTF labelWithString:@"" fontName:@"Courier" fontSize: (isDeviceIPad()?30:15)];
        [_debugLabel setPosition:CGPointMake(self.textureRect.size.width /2, self.textureRect.size.height /2)];
        [self addChild:_debugLabel];

    }
    return self;
}


- (void)setBackSideVisible:(BOOL)backSideVisible {
    if( _backSideVisible == backSideVisible ) return;

    CCSpriteFrame *spriteFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:((backSideVisible==YES)?@"UDTileBack.png":@"UDEmptyTile.png")];

    for( CCSprite *child in self.children ){
        [child setVisible: !backSideVisible];
    }
    
    [self setTexture:spriteFrame.texture];
    [self setTextureRect:spriteFrame.rect];

    _backSideVisible = backSideVisible;
}


- (CGPoint)positionInGrid {
    return CGPointMake((self.position.x -self.textureRect.size.width  /2) /self.textureRect.size.width,
                       (self.position.y -self.textureRect.size.height /2) /self.textureRect.size.height);
}


- (void)setPositionInGrid:(CGPoint)positionInGrid {
    [self setPosition: CGPointMake(positionInGrid.x *self.textureRect.size.width  +self.textureRect.size.width  /2,
                                   positionInGrid.y *self.textureRect.size.height +self.textureRect.size.height /2)];
}


- (UDTileEdge)edgeTop {
    switch ( (int)self.rotation ) {
        case  0: return _edgeTop;
        case 90: return _edgeLeft;
        case 180: return _edgeBottom;
        case 270: return _edgeRight;
    }
    
    return UDTileEdgeNone;
}


- (UDTileEdge)edgeLeft {
    switch ( (int)self.rotation ) {
        case 0: return _edgeLeft;
        case 90: return _edgeBottom;
        case 180: return _edgeRight;
        case 270: return _edgeTop;
    }
    
    return UDTileEdgeNone;
}


- (UDTileEdge)edgeBottom {
    switch ( (int)self.rotation ) {
        case 0: return _edgeBottom;
        case 90: return _edgeRight;
        case 180: return _edgeTop;
        case 270: return _edgeLeft;
    }
    
    return UDTileEdgeNone;
}


- (UDTileEdge)edgeRight {
    switch ( (int)self.rotation ) {
        case 0: return _edgeRight;
        case 90: return _edgeTop;
        case 180: return _edgeLeft;
        case 270: return _edgeBottom;
    }
    
    return UDTileEdgeNone;
}


@synthesize backSideVisible=_backSideVisible;
@end
