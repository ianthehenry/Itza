//
//  SCHelpers.h
//  Itza
//
//  Created by Ian Henry on 2/16/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ABSTRACT { @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)] userInfo:nil]; }

CGPoint CGPointAdd(CGPoint a, CGPoint b);
CGPoint CGPointSubtract(CGPoint a, CGPoint b);
CGPoint CGPointMultiply(CGPoint a, CGPoint b);
CGPoint CGPointScale(CGPoint point, CGFloat scale);
CGPoint CGRectGetCenter(CGRect rect);
CGRect CGRectMakeSize(CGFloat x, CGFloat y, CGSize size);
CGRect CGRectMakeComponents(CGPoint origin, CGSize size);

double usefulrand();

@interface UIScrollView (Helpers)
@property (nonatomic, assign) CGFloat contentInsetBottom, contentInsetTop, contentInsetLeft, contentInsetRight;
@property (nonatomic, assign) CGFloat scrollIndicatorInsetsBottom, scrollIndicatorInsetsTop, scrollIndicatorInsetsLeft, scrollIndicatorInsetsRight;
@end

@interface UIView (Helpers)

@property (nonatomic, readonly) CGPoint boundsCenter;
- (void)removeAllSubviews;
@property (nonatomic, assign) CGFloat frameHeight, frameWidth, frameOriginX, frameOriginY;

@end

@interface RACSignal (Helpers)

- (RACSignal *)index:(NSUInteger)index;
- (RACSignal *)of:(NSDictionary *)dictionary;
- (RACDisposable *)subscribeChanges:(void(^)(id previous, id current))block start:(id)start;

@end

@interface NSObject (Helpers)

- (NSValue *)pointerValue;

@end
