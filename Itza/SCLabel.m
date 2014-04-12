//
//  SCLabel.m
//  Itza
//
//  Created by Ian Henry on 4/12/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCLabel.h"

@implementation SCLabel

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

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize actualSize = size;
    actualSize.width -= (self.insets.left + self.insets.right);
    actualSize.height -= (self.insets.top + self.insets.bottom);
    
    CGSize answer = [super sizeThatFits:actualSize];
    answer.width += (self.insets.left + self.insets.right);
    answer.height += (self.insets.top + self.insets.bottom);
    return answer;
}

- (void)setup {
    @weakify(self);
    [RACObserve(self, insets) subscribeNext:^(id x) {
        @strongify(self);
        [self setNeedsDisplay];
    }];
}

- (CGSize)intrinsicContentSize {
    CGSize size = [super intrinsicContentSize];
    return CGSizeMake(size.width + (self.insets.left + self.insets.right),
                      size.height + (self.insets.top + self.insets.bottom));
}


@end
