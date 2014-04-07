//
//  SCForeground.m
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCForeground.h"

@implementation SCForeground

- (UIColor *)tileColor {
    return [UIColor colorWithHue:0.33 saturation:0.9 brightness:0.6 alpha:1];
}

- (NSString *)symbol {
    return @"";
}

- (CGFloat)fontSize {
    return 20;
}

- (NSString *)name ABSTRACT

@end

@implementation SCGrass

- (NSString *)name {
    return @"Grass";
}

@end

@implementation SCForest

- (NSString *)name {
    return @"Forest";
}

- (NSString *)symbol {
    return @"♣";
}

@end

@implementation SCRiver

- (NSString *)name {
    return @"River";
}

- (UIColor *)tileColor {
    return [UIColor colorWithHue:0.66 saturation:0.9 brightness:0.6 alpha:1];
}

@end

@implementation SCTemple

- (NSString *)name {
    return @"Temple";
}

- (NSString *)symbol {
    return @"*";
}

- (UIColor *)tileColor {
    return [UIColor colorWithHue:0.15 saturation:1.0 brightness:0.7 alpha:1];
}

- (CGFloat)fontSize {
    return 30;
}

@end
