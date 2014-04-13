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
#import "SCRadialMenuView.h"
#import "SCPassthroughView.h"
#import "SCInputView.h"
#import "SCLabel.h"

static CGFloat RADIUS;
static CGFloat APOTHEM;
static CGFloat PADDING;

static const CGFloat menuAnimationSpringDamping = 0.75;
static const NSTimeInterval menuAnimationDuration = 0.5;

@interface SCViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet SCScrollView *scrollView;
@property (strong, nonatomic) UIView *tilesView;
@property (nonatomic, strong) SCCity *city;
@property (nonatomic, strong) NSMutableDictionary *tileViewForTile;

@property (strong, nonatomic) IBOutlet UIButton *endTurnButton;
@property (strong, nonatomic) IBOutlet UIView *commandView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIButton *buildButton;

@property (nonatomic, strong) SCRadialMenuView *currentMenuView;

@property (strong, nonatomic) UIView *detailView;

@property (nonatomic, strong) SCTile *selectedTile;

@property (nonatomic, assign) NSUInteger labor;

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGRect unobscuredFrame;

@end

@implementation SCViewController

+ (void)initialize {
    APOTHEM = 22;
    RADIUS = APOTHEM / 0.5 / sqrtf(3.0f);
    PADDING = APOTHEM * 3;
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
        SCTileView *tileView = [[SCTileView alloc] initWithApothem:APOTHEM];
        tileView.tile = tile;
        self.tileViewForTile[tile.pointerValue] = tileView;
        tileView.center = [self centerForPosition:tile.hex.position];
        [[tileView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(SCTileView *tileView) {
            self.selectedTile = self.selectedTile == tileView.tile ? nil : tileView.tile;
        }];
        [self.tilesView addSubview:tileView];
    }
    self.scrollView.backgroundColor = UIColor.darkGrayColor;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.view layoutIfNeeded];
    RAC(self, contentSize) = [RACObserve(self, world.radius) map:^(NSNumber *worldRadius) {
        return [NSValue valueWithCGSize:boundingSizeForHexagons(APOTHEM, worldRadius.unsignedIntegerValue * 2 + 1)];
    }];
    RAC(self.scrollView, contentSize) = [self paddedContentSize];
    
    @weakify(self);
    [RACObserve(self, selectedTile) subscribeChanges:^(SCTile *previous, SCTile *current) {
        @strongify(self);
        [self removeCurrentMenuView];
        if (current != nil) {
            [self addMenuViewForTile:current];
        }
        
        [self tileViewForTile:previous].selected = NO;
        SCTileView *selectedTileView = [self tileViewForTile:current];
        selectedTileView.selected = YES;
        [selectedTileView.superview bringSubviewToFront:selectedTileView];
    } start:self.selectedTile];
}

- (RACSignal *)paddedContentSize {
    return [RACObserve(self, contentSize) map:^id(NSValue *sizeValue) {
        CGSize size = sizeValue.CGSizeValue;
        size.width += PADDING * 2;
        size.height += PADDING * 2;
        return [NSValue valueWithCGSize:size];
    }];
}

- (void)removeCurrentMenuView {
    [self popClosed:self.currentMenuView];
    self.currentMenuView = nil;
}

