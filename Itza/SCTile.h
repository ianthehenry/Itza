//
//  SCTile.h
//  Itza
//
//  Created by Ian Henry on 4/6/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCPosition.h"
#import "SCForeground.h"

@interface SCTile : NSObject

- (id)initWithHex:(SCHex *)hex;

@property (nonatomic, strong, readonly) SCHex *hex;
@property (nonatomic, strong) SCForeground *foreground;

@end
