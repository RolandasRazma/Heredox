//
//  UDTile.m
//  RRHeredox
//
//  Created by Rolandas Razma on 7/13/12.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "UDTile.h"


@implementation UDTile {
    BOOL _backSideVisible;
}


#pragma mark -
#pragma mark UDTile


+ (id)tileWithEdgeTop:(UDTileEdge)top left:(UDTileEdge)left bottom:(UDTileEdge)bottom right:(UDTileEdge)right {
    return [[[self alloc] initWithEdgeTop:top left:left bottom:bottom right:right] autorelease];
}


- (id)initWithEdgeTop:(UDTileEdge)top left:(UDTileEdge)left bottom:(UDTileEdge)bottom right:(UDTileEdge)right {
    if( (self = [self initWithSpriteFrameName:@"UDEmptyTile.png"]) ){

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


@synthesize backSideVisible=_backSideVisible;
@end
