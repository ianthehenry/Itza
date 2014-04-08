//
//  SCRadialMenu.m
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCRadialMenuView.h"
#import "SCPosition.h"

@implementation SCButtonDescription

+ (instancetype)buttonWithText:(NSString *)text handler:(void(^)())handler {
    SCButtonDescription *buttonDescription = [[self alloc] init];
    buttonDescription.text = text;
    buttonDescription.handler = handler;
    return buttonDescription;
}

@end

@implementation SCRadialMenuView

- (id)initWithApothem:(CGFloat)apothem buttons:(NSArray *)buttonDescriptions {
    CGFloat centerDistance = apothem * 3;
    CGFloat buttonRadius = apothem;
    CGFloat outerCircleRadius = centerDistance + buttonRadius;
    
    if (self = [super initWithFrame:CGRectMake(0, 0, outerCircleRadius * 2, outerCircleRadius * 2)]) {
        CGFloat angleStep = M_PI / 3.0;
        CGFloat startAngle = (-M_PI * 0.5) - (angleStep * (buttonDescriptions.count - 1) * 0.5);
        NSInteger i = 0;
        
        for (SCButtonDescription *buttonDescription in buttonDescriptions) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = UIColor.whiteColor;
            button.frameWidth =
            button.frameHeight = buttonRadius * 2;
            [button setTitle:buttonDescription.text forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont fontWithName:@"Menlo" size:13];
            [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            button.layer.cornerRadius = buttonRadius;
            
            [[button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                buttonDescription.handler();
            }];
            
            CGFloat angle = startAngle + angleStep * i;
            
            button.center = CGPointAdd(self.boundsCenter, CGPointMake(cosf(angle) * centerDistance,
                                                                      sinf(angle) * centerDistance));
            [self addSubview:button];
            i++;
        }
    }
    return self;    
}

@end
