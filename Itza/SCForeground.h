//
//  SCForeground.h
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCResourceOwner.h"

@class SCTile;

@interface SCForeground : NSObject

- (id)initWithArgs:(NSDictionary *)args;
@property (nonatomic, weak) SCTile *tile;
- (void)iterate;

// protected!
- (void)initalize:(NSDictionary *)args;

@end

@interface SCGrass : SCForeground
@end

@interface SCForest : SCForeground <SCResourceOwner>

+ (NSUInteger)baseLaborPerTree;
+ (NSUInteger)baseWoodPerTree;

@end

@interface SCRiver : SCForeground

+ (NSUInteger)baseLaborToFish;
+ (NSUInteger)baseMinFish;
+ (NSUInteger)baseMaxFish;

@end
