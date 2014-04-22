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
@end
