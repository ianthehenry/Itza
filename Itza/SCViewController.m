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
#import "SCCity.h"

static CGFloat RADIUS;
static CGFloat APOTHEM;

@interface SCViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet SCScrollView *scrollView;
@property (nonatomic, strong) SCCity *city;
@property (nonatomic, strong) NSMutableDictionary *tileViewForTile;

@property (strong, nonatomic) IBOutlet UIButton *endTurnButton;
@property (strong, nonatomic) IBOutlet UILabel *populationLabel;

@property (nonatomic, strong) SCTile *selectedTile;

@property (nonatomic, assign) NSUInteger labor;

@end

@implementation SCViewController

+ (void)initialize {
    APOTHEM = 22;
    RADIUS = APOTHEM / 0.5 / sqrtf(3.0f);
}

- (SCTileView *)tileViewForTile:(SCTile *)tile {
    if (tile == nil) {
        return nil;
    }
    return self.tileViewForTile[tile.pointerValue];
}

- (SCWorld *)world {
    return self.city.world;
}

- (void)setupGrid {    
    self.tileViewForTile = [[NSMutableDictionary alloc] init];

    for (SCTile *tile in self.world.tiles) {
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
    self.scrollView.contentSize = [self sizeWithRadius:self.world.radius];
    
    [[RACObserve(self, selectedTile) combinePreviousWithStart:nil reduce:^id(SCTile *previous, SCTile *current) {
        [self tileViewForTile:previous].selected = NO;
        SCTileView *selectedTileView = [self tileViewForTile:current];
        selectedTileView.selected = YES;
        [selectedTileView.superview bringSubviewToFront:selectedTileView];
        return nil;
    }] subscribeNext:^(id x) {}];
}

- (void)iterate {
    [self.city iterate];
    [self.world iterate];
    self.labor = self.city.population;
}

- (void)viewDidLoad {
    self.city = [SCCity cityWithWorld:[SCWorld worldWithRadius:4]];
    self.labor = self.city.population;
    [self setupGrid];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = infoLabel;
    infoLabel.frame = self.navigationController.navigationBar.bounds;
    
    RAC(self, title) = [RACObserve(self.world, turn) map:^id(NSNumber *turn) {
        return [NSString stringWithFormat:@"turn %@", turn];
    }];
    
    static NSDictionary *tileNameMap = nil;
    if (tileNameMap == nil) {
        tileNameMap = @{@(SCTileTypeForest): @"Forest",
                        @(SCTileTypeGrass): @"Grass",
                        @(SCTileTypeWater): @"Water",
                        @(SCTileTypeTemple): @"Temple"};
    }
    static NSDictionary *seasonNameMap = nil;
    if (seasonNameMap == nil) {
        seasonNameMap = @{@(SCSeasonSpring): @"Spring",
                          @(SCSeasonSummer): @"Summer",
                          @(SCSeasonAutumn): @"Autumn",
                          @(SCSeasonWinter): @"Winter"};
    }

    RAC(self.populationLabel, text) = [RACObserve(self, selectedTile) map:^(SCTile *tile) {
        return tile == nil ? @"No selected tile" : tileNameMap[@(tile.type)];
    }];
    
    RAC(infoLabel, text) =
    [RACSignal combineLatest:@[RACObserve(self.world, turn),
                               RACObserve(self.city, population),
                               RACObserve(self.city, meat),
                               RACObserve(self, labor),
                               RACObserve(self.city, maize)]
                      reduce:^(NSNumber *turn, NSNumber *population, NSNumber *meat, NSNumber *labor, NSNumber *maize) {
                          NSUInteger year = turn.unsignedIntegerValue / 4;
                          NSString *season = seasonNameMap[@(self.world.season)];
                          return [NSString stringWithFormat:@"%@ - %u\n%@l %@p %@m %@c", season, year, labor, population, meat, maize];
                      }];
    
    [[self.endTurnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self iterate];
    }];
}

- (CGPoint)centerForPosition:(SCPosition *)position {
    CGFloat offset = ABS(position.x) % 2 == 1 ? APOTHEM : 0;
    return CGPointMake(position.x * RADIUS * 1.47, offset + position.y * APOTHEM * 2);
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
