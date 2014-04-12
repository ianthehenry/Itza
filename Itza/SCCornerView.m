//
//  SCCornerView.m
//  Itza
//
//  Created by Ian Henry on 4/12/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCCornerView.h"

@implementation SCCornerView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = UIColor.clearColor;
    self.opaque = NO;
    @weakify(self);
    [[RACSignal merge:@[RACObserve(self, radius), RACObserve(self, color), RACObserve(self, corner)]] subscribeNext:^(id x) {
        @strongify(self);
        [self setNeedsUpdateConstraints];
        [self setNeedsDisplay];
    }];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(self.radius, self.radius);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGPoint start, origin, corner;
    NSInteger arc;
    CGFloat radius = self.radius;
    switch (self.corner) {
        case UIRectCornerBottomRight:
            arc = 0;
            start = CGPointMake(radius, 0);
            origin = CGPointMake(0, 0);
            corner = CGPointMake(radius, radius);
            break;
        case UIRectCornerBottomLeft:
            arc = 1;
            start = CGPointMake(0, radius);
            origin = CGPointMake(radius, 0);
            corner = CGPointMake(0, radius);
            break;
        case UIRectCornerTopLeft:
            arc = 2;
            start = CGPointMake(0, radius);
            origin = CGPointMake(radius, radius);
            corner = CGPointMake(0, 0);
            break;
        case UIRectCornerTopRight:
            arc = 3;
            start = CGPointMake(0, 0);
            origin = CGPointMake(0, radius);
            corner = CGPointMake(radius, 0);
            break;
        default:
            NSAssert(NO, @"Can't specify more than one corner!");
            break;
    }
    
    [self.color setFill];
    
    CGContextMoveToPoint(c, start.x, start.y);
    CGContextAddArc(c, origin.x, origin.y, radius, M_PI * 0.5 * arc, M_PI * 0.5 * (arc + 1), NO);
    CGContextAddLineToPoint(c, corner.x, corner.y);
    CGContextClosePath(c);
    CGContextFillPath(c);
}

@end
