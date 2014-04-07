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
@property (strong, nonatomic) IBOutlet UIView *commandView;

@property (strong, nonatomic) UIView *detailView;

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

- (UIView *)tileDetailViewForTile:(SCTile *)tile {
    static NSDictionary *tileNameMap = nil;
    if (tileNameMap == nil) {
        tileNameMap = @{@(SCTileTypeForest): @"Forest",
                        @(SCTileTypeGrass): @"Grass",
                        @(SCTileTypeWater): @"Water",
                        @(SCTileTypeTemple): @"Temple"};
    }

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, APOTHEM * 3)];
    
    SCTileView *tileView = [[SCTileView alloc] initWithRadius:RADIUS];
    tileView.tile = tile;
    [view addSubview:tileView];
    tileView.center = CGPointMake(50, APOTHEM);
    tileView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [[tileView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self scrollToTile:tile];
    }];

    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(tileView.frame), 100, APOTHEM)];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    nameLabel.text = tileNameMap[@(tile.type)];
    nameLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    
    return view;
}

- (void)viewDidLoad {
    self.city = [SCCity cityWithWorld:[SCWorld worldWithRadius:6]];
    self.labor = self.city.population;
    [self setupGrid];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = infoLabel;
    infoLabel.frame = self.navigationController.navigationBar.bounds;
    @weakify(self);
    RAC(self, detailView) = [[RACObserve(self, selectedTile) distinctUntilChanged] map:^(SCTile *tile) {
        @strongify(self);
        return tile == nil ? self.commandView : [self tileDetailViewForTile:tile];
    }];
    
    [RACObserve(self, detailView) subscribeChanges:^(UIView *previous, UIView *current) {
        [previous removeFromSuperview];
        current.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.scrollView.frameHeight = self.view.bounds.size.height - current.frame.size.height;
        current.frame = CGRectMake(0,
                                   CGRectGetMaxY(self.scrollView.frame),
                                   CGRectGetWidth(self.view.bounds),
                                   current.frame.size.height);
        [self.view addSubview:current];
    } start:nil];
    
    RAC(self, title) = [RACObserve(self.world, turn) map:^id(NSNumber *turn) {
        return [NSString stringWithFormat:@"turn %@", turn];
    }];
    
    static NSDictionary *seasonNameMap = nil;
    if (seasonNameMap == nil) {
        seasonNameMap = @{@(SCSeasonSpring): @"Spring",
                          @(SCSeasonSummer): @"Summer",
                          @(SCSeasonAutumn): @"Autumn",
                          @(SCSeasonWinter): @"Winter"};
    }
    
    RAC(infoLabel, text) =
    [RACSignal combineLatest:@[RACObserve(self.world, turn),
                               RACObserve(self.city, population),
                               RACObserve(self.city, meat),
                               RACObserve(self, labor),
                               RACObserve(self.city, maize),
                               RACObserve(self.city, wood),
                               RACObserve(self.city, stone)]
                      reduce:^(NSNumber *turn, NSNumber *population, NSNumber *meat, NSNumber *labor, NSNumber *maize, NSNumber *wood, NSNumber *stone) {
                          NSUInteger year = turn.unsignedIntegerValue / 4;
                          NSString *season = seasonNameMap[@(self.world.season)];
                          return [NSString stringWithFormat:@"%@ - %u\n%@l %@p %@m %@c %@w %@s", season, year, labor, population, meat, maize, wood, stone];
                      }];
    
    [[self.endTurnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self iterate];
    }];
}

- (void)scrollToTile:(SCTile *)tile {
    CGPoint center = [self centerForPosition:tile.hex.position];
    CGRect rect = self.scrollView.bounds;
    rect.origin.x = center.x - rect.size.width * 0.5;
    rect.origin.y = center.y - rect.size.height * 0.5;
    [self.scrollView zoomToRect:rect animated:YES];
}

- (CGPoint)centerForPosition:(SCPosition *)position {
    CGFloat offset = ABS(position.x) % 2 == 1 ? APOTHEM : 0;
    return CGPointMake(position.x * RADIUS * 1.47, offset + position.y * APOTHEM * 2);
}

- (CGSize)sizeWithRadius:(NSInteger)radius {
    NSInteger diameter = 2 * radius + 1;
    return CGSizeMake(1.47 * RADIUS * (diameter + 1) - RADIUS, diameter * APOTHEM * 2);
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
