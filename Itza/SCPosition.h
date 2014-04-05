//
//  SCPosition.h
//  Itza
//
//  Created by Ian Henry on 2/17/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SCHexDirection)  {
    SCHexDirectionNorth = 0,
    SCHexDirectionNorthEast = 1,
    SCHexDirectionSouthEast = 2,
    SCHexDirectionSouth = 3,
    SCHexDirectionSouthWest = 4,
    SCHexDirectionNorthWest = 5
};

SCHexDirection SCHexDirectionGetOpposite(SCHexDirection direction);

@class SCHexConnection;

@interface SCPosition : NSObject <NSCopying>

@property (nonatomic, readonly, assign) NSInteger x, y;
+ (instancetype)x:(NSInteger)x y:(NSInteger)y;
- (instancetype)positionInDirection:(SCHexDirection)direction;

@end

// -------------------------------------

@interface SCHex : NSObject

@property (nonatomic, copy) SCPosition *position;
- (SCHexConnection *)connectionWithDirection:(SCHexDirection)direction;
- (void)connectToHex:(SCHex *)otherHex inDirection:(SCHexDirection)direction;

@end

// -------------------------------------

@interface SCHexConnection : NSObject

@property (nonatomic, weak) SCHex *oneHex;
@property (nonatomic, weak) SCHex *anotherHex;
- (SCHex *)otherHex:(SCHex *)hex;
- (SCHexDirection)directionFrom:(SCHex *)hex;
- (void)setOtherHex:(SCHex *)hex;

@end

