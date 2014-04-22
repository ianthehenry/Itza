//
//  SCWorld.m
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCWorld.h"
#import "SCForegrounds.h"

@interface SCWorld ()

@property (nonatomic, strong) NSMutableSet *mutableTiles;
@property (nonatomic, strong) NSMutableDictionary *tileForLocation;
@property (nonatomic, assign, readwrite) NSUInteger radius;

@property (nonatomic, assign, readwrite) NSUInteger turn;

@end

@implementation SCWorld

- (void)iterate {
    self.turn += 1;
    for (SCTile *tile in self.tiles) {
        [tile.foreground iterate];
    }
}

- (SCSeason)season {
    return self.turn % 4;
}

+ (instancetype)worldWithRadius:(NSUInteger)radius {
    SCWorld *world = [[self alloc] init];
    world.radius = radius;
    world.tileForLocation = [[NSMutableDictionary alloc] init];
    world.mutableTiles = [[NSMutableSet alloc] init];
    
    [world addTileForPosition:[SCPosition x:0 y:0] foreground:[[SCTemple alloc] initWithRequiredResources:[RACSequence empty] args:nil]];
    
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
                [world addTileForPosition:position foreground:[self randomForeground]];
                position = [position positionInDirection:direction];
            }
        }
    }
    return world;
}

+ (SCForeground *)randomForeground {
    switch (arc4random_uniform(10)) {
        case 0: case 1: case 2: {
            SCForest *forest = [[SCForest alloc] init];
            [forest gainQuantity:(75 + arc4random_uniform(51)) ofResource:SCResourceWood];
            return forest;
        }
        case 3: case 4:
            return [[SCRiver alloc] init];
        default:
            return [[SCGrass alloc] init];
    }
}

- (NSSet *)tiles {
    return self.mutableTiles;
}

- (SCTile *)tileAt:(SCPosition *)position {
    return self.tileForLocation[position];
}

- (void)addTileForPosition:(SCPosition *)position foreground:(SCForeground *)foreground {
    SCHex *hex = [[SCHex alloc] init];
    hex.position = position;
    SCTile *tile = [[SCTile alloc] initWithHex:hex];
    tile.foreground = foreground;

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
