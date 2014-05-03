//
//  SCCity.m
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCCity.h"
#import "SCBuildings.h"

@interface SCCity ()

@property (nonatomic, strong, readwrite) SCWorld *world;

@end

@implementation SCCity

- (NSArray *)iterate {
    NSMutableArray *messages = [[NSMutableArray alloc] init];
    
    void (^log)(NSUInteger number, NSString *format) = ^(NSUInteger number, NSString *format) {
        if (number > 0) {
            NSString *numberString = [NSString stringWithFormat:@"%u", (unsigned int)number];
            [messages addObject:[format stringByReplacingOccurrencesOfString:@"%" withString:numberString]];
        }
    };
    void (^logDelta)(NSInteger number, NSString *format) = ^(NSInteger number, NSString *name) {
        NSString *numberString = [NSString stringWithFormat:@"%u", (unsigned int)ABS(number)];
        NSString *signString = number < 0 ? @"-" : @"+";
        [messages addObject:[NSString stringWithFormat:@"%@%@ %@", signString, numberString, name]];
    };
    
    NSUInteger populationBefore = [self currentQuantityOfResource:SCResourcePeople];
    
    NSUInteger hunger = populationBefore;
    
    NSUInteger meatToEat = MIN(hunger, [self currentQuantityOfResource:SCResourceMeat]);
    [self loseQuantity:meatToEat ofResource:SCResourceMeat];
    hunger -= meatToEat;
    log(meatToEat, @"% meat eaten");
    
    NSUInteger fishToEat = MIN(hunger, [self currentQuantityOfResource:SCResourceFish]);
    [self loseQuantity:fishToEat ofResource:SCResourceFish];
    hunger -= fishToEat;
    log(fishToEat, @"% fish eaten");
    
    NSUInteger maizeToEat = MIN(hunger, [self currentQuantityOfResource:SCResourceMaize]);
    [self loseQuantity:maizeToEat ofResource:SCResourceMaize];
    hunger -= maizeToEat;
    log(maizeToEat, @"% maize eaten");
    
    log(hunger, @"% people starved");
    [self loseQuantity:hunger ofResource:SCResourcePeople];
    
    NSUInteger meatToRot = 3 * [self currentQuantityOfResource:SCResourceMeat] / 4;
    [self loseQuantity:meatToRot ofResource:SCResourceMeat];
    log(meatToRot, @"% meat went bad");
    
    NSUInteger fishToRot = 2 * [self currentQuantityOfResource:SCResourceFish] / 3;
    [self loseQuantity:fishToRot ofResource:SCResourceFish];
    log(fishToRot, @"% fish went bad");
    
    NSUInteger maizeToRot = [self currentQuantityOfResource:SCResourceMaize] / 10;
    [self loseQuantity:maizeToRot ofResource:SCResourceMaize];
    log(fishToRot, @"% maize went bad");
    
    NSUInteger populationBeforeTheNaturalCourseOfLifeAndDeath = [self currentQuantityOfResource:SCResourcePeople];
    NSUInteger peopleToBeBorn = 0;
    for (NSUInteger i = 0; i < populationBeforeTheNaturalCourseOfLifeAndDeath / 10; i++) {
        peopleToBeBorn += arc4random_uniform(4);
    }
    
    NSUInteger peopleToDie = 0;
    for (NSUInteger i = 0; i < populationBeforeTheNaturalCourseOfLifeAndDeath / 10; i++) {
        peopleToDie += arc4random_uniform(3);
    }
    
    [self gainQuantity:peopleToBeBorn ofResource:SCResourcePeople];
    [self loseQuantity:peopleToDie ofResource:SCResourcePeople];
    
    log(peopleToBeBorn, @"% people were born");
    log(peopleToDie, @"% people died");
    
    [self setQuantity:MIN([self currentQuantityOfResource:SCResourcePeople], self.shelter) ofResource:SCResourceLabor];
    
    [messages addObject:@""];

    logDelta((NSInteger)[self currentQuantityOfResource:SCResourcePeople] - (NSInteger)populationBefore, @"people");
    
    return messages;
}

- (NSUInteger)shelter {
    return [[[[[self.world.tiles.rac_sequence map:^(SCTile *tile) {
        return tile.foreground;
    }] filter:^BOOL(SCForeground *foreground) {
        return [foreground isKindOfClass:SCHouse.class];
    }] map:^(SCHouse *house) {
        return @(house.shelter);
    }] foldLeftWithStart:@0 reduce:^(NSNumber *accumulator, NSNumber *value) {
        return @(accumulator.unsignedIntegerValue + value.unsignedIntegerValue);
    }] unsignedIntegerValue];
}

+ (instancetype)cityWithWorld:(SCWorld *)world {
    SCCity *city = [[self alloc] init];
    city.world = world;
    [city gainQuantity:100 ofResource:SCResourceLabor];
    [city gainQuantity:100 ofResource:SCResourceMeat];
    [city gainQuantity:100 ofResource:SCResourceMaize];
    [city gainQuantity:100 ofResource:SCResourceWood];
    [city gainQuantity:100 ofResource:SCResourceFish];
    [city gainQuantity:100 ofResource:SCResourceStone];
    [city gainQuantity:100 ofResource:SCResourcePeople];
    return city;
}

- (RACSignal *)quantityOfFood {
    return [[RACSignal combineLatest:@[[self quantityOfResource:SCResourceMaize],
                                       [self quantityOfResource:SCResourceMeat],
                                       [self quantityOfResource:SCResourceFish]]] sum];
}

@end