- (NSArray *)buttonsForTile:(SCTile *)tile {
    SCButtonDescription *(^button)(NSString *name) = ^(NSString *name) {
        return [SCButtonDescription buttonWithText:name handler:^{
            [self flashMessage:name];
        }];
    };
    
    if ([tile.foreground isKindOfClass:SCRiver.class]) {
        return @[[SCButtonDescription buttonWithText:@"Fish" handler:^{
            [self displayLaborModalWithTitle:@"Fish for fishes" inputRate:3 outputRateMin:0 outputRateMax:5 outputName:@"fish" commitBlock:^(NSUInteger input, NSUInteger output) {
                self.labor -= input;
                [self.city gainFish:output];
                [self flashMessage:[NSString stringWithFormat:@"+ %@ fish", @(output)]];
            }];
        }]];
    } else if ([tile.foreground isKindOfClass:SCGrass.class]) {
        return @[button(@"Farm"), button(@"Build")];
    } else if ([tile.foreground isKindOfClass:SCTemple.class]) {
        return @[button(@"Worship"), button(@"Sacrifice")];
    } else if ([tile.foreground isKindOfClass:SCForest.class]) {
        return @[[SCButtonDescription buttonWithText:@"Hunt" handler:^{
            [self displayLaborModalWithTitle:@"Hunt" inputRate:1 outputRateMin:1 outputRateMax:3 outputName:@"meat" commitBlock:^(NSUInteger input, NSUInteger output) {
                self.labor -= input;
                [self.city gainMeat:output];
                [self flashMessage:[NSString stringWithFormat:@"+ %@ meat", @(output)]];
            }];
        }], [SCButtonDescription buttonWithText:@"Frg" handler:^{
            [self displayLaborModalWithTitle:@"Forage for Maize" inputRate:2 outputRateMin:0 outputRateMax:2 outputName:@"maize" commitBlock:^(NSUInteger input, NSUInteger output) {
                self.labor -= input;
                [self.city gainMaize:output];
                [self flashMessage:[NSString stringWithFormat:@"+ %@ maize", @(output)]];
            }];
        }], [SCButtonDescription buttonWithText:@"Chop" handler:^{
            [self displayLaborModalWithTitle:@"Chop Wood" inputRate:3 outputRate:1 outputName:@"wood" commitBlock:^(NSUInteger input, NSUInteger output) {
                self.labor -= input;
                [self.city gainWood:output];
                [self flashMessage:[NSString stringWithFormat:@"+ %@ wood", @(output)]];
            }];
        }]];
    } else {
        return nil;
    }
}

- (void)flashMessage:(NSString *)message {
    SCLabel *label = [[SCLabel alloc] initWithFrame:CGRectZero];
    [label size:@"k"];
    label.text = message;
    label.insets = UIEdgeInsetsMake(5, 5, 5, 5);
    [label sizeToFit];
    label.center = CGPointMake(CGRectGetMidX(self.view.bounds), 0);
    label.frameOriginY = CGRectGetMaxY(self.navigationController.navigationBar.frame) + 5;
    label.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    label.layer.cornerRadius = label.frameHeight * 0.5;
    label.layer.masksToBounds = YES;
    
    [self popOpen:label inView:self.view completion:^(BOOL finished) {
        [self popClosed:label delay:0.25];
    }];
}

- (void)popOpen:(UIView *)view inView:(UIView *)superview {
    [self popOpen:view inView:superview completion:nil];
}

- (void)popOpen:(UIView *)view inView:(UIView *)superview completion:(void(^)(BOOL))completion {
    view.transform = CGAffineTransformMakeScale(0.1, 0.1);
    view.alpha = 0;
    [superview addSubview:view];
    
    [UIView animateWithDuration:menuAnimationDuration
                          delay:0
         usingSpringWithDamping:menuAnimationSpringDamping
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.alpha = 1;
                         view.transform = CGAffineTransformIdentity;
                     } completion:completion];
}

- (void)popClosed:(UIView *)view {
    [self popClosed:view delay:0];
}

- (void)popClosed:(UIView *)view delay:(NSTimeInterval)delay {
    [UIView animateWithDuration:menuAnimationDuration * 0.25
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:menuAnimationDuration * 0.25
                                               delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              view.alpha = 0;
                                              view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                          } completion:^(BOOL finished) {
                                              [view removeFromSuperview];
                                          }];
                     }];
}

