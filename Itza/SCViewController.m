//
//  SCViewController.m
//  Itza
//
//  Created by Ian Henry on 4/2/14.
//  Copyright (c) 2014 Ian Henry. All rights reserved.
//

#import "SCViewController.h"

@interface SCViewController ()

@property (strong, nonatomic) IBOutlet UIButton *endTurnButton;
@property (strong, nonatomic) IBOutlet UILabel *populationLabel;
@property (strong, nonatomic) IBOutlet UILabel *turnLabel;

@property (nonatomic, assign) NSUInteger turn;
@property (nonatomic, assign) NSUInteger population;
@property (nonatomic, assign) NSUInteger meat;
@property (nonatomic, assign) NSUInteger maize;

@end

@implementation SCViewController

- (void)viewDidLoad {
    self.population = 100;
    self.maize = 100;
    self.meat = 100;
    
    RAC(self.turnLabel, text) = [RACObserve(self, turn) map:^id(NSNumber *turn) {
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
        self.turn += 1;
        if (self.population > 0) {
            self.population -= 1;
            self.maize -= 1;
            self.meat -= 1;
        }
    }];
}

@end
