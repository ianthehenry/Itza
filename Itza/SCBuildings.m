//
//  SCBuildings.m
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCBuildings.h"
#import "SCTile.h"

@implementation SCTemple
@end

@implementation SCGranary
@end

@implementation SCFarm

- (void)initalize:(NSDictionary *)args {
    [super initalize:args];
    [self setCapacity:[args[@"capacity"] unsignedIntegerValue] forResource:SCResourceMaize];
}

@end

@implementation SCLumberMill
@end

@implementation SCFishery
@end

@implementation SCHouse

- (NSUInteger)shelter {
    if (!self.isComplete) {
        return 0;
    }
    NSUInteger count = [[[self.tile.adjacentTiles filter:^BOOL(SCTile *tile) {
        return [tile.foreground isKindOfClass:SCHouse.class] && [(SCHouse *)tile.foreground isComplete];
    }] foldLeftWithStart:@0 reduce:^id(NSNumber *accumulator, id value) {
        return @(accumulator.unsignedIntegerValue + 1);
    }] unsignedIntegerValue];
    return SCHouse.baseShelter + count * SCHouse.shelterPerNeighbor;
}

+ (NSUInteger)baseShelter {
    return 30;
}

+ (NSUInteger)shelterPerNeighbor {
    return 5;
}

@end
