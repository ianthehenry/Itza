//
//  SCViewController.m
//  Itza
//
//  Created by Ian Henry on 4/2/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCViewController.h"
#import "SCScrollView.h"
#import "SCTileView.h"
#import "SCTile.h"
#import "SCPosition.h"

static CGFloat RADIUS;
static CGFloat APOTHEM;

@interface SCViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet SCScrollView *scrollView;
@property (nonatomic, strong) NSMutableSet *tiles;
@property (nonatomic, strong) NSMutableDictionary *tileMap;

@property (strong, nonatomic) IBOutlet UIButton *endTurnButton;
@property (strong, nonatomic) IBOutlet UILabel *populationLabel;

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
    NSInteger radius = 4;
    
    [self makeHexGridWithRadius:radius];
    for (SCTile *tile in self.tiles) {
        SCTileView *cell = [[SCTileView alloc] initWithRadius:RADIUS];
        cell.tile = tile;
        cell.center = [self centerForPosition:tile.hex.position];
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
    
    [[self.endTurnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self iterate];
    }];
}

- (SCTile *)tileAt:(SCPosition *)position {
    return self.tileMap[position];
}

- (void)addTileForPosition:(SCPosition *)position type:(SCTileType)type {
    SCHex *hex = [[SCHex alloc] init];
    hex.position = position;
    SCTile *tile = [[SCTile alloc] initWithHex:hex];
    tile.type = type;
    
    [self.tiles addObject:tile];
    self.tileMap[hex.position] = tile;
    
    static NSArray *directions = nil;
    if (directions == nil) {
        directions = @[@(SCHexDirectionNorth), @(SCHexDirectionNorthEast), @(SCHexDirectionSouthEast), @(SCHexDirectionSouth), @(SCHexDirectionSouthWest), @(SCHexDirectionNorthWest)];
    }
    for (NSNumber *directionNumber in directions) {
        SCHexDirection direction = directionNumber.unsignedIntegerValue;
        [hex connectToHex:[self tileAt:[hex.position positionInDirection:direction]].hex inDirection:direction];
    }

}

- (void)makeHexGridWithRadius:(NSInteger)radius {
    self.tileMap = [[NSMutableDictionary alloc] init];
    self.tiles = [[NSMutableSet alloc] init];

    [self addTileForPosition:[SCPosition x:0 y:0] type:SCTileTypeTemple];
    
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
                [self addTileForPosition:position type:arc4random_uniform(3)];
                position = [position positionInDirection:direction];
            }
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
