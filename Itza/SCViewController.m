//
//  SCViewController.m
//  Itza
//
//  Created by Ian Henry on 4/2/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCViewController.h"
#import "SCScrollView.h"
#import "SCHexView.h"
#import "SCPosition.h"

static CGFloat RADIUS;
static CGFloat APOTHEM;

@interface SCViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet SCScrollView *scrollView;
@property (nonatomic, strong) NSMutableSet *hexes;
@property (nonatomic, strong) NSMutableDictionary *hexMap;

@property (strong, nonatomic) IBOutlet UIButton *endTurnButton;
@property (strong, nonatomic) IBOutlet UILabel *populationLabel;
@property (strong, nonatomic) IBOutlet UILabel *turnLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;

@property (nonatomic, assign) NSUInteger turn;
@property (nonatomic, assign) NSUInteger population;
@property (nonatomic, assign) NSUInteger meat;
@property (nonatomic, assign) NSUInteger maize;

@end

@implementation SCViewController

+ (void)initialize {
    APOTHEM = 22;
    RADIUS = APOTHEM / 0.5 / sqrtf(3.0f);
}

- (void)iterate {
    self.turn += 1;
    if (self.population > 0) {
        self.population -= 1;
        self.maize -= 1;
        self.meat -= 1;
    }
}

- (void)setupGrid {
    NSInteger radius = 10;
    
    [self makeHexGridWithRadius:radius];
    for (SCHex *hex in self.hexes) {
        SCHexView *cell = [[SCHexView alloc] initWithRadius:RADIUS];
        cell.center = [self centerForPosition:hex.position];
        [self.scrollView.contentView addSubview:cell];
    }
    self.scrollView.backgroundColor = UIColor.darkGrayColor;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.view layoutIfNeeded];
    self.scrollView.contentSize = [self sizeWithRadius:radius];
}

- (void)viewDidLoad {
    [self setupGrid];
    
    self.population = 100;
    self.maize = 100;
    self.meat = 100;
    
    RAC(self, title) = [RACObserve(self, turn) map:^id(NSNumber *turn) {
        return [NSString stringWithFormat:@"turn %@", turn];
    }];
    
    RAC(self.populationLabel, text) =
    [RACSignal combineLatest:@[RACObserve(self, population),
                               RACObserve(self, meat),
                               RACObserve(self, maize)]
                      reduce:^(NSNumber *population, NSNumber *meat, NSNumber *maize) {
                          return [NSString stringWithFormat:@"%@ population\n%@ meat\n%@ maize", population, meat, maize];
                      }];
    
    [[[self.slider rac_signalForControlEvents:UIControlEventValueChanged] map:^(UISlider *slider) {
        return @(slider.value);
    }] subscribeNext:^(id x) {
        NSLog(@"%@", x);
    }];
    
    [[self.endTurnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self iterate];
    }];
}

- (void)addHexForPosition:(SCPosition *)position {
    SCHex *hex = [[SCHex alloc] init];
    hex.position = position;
    [self.hexes addObject:hex];
    self.hexMap[hex.position] = hex;
}

- (void)makeHexGridWithRadius:(NSInteger)radius {
    self.hexMap = [[NSMutableDictionary alloc] init];
    self.hexes = [[NSMutableSet alloc] init];

    [self addHexForPosition:[SCPosition x:0 y:0]];
    
    for (NSInteger distance = 1; distance <= radius; distance++) {
        SCPosition *position = [SCPosition x:0 y:-distance];
        
        for (NSNumber *directionNumber in @[@(SCHexDirectionSouthWest),
                                            @(SCHexDirectionSouth),
                                            @(SCHexDirectionSouthEast),
                                            @(SCHexDirectionNorthEast),
                                            @(SCHexDirectionNorth),
                                            @(SCHexDirectionNorthWest)]) {
            SCHexDirection direction = directionNumber.unsignedIntegerValue;
            for (NSInteger i = 0; i < distance; i++) {
                [self addHexForPosition:position];
                position = [position positionInDirection:direction];
            }
        }
    }
    
    NSArray *directions = @[@(SCHexDirectionNorth), @(SCHexDirectionNorthEast), @(SCHexDirectionSouthEast), @(SCHexDirectionSouth), @(SCHexDirectionSouthWest), @(SCHexDirectionNorthWest)];
    for (SCHex *hex in self.hexes) {
        for (NSNumber *directionNumber in directions) {
            SCHexDirection direction = (SCHexDirection)directionNumber.integerValue;
            SCPosition *otherPosition = [hex.position positionInDirection:direction];
            SCHex *otherHex = self.hexMap[otherPosition];
            [hex connectToHex:otherHex inDirection:direction];
        }
    }
}

- (CGPoint)centerForPosition:(SCPosition *)position {
    CGFloat offset = ABS(position.x) % 2 == 1 ? APOTHEM : 0;
    return CGPointMake(position.x * RADIUS * 1.5, offset + position.y * APOTHEM * 2);
}

- (CGSize)sizeWithRadius:(NSInteger)radius {
    NSInteger diameter = 2 * radius + 1;
    return CGSizeMake(1.5 * RADIUS * (diameter + 1) - RADIUS, diameter * APOTHEM * 2);
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    CGFloat velocity = scrollView.pinchGestureRecognizer.velocity;
    if (ABS(velocity) < 1) {
        return;
    }
    [UIView animateWithDuration:0.25 animations:^{
        scrollView.zoomScale = scrollView.zoomScale + velocity * 0.25;
    }];
}

- (UIView *)viewForZoomingInScrollView:(SCScrollView *)scrollView {
    return scrollView.contentView;
}

@end
