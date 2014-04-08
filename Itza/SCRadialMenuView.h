//
//  SCRadialMenu.h
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCPassthroughView.h"

@interface SCButtonDescription : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) void(^handler)();

+ (instancetype)buttonWithText:(NSString *)text handler:(void(^)())handler;

@end

@interface SCRadialMenuView : SCPassthroughView

- (id)initWithApothem:(CGFloat)apothem buttons:(NSArray *)buttonDescriptions;

@end
