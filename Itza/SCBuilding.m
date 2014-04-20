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

static NSUInteger gcd3(NSUInteger a, NSUInteger b, NSUInteger c) {
    return gcd(a, gcd(b, c));
}

@implementation SCBuilding
- (instancetype)initWithLabor:(NSUInteger)labor wood:(NSUInteger)wood stone:(NSUInteger)stone {
    if (self = [super init]) {
        _stepCount = gcd3(labor, wood, stone);
        NSAssert(_stepCount > 0, @"Building can't be free!");
        _laborPerStep = labor / _stepCount;
        _woodPerStep = wood / _stepCount;
        _stonePerStep = stone / _stepCount;
    }
    return self;
}
- (void)build:(NSUInteger)steps {
    NSAssert(steps <= self.remainingSteps, @"You can't overbuild!");
    self.stepsTaken += steps;
}

- (NSUInteger)remainingSteps  {
    return self.stepCount - self.stepsTaken;
}

- (BOOL)isComplete {
    return self.remainingSteps == 0;
}

+ (NSSet *)keyPathsForValuesAffectingRemainingSteps {
    return [NSSet setWithObjects:@"stepCount", @"stepsTaken", nil];
}

+ (NSSet *)keyPathsForValuesAffectingIsComplete {
    return [NSSet setWithObject:@"remainingSteps"];
}

@end
