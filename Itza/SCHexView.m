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
@property (nonatomic, strong) UIBezierPath *path;

@end

static CGFloat lineApothem;
static CGFloat lineRadius;

@implementation SCHexView {
    CGFloat _apothem;
}

+ (void)initialize {
    lineApothem = 4;
    lineRadius = (lineApothem * 2) / sqrtf(3.0f);
}

- (id)initWithRadius:(CGFloat)radius {
    CGFloat apothem = 0.5 * radius * sqrtf(3.0);
    if (self = [super initWithFrame:CGRectMake(0, 0, radius * 2 + lineRadius, apothem * 2 + lineApothem)]) {
        self.opaque = NO;
        _radius = radius;
        _apothem = apothem;
                
        @weakify(self);
        [RACObserve(self, fillColor) subscribeNext:^(id x) {
            @strongify(self);
            [self setNeedsDisplay];
        }];
    }
    return self;
}

- (UIBezierPath *)path {
    if (_path == nil) {
        _path = [UIBezierPath bezierPath];
        
        CGPoint center = self.boundsCenter;
        [_path moveToPoint:CGPointMake(self.radius, 0)];
        for (NSInteger i = 1; i <= 5; i++) {
            CGFloat angle = (2 * M_PI / 6.0f) * i;
            [_path addLineToPoint:CGPointScale(CGPointMake(cosf(angle), sinf(angle)), self.radius)];
        }
        
        [_path closePath];
        [_path applyTransform:CGAffineTransformMakeTranslation(center.x, center.y)];
        _path.lineWidth = lineApothem;
        _path.lineJoinStyle = kCGLineJoinRound;
    }
    return _path;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint relativeToCenter = CGPointSubtract(point, self.boundsCenter);
    CGPoint relativeSquared = CGPointMultiply(relativeToCenter, relativeToCenter);
    return relativeSquared.x + relativeSquared.y < _apothem * _apothem;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (self.selected) {
        [[UIColor colorWithWhite:1 alpha:1] setStroke];
        [self.path stroke];
    }

    [self.fillColor setFill];
    [self.path fill];

    if (self.highlighted) {
        [[UIColor colorWithWhite:0 alpha:0.1] setFill];
        [self.path fill];
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = {
        1.0, 1.0, 1.0, 0.1,
        1.0, 1.0, 1.0, 0.0
    };
    
    CGColorSpaceRef rgbColorspace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, sizeof(locations) / sizeof(*locations));
    
    CGPoint center = self.boundsCenter;
    CGPoint topCenter = CGPointMake(center.x, center.y - _apothem);
    CGPoint bottomCenter = CGPointMake(center.x, center.y + _apothem);
    CGContextSetBlendMode(c, kCGBlendModeSourceAtop);
    CGContextDrawLinearGradient(c, gradient, topCenter, bottomCenter, 0);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(rgbColorspace);
}

@end
