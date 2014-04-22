//
//  SCResourceOwner.m
//  Itza
//
//  Created by Ian Henry on 4/20/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCResourceOwner.h"

static char kCurrentResourceKey;
static char kMaxResourceKey;

static NSMutableDictionary *subjectsForObject(id object, void *key) {
    NSMutableDictionary *dict = objc_getAssociatedObject(object, key);
    if (dict == nil) {
        dict = [[NSMutableDictionary alloc] init];
        objc_setAssociatedObject(object, key, dict, OBJC_ASSOCIATION_RETAIN);
    }
    return dict;
}

RACReplaySubject *replaySubjectForObjectAndResource(id object, void *key, SCResource resource, NSUInteger defaultValue) {
    NSMutableDictionary *subjects = subjectsForObject(object, key);
    RACReplaySubject *replaySubject = subjects[@(resource)];
    if (replaySubject == nil) {
        replaySubject = [RACReplaySubject replaySubjectWithCapacity:1];
        [replaySubject sendNext:@(defaultValue)];
        subjects[@(resource)] = replaySubject;
    }
    return replaySubject;
}

@concreteprotocol(SCResourceOwner)

- (void)setCapacity:(NSUInteger)capacity forResource:(SCResource)resource {
    RACReplaySubject *capacityReplaySubject = replaySubjectForObjectAndResource(self, &kMaxResourceKey, resource, 0);
    NSAssert(capacity >= [self currentQuantityOfResource:resource], @"You can't shrink capacity!");
    [capacityReplaySubject sendNext:@(capacity)];
}

- (void)setQuantity:(NSUInteger)quantity ofResource:(SCResource)resource {
    RACReplaySubject *currentReplaySubject = replaySubjectForObjectAndResource(self, &kCurrentResourceKey, resource, 0);
    NSAssert(quantity <= [self currentCapacityForResource:resource], @"no that would overflow it");
    [currentReplaySubject sendNext:@(quantity)];
}

- (void)loseQuantity:(NSUInteger)quantity ofResource:(SCResource)resource {
    RACReplaySubject *replaySubject = replaySubjectForObjectAndResource(self, &kCurrentResourceKey, resource, 0);
    NSUInteger currentValue = [[replaySubject first] unsignedIntegerValue];
    NSAssert(quantity <= currentValue, @"Cannot lose more than you have!");
    [replaySubject sendNext:@(currentValue - quantity)];
}

- (void)gainQuantity:(NSUInteger)quantity ofResource:(SCResource)resource {
    RACReplaySubject *currentReplaySubject = replaySubjectForObjectAndResource(self, &kCurrentResourceKey, resource, 0);
    NSUInteger currentValue = [[currentReplaySubject first] unsignedIntegerValue];
    NSUInteger unusedCapacity = [self currentUnusedCapacityForResource:resource];
    NSAssert(quantity <= unusedCapacity, @"no that would overflow it");
    [currentReplaySubject sendNext:@(currentValue + quantity)];
}

- (NSUInteger)currentQuantityOfResource:(SCResource)resource {
    return [[[self quantityOfResource:resource] first] unsignedIntegerValue];
}

- (NSUInteger)currentCapacityForResource:(SCResource)resource {
    return [[[self capacityForResource:resource] first] unsignedIntegerValue];
}

- (NSUInteger)currentUnusedCapacityForResource:(SCResource)resource {
    return [[[self unusedCapacityForResource:resource] first] unsignedIntegerValue];
}

- (RACSignal *)quantityOfResource:(SCResource)resource {
    return replaySubjectForObjectAndResource(self, &kCurrentResourceKey, resource, 0);
}

- (RACSignal *)capacityForResource:(SCResource)resource {
    return replaySubjectForObjectAndResource(self, &kMaxResourceKey, resource, NSUIntegerMax);
}

- (RACSignal *)unusedCapacityForResource:(SCResource)resource {
    return [RACSignal combineLatest:@[[self quantityOfResource:resource],
                                      [self capacityForResource:resource]]
                             reduce:^(NSNumber *currentNumber, NSNumber *maxNumber) {
                                 NSUInteger current = currentNumber.unsignedIntegerValue;
                                 NSUInteger max = maxNumber.unsignedIntegerValue;
                                 NSAssert(current <= max, @"Invariant violated: quantity of resource is greater than max");
                                 return @(max - current);
                             }];
}

@end
