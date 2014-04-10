//
//  SCRatioView.m
//  Itza
//
//  Created by Ian Henry on 4/10/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCInputView.h"

@interface SCInputView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *promptLabel;
@property (strong, nonatomic, readwrite) IBOutlet UIButton *button;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *topLabel;
@property (strong, nonatomic, readwrite) IBOutlet UITextField *textField;
@property (strong, nonatomic, readwrite) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic, readwrite) IBOutlet UIButton *cancelButton;

@end

@implementation SCInputView {
    BOOL _initialized;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // because i'm sick of overriding every fucking init method
    if (_initialized) {
        return;
    }
    _initialized = YES;
    self.contentBackgroundColor = [UIColor colorWithWhite:1 alpha:0.75];
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
}

@end
