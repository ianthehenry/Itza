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
static NSDictionary *foregroundDisplayInfo;

@interface SCViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet SCScrollView *scrollView;
@property (strong, nonatomic) UIView *tilesView;
@property (nonatomic, strong) SCCity *city;
@property (nonatomic, strong) NSMutableDictionary *tileViewForTile;

@property (strong, nonatomic) IBOutlet UIButton *endTurnButton;
@property (strong, nonatomic) IBOutlet UIView *commandView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) IBOutlet UIButton *scienceButton;
@property (strong, nonatomic) IBOutlet UIButton *cheatButton;

@property (nonatomic, strong) SCRadialMenuView *currentMenuView;

@property (strong, nonatomic) UIView *detailView;

@property (nonatomic, strong) SCTile *selectedTile;

@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) CGRect unobscuredFrame;

@end

@implementation SCViewController

+ (void)initialize {
    APOTHEM = 22;
    RADIUS = APOTHEM / 0.5 / sqrtf(3.0f);
    PADDING = APOTHEM * 3;
    
    UIColor *buildingColor = [UIColor brownColor];
    
    foregroundDisplayInfo =
    @{
      SCGrass.class.pointerValue: RACTuplePack(@"Grass", @"", [UIColor colorWithHue:0.33 saturation:0.9 brightness:0.6 alpha:1]),
      SCForest.class.pointerValue: RACTuplePack(@"Forest", @"♣", [UIColor colorWithHue:0.33 saturation:0.9 brightness:0.6 alpha:1]),
      SCRiver.class.pointerValue: RACTuplePack(@"River", @"", [UIColor colorWithHue:0.66 saturation:0.9 brightness:0.6 alpha:1]),
      SCTemple.class.pointerValue: RACTuplePack(@"Temple", @"T", [UIColor colorWithHue:0.15 saturation:1.0 brightness:0.7 alpha:1]),
      SCFarm.class.pointerValue: RACTuplePack(@"Farm", @"=", [UIColor colorWithHue:0.15 saturation:1.0 brightness:0.7 alpha:1]),
      SCGranary.class.pointerValue: RACTuplePack(@"Granary", @"G", buildingColor),
      SCFishery.class.pointerValue: RACTuplePack(@"Fishery", @"F", buildingColor),
      SCLumberMill.class.pointerValue: RACTuplePack(@"Lumbery", @"L", buildingColor),
      SCHouse.class.pointerValue: RACTuplePack(@"House", @"H", buildingColor),
      };
}

- (SCTileView *)tileViewForTile:(SCTile *)tile {
    if (tile == nil) {
        return nil;
    }
    SCTileView *tileView = self.tileViewForTile[tile.pointerValue];
    if (tileView == nil) {
        tileView =
        self.tileViewForTile[tile.pointerValue] = [self makeTileViewForTile:tile];
    }
    return tileView;
}

- (RACSignal *)foregroundInfoForTile:(SCTile *)tile {
    return [RACObserve(tile, foreground) map:^(SCForeground *foreground) {
        return foregroundDisplayInfo[foreground.class.pointerValue];
    }];
}

- (SCTileView *)makeTileViewForTile:(SCTile *)tile {
    SCTileView *tileView = [[SCTileView alloc] initWithApothem:APOTHEM];
    
    RACSignal *foregroundInfo = [self foregroundInfoForTile:tile];
    
    RAC(tileView.label, text, @"?") = [foregroundInfo index:1];
    tileView.label.font = [UIFont fontWithName:@"Menlo" size:20];
    RAC(tileView, fillColor) = [foregroundInfo index:2];
    return tileView;
}

- (SCWorld *)world {
    return self.city.world;
}

