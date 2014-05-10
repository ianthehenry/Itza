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

typedef NS_ENUM(NSUInteger, SCSeason) {
    SCSeasonSpring = 0,
    SCSeasonSummer = 1,
    SCSeasonAutumn = 2,
    SCSeasonWinter = 3
};

@interface SCWorld : NSObject

@property (nonatomic, assign, readonly) NSUInteger radius;

@property (nonatomic, readonly) SCSeason season;
@property (nonatomic, assign, readonly) NSUInteger turn;

- (void)iterate;
- (NSSet *)tiles;
- (SCTile *)tileAt:(SCPosition *)position;
- (void)generateRing;
+ (instancetype)worldWithRadius:(NSUInteger)radius;
- (RACSignal *)newTiles;


@end
