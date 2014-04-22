//
//  SCBuilding.h
//  Itza
//
//  Created by Ian Henry on 4/19/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCForeground.h"
#import "SCResourceOwner.h"

@interface SCBuilding : SCForeground <SCResourceOwner>

@property (nonatomic, assign, readonly) BOOL isComplete;
@property (nonatomic, strong, readonly) RACSequence *inputRates;
- (instancetype)initWithRequiredResources:(RACSequence *)requiredResources args:(NSDictionary *)args;
- (void)initalize:(NSDictionary *)args;

@end
