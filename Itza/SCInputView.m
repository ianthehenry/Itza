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
@property (strong, nonatomic, readwrite) IBOutlet UIButton *button;
@property (strong, nonatomic, readwrite) IBOutlet SCLabel *topLabel;
@property (strong, nonatomic, readwrite) IBOutlet SCLabel *bottomLabel;
@property (strong, nonatomic, readwrite) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic, readwrite) IBOutlet UISlider *slider;

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
    RACObserve(self, contentBackgroundColor);
    
    RAC(self.titleLabel, textColor) =
    RAC(self.topLabel, textColor) =
    RAC(self.bottomLabel, textColor) =
    RACObserve(self, contentForegroundColor);
    
    self.titleLabel.insets =
    self.topLabel.insets =
    self.bottomLabel.insets = UIEdgeInsetsMake(padding, padding, padding, padding);
    
    self.cancelButton.contentEdgeInsets =
    self.button.contentEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
}

@end
