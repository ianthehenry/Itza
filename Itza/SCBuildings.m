//
//  SCBuildings.m
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCBuildings.h"

@implementation SCTemple
@end

@implementation SCGranary
@end

@interface SCFarm ()

@property (nonatomic, assign, readwrite) NSUInteger maize;
@property (nonatomic, assign, readwrite) NSUInteger maizeCapacity;

@end

@implementation SCFarm

- (void)initalize:(NSDictionary *)args {
    [super initalize:args];
    self.maizeCapacity = [args[@"capacity"] unsignedIntegerValue];
}

- (void)plantMaize:(NSUInteger)maize {
    self.maize += maize;
}

- (void)harvestMaize:(NSUInteger)maize {
    NSAssert(maize <= self.maize, @"Not enough maize!");
    self.maize -= maize;
}

- (NSUInteger)remainingMaize {
    return self.maizeCapacity - self.maize;
}

+ (NSSet *)keyPathsForValuesAffectingRemainingMaize {
    return [NSSet setWithObjects:@"maize", @"maizeCapacity", nil];
}

@end

@implementation SCLumberMill
@end

@implementation SCFishery
@end

@implementation SCHouse
@end
