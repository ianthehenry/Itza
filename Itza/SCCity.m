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
    NSUInteger hunger = self.population;
    
    NSUInteger meatToEat = MIN(hunger, self.meat);
    self.meat -= meatToEat;
    hunger -= meatToEat;
    NSLog(@"ate %u meat", meatToEat);
    
    NSUInteger maizeToEat = MIN(hunger, self.maize);
    self.maize -= maizeToEat;
    hunger -= maizeToEat;
    NSLog(@"ate %u maize", maizeToEat);
    
    NSUInteger starvation = hunger;
    NSLog(@"%u people starved to death", starvation);
    self.population -= starvation;
    
    NSUInteger meatToRot = self.meat / 2;
    self.meat -= meatToRot;
    NSLog(@"%u meat rotted", meatToRot);
    
    NSUInteger maizeToRot = self.maize / 10;
    self.maize -= maizeToRot;
    NSLog(@"%u maize rotted", maizeToRot);
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

- (void)gainMaize:(NSUInteger)maize {
    self.maize += maize;
}

- (void)gainMeat:(NSUInteger)meat {
    self.meat += meat;
}

@end
