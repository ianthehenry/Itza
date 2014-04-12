//
//  SCCornerView.h
//  Itza
//
//  Created by Ian Henry on 4/12/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCCornerView : UIView

@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) UIRectCorner corner;
@property (nonatomic, strong) UIColor *color;

@end
