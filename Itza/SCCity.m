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
@property (nonatomic, assign, readwrite) NSUInteger labor;
@property (nonatomic, strong, readwrite) SCWorld *world;

@end

@implementation SCCity

- (NSArray *)iterate {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    void (^log)(NSUInteger number, NSString *format) = ^(NSUInteger number, NSString *format) {
        if (number > 0) {
            NSString *numberString = [NSString stringWithFormat:@"%u", number];
            [messages addObject:[format stringByReplacingOccurrencesOfString:@"%" withString:numberString]];
        }
    };
    void (^logDelta)(NSInteger number, NSString *format) = ^(NSInteger number, NSString *name) {
        NSString *numberString = [NSString stringWithFormat:@"%i", ABS(number)];
        NSString *signString = number < 0 ? @"-" : @"+";
        [messages addObject:[NSString stringWithFormat:@"%@%@ %@", signString, numberString, name]];
    };
    
    NSUInteger foodBefore = self.food;
    NSUInteger populationBefore = self.population;
    
    NSUInteger hunger = self.population;
    
    NSUInteger meatToEat = MIN(hunger, self.meat);
    self.meat -= meatToEat;
    hunger -= meatToEat;
    log(meatToEat, @"% meat eaten");
    
    NSUInteger fishToEat = MIN(hunger, self.fish);
    self.fish -= fishToEat;
    hunger -= fishToEat;
    log(fishToEat, @"% fish eaten");
    
    NSUInteger maizeToEat = MIN(hunger, self.maize);
    self.maize -= maizeToEat;
    hunger -= maizeToEat;
    log(maizeToEat, @"% maize eaten");
    
    log(hunger, @"% people starved");
    self.population -= hunger;
    
    NSUInteger meatToRot = 3 * self.meat / 4;
    self.meat -= meatToRot;
    log(meatToRot, @"% meat went bad");
    
    NSUInteger fishToRot = 2 * self.fish / 3;
    self.fish -= fishToRot;
    log(fishToRot, @"% fish went bad");
    
    NSUInteger maizeToRot = self.maize / 10;
    self.maize -= maizeToRot;
    log(fishToRot, @"% maize went bad");
    
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
    
    log(peopleToBeBorn, @"% people were born");
    log(peopleToDie, @"% people died");
    
    self.labor = self.population;
    
    [messages addObject:@""];

    logDelta((NSInteger)self.food - (NSInteger)foodBefore, @"food");
    logDelta((NSInteger)self.population - (NSInteger)populationBefore, @"people");
    
    return messages;
}

+ (instancetype)cityWithWorld:(SCWorld *)world {
    SCCity *city = [[self alloc] init];
    city.population = 100;
    city.meat = 10;
    city.maize = 0;
    city.world = world;
    city.labor = city.population;
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

- (void)loseLabor:(NSUInteger)labor {
    NSAssert(labor <= self.labor, @"That's more labor than you have!");
    self.labor -= labor;
}

+ (NSSet *)keyPathsForValuesAffectingFood {
    return [NSSet setWithObjects:@"meat", @"maize", @"fish", nil];
}

- (NSUInteger)food {
    return self.meat + self.fish + self.maize;
}

@end
