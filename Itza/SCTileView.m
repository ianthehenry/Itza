//
//  SCTileView.m
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCTileView.h"
#import "SCTile.h"

@interface SCTileView ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation SCTileView

- (id)initWithRadius:(CGFloat)radius {
    if (self = [super initWithRadius:radius]) {
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        static NSDictionary *map = nil;
        if (map == nil) {
            map = @{@(SCTileTypeForest): RACTuplePack(@"♣", @26, [UIColor colorWithHue:0.33 saturation:0.9 brightness:0.6 alpha:1.0]),
                    @(SCTileTypeGrass): RACTuplePack(@"", @0, [UIColor colorWithHue:0.33 saturation:0.9 brightness:0.6 alpha:1.0]),
                    @(SCTileTypeWater): RACTuplePack(@"", @0, [UIColor colorWithHue:0.66 saturation:0.9 brightness:0.6 alpha:1.0]),
                    @(SCTileTypeTemple): RACTuplePack(@"⎈", @40, [UIColor colorWithHue:0.15 saturation:0.9 brightness:0.6 alpha:1.0])};
        }
        RACSignal *result = [[RACObserve(self, tile.type) skip:1] map:^(NSNumber *type) {
            return map[type];
        }];
        
        RAC(_label, text) = [result index:0];
        RAC(_label, font) = [[result index:1] map:^(NSNumber *size) {
            return [UIFont fontWithName:@"Menlo" size:size.floatValue];
        }];
        RAC(self, fillColor) = [result index:2];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

@end
