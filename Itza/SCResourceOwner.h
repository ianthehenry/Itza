//
//  SCResourceOwner.h
//  Itza
//
//  Created by Ian Henry on 4/20/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libextobjc/EXTConcreteProtocol.h>
#import "SCResource.h"

@protocol SCResourceOwner <NSObject>

@concrete

- (void)setQuantity:(NSUInteger)quantity ofResource:(SCResource)resource;
- (void)loseQuantity:(NSUInteger)quantity ofResource:(SCResource)resource;
- (void)gainQuantity:(NSUInteger)quantity ofResource:(SCResource)resource;

- (void)setCapacity:(NSUInteger)capacity forResource:(SCResource)resource;

- (NSUInteger)currentQuantityOfResource:(SCResource)resource;
- (NSUInteger)currentCapacityForResource:(SCResource)resource;
- (NSUInteger)currentUnusedCapacityForResource:(SCResource)resource;

- (RACSignal *)quantityOfResource:(SCResource)resource;
- (RACSignal *)capacityForResource:(SCResource)resource;
- (RACSignal *)unusedCapacityForResource:(SCResource)resource;

@end
