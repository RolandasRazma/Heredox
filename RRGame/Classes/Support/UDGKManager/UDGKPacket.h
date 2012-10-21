//
//  UDGKPacket.h
//
//  Created by Rolandas Razma on 11/08/2012.
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
