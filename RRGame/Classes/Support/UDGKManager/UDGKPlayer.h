//
//  UDGKPlayer.h
//  RRHeredox
//
//  Created by Rolandas Razma on 11/08/2012.
//  Copyright (c) 2012 UD7. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UDGKPlayer : NSObject {
    NSString *_playerID;
    NSString *_alias;
}

@property(nonatomic, copy)  NSString *playerID;
@property(nonatomic, copy)  NSString *alias;

@end
