//
//  UDGKPacket.h
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRHeredox.h"


typedef enum UDGKPacketType : NSUInteger {
    UDGKPacketTypePickHost,
    UDGKPacketTypeEnterScene,
    UDGKPacketTypePickColor,
    UDGKPacketTypeTileMove
} UDGKPacketType;


typedef struct UDGKPacket {
	UDGKPacketType  type;
} UDGKPacket;


typedef struct UDGKPacketPickHost {
	UDGKPacketType  type;
    NSUInteger      hostIndex;
} UDGKPacketPickHost;


typedef struct UDGKPacketEnterScene {
	UDGKPacketType  type;
    NSUInteger      sceneID;
} UDGKPacketEnterScene;


typedef struct UDGKPacketPickColor {
	UDGKPacketType  type;
    RRPlayerColor   color;
} UDGKPacketPickColor;

typedef struct UDGKPacketTileMove {
	UDGKPacketType  type;
    RRTileMove      move;
} UDGKPacketTileMove;




static UDGKPacketPickHost UDGKPacketPickHostMake( NSUInteger hostIndex ) {
    return (UDGKPacketPickHost){
        UDGKPacketTypePickHost,
        hostIndex
    };
}


static UDGKPacketPickColor UDGKPacketPickColorMake( RRPlayerColor color ) {
    return (UDGKPacketPickColor){
        UDGKPacketTypePickColor,
        color
    };
}


static UDGKPacketEnterScene UDGKPacketEnterSceneMake( NSUInteger sceneID ) {
    return (UDGKPacketEnterScene){
        UDGKPacketTypeEnterScene,
        sceneID
    };
}


static UDGKPacketTileMove UDGKPacketTileMoveMake( RRTileMove move ) {
    return (UDGKPacketTileMove){
        UDGKPacketTypeTileMove,
        move
    };
}