- (void)displayLaborModalWithTitle:(NSString *)title
                         inputRate:(NSUInteger)inputRate
                     outputRateMin:(NSUInteger)outputRateMin
                     outputRateMax:(NSUInteger)outputRateMax
                        outputName:(NSString *)outputName
                       commitBlock:(void(^)(NSUInteger input, NSUInteger output))commitBlock {
    SCInputView *inputView = [[UINib nibWithNibName:@"SCInputView" bundle:nil] instantiateWithOwner:nil options:nil][0];
    [inputView size:@""];
    
    inputView.slider.minimumValue = 0;
    inputView.slider.maximumValue = inputRate * (self.labor / inputRate);
    inputView.slider.value = 0;
    
    RACSignal *inputSignal = [[[RACSignal defer:^{
        return [RACSignal return:@(inputView.slider.value)];
    }] concat:[[inputView.slider rac_signalForControlEvents:UIControlEventValueChanged] map:^(UISlider *slider) {
        return @(slider.value);
    }]] map:^(NSNumber *sliderValue) {
        NSUInteger labor = roundf(sliderValue.floatValue);
        NSUInteger rounded = inputRate * (labor / inputRate);
        return @(rounded);
    }];
    
    RACSignal *outputMinSignal = [inputSignal map:^(NSNumber *inputNumber) {
        return @((inputNumber.unsignedIntegerValue / inputRate) * outputRateMin);
    }];
    RACSignal *outputMaxSignal = [inputSignal map:^(NSNumber *inputNumber) {
        return @((inputNumber.unsignedIntegerValue / inputRate) * outputRateMax);
    }];
    
    inputView.topLabel.text = (outputRateMin == outputRateMax) ?
    [NSString stringWithFormat:@"%@ labor ➜ %@ %@", @(inputRate), @(outputRateMin), outputName] :
    [NSString stringWithFormat:@"%@ labor ➜ %@-%@ %@", @(inputRate), @(outputRateMin), @(outputRateMax), outputName];
    
    inputView.titleLabel.text = title;
    
    RAC(inputView.bottomLabel, text) = [RACSignal combineLatest:@[inputSignal, outputMinSignal, outputMaxSignal] reduce:^(NSNumber *input, NSNumber *outputMin, NSNumber *outputMax) {
        if (self.labor < inputRate) {
            return @"Not enough labor!";
        } else if ([outputMax isEqual:@0]) {
            return @"How much labor?";
        } else if ([outputMin isEqual:outputMax]) {
            return [NSString stringWithFormat:@"%@ labor ➜ %@ %@", input, outputMin, outputName];
        } else {
            return [NSString stringWithFormat:@"%@ labor ➜ %@-%@ %@", input, outputMin, outputMax, outputName];
        }
    }];
    
    [inputView.button setTitle:@"Commit" forState:UIControlStateNormal];
    
    __block BOOL dismissed = NO;
    void (^dismiss)() = ^{
        dismissed = YES;
        [self popClosed:inputView];
    };
    
    [[inputView.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSUInteger input = [[inputSignal first] unsignedIntegerValue];
        assert(input % inputRate == 0);
        NSUInteger inputEvents = input / inputRate;
        NSUInteger output = 0;
        NSUInteger outputSpread = outputRateMax - outputRateMin;
        if (outputSpread == 0) {
            output = outputRateMin * inputEvents;
        } else {
            for (NSUInteger i = 0; i < inputEvents; i++) {
                output += arc4random_uniform((u_int32_t)outputSpread + 1) + outputRateMin;
            }
        }
        commitBlock(input, output);
        dismiss();
    }];
    
    [[inputView.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        dismiss();
    }];
    
    // This is dumb, but I don't know a better way to do it.
    [inputView layoutIfNeeded];
    inputView.frameHeight = CGRectGetMaxY(inputView.button.frame);
    
    RAC(inputView, center) = [[RACObserve(self, unobscuredFrame) map:^id(NSValue *frame) {
        return [NSValue valueWithCGPoint:CGRectGetCenter(frame.CGRectValue)];
    }] takeUntilBlock:^BOOL(id x) {
        return dismissed;
    }];
    
    inputView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [self popOpen:inputView inView:self.view];
}

- (void)displayLaborModalWithTitle:(NSString *)title
                         inputRate:(NSUInteger)inputRate
                        outputRate:(NSUInteger)outputRate
                        outputName:(NSString *)outputName
                       commitBlock:(void(^)(NSUInteger input, NSUInteger output))commitBlock {
    [self displayLaborModalWithTitle:title inputRate:inputRate outputRateMin:outputRate outputRateMax:outputRate outputName:outputName commitBlock:commitBlock];
}

- (void)addMenuViewForTile:(SCTile *)tile {
    self.currentMenuView = [[SCRadialMenuView alloc] initWithApothem:APOTHEM buttons:[self buttonsForTile:tile]];
    self.currentMenuView.center = [self centerForPosition:tile.hex.position];
    
    [self popOpen:self.currentMenuView inView:self.tilesView];
}

- (void)iterate {
    [self.city iterate];
    [self.world iterate];
    self.labor = self.city.population;
}

- (UIView *)tileDetailViewForTile:(SCTile *)tile {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, APOTHEM * 3)];
    
    SCTileView *tileView = [[SCTileView alloc] initWithApothem:APOTHEM];
    tileView.tile = tile;
    [view addSubview:tileView];
    tileView.center = CGPointMake(50, APOTHEM);
    tileView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    @weakify(self);
    [[tileView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self scrollToTile:tile];
    }];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, APOTHEM * 2, 100, APOTHEM)];
    nameLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    RAC(nameLabel, text) = RACObserve(tile, foreground.name);
    nameLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:nameLabel];
    
    return view;
}

