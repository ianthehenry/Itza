//
//  SCWorld.m
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCWorld.h"

@interface SCWorld ()

@property (nonatomic, strong) NSMutableSet *mutableTiles;
@property (nonatomic, strong) NSMutableDictionary *tileForLocation;
@property (nonatomic, assign, readwrite) NSUInteger radius;

@property (nonatomic, assign, readwrite) SCSeason season;
@property (nonatomic, assign, readwrite) NSUInteger turn;

@end

@implementation SCWorld

- (void)iterate {
    self.season = (self.season + 1) % 4;
    self.turn += 1;
}

+ (instancetype)worldWithRadius:(NSUInteger)radius {
    SCWorld *world = [[self alloc] init];
    world.radius = radius;
    world.season = SCSeasonSpring;
    world.tileForLocation = [[NSMutableDictionary alloc] init];
    world.mutableTiles = [[NSMutableSet alloc] init];
    
    [world addTileForPosition:[SCPosition x:0 y:0] type:SCTileTypeTemple];
    
    for (NSInteger distance = 1; distance <= radius; distance++) {
        SCPosition *position = [SCPosition x:0 y:-distance];
        
        for (NSNumber *directionNumber in @[@(SCHexDirectionSouthWest),
                                            @(SCHexDirectionSouth),
                                            @(SCHexDirectionSouthEast),
                                            @(SCHexDirectionNorthEast),
                                            @(SCHexDirectionNorth),
                                            @(SCHexDirectionNorthWest)]) {
            SCHexDirection direction = directionNumber.unsignedIntegerValue;
            for (NSInteger i = 0; i < distance; i++) {
                [world addTileForPosition:position type:arc4random_uniform(3)];
                position = [position positionInDirection:direction];
            }
        }
    }
    return world;
}

- (NSSet *)tiles {
    return self.mutableTiles;
}

- (SCTile *)tileAt:(SCPosition *)position {
    return self.tileForLocation[position];
}

- (void)addTileForPosition:(SCPosition *)position type:(SCTileType)type {
    SCHex *hex = [[SCHex alloc] init];
    hex.position = position;
    SCTile *tile = [[SCTile alloc] initWithHex:hex];
    tile.type = type;
    
    [self.mutableTiles addObject:tile];
    self.tileForLocation[hex.position] = tile;
    
    static NSArray *directions = nil;
    if (directions == nil) {
        directions = @[@(SCHexDirectionNorth), @(SCHexDirectionNorthEast), @(SCHexDirectionSouthEast), @(SCHexDirectionSouth), @(SCHexDirectionSouthWest), @(SCHexDirectionNorthWest)];
    }
    for (NSNumber *directionNumber in directions) {
        SCHexDirection direction = directionNumber.unsignedIntegerValue;
        [hex connectToHex:[self tileAt:[hex.position positionInDirection:direction]].hex inDirection:direction];
    }
}


@end
