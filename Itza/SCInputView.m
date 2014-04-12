//
//  SCRatioView.m
//  Itza
//
//  Created by Ian Henry on 4/10/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCInputView.h"
#import "SCLabel.h"

@interface SCInputView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic, readwrite) IBOutlet SCLabel *titleLabel;
@property (strong, nonatomic, readwrite) IBOutlet SCLabel *promptLabel;
@property (strong, nonatomic, readwrite) IBOutlet UIButton *button;
@property (strong, nonatomic, readwrite) IBOutlet SCLabel *topLabel;
@property (strong, nonatomic, readwrite) IBOutlet UITextField *textField;
@property (strong, nonatomic, readwrite) IBOutlet SCLabel *bottomLabel;
@property (strong, nonatomic, readwrite) IBOutlet UIButton *cancelButton;

@end

static const CGFloat padding = 10;

@implementation SCInputView

- (void)awakeFromNib {
    self.contentBackgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    self.contentForegroundColor = UIColor.blackColor;
    
    RAC(self.titleLabel, backgroundColor) =
    RAC(self.contentView, backgroundColor) =
    RAC(self.button, backgroundColor) =
    RAC(self.cancelButton, backgroundColor) =
    RAC(self.textField, backgroundColor) =
    RACObserve(self, contentBackgroundColor);
    
    RAC(self.titleLabel, textColor) =
    RAC(self.promptLabel, textColor) =
    RAC(self.topLabel, textColor) =
    RAC(self.bottomLabel, textColor) =
    RAC(self.textField, textColor) =
    RACObserve(self, contentForegroundColor);
    
    self.titleLabel.insets =
    self.topLabel.insets =
    self.bottomLabel.insets = UIEdgeInsetsMake(padding, padding, padding, padding);
    self.promptLabel.insets = UIEdgeInsetsMake(padding, padding, padding, 0);
    
    self.cancelButton.contentEdgeInsets =
    self.button.contentEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
}

@end
