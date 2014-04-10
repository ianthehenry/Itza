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
    RAC(self.scrollView, contentSize) = [RACObserve(self, contentSize) map:^id(NSValue *sizeValue) {
        CGSize size = sizeValue.CGSizeValue;
        size.width += PADDING * 2;
        size.height += PADDING * 2;
        return [NSValue valueWithCGSize:size];
    }];
    
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

- (void)removeCurrentMenuView {
    UIView *view = self.currentMenuView;
    
    [UIView animateWithDuration:menuAnimationDuration * 0.25
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         view.transform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:menuAnimationDuration * 0.25
                                               delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              view.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                          } completion:^(BOOL finished) {
                                              [view removeFromSuperview];
                                          }];
                     }];
    self.currentMenuView = nil;
}

- (NSArray *)buttonsForTile:(SCTile *)tile {
    SCButtonDescription *(^button)(NSString *name) = ^(NSString *name) {
        return [SCButtonDescription buttonWithText:name handler:^{
            self.labor -= 1;
            NSLog(@"%@", name);
        }];
    };
    
    if ([tile.foreground isKindOfClass:SCRiver.class]) {
        return @[button(@"Fish")];
    } else if ([tile.foreground isKindOfClass:SCGrass.class]) {
        return @[button(@"Farm"), button(@"Build")];
    } else if ([tile.foreground isKindOfClass:SCTemple.class]) {
        return @[button(@"Worship"), button(@"Sacrifice")];
    } else if ([tile.foreground isKindOfClass:SCForest.class]) {
        return @[button(@"Hunt"), button(@"Forage"), [SCButtonDescription buttonWithText:@"CHOP" handler:^{
            self.labor -= 1;
            [self displayLaborModalWithName:@"CHOP"];
        }]];
    } else {
        return nil;
    }
}

- (void)displayLaborModalWithName:(NSString *)name {
    CGFloat width = 300;
    
    UIColor *color = UIColor.whiteColor;
    
    SCPassthroughView *passthroughView = [[SCPassthroughView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    passthroughView.backgroundColor = UIColor.clearColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [titleLabel size:@"k"];
    titleLabel.text = name;
    titleLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    titleLabel.backgroundColor = color;
    titleLabel.frameHeight = 44;
    [titleLabel sizeToFit];

    UILabel *explanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    explanationLabel.text = @"3 labor -> 1 wood";
    explanationLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    explanationLabel.textAlignment = NSTextAlignmentCenter;
    [explanationLabel size:@"k"];
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    promptLabel.text = @"How much labor? ";
    promptLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    [promptLabel sizeToFit];
    [promptLabel size:@"h"];
    
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.frameWidth = width - CGRectGetMaxX(promptLabel.frame);
    textField.font = [UIFont fontWithName:@"Menlo" size:13];
    [textField size:@"hl"];
    
    NSInteger conversion = 3;

    RACSignal *numberSignal = [textField.rac_textSignal map:^id(NSString *text) {
        NSInteger labor = MIN(text.integerValue, self.labor);
        NSInteger rounded = conversion * (labor / conversion);
        
        return @(rounded);
    }];
    
    UIView *textFieldAndPromptView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    [textFieldAndPromptView size:@"hlk"];
    [textFieldAndPromptView stackViewsHorizontallyCentered:@[promptLabel, textField]];
    
    UILabel *outputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, 44)];
    RAC(outputLabel, text) = [numberSignal map:^(NSNumber *labor) {
        return [NSString stringWithFormat:@"%@ labor -> %@ wood", labor, @(labor.integerValue * conversion)];
    }];
    outputLabel.textAlignment = NSTextAlignmentCenter;
    outputLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    [outputLabel size:@"k"];

    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 88)];
    contentView.backgroundColor = UIColor.redColor;
    [contentView size:@"jk"];
    
    [contentView stackViewsVerticallyCentered:@[explanationLabel, textFieldAndPromptView, outputLabel]];
    
    UIButton *commitButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [[commitButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [textField resignFirstResponder];
    }];
    [commitButton setTitle:@"DO IT" forState:UIControlStateNormal];
    commitButton.titleLabel.font = [UIFont fontWithName:@"Menlo" size:13];
    [commitButton size:@"j"];
    commitButton.backgroundColor = color;
    [commitButton sizeToFit];
    
    [passthroughView stackViewsVerticallyCentered:@[titleLabel, contentView, commitButton]];
    passthroughView.center = self.view.boundsCenter;
    RAC(passthroughView, center) = [RACObserve(self, unobscuredFrame) map:^id(NSValue *frame) {
        return [NSValue valueWithCGPoint:CGRectGetCenter(frame.CGRectValue)];
    }];

    [self.view addSubview:passthroughView];
    [textField becomeFirstResponder];
}

- (void)addMenuViewForTile:(SCTile *)tile {
    self.currentMenuView = [[SCRadialMenuView alloc] initWithApothem:APOTHEM buttons:[self buttonsForTile:tile]];
    self.currentMenuView.center = [self centerForPosition:tile.hex.position];
    
    self.currentMenuView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [self.tilesView addSubview:self.currentMenuView];
    
    [UIView animateWithDuration:menuAnimationDuration
                          delay:0
         usingSpringWithDamping:menuAnimationSpringDamping
          initialSpringVelocity:0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.currentMenuView.transform = CGAffineTransformIdentity;
                     } completion:nil];
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
    
    RACSignal *boundsSignal = [RACObserve(self, contentSize) map:^(NSValue *contentSizeValue) {
        CGSize contentSize = contentSizeValue.CGSizeValue;
        CGRect bounds = CGRectMake(contentSize.width * -0.5, contentSize.height * -0.5, contentSize.width, contentSize.height);
        return [NSValue valueWithCGRect:bounds];
    }];
    
    RACSignal *frameSignal = [RACObserve(self, contentSize) map:^(NSValue *contentSizeValue) {
        return [NSValue valueWithCGRect:CGRectMakeSize(PADDING, PADDING, contentSizeValue.CGSizeValue)];
    }];
    
    RAC(self.tilesView, bounds) = boundsSignal;
    RAC(self.tilesView, frame) = frameSignal;
    
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
