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
@property (nonatomic, assign, readwrite) NSUInteger fish;
@property (nonatomic, strong, readwrite) SCWorld *world;

@end

@implementation SCCity

- (void)iterate {
    NSUInteger hunger = self.population;
    
    NSUInteger meatToEat = MIN(hunger, self.meat);
    self.meat -= meatToEat;
    hunger -= meatToEat;
    NSLog(@"ate %@ meat", @(meatToEat));
    
    NSUInteger fishToEat = MIN(hunger, self.fish);
    self.fish -= fishToEat;
    hunger -= fishToEat;
    NSLog(@"ate %@ fish", @(fishToEat));
    
    NSUInteger maizeToEat = MIN(hunger, self.maize);
    self.maize -= maizeToEat;
    hunger -= maizeToEat;
    NSLog(@"ate %@ maize", @(maizeToEat));
    
    NSLog(@"%@ people starved to death", @(hunger));
    self.population -= hunger;
    
    NSUInteger meatToRot = 3 * self.meat / 4;
    self.meat -= meatToRot;
    NSLog(@"%@ meat rotted", @(meatToRot));
    
    NSUInteger fishToRot = 2 * self.fish / 3;
    self.fish -= fishToRot;
    NSLog(@"%@ fish rotted", @(fishToRot));
    
    NSUInteger maizeToRot = self.maize / 10;
    self.maize -= maizeToRot;
    NSLog(@"%@ maize rotted", @(maizeToRot));
    
    NSUInteger peopleToBeBorn = 0;
    for (NSUInteger i = 0; i < self.population / 10; i++) {
        peopleToBeBorn += arc4random_uniform(4);
    }
    
    NSUInteger peopleToDie = 0;
    for (NSUInteger i = 0; i < self.population / 10; i++) {
        peopleToDie += arc4random_uniform(3);
    }
    
    self.population += peopleToBeBorn;
    self.population -= peopleToDie;
    
    NSLog(@"%@ people are born", @(peopleToBeBorn));
    NSLog(@"%@ people die", @(peopleToDie));
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

- (void)gainFish:(NSUInteger)fish {
    self.fish += fish;
}

@end
