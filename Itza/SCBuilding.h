//
//  SCBuilding.h
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCForeground.h"
#import "SCResourceOwner.h"

@class SCCity;

@interface SCBuilding : SCForeground <SCResourceOwner>

@property (nonatomic, weak, readonly) SCCity *city;
@property (nonatomic, assign, readonly) BOOL isComplete;
@property (nonatomic, strong, readonly) RACSequence *inputRates;
- (instancetype)initWithCity:(SCCity *)city resources:(RACSequence *)resources args:(NSDictionary *)args;

// Protected methods...
- (void)didComplete;

@end
