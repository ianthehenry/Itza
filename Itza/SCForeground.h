//
//  SCForeground.h
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCTile;

@interface SCForeground : NSObject
@property (nonatomic, weak) SCTile *tile;
@end

@interface SCGrass : SCForeground
@end

@interface SCForest : SCForeground
@end

@interface SCBuilding : SCForeground
@property (nonatomic, assign, readonly) NSUInteger stepCount;
@property (nonatomic, assign, readonly) NSUInteger stepsTaken;
@property (nonatomic, assign, readonly) NSUInteger laborPerStep;
@property (nonatomic, assign, readonly) NSUInteger woodPerStep;
@property (nonatomic, assign, readonly) NSUInteger stonePerStep;
@property (nonatomic, assign, readonly) NSUInteger remainingSteps;
@property (nonatomic, assign, readonly) BOOL isComplete;
- (void)build:(NSUInteger)steps;
- (instancetype)initWithLabor:(NSUInteger)labor wood:(NSUInteger)wood stone:(NSUInteger)stone;
@end

@interface SCTemple : SCBuilding
@end

@interface SCRiver : SCForeground
@end

@interface SCGranary : SCBuilding
@end

@interface SCFarm : SCBuilding
@end

@interface SCLumberMill : SCBuilding
@end

@interface SCFishery : SCBuilding
@end

@interface SCHouse : SCBuilding
@end
