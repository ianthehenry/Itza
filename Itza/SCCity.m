//
//  SCCity.m
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCCity.h"

@interface SCCity ()

@property (nonatomic, assign, readwrite) NSUInteger population;
@property (nonatomic, assign, readwrite) NSUInteger meat;
@property (nonatomic, assign, readwrite) NSUInteger maize;
@property (nonatomic, assign, readwrite) NSUInteger wood;
@property (nonatomic, assign, readwrite) NSUInteger stone;
@property (nonatomic, strong, readwrite) SCWorld *world;

@end

@implementation SCCity

- (void)iterate {

}

+ (instancetype)cityWithWorld:(SCWorld *)world {
    SCCity *city = [[self alloc] init];
    city.population = 100;
    city.meat = 10;
    city.maize = 0;
    city.world = world;
    return city;
}

- (void)gainWood:(NSUInteger)wood {
    self.wood += wood;
}

@end
