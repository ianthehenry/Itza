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

- (void)iterate {}

@end

@implementation SCGrass
@end

@implementation SCRiver

+ (NSUInteger)baseLaborToFish {
    return 3;
}

+ (NSUInteger)baseMinFish {
    return 0;
}

+ (NSUInteger)baseMaxFish {
    return 5;
}

@end
