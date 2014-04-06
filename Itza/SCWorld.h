//
//  SCWorld.h
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPosition.h"
#import "SCTile.h"

@interface SCWorld : NSObject

@property (nonatomic, assign, readonly) NSUInteger radius;
- (NSSet *)tiles;
- (SCTile *)tileAt:(SCPosition *)position;
- (void)addTileForPosition:(SCPosition *)position type:(SCTileType)type;
+ (instancetype)worldWithRadius:(NSUInteger)radius;

@end
