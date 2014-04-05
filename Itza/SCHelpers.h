//
//  SCHelpers.h
//  Itza
//
//  Created by Ian Henry on 2/16/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

CGPoint CGPointAdd(CGPoint a, CGPoint b);
CGPoint CGPointSubtract(CGPoint a, CGPoint b);
CGPoint CGPointMultiply(CGPoint a, CGPoint b);
CGPoint CGPointScale(CGPoint point, CGFloat scale);
double usefulrand();

@interface UIView (Helpers)

- (CGPoint)localCenter;

@end