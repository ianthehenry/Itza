//
//  SCHelpers.m
//  Itza
//
//  Created by Ian Henry on 2/16/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCHelpers.h"

CGRect CGRectMakeSize(CGFloat x, CGFloat y, CGSize size) {
    return (CGRect) {.origin = (CGPoint) {x, y}, .size = size};
}

CGRect CGRectMakeComponents(CGPoint origin, CGSize size) {
    return (CGRect) {.origin = origin, .size = size};
}

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

CGSize boundingSizeForHexagonWithApothem(CGFloat apothem) {
    return CGSizeMake(radiusForApothem(apothem) * 2, apothem * 2);
}

CGSize boundingSizeForHexagonWithRadius(CGFloat radius) {
    return CGSizeMake(radius * 2, apothemForRadius(radius) * 2);
}

CGFloat apothemForRadius(CGFloat radius) {
    return 0.5 * radius * sqrtf(3.0);
}

CGFloat radiusForApothem(CGFloat apothem) {
    return apothem * 2 / sqrtf(3.0f);
}

CGPoint hexCenter(NSInteger x, NSInteger y, CGFloat apothem) {
    CGFloat radius = radiusForApothem(apothem);
    CGFloat offset = ABS(x) % 2 == 1 ? apothem : 0;
    return CGPointMake(x * radius * 1.47, offset + y * apothem * 2);
}

CGSize boundingSizeForHexagons(CGFloat apothem, NSInteger diameter) {
    CGFloat radius = radiusForApothem(apothem);
    return CGSizeMake(1.47 * radius * (diameter + 1) - radius, diameter * apothem * 2);
}

double usefulrand() {
    return ((double)arc4random() / 0x100000000u);
}

@implementation UIScrollView (Helpers)

- (CGFloat)contentInsetTop { return self.contentInset.top; }
- (CGFloat)contentInsetBottom { return self.contentInset.bottom; }
- (CGFloat)contentInsetLeft { return self.contentInset.left; }
- (CGFloat)contentInsetRight { return self.contentInset.right; }

- (void)setContentInsetTop:(CGFloat)contentInsetTop {
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.top = contentInsetTop;
    self.contentInset = contentInset;
}

- (void)setContentInsetLeft:(CGFloat)contentInsetLeft {
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.left = contentInsetLeft;
    self.contentInset = contentInset;
}

- (void)setContentInsetBottom:(CGFloat)contentInsetBottom {
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.bottom = contentInsetBottom;
    self.contentInset = contentInset;
}

- (void)setContentInsetRight:(CGFloat)contentInsetRight {
    UIEdgeInsets contentInset = self.contentInset;
    contentInset.right = contentInsetRight;
    self.contentInset = contentInset;
}

- (CGFloat)scrollIndicatorInsetsTop { return self.scrollIndicatorInsets.top; }
- (CGFloat)scrollIndicatorInsetsBottom { return self.scrollIndicatorInsets.bottom; }
- (CGFloat)scrollIndicatorInsetsLeft { return self.scrollIndicatorInsets.left; }
- (CGFloat)scrollIndicatorInsetsRight { return self.scrollIndicatorInsets.right; }

- (void)setScrollIndicatorInsetsTop:(CGFloat)scrollIndicatorInsetsTop {
    UIEdgeInsets scrollIndicatorInsets = self.scrollIndicatorInsets;
    scrollIndicatorInsets.top = scrollIndicatorInsetsTop;
    self.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (void)setScrollIndicatorInsetsLeft:(CGFloat)scrollIndicatorInsetsLeft {
    UIEdgeInsets scrollIndicatorInsets = self.scrollIndicatorInsets;
    scrollIndicatorInsets.left = scrollIndicatorInsetsLeft;
    self.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (void)setScrollIndicatorInsetsBottom:(CGFloat)scrollIndicatorInsetsBottom {
    UIEdgeInsets scrollIndicatorInsets = self.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom = scrollIndicatorInsetsBottom;
    self.scrollIndicatorInsets = scrollIndicatorInsets;
}

- (void)setScrollIndicatorInsetsRight:(CGFloat)scrollIndicatorInsetsRight {
    UIEdgeInsets scrollIndicatorInsets = self.scrollIndicatorInsets;
    scrollIndicatorInsets.right = scrollIndicatorInsetsRight;
    self.scrollIndicatorInsets = scrollIndicatorInsets;
}

@end

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

- (void)size:(NSString *)format {
    BOOL anchorLeft = [format rangeOfString:@"h"].location != NSNotFound;
    BOOL anchorRight = [format rangeOfString:@"l"].location != NSNotFound;
    BOOL anchorBottom = [format rangeOfString:@"j"].location != NSNotFound;
    BOOL anchorTop = [format rangeOfString:@"k"].location != NSNotFound;
    
    UIViewAutoresizing mask = 0;
    
    if (anchorLeft && anchorRight) {
        mask |= UIViewAutoresizingFlexibleWidth;
    } else {
        if (anchorLeft) {
            mask |= UIViewAutoresizingFlexibleRightMargin;
        }
        if (anchorRight) {
            mask |= UIViewAutoresizingFlexibleLeftMargin;
        }
    }
    if (anchorBottom && anchorTop) {
        mask |= UIViewAutoresizingFlexibleHeight;
    } else {
        if (anchorBottom) {
            mask |= UIViewAutoresizingFlexibleTopMargin;
        }
        if (anchorTop) {
            mask |= UIViewAutoresizingFlexibleBottomMargin;
        }
    }
    
    self.autoresizingMask = mask;
}

- (void)stackViewsVerticallyCentered:(NSArray *)views {
    CGFloat top = 0;
    for (UIView *view in views) {
        view.frameOriginY = top;
        view.center = CGPointMake(self.boundsCenter.x, view.center.y);
        top += view.frameHeight;
        [self addSubview:view];
    }
    BOOL old = self.autoresizesSubviews;
    self.autoresizesSubviews = NO;
    self.frameHeight = top;
    self.autoresizesSubviews = old;
}

- (void)stackViewsHorizontallyCentered:(NSArray *)views {
    CGFloat left = 0;
    for (UIView *view in views) {
        view.frameOriginX = left;
        view.center = CGPointMake(view.center.x, self.boundsCenter.y);
        left += view.frameWidth;
        [self addSubview:view];
    }
    BOOL old = self.autoresizesSubviews;
    self.autoresizesSubviews = NO;
    self.frameWidth = left;
    self.autoresizesSubviews = old;
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

- (RACSignal *)is:(id)y {
    return [self map:^id(id x) {
        return @([x isEqual:y]);
    }];
}

@end

@implementation NSObject (Helpers)

- (NSValue *)pointerValue {
    return [NSValue valueWithNonretainedObject:self];
}

@end
