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

CGPoint CGRectGetCenter(CGRect rect) {
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

double usefulrand() {
    return ((double)arc4random() / 0x100000000u);
}

@implementation UIView (Helpers)

- (CGPoint)boundsCenter {
    return CGRectGetCenter(self.bounds);
}

- (void)removeAllSubviews {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (CGFloat)frameHeight { return self.frame.size.height; }
- (CGFloat)frameWidth { return self.frame.size.width; }
- (CGFloat)frameOriginX { return self.frame.origin.x; }
- (CGFloat)frameOriginY { return self.frame.origin.y; }

- (void)setFrameHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (void)setFrameWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (void)setFrameOriginX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (void)setFrameOriginY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

@end

@implementation RACSignal (Helpers)

- (RACSignal *)index:(NSUInteger)index {
    return [self map:^id(id value) {
        return [value objectAtIndexedSubscript:index];
    }];
}

- (RACSignal *)of:(NSDictionary *)dictionary {
    return [self map:^id(id value) {
        return dictionary[value];
    }];
}

- (RACDisposable *)subscribeChanges:(void(^)(id previous, id current))block start:(id)start {
    return [[self combinePreviousWithStart:start reduce:^id(id previous, id current) {
        block(previous, current);
        return nil;
    }] subscribeNext:^(id x) {}];
}

@end

@implementation NSObject (Helpers)

- (NSValue *)pointerValue {
    return [NSValue valueWithNonretainedObject:self];
}

@end