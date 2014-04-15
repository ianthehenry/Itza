//
//  SCCity.h
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCWorld.h"

@interface SCCity : NSObject

@property (nonatomic, assign, readonly) NSUInteger population;
@property (nonatomic, assign, readonly) NSUInteger meat;
@property (nonatomic, assign, readonly) NSUInteger maize;
@property (nonatomic, assign, readonly) NSUInteger fish;
@property (nonatomic, assign, readonly) NSUInteger wood;
@property (nonatomic, assign, readonly) NSUInteger stone;
@property (nonatomic, assign, readonly) NSUInteger labor;
@property (nonatomic, assign, readonly) NSUInteger food;

@property (nonatomic, strong, readonly) SCWorld *world;

- (NSArray *)iterate;

+ (instancetype)cityWithWorld:(SCWorld *)world;

- (void)gainWood:(NSUInteger)wood;
- (void)gainMaize:(NSUInteger)maize;
- (void)gainMeat:(NSUInteger)meat;
- (void)gainFish:(NSUInteger)fish;
- (void)loseLabor:(NSUInteger)labor;

@end
