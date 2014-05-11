//
//  SCBuildings.h
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCBuilding.h"
#import "SCResourceOwner.h"

@interface SCTemple : SCBuilding
@end

@interface SCGranary : SCBuilding
@end

@interface SCFarm : SCBuilding <SCResourceOwner>
@end

@interface SCLumberYard : SCBuilding

+ (NSUInteger)laborAdjustment;

@end

@interface SCFishery : SCBuilding

+ (NSUInteger)minFishAdjustment;

@end

@interface SCHouse : SCBuilding

- (RACSignal *)quantityOfShelter;
- (NSUInteger)currentQuantityOfShelter;
+ (NSUInteger)baseShelter;
+ (NSUInteger)shelterPerNeighbor;

@end
