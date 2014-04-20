//
//  SCBuildings.h
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCBuilding.h"

@interface SCTemple : SCBuilding
@end

@interface SCGranary : SCBuilding
@end

@interface SCFarm : SCBuilding

@property (nonatomic, assign, readonly) NSUInteger maize;
@property (nonatomic, assign, readonly) NSUInteger maizeCapacity;
@property (nonatomic, assign, readonly) NSUInteger remainingMaize;
- (void)plantMaize:(NSUInteger)maize;
- (void)harvestMaize:(NSUInteger)maize;

@end

@interface SCLumberMill : SCBuilding
@end

@interface SCFishery : SCBuilding
@end

@interface SCHouse : SCBuilding
@end
