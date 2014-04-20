//
//  SCBuilding.h
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCForeground.h"

@interface SCBuilding : SCForeground

@property (nonatomic, assign, readonly) NSUInteger stepCount;
@property (nonatomic, assign, readonly) NSUInteger stepsTaken;
@property (nonatomic, assign, readonly) NSUInteger laborPerStep;
@property (nonatomic, assign, readonly) NSUInteger woodPerStep;
@property (nonatomic, assign, readonly) NSUInteger stonePerStep;
@property (nonatomic, assign, readonly) NSUInteger remainingSteps;
@property (nonatomic, assign, readonly) BOOL isComplete;
- (void)build:(NSUInteger)steps;
- (instancetype)initWithLabor:(NSUInteger)labor wood:(NSUInteger)wood stone:(NSUInteger)stone args:(NSDictionary *)args;
- (void)initalize:(NSDictionary *)args;

@end
