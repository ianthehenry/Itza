//
//  SCScrollView.m
//  Itza
//
//  Created by Ian Henry on 2/16/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCScrollView.h"

@interface SCScrollView ()

@property (nonatomic, strong, readwrite) UIView *contentView;

@end

@implementation SCScrollView

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        CGRect rect = CGRectZero;
        rect.size = self.contentSize;
        _contentView = [[UIView alloc] initWithFrame:rect];
        _contentView.autoresizesSubviews = NO;
        [self addSubview:_contentView];
        
        self.delaysContentTouches = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        [self updateZoomScale];
    }
    return self;
}

- (CGSize)actualContentSize {
    return CGSizeMake(self.contentSize.width / self.zoomScale, self.contentSize.height / self.zoomScale);
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    if (self.zoomScale == 1) {
        self.contentView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
        [self updateZoomScale];
    }
}

- (void)updateZoomScale {
    self.minimumZoomScale = MIN(1, MIN(CGRectGetWidth(self.bounds) / self.actualContentSize.width, CGRectGetHeight(self.bounds) / self.actualContentSize.height));
    if (self.zoomScale < self.minimumZoomScale) {
        self.zoomScale = self.minimumZoomScale;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateZoomScale];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    return YES;
}

@end
