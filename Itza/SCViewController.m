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
@property (nonatomic, strong) NSMutableDictionary *tileForLocation;
@property (nonatomic, strong) NSMutableDictionary *tileViewForTile;

@property (strong, nonatomic) IBOutlet UIButton *endTurnButton;
@property (strong, nonatomic) IBOutlet UILabel *populationLabel;

@property (nonatomic, assign) NSUInteger turn;
@property (nonatomic, assign) NSUInteger population;
@property (nonatomic, assign) NSUInteger meat;
@property (nonatomic, assign) NSUInteger maize;

@property (nonatomic, strong) SCTile *selectedTile;

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

- (SCTileView *)tileViewForTile:(SCTile *)tile {
    if (tile == nil) {
        return nil;
    }
    return self.tileViewForTile[tile.pointerValue];
}

- (void)setupGrid {
    NSInteger radius = 4;
    
    [self makeHexGridWithRadius:radius];
    self.tileViewForTile = [[NSMutableDictionary alloc] init];

    for (SCTile *tile in self.tiles) {
        SCTileView *tileView = [[SCTileView alloc] initWithRadius:RADIUS];
        tileView.tile = tile;
        self.tileViewForTile[tile.pointerValue] = tileView;
        tileView.center = [self centerForPosition:tile.hex.position];
        [[tileView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(SCTileView *tileView) {
            self.selectedTile = tileView.tile;
        }];
        [self.scrollView.contentView addSubview:tileView];
    }
    self.scrollView.backgroundColor = UIColor.darkGrayColor;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.view layoutIfNeeded];
    self.scrollView.contentSize = [self sizeWithRadius:radius];
    
    [[RACObserve(self, selectedTile) combinePreviousWithStart:nil reduce:^id(SCTile *previous, SCTile *current) {
        [self tileViewForTile:previous].selected = NO;
        SCTileView *selectedTileView = [self tileViewForTile:current];
        selectedTileView.selected = YES;
        [selectedTileView.superview bringSubviewToFront:selectedTileView];
        return nil;
    }] subscribeNext:^(id x) {}];
}

- (void)viewDidLoad {
    [self setupGrid];
    
    self.population = 100;
    self.maize = 100;
    self.meat = 100;
    
    UILabel *infoLabel = [[UILabel alloc] init];
    self.navigationItem.titleView = infoLabel;
    infoLabel.frame = self.navigationController.navigationBar.bounds;
    
    RAC(self, title) = [RACObserve(self, turn) map:^id(NSNumber *turn) {
        return [NSString stringWithFormat:@"turn %@", turn];
    }];
    
    static NSDictionary *map = nil;
    if (map == nil) {
        map = @{@(SCTileTypeForest): @"Forest",
                @(SCTileTypeGrass): @"Grass",
                @(SCTileTypeWater): @"Water",
                @(SCTileTypeTemple): @"Temple"};
    }

    RAC(self.populationLabel, text) = [RACObserve(self, selectedTile) map:^(SCTile *tile) {
        return tile == nil ? @"No selected tile" : map[@(tile.type)];
    }];
    
    RAC(infoLabel, text) =
    [RACSignal combineLatest:@[RACObserve(self, population),
                               RACObserve(self, meat),
                               RACObserve(self, maize)]
                      reduce:^(NSNumber *population, NSNumber *meat, NSNumber *maize) {
                          return [NSString stringWithFormat:@"%@ population; %@ meat; %@ maize", population, meat, maize];
                      }];
    
    [[self.endTurnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self iterate];
    }];
}

- (SCTile *)tileAt:(SCPosition *)position {
    return self.tileForLocation[position];
}

- (void)addTileForPosition:(SCPosition *)position type:(SCTileType)type {
    SCHex *hex = [[SCHex alloc] init];
    hex.position = position;
    SCTile *tile = [[SCTile alloc] initWithHex:hex];
    tile.type = type;
    
    [self.tiles addObject:tile];
    self.tileForLocation[hex.position] = tile;
    
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
    self.tileForLocation = [[NSMutableDictionary alloc] init];
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
