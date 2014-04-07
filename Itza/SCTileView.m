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
        
        RAC(_label, text) = RACObserve(self, tile.foreground.symbol);
        RAC(_label, font) = [RACObserve(self, tile.foreground.fontSize) map:^(NSNumber *size) {
            return [UIFont fontWithName:@"Menlo" size:size.floatValue];
        }];
        RAC(self, fillColor) = RACObserve(self, tile.foreground.tileColor);
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
    }
    return self;
}

@end
