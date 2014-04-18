//
//  SCInputView.h
//  Itza
//
//  Created by Ian Henry on 4/10/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCInputView : UIView

@property (strong, nonatomic, readonly) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic, readonly) IBOutlet UIButton *button;
@property (strong, nonatomic, readonly) IBOutlet UILabel *topLabel;
@property (strong, nonatomic, readonly) IBOutlet UILabel *bottomLabel;
@property (strong, nonatomic, readonly) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic, readonly) IBOutlet UISlider *slider;

@end
