//
//  UDGKPacket.h
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import "RRHeredox.h"


typedef enum UDGKPacketType : unsigned int {
    UDGKPacketTypePickHost  = 1,
    UDGKPacketTypeEnterScene= 2,
    UDGKPacketTypePickColor = 3,
    UDGKPacketTypeTileMove  = 4,
    UDGKPacketTypeResetGame = 5,
} UDGKPacketType;


typedef struct UDGKPacket {
	UDGKPacketType  type;
} UDGKPacket;


typedef struct UDGKPacketPickHost {
	UDGKPacketType  type;
    unsigned int    hostIndex;
} UDGKPacketPickHost;


typedef struct UDGKPacketEnterScene {
	UDGKPacketType  type;
    unsigned int    sceneID;
} UDGKPacketEnterScene;


typedef struct UDGKPacketPickColor {
	UDGKPacketType  type;
    RRPlayerColor   color;
} UDGKPacketPickColor;


typedef struct UDGKPacketTileMove {
	UDGKPacketType  type;
    RRTileMove      move;
    bool            finite;
} UDGKPacketTileMove;


typedef struct UDGKPacketResetGame {
	UDGKPacketType  type;
    unsigned int    seed;
} UDGKPacketResetGame;



static UDGKPacketPickHost UDGKPacketPickHostMake( unsigned int hostIndex ) {
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


static UDGKPacketEnterScene UDGKPacketEnterSceneMake( unsigned int sceneID ) {
    return (UDGKPacketEnterScene){
        UDGKPacketTypeEnterScene,
        sceneID
    };
}


static UDGKPacketTileMove UDGKPacketTileMoveMake( RRTileMove move, bool finite ) {
    return (UDGKPacketTileMove){
        UDGKPacketTypeTileMove,
        move,
        finite
    };
}


static UDGKPacketResetGame UDGKPacketResetGameMake( unsigned int seed ) {
    return (UDGKPacketResetGame){
        UDGKPacketTypeResetGame,
        seed
    };
}
