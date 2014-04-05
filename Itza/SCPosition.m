//
//  SCPosition.m
//  Itza
//
//  Created by Ian Henry on 2/17/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCPosition.h"

SCHexDirection SCHexDirectionGetOpposite(SCHexDirection direction) {
    return (SCHexDirection)((direction + 3) % 6);
}

@interface SCPosition ()

@property (nonatomic, readwrite, assign) NSInteger x, y;

@end

@implementation SCPosition

- (instancetype)copyWithZone:(NSZone *)zone {
    SCPosition *copy = [[[self class] allocWithZone:zone] init];
    copy.x = self.x;
    copy.y = self.y;
    return copy;
}

+ (instancetype)x:(NSInteger)x y:(NSInteger)y {
    SCPosition *position = [[SCPosition alloc] init];
    position.x = x;
    position.y = y;
    return position;
}

- (BOOL)isEqual:(SCPosition *)other {
    return self.x == other.x && self.y == other.y;
}

- (NSUInteger)hash {
    return self.x * 10024 + self.y;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"SCHexPosition(%ld, %ld)", (long)self.x, (long)self.y];
}

- (instancetype)positionInDirection:(SCHexDirection)direction {
    BOOL even = self.x % 2 == 0;
    switch (direction) {
        case SCHexDirectionNorth:     return [SCPosition x:self.x y:self.y - 1];
        case SCHexDirectionNorthEast: return [SCPosition x:self.x + 1 y:(even ? self.y - 1 : self.y)];
        case SCHexDirectionSouthEast: return [SCPosition x:self.x + 1 y:(even ? self.y : self.y + 1)];
        case SCHexDirectionSouth:     return [SCPosition x:self.x y:self.y + 1];
        case SCHexDirectionSouthWest: return [SCPosition x:self.x - 1 y:(even ? self.y : self.y + 1)];
        case SCHexDirectionNorthWest: return [SCPosition x:self.x - 1 y:(even ? self.y - 1 : self.y)];
    }
}

@end

// -------------------------------------

@interface SCHex ()
@property (nonatomic, retain) NSMutableDictionary *connections;
@end

@implementation SCHex

- (id)init {
    if (self = [super init]) {
        _connections = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)connectToHex:(SCHex *)otherHex inDirection:(SCHexDirection)direction {
    assert(self.connections[@(direction)] == nil);
    SCHexConnection *connection = otherHex.connections[@(SCHexDirectionGetOpposite(direction))];
    if (connection == nil) {
        connection = [[SCHexConnection alloc] init];
        connection.oneHex = self;
        connection.anotherHex = otherHex;
    } else {
        [connection setOtherHex:self];
    }
    self.connections[@(direction)] = connection;
}

- (SCHexConnection *)connectionWithDirection:(SCHexDirection)direction {
    SCHexConnection *connection = self.connections[@(direction)];
    assert(connection);
    return connection;
}

@end

// -------------------------------------

@implementation SCHexConnection

- (SCHex *)otherHex:(SCHex *)hex {
    return hex == self.oneHex ? self.anotherHex : self.oneHex;
}

- (void)setOtherHex:(SCHex *)hex {
    if (self.oneHex == nil) {
        self.oneHex = hex;
    } else {
        assert(self.anotherHex == nil || self.anotherHex == hex);
        self.anotherHex = hex;
    }
}

- (SCHexDirection)directionFrom:(SCHex *)hex {
    SCHex *otherHex = [self otherHex:hex];
    if (otherHex.position.x < hex.position.x) {
        return (hex.position.y == otherHex.position.y) ^ (hex.position.x % 2 == 0) ?
        SCHexDirectionSouthWest : SCHexDirectionNorthWest;
    } else if (otherHex.position.x > hex.position.x) {
        return (hex.position.y == otherHex.position.y) ^ (hex.position.x % 2 == 0) ?
        SCHexDirectionSouthEast : SCHexDirectionNorthEast;
    } else {
        return hex.position.y < otherHex.position.y ? SCHexDirectionSouth : SCHexDirectionNorth;
    }
}

@end