- (void)setupGrid {
    self.tileViewForTile = [[NSMutableDictionary alloc] init];
    
    for (SCTile *tile in self.world.tiles) {
        SCTileView *tileView = [self tileViewForTile:tile];
        tileView.center = [self centerForPosition:tile.hex.position];
        [[tileView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(SCTileView *tileView) {
            self.selectedTile = self.selectedTile == tile ? nil : tile;
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
    if (self.currentMenuView == nil) {
        return;
    }
    [self popClosed:self.currentMenuView];
    self.currentMenuView = nil;
}

- (NSArray *)buttonsForTile:(SCTile *)tile {
    SCButtonDescription *(^button)(NSString *name) = ^(NSString *name) {
        return [SCButtonDescription buttonWithText:name handler:^{
            [self flashMessage:name];
        }];
    };
    
    SCButtonDescription *(^laborInputButton)(NSString *buttonName, NSString *title, NSUInteger inputRate, NSUInteger outputRateMin, NSUInteger outputRateMax, NSString *outputName, void(^)(NSUInteger output)) = ^(NSString *buttonName, NSString *title, NSUInteger inputRate, NSUInteger outputRateMin, NSUInteger outputRateMax, NSString *outputName, void(^outputBlock)(NSUInteger output)) {
        return [SCButtonDescription buttonWithText:buttonName handler:^{
            [self removeCurrentMenuView];
            [self displayLaborModalWithTitle:title inputRate:inputRate outputRateMin:outputRateMin outputRateMax:outputRateMax outputName:outputName commitBlock:^(NSUInteger input, NSUInteger output) {
                [self.city loseLabor:input];
                outputBlock(output);
                [self flashMessage:[NSString stringWithFormat:@"+ %@ %@", @(output), outputName]];
                self.selectedTile = nil;
            }];
        }];
    };
    
    if ([tile.foreground isKindOfClass:SCRiver.class]) {
        return @[laborInputButton(@"Fish", @"Fish for Fishes", 3, 0, 5, @"fish", ^(NSUInteger output) {
            [self.city gainFish:output];
        })];
    } else if ([tile.foreground isKindOfClass:SCGrass.class]) {
        return @[button(@"Farm"), [SCButtonDescription buttonWithText:@"Build" handler:^{
            [self removeCurrentMenuView];
            [self showBuildingModalForTile:tile];
        }]];
    } else if ([tile.foreground isKindOfClass:SCTemple.class]) {
        return @[button(@"Worship"), button(@"Sacrifice")];
    } else if ([tile.foreground isKindOfClass:SCForest.class]) {
        return @[laborInputButton(@"Hunt", @"Hunt for Animals", 1, 1, 2, @"meat", ^(NSUInteger output) {
            [self.city gainMeat:output];
        }), laborInputButton(@"Gthr", @"Gather Maize", 2, 0, 2, @"maize", ^(NSUInteger output) {
            [self.city gainMaize:output];
        }), laborInputButton(@"Chop", @"Chop Wood", 3, 1, 1, @"wood", ^(NSUInteger output) {
            [self.city gainWood:output];
        })];
    } else if ([tile.foreground isKindOfClass:SCBuilding.class]) {
        return @[[SCButtonDescription buttonWithText:@"Build" handler:^{
            [self removeCurrentMenuView];
            [self showConstructionModalForBuilding:(SCBuilding *)tile.foreground];
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

- (void)showConstructionModalForBuilding:(SCBuilding *)building {
    NSMutableArray *relevantSignals = [[NSMutableArray alloc] init];
    
    [relevantSignals addObject:RACObserve(building, remainingSteps)];
    
    if (building.laborPerStep > 0) {
        [relevantSignals addObject:[RACObserve(self.city, labor) map:^(NSNumber *labor) {
            return @(labor.unsignedIntegerValue / building.laborPerStep);
        }]];
    }
    
    if (building.woodPerStep > 0) {
        [relevantSignals addObject:[RACObserve(self.city, wood) map:^(NSNumber *wood) {
            return @(wood.unsignedIntegerValue / building.woodPerStep);
        }]];
    }
    
    if (building.stonePerStep > 0) {
        [relevantSignals addObject:[RACObserve(self.city, stone) map:^(NSNumber *stone) {
            return @(stone.unsignedIntegerValue / building.stonePerStep);
        }]];
    }
    
    RACSignal *maxSteps = [[RACSignal combineLatest:relevantSignals] map:^id(RACTuple *nums) {
        RACSequence *seq = nums.rac_sequence;
        NSNumber *min = seq.head;
        for (NSNumber *num in seq.tail) {
            if ([num compare:min] == NSOrderedAscending) {
                min = num;
            }
        }
        return min;
    }];
    
    RACTupleUnpack(SCInputView *inputView, RACSignal *inputStepsSignal) = [self inputViewWithMaxValue:maxSteps cancel:^{
        [self addMenuViewForTile:building.tile];
    } commit:^(NSUInteger inputSteps) {
        [building build:inputSteps];
        [self.city loseLabor:inputSteps * building.laborPerStep];
        [self.city loseWood:inputSteps * building.woodPerStep];
        [self.city loseStone:inputSteps * building.stonePerStep];
    }];
    
    NSString *(^nonzeroList)(NSArray *tuples) = ^(NSArray *tuples) {
        return [[[[tuples.rac_sequence filter:^BOOL(RACTuple *tuple) {
            return [tuple[0] unsignedIntegerValue] != 0;
        }] map:^(RACTuple *tuple) {
            return [NSString stringWithFormat:@"%@ %@", tuple[0], tuple[1]];
        }] array] componentsJoinedByString:@", "];
    };

    inputView.topLabel.text = [NSString stringWithFormat:@"%@ per step", nonzeroList(@[RACTuplePack(@(building.laborPerStep), @"labor"),
                                                                                       RACTuplePack(@(building.woodPerStep), @"wood"),
                                                                                       RACTuplePack(@(building.stonePerStep), @"stone")])];
    
    RAC(inputView.bottomLabel, text) = [inputStepsSignal map:^(NSNumber *inputStepsNumber) {
        NSUInteger steps = inputStepsNumber.unsignedIntegerValue;
        if (steps == 0) {
            return @"How much labor?";
        } else {
            return nonzeroList(@[RACTuplePack(@(steps * building.laborPerStep), @"labor"),
                                 RACTuplePack(@(steps * building.woodPerStep), @"wood"),
                                 RACTuplePack(@(steps * building.stonePerStep), @"stone")]);
        }
    }];
}

- (void)showBuildingModalForTile:(SCTile *)tile {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
    view.backgroundColor = UIColor.whiteColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    titleLabel.text = @"Build a Building";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    SCScrollView *scrollView = [[SCScrollView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)];
    scrollView.delaysContentTouches = NO;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    cancelButton.frame = CGRectMake(0, 0, 300, 44);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [view stackViewsVerticallyCentered:@[titleLabel, scrollView, cancelButton]];
    
    __block BOOL dismissed = NO;
    void (^dismiss)() = [self showModal:view dismissed:&dismissed];
    [[cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        dismiss();
        [self addMenuViewForTile:tile];
    }];
    
    NSArray *buildings =
    @[
      RACTuplePack(SCHouse.class, @"+100 max pop, +10 more for each adjacent house", @20, @20, @0),
      RACTuplePack(SCFarm.class, @"Turns maize into more maize", @30, @0, @0),
      RACTuplePack(SCGranary.class, @"95% preservation of up to 200 maize", @30, @30, @0),
      RACTuplePack(SCTemple.class, @"Extends visible range", @60, @0, @30),
      RACTuplePack(SCLumberMill.class, @"+1 wood per labor in adjacent forests", @20, @10, @0),
      RACTuplePack(SCFishery.class, @"+2 fish per labor in adjacent rivers and lakes", @50, @30, @0),
      ];
    CGFloat padding = 10;
    CGFloat top = 0;
    for (RACTuple *tuple in buildings) {
        RACTupleUnpack(Class class, NSString *description, NSNumber *labor, NSNumber *wood, NSNumber *stone) = tuple;
        UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, top, 300, 30)];
        RAC(control, backgroundColor) = [RACObserve(control, highlighted) map:^(NSNumber *highlighted) {
            return highlighted.boolValue ? [UIColor colorWithWhite:0.9 alpha:1] : [UIColor whiteColor];
        }];
        
        SCTileView *tileView = [[SCTileView alloc] initWithApothem:APOTHEM];
        tileView.frameOriginX = padding;
        tileView.fillColor = foregroundDisplayInfo[class.pointerValue][2];
        tileView.label.text = foregroundDisplayInfo[class.pointerValue][1];
        tileView.label.font = [UIFont fontWithName:@"Menlo" size:13];
        tileView.userInteractionEnabled = NO;
        [tileView size:@"hk"];
        [control addSubview:tileView];
        tileView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, CGRectGetMaxY(tileView.frame), CGRectGetWidth(tileView.frame), 22)];
        nameLabel.text = foregroundDisplayInfo[class.pointerValue][0];
        nameLabel.font = [UIFont fontWithName:@"Menlo" size:11];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [nameLabel size:@"hk"];
        [control addSubview:nameLabel];
        nameLabel.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
        
        CGFloat left = CGRectGetMaxX(tileView.frame);
        UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, 0, control.bounds.size.width - left - padding, control.bounds.size.height)];
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.text = [NSString stringWithFormat:@"%@ (%@w %@s %@l)", description, wood, stone, labor];
        [descriptionLabel size:@"hjkl"];
        [control addSubview:descriptionLabel];
        descriptionLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
        
        [[control rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            dismiss();
            SCBuilding *building = (SCBuilding *)[[class alloc] initWithLabor:labor.unsignedIntegerValue
                                                                         wood:wood.unsignedIntegerValue
                                                                        stone:stone.unsignedIntegerValue];
            tile.foreground = building;
            [self showConstructionModalForBuilding:building];
        }];
        control.frameHeight = CGRectGetMaxY(nameLabel.frame);
        top = CGRectGetMaxY(control.frame);
        [scrollView addSubview:control];
    }
    scrollView.contentSize = CGSizeMake(300, top);
}

- (void(^)())showModal:(UIView *)view dismissed:(BOOL *)dismissed {
    [view size:@""];

    NSAssert(*dismissed == NO, @"Must pass a pointer to NO");
    void (^dismiss)() = ^{
        *dismissed = YES;
        [self popClosed:view];
    };

    RAC(view, center) = [[RACObserve(self, unobscuredFrame) map:^id(NSValue *frame) {
        return [NSValue valueWithCGPoint:CGRectGetCenter(frame.CGRectValue)];
    }] takeUntilBlock:^BOOL(id x) {
        return *dismissed;
    }];
    
    [self popOpen:view inView:self.view];

    return dismiss;
}

- (RACTuple *)inputViewWithMaxValue:(RACSignal *)maxValueSignal
                             cancel:(void(^)())cancelBlock
                             commit:(void(^)(NSUInteger steps))commitBlock {
    SCInputView *inputView = [[UINib nibWithNibName:@"SCInputView" bundle:nil] instantiateWithOwner:nil options:nil][0];
    __block BOOL dismissed = NO;
    
    inputView.slider.minimumValue = 0;
    inputView.slider.value = 0;
    [[maxValueSignal takeUntilBlock:^BOOL(id x) {
        return dismissed;
    }] subscribeNext:^(NSNumber *maxSteps) {
        inputView.slider.maximumValue = maxSteps.unsignedIntegerValue;
        [inputView.slider sendActionsForControlEvents:UIControlEventValueChanged];
    }];
    
    RACSignal *inputSignal = [[[RACSignal defer:^{
        return [RACSignal return:@(inputView.slider.value)];
    }] concat:[[inputView.slider rac_signalForControlEvents:UIControlEventValueChanged] map:^(UISlider *slider) {
        return @(slider.value);
    }]] map:^(NSNumber *sliderValue) {
        return @((NSUInteger)roundf(sliderValue.floatValue));
    }];
    
    [inputView.button setTitle:@"Commit" forState:UIControlStateNormal];
    [inputView layoutIfNeeded];
    inputView.frameHeight = CGRectGetMaxY(inputView.button.frame);
    RAC(inputView.button, enabled) = [[inputSignal is:@0] not];
    
    void (^dismissModal)() = [self showModal:inputView dismissed:&dismissed];
    
    [[inputView.button rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        dismissModal();
        NSUInteger input = [[inputSignal first] unsignedIntegerValue];
        assert(input > 0);
        commitBlock(input);
    }];
    
    [[inputView.cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        dismissModal();
        cancelBlock();
    }];
    
    return RACTuplePack(inputView, inputSignal);
}

- (void)displayLaborModalWithTitle:(NSString *)title
                         inputRate:(NSUInteger)inputRate
                     outputRateMin:(NSUInteger)outputRateMin
                     outputRateMax:(NSUInteger)outputRateMax
                        outputName:(NSString *)outputName
                       commitBlock:(void(^)(NSUInteger input, NSUInteger output))commitBlock {
    RACSignal *maxSteps = [RACObserve(self.city, labor) map:^(NSNumber *labor) {
        return @(labor.unsignedIntegerValue / inputRate);
    }];
    
    RACTupleUnpack(SCInputView *inputView, RACSignal *inputStepsSignal) = [self inputViewWithMaxValue:maxSteps cancel:^{
        [self addMenuViewForTile:self.selectedTile];
    } commit:^(NSUInteger inputSteps) {
        NSUInteger output = 0;
        NSUInteger outputSpread = outputRateMax - outputRateMin;
        if (outputSpread == 0) {
            output = outputRateMin * inputSteps;
        } else {
            for (NSUInteger i = 0; i < inputSteps; i++) {
                output += arc4random_uniform((u_int32_t)outputSpread + 1) + outputRateMin;
            }
        }
        commitBlock(inputSteps * inputRate, output);
    }];
    
    RACSignal *inputSignal = [inputStepsSignal map:^(NSNumber *value) {
        return @(inputRate * value.unsignedIntegerValue);
    }];
    
    RACSignal *outputMinSignal = [inputStepsSignal map:^(NSNumber *inputSteps) {
        return @(inputSteps.unsignedIntegerValue * outputRateMin);
    }];
    RACSignal *outputMaxSignal = [inputStepsSignal map:^(NSNumber *inputSteps) {
        return @(inputSteps.unsignedIntegerValue * outputRateMax);
    }];
    
    inputView.topLabel.text = (outputRateMin == outputRateMax) ?
    [NSString stringWithFormat:@"%@ labor ➜ %@ %@", @(inputRate), @(outputRateMin), outputName] :
    [NSString stringWithFormat:@"%@ labor ➜ %@-%@ %@", @(inputRate), @(outputRateMin), @(outputRateMax), outputName];
    
    inputView.titleLabel.text = title;
    
    RAC(inputView.bottomLabel, text) = [RACSignal combineLatest:@[inputSignal, outputMinSignal, outputMaxSignal] reduce:^(NSNumber *input, NSNumber *outputMin, NSNumber *outputMax) {
        if (self.city.labor < inputRate) {
            return @"Not enough labor!";
        } else if ([outputMax isEqual:@0]) {
            return @"How much labor?";
        } else if ([outputMin isEqual:outputMax]) {
            return [NSString stringWithFormat:@"%@ labor ➜ %@ %@", input, outputMin, outputName];
        } else {
            return [NSString stringWithFormat:@"%@ labor ➜ %@-%@ %@", input, outputMin, outputMax, outputName];
        }
    }];
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

- (NSArray *)iterate {
    [self.world iterate];
    return [self.city iterate];
}

- (UIView *)tileDetailViewForTile:(SCTile *)tile {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 500, APOTHEM * 3)];
    
    SCTileView *tileView = [self makeTileViewForTile:tile];
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
    RAC(nameLabel, text) = [[self foregroundInfoForTile:tile] index:0];
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
    
    RAC(infoLabel, text) =
    [RACSignal combineLatest:@[RACObserve(self.world, turn),
                               RACObserve(self.city, population),
                               RACObserve(self.city, food),
                               RACObserve(self.city, labor),
                               RACObserve(self.city, wood),
                               RACObserve(self.city, stone)]
                      reduce:^(NSNumber *turn, NSNumber *population, NSNumber *food, NSNumber *labor, NSNumber *wood, NSNumber *stone) {
                          NSUInteger year = turn.unsignedIntegerValue / 4;
                          NSString *season = seasonNameMap[@(self.world.season)];
                          return [NSString stringWithFormat:@"%@ - Year %@\n%@l %@p %@f %@w %@s", season, @(year), labor, population, food, wood, stone];
                      }];
    
    [[self.endTurnButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSUInteger year = self.world.turn / 4;
        NSString *season = seasonNameMap[@(self.world.season)];
        NSString *title = [NSString stringWithFormat:@"Summary for %@ - Year %@", season, @(year)];
        NSArray *messages = [self iterate];
        [self showWallOfTextModalWithTitle:title body:[messages componentsJoinedByString:@"\n"]];
    }];
    
    [[self.scienceButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self flashMessage:@"there's no science...yet"];
    }];

    [[self.cheatButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self flashMessage:@"+100 people"];
        [self.city setValue:@(self.city.population + 100) forKey:@"population"];
        [self.city setValue:@(self.city.labor + 100) forKey:@"labor"];
    }];
    
    [[[self rac_signalForSelector:@selector(viewWillAppear:)] take:1] subscribeNext:^(id x) {
        [self scrollToTile:[self.world tileAt:[SCPosition origin]]];
    }];
}

