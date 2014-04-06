//
//  SCHelpers.m
//  Itza
//
//  Created by Ian Henry on 2/16/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCHelpers.h"

CGPoint CGPointAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}

CGPoint CGPointSubtract(CGPoint a, CGPoint b) {
    return CGPointMake(a.x - b.x, a.y - b.y);
}

CGPoint CGPointMultiply(CGPoint a, CGPoint b) {
    return CGPointMake(a.x * b.x, a.y * b.y);
}

CGPoint CGPointScale(CGPoint point, CGFloat scale) {
    return CGPointMake(point.x * scale, point.y * scale);
}

double usefulrand() {
    return ((double)arc4random() / 0x100000000u);
}

@implementation UIView (Helpers)

- (CGPoint)localCenter {
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

@end

@implementation RACSignal (Helpers)

- (RACSignal *)index:(NSUInteger)index {
    return [self map:^id(id value) {
        return [value objectAtIndexedSubscript:index];
    }];
}

@end
