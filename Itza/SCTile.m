//
//  SCTile.m
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCTile.h"

@interface SCTile ()

@property (nonatomic, strong, readwrite) SCHex *hex;

@end

@implementation SCTile

- (id)initWithHex:(SCHex *)hex {
    if (self = [super init]) {
        _hex = hex;
    }
    return self;
}

@end
