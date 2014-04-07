//
//  SCForeground.h
//  Itza
//
//  Created by Ian Henry on 4/7/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCForeground : NSObject

- (UIColor *)tileColor;
- (NSString *)symbol;
- (NSString *)name;
- (CGFloat)fontSize;

@end

@interface SCGrass : SCForeground

@end

@interface SCForest : SCForeground

@end

@interface SCTemple : SCForeground

@end

@interface SCRiver : SCForeground

@end
