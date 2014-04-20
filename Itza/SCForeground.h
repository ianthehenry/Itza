//
//  SCForeground.h
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCTile;

@interface SCForeground : NSObject
@property (nonatomic, weak) SCTile *tile;
@end

@interface SCGrass : SCForeground
@end

@interface SCForest : SCForeground
@property (nonatomic, assign, readonly) NSUInteger trees;
@end

@interface SCRiver : SCForeground
@end
