//
//  SCPassthroughView.m
//  Itza
//
//  Created by Ian Henry on 4/8/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCPassthroughView.h"

@implementation SCPassthroughView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *superTest = [super hitTest:point withEvent:event];
    return superTest == self ? nil : superTest;
}

@end
