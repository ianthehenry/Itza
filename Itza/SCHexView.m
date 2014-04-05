//
//  SCHexCell.m
//  Itza
//
//  Created by Ian Henry on 2/16/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCHexView.h"

@interface SCHexView ()

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat hue;
@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation SCHexView {
    CGFloat _apothem;
}

- (id)initWithRadius:(CGFloat)radius {
    if (self = [super initWithFrame:CGRectMake(0, 0, radius * 2, radius * 2)]) {
        self.opaque = NO;
        _radius = radius;
        _apothem = 0.5 * radius * sqrtf(3.0);
        _hue = usefulrand();
        @weakify(self);
        [RACObserve(self, hue) subscribeNext:^(id x) {
            @strongify(self);
            [self setNeedsDisplay];
        }];
    }
    return self;
}

- (UIBezierPath *)path {
    if (_path == nil) {
        _path = [UIBezierPath bezierPath];
        
        CGPoint center = self.localCenter;
        [_path moveToPoint:CGPointMake(self.radius, 0)];
        for (NSInteger i = 1; i <= 5; i++) {
            CGFloat angle = (2 * M_PI / 6.0f) * i;
            [_path addLineToPoint:CGPointScale(CGPointMake(cosf(angle), sinf(angle)), self.radius)];
        }
        
        [_path closePath];
        [_path applyTransform:CGAffineTransformMakeTranslation(center.x, center.y)];
    }
    return _path;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint relativeToCenter = CGPointSubtract(point, self.localCenter);
    CGPoint relativeSquared = CGPointMultiply(relativeToCenter, relativeToCenter);
    return relativeSquared.x + relativeSquared.y < _apothem * _apothem;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (UIColor *)fillColor {
    if (self.isHighlighted) {
        return [UIColor colorWithHue:self.hue saturation:0.9 brightness:0.5 alpha:1.0];
    } else {
        return [UIColor colorWithHue:self.hue saturation:0.9 brightness:0.6 alpha:1.0];
    }
}

- (void)drawRect:(CGRect)rect {
    [self.fillColor setFill];
    [self.path fill];
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 0.1,
        1.0, 1.0, 1.0, 0.0
    };
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, sizeof(locations) / sizeof(*locations));
    
    CGPoint center = self.localCenter;
    CGPoint topCenter = CGPointMake(center.x, center.y - _apothem);
    CGPoint bottomCenter = CGPointMake(center.x, center.y + _apothem);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextDrawLinearGradient(c, gradient, topCenter, bottomCenter, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace);
}

@end