- (void)showWallOfTextModalWithTitle:(NSString *)title body:(NSString *)body {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
    view.backgroundColor = UIColor.whiteColor;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    titleLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 300, 0)];
    textView.font = [UIFont fontWithName:@"Menlo" size:13];
    textView.editable = NO;
    textView.selectable = NO;
    textView.text = body;
    textView.frameHeight = MIN([textView sizeThatFits:CGSizeMake(300, CGFLOAT_MAX)].height, 200);
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeButton setTitle:@"Done" forState:UIControlStateNormal];
    closeButton.frame = CGRectMake(0, 0, 300, 44);
    [view stackViewsVerticallyCentered:@[titleLabel, textView, closeButton]];
    __block BOOL dismissed = NO;
    void (^dismiss)() = [self showModal:view dismissed:&dismissed];
    [[closeButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        dismiss();
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

- (void)centerCanvas {
    UIScrollView *scrollView = self.scrollView;
    UIEdgeInsets contentInsets = self.scrollView.contentInset;
    CGFloat logicalWidth = scrollView.bounds.size.width - contentInsets.left - contentInsets.right;
    CGFloat logicalHeight = scrollView.bounds.size.height - contentInsets.top - contentInsets.bottom;
    
    CGFloat offsetX = MAX(0, (logicalWidth - scrollView.contentSize.width) * 0.5);
    CGFloat offsetY = MAX(0, (logicalHeight - scrollView.contentSize.height) * 0.5);
    
    self.scrollView.contentView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                                     scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerCanvas];
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