- (void)setUnobscuredFrame:(CGRect)unobscuredFrame withAnimationFromUserInfo:(NSDictionary *)userInfo {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:[userInfo[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue]];
    [UIView setAnimationDuration:[userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    self.unobscuredFrame = unobscuredFrame;
    [UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.unobscuredFrame = self.view.bounds;
}

- (void)viewDidLoad {
    @weakify(self);
    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        CGRect keyboardFrame = [self.view convertRect:[note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] fromView:nil];
        CGRect obscured = CGRectIntersection(self.view.bounds, keyboardFrame);
        CGRect bounds = self.view.bounds;
        bounds.size.height -= obscured.size.height;
        [self setUnobscuredFrame:bounds withAnimationFromUserInfo:note.userInfo];
    }];
    [NSNotificationCenter.defaultCenter addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        [self setUnobscuredFrame:self.view.bounds withAnimationFromUserInfo:note.userInfo];
    }];
    
    self.tilesView = [[SCPassthroughView alloc] initWithFrame:self.scrollView.contentView.bounds];
    [self.scrollView.contentView addSubview:self.tilesView];
    
    RAC(self.tilesView, bounds) = [self.paddedContentSize map:^(NSValue *contentSizeValue) {
        CGSize contentSize = contentSizeValue.CGSizeValue;
        CGRect bounds = CGRectMake(contentSize.width * -0.5, contentSize.height * -0.5, contentSize.width, contentSize.height);
        return [NSValue valueWithCGRect:bounds];
    }];
    RAC(self.tilesView, frame) = [self.paddedContentSize map:^(NSValue *contentSizeValue) {
        return [NSValue valueWithCGRect:CGRectMakeSize(0, 0, contentSizeValue.CGSizeValue)];
    }];
    
    self.city = [SCCity cityWithWorld:[SCWorld worldWithRadius:6]];
    self.labor = self.city.population;
    [self setupGrid];
    [self.view layoutIfNeeded];
    
    UILabel *infoLabel = [[UILabel alloc] init];
    infoLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    infoLabel.numberOfLines = 0;
    infoLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = infoLabel;
    infoLabel.frame = self.navigationController.navigationBar.bounds;
    
    RAC(self, detailView) = [RACObserve(self, selectedTile) map:^(SCTile *tile) {
        @strongify(self);
        return tile == nil ? self.commandView : [self tileDetailViewForTile:tile];
    }];
    
    [RACObserve(self, detailView) subscribeChanges:^(UIView *previous, UIView *current) {
        [previous removeFromSuperview];
        current.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        current.frameWidth = self.toolbar.frameWidth;
        current.frame = self.toolbar.bounds;
        [self.toolbar addSubview:current];
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
    
    RACSignal *foodSignal = [[RACSignal combineLatest:@[RACObserve(self.city, meat),
                                                        RACObserve(self.city, fish),
                                                        RACObserve(self.city, maize)]] map:^id(id <NSFastEnumeration> foods) {
        NSUInteger totalFood = 0;
        for (NSNumber *food in foods) {
            totalFood += food.unsignedIntegerValue;
        }
        return @(totalFood);
    }];
    
    RAC(infoLabel, text) =
    [RACSignal combineLatest:@[RACObserve(self.world, turn),
                               RACObserve(self.city, population),
                               foodSignal,
                               RACObserve(self, labor),
                               RACObserve(self.city, wood),
                               RACObserve(self.city, stone)]
                      reduce:^(NSNumber *turn, NSNumber *population, NSNumber *food, NSNumber *labor, NSNumber *wood, NSNumber *stone) {
                          NSUInteger year = turn.unsignedIntegerValue / 4;
                          NSString *season = seasonNameMap[@(self.world.season)];
                          return [NSString stringWithFormat:@"%@ - %@\n%@l %@p %@f %@w %@s", season, @(year), labor, population, food, wood, stone];
                      }];
    
    [[self.endTurnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self iterate];
    }];
}

- (void)scrollToTile:(SCTile *)tile {
    UIView *tileView = [self tileViewForTile:tile];
    CGRect rect = [self.scrollView.contentView convertRect:tileView.frame fromView:tileView.superview];
    [self.scrollView zoomToRect:rect animated:YES];
}

- (CGPoint)centerForPosition:(SCPosition *)position {
    return hexCenter(position.x, position.y, APOTHEM);
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
