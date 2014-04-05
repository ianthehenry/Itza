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
@property (nonatomic, strong) NSDictionary *hexMap;
@property (nonatomic, strong) NSSet *hexes;

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
    RADIUS = 50;
    APOTHEM = 0.5 * sqrtf(3.0f) * RADIUS;
}

- (void)iterate {
    self.turn += 1;
    if (self.population > 0) {
        self.population -= 1;
        self.maize -= 1;
        self.meat -= 1;
    }
}

- (void)viewDidLoad {
    CGFloat width = 30;
    CGFloat height = 20;
    [self makeHexGridWithWidth:width height:height];
    for (SCHex *hex in self.hexes) {
        SCHexView *cell = [[SCHexView alloc] initWithRadius:RADIUS + 0.5];
        cell.center = [self centerForPosition:hex.position];
        [self.scrollView.contentView addSubview:cell];
    }
    self.scrollView.backgroundColor = UIColor.darkGrayColor;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.view layoutIfNeeded];
    self.scrollView.contentSize = [self sizeWithWidth:width height:height];
    [self addWallForConnection:[self.hexMap[[SCPosition x:2 y:3]] connectionWithDirection:SCHexDirectionNorth]];
    [self addWallForConnection:[self.hexMap[[SCPosition x:2 y:3]] connectionWithDirection:SCHexDirectionNorthEast]];
    [self addWallForConnection:[self.hexMap[[SCPosition x:2 y:3]] connectionWithDirection:SCHexDirectionSouthEast]];
    [self addWallForConnection:[self.hexMap[[SCPosition x:2 y:4]] connectionWithDirection:SCHexDirectionNorthEast]];
    [self addWallForConnection:[self.hexMap[[SCPosition x:2 y:4]] connectionWithDirection:SCHexDirectionSouthEast]];
    [self addRoadForConnection:[self.hexMap[[SCPosition x:2 y:4]] connectionWithDirection:SCHexDirectionSouthWest]];
    [self addRoadForConnection:[self.hexMap[[SCPosition x:1 y:4]] connectionWithDirection:SCHexDirectionSouth]];

    // blah blah blah
    
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

- (void)makeHexGridWithWidth:(NSInteger)width height:(NSInteger)height {
    NSMutableDictionary *hexDictionary = [[NSMutableDictionary alloc] init];
    NSMutableSet *hexSet = [[NSMutableSet alloc] init];
    for (NSInteger y = 0; y < height; y++) {
        for (NSInteger x = 0; x < width; x++) {
            SCHex *hex = [[SCHex alloc] init];
            hex.position = [SCPosition x:x y:y];
            [hexSet addObject:hex];
            hexDictionary[hex.position] = hex;
        }
    }
    
    NSArray *directions = @[@(SCHexDirectionNorth), @(SCHexDirectionNorthEast), @(SCHexDirectionSouthEast), @(SCHexDirectionSouth), @(SCHexDirectionSouthWest), @(SCHexDirectionNorthWest)];
    for (SCHex *hex in hexSet) {
        for (NSNumber *directionNumber in directions) {
            SCHexDirection direction = (SCHexDirection)directionNumber.integerValue;
            SCPosition *otherPosition = [hex.position positionInDirection:direction];
            SCHex *otherHex = hexDictionary[otherPosition];
            [hex connectToHex:otherHex inDirection:direction];
        }
    }
    
    self.hexes = hexSet;
    self.hexMap = hexDictionary;
}

- (CGPoint)centerForPosition:(SCPosition *)position {
    CGFloat offset = position.x % 2 == 1 ? APOTHEM : 0;
    return CGPointMake(position.x * RADIUS * 1.5 + RADIUS, offset + position.y * APOTHEM * 2 + APOTHEM);
}

- (CGSize)sizeWithWidth:(NSInteger)width height:(NSInteger)height {
    return CGSizeMake(1.5 * RADIUS * (width + 1) - RADIUS, (height + 1) * APOTHEM * 2 - APOTHEM);
}

- (CGFloat)angleForDirection:(SCHexDirection)direction {
    return -(M_PI * 2.0 / 6.0) * direction;
}

- (void)addRoadForConnection:(SCHexConnection *)connection {
    CGFloat width = RADIUS * 0.5;
    UIView *road = [[UIView alloc] initWithFrame:CGRectMake(0, 0, APOTHEM * 2 + width, width)];
    road.opaque = NO;
    road.layer.cornerRadius = width * 0.5;
    road.layer.masksToBounds = YES;
    road.userInteractionEnabled = NO;
    road.backgroundColor = UIColor.brownColor;
    road.center = CGPointScale(CGPointAdd([self centerForPosition:connection.oneHex.position], [self centerForPosition:connection.anotherHex.position]), 0.5);
    road.transform = CGAffineTransformMakeRotation([self angleForDirection:[connection directionFrom:connection.oneHex]] + M_PI * 0.5);
    [self.scrollView.contentView addSubview:road];
}

- (void)addWallForConnection:(SCHexConnection *)connection {
    CGFloat width = RADIUS * 0.25;
    UIView *wall = [[UIView alloc] initWithFrame:CGRectMake(0, 0, RADIUS + width, width)];
    wall.layer.cornerRadius = width * 0.5;
    wall.layer.masksToBounds = YES;
    wall.userInteractionEnabled = NO;
    wall.backgroundColor = UIColor.grayColor;
    wall.center = CGPointScale(CGPointAdd([self centerForPosition:connection.oneHex.position], [self centerForPosition:connection.anotherHex.position]), 0.5);
    wall.transform = CGAffineTransformMakeRotation([self angleForDirection:[connection directionFrom:connection.oneHex]]);
    [self.scrollView.contentView addSubview:wall];
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

- (IBAction)didTapEndTurnButton {
    NSLog(@"This doesn't do anything");
}

- (UIView *)viewForZoomingInScrollView:(SCScrollView *)scrollView {
    return scrollView.contentView;
}

@end
