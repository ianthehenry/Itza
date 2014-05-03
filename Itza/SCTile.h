//
//  SCTile.h
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPosition.h"
#import "SCForeground.h"

@class SCWorld;

@interface SCTile : NSObject

- (id)initWithHex:(SCHex *)hex world:(SCWorld *)world;

@property (nonatomic, weak, readonly) SCWorld *world;
@property (nonatomic, strong, readonly) SCHex *hex;
@property (nonatomic, strong) SCForeground *foreground;
@property (nonatomic, readonly) RACSequence *adjacentTiles;

@end
