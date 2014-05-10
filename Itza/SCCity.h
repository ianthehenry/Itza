//
//  SCCity.h
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCWorld.h"
#import "SCResourceOwner.h"

@interface SCCity : NSObject <SCResourceOwner>

@property (nonatomic, strong, readonly) SCWorld *world;

- (NSArray *)iterate;

+ (instancetype)cityWithWorld:(SCWorld *)world;

- (RACSignal *)quantityOfFood;
- (RACSignal *)quantityOfShelter;
- (void)gainShelter:(NSUInteger)shelter;

@end
