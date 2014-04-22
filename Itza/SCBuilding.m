//
//  SCBuilding.m
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCBuilding.h"

@interface SCBuilding ()

@property (nonatomic, assign, readwrite) NSUInteger stepCount;
@property (nonatomic, assign, readwrite) NSUInteger stepsTaken;
@property (nonatomic, assign, readwrite) NSUInteger laborPerStep;
@property (nonatomic, assign, readwrite) NSUInteger woodPerStep;
@property (nonatomic, assign, readwrite) NSUInteger stonePerStep;

@property (nonatomic, assign) BOOL initialized;

@end

static NSUInteger gcd(NSUInteger a, NSUInteger b) {
    if (a == 0) {
        return b;
    }
    if (b == 0) {
        return a;
    }
    if (a == b) {
        return a;
    } else if (a > b) {
        return gcd(a - b, b);
    } else {
        return gcd(a, b - a);
    }
}

@interface SCBuilding ()

@property (nonatomic, assign, readwrite) RACSequence *inputRates;

@end

@implementation SCBuilding

- (instancetype)initWithRequiredResources:(RACSequence *)requiredResources args:(NSDictionary *)args {
    if (self = [super init]) {
        NSUInteger stepCount = 0;
        for (RACTuple *tuple in requiredResources) {
            stepCount = gcd(stepCount, [tuple[1] unsignedIntegerValue]);
        }
        self.inputRates = [requiredResources reduceEach:^(NSNumber *resource, NSNumber *quantity) {
            return RACTuplePack(resource, @(quantity.unsignedIntegerValue / stepCount));
        }];
        [self setCapacity:stepCount forResource:SCResourceConstruction];
        [self initalize:args];
    }
    return self;
}

- (void)initalize:(NSDictionary *)args {
    NSAssert(!self.initialized, @"initialize invoked twice!");
    self.initialized = YES;
}

- (BOOL)isComplete {
    return [self currentUnusedCapacityForResource:SCResourceConstruction] == 0;
}
@end
