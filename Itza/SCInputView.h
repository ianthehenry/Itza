//
//  SCRatioView.h
//  Itza
//
//  Created by Ian Henry on 4/10/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCPassthroughView.h"

@class SCLabel;

@interface SCInputView : SCPassthroughView

@property (strong, nonatomic) UIColor *contentBackgroundColor;
@property (strong, nonatomic) UIColor *contentForegroundColor;

@property (strong, nonatomic, readonly) IBOutlet SCLabel *titleLabel;
@property (strong, nonatomic, readonly) IBOutlet UIButton *button;
@property (strong, nonatomic, readonly) IBOutlet SCLabel *topLabel;
@property (strong, nonatomic, readonly) IBOutlet SCLabel *bottomLabel;
@property (strong, nonatomic, readonly) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic, readonly) IBOutlet UISlider *slider;

@end
