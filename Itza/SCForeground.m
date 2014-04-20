//
//  SCForeground.m
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCForeground.h"
#import "SCTile.h"

@implementation SCForeground
@end

@implementation SCGrass
@end

@interface SCForest ()

@property (nonatomic, assign, readwrite) NSUInteger wood;
- (void)loseWood:(NSUInteger)wood;

@end

@implementation SCForest

- (instancetype)initWithWood:(NSUInteger)wood {
    if (self = [super init]) {
        _wood = wood;
    }
    return self;
}

- (void)loseWood:(NSUInteger)wood {
    NSAssert(wood <= self.wood, @"Not enough wood!");
    self.wood -= wood;
    if (self.wood == 0) {
        self.tile.foreground = [[SCGrass alloc] init];
    }
}

@end

@implementation SCRiver
@end
