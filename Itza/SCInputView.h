//
//  SCRatioView.h
//  Itza
//
//  Created by Ian Henry on 4/10/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCPassthroughView.h"

@interface SCInputView : SCPassthroughView

@property (strong, nonatomic) UIColor *contentBackgroundColor;
@property (strong, nonatomic) UIColor *contentForegroundColor;

@property (strong, nonatomic, readonly) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic, readonly) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic, readonly) IBOutlet UIButton *button;
@property (strong, nonatomic, readonly) IBOutlet UILabel *topLabel;
@property (strong, nonatomic, readonly) IBOutlet UITextField *textField;
@property (strong, nonatomic, readonly) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic, readonly) IBOutlet UIButton *cancelButton;

@end
