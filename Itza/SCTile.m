//
//  SCTile.m
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCTile.h"
#import "SCWorld.h"

@interface SCTile ()

@property (nonatomic, strong, readwrite) SCHex *hex;
@property (nonatomic, weak, readwrite) SCWorld *world;

@end

@implementation SCTile

- (id)initWithHex:(SCHex *)hex world:(SCWorld *)world {
    if (self = [super init]) {
        _hex = hex;
        _world = world;
        @weakify(self);
        [RACObserve(self, foreground) subscribeNext:^(SCForeground *foreground) {
            @strongify(self);
            foreground.tile = self;
        }];
    }
    return self;
}

- (RACSequence *)adjacentTiles {
    return [[@[@(SCHexDirectionNorth),
               @(SCHexDirectionNorthEast),
               @(SCHexDirectionNorthWest),
               @(SCHexDirectionSouth),
               @(SCHexDirectionSouthEast),
               @(SCHexDirectionSouthWest)].rac_sequence map:^id(NSNumber *direction) {
                   SCPosition *position = [self.hex.position positionInDirection:direction.unsignedIntegerValue];
                   return [self.world tileAt:position];
               }] ignore:nil];
}

@end
