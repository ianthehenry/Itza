//
//  SCBuildings.m
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCBuildings.h"
#import "SCTile.h"
#import "SCCity.h"

@implementation SCTemple
@end

@implementation SCGranary
@end

@implementation SCFarm

- (void)iterate {
    [super iterate];
    if (self.tile.world.season != SCSeasonAutumn) {
        return;
    }
    NSUInteger bonusMaize = 0;
    NSUInteger times = [self currentQuantityOfResource:SCResourceMaize];
    for (NSUInteger i = 0; i < times; i++) {
        bonusMaize += arc4random_uniform(2);
    }
    [self setCapacity:([self currentQuantityOfResource:SCResourceMaize] + bonusMaize) forResource:SCResourceMaize];
    [self gainQuantity:bonusMaize ofResource:SCResourceMaize];
}

- (void)initalize:(NSDictionary *)args {
    [super initalize:args];
    [self setCapacity:[args[@"capacity"] unsignedIntegerValue] forResource:SCResourceMaize];
}

@end

@implementation SCLumberYard

+ (NSUInteger)laborAdjustment {
    return 1;
}

@end

@implementation SCFishery

+ (NSUInteger)minFishAdjustment {
    return 2;
}

@end

@interface SCHouse ()
@property (nonatomic, assign) NSUInteger shelter;
@end

@implementation SCHouse

- (void)initalize:(NSDictionary *)args {
    [super initalize:args];
    @weakify(self);
    [[[RACObserve(self, shelter) combinePreviousWithStart:@(self.shelter) reduce:^id(NSNumber *before, NSNumber *after) {
        return @(after.unsignedIntegerValue - before.unsignedIntegerValue);
    }] ignore:@0] subscribeNext:^(NSNumber *delta) {
        @strongify(self);
        [self.city gainShelter:delta.unsignedIntegerValue];
    }];
}

- (RACSignal *)quantityOfShelter {
    return RACObserve(self, shelter);
}

- (NSUInteger)currentQuantityOfShelter {
    return self.shelter;
}

- (void)didComplete {
    NSUInteger shelter = SCHouse.baseShelter;
    RACSequence *neighboringHouses = [[[self.tile.adjacentTiles map:^id(SCTile *tile) {
        return tile.foreground;
    }] filter:^BOOL(SCForeground *foreground) {
        return [foreground isKindOfClass:SCHouse.class];
    }] filter:^BOOL(SCHouse *house) {
        return house.isComplete;
    }];
    
    for (SCHouse *house in neighboringHouses) {
        shelter += SCHouse.shelterPerNeighbor;
        house.shelter += SCHouse.shelterPerNeighbor;
    }
    self.shelter = shelter;
}

+ (NSUInteger)baseShelter {
    return 30;
}

+ (NSUInteger)shelterPerNeighbor {
    return 5;
}

@end
