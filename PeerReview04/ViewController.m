//
//  ViewController.m
//  PeerReview04
//
//  Created by Miguel Melendez on 5/31/16.
//  Copyright © 2016 Miguel Melendez. All rights reserved.
//

#import "ViewController.h"
#import "DistanceGetter/DGDistanceRequest.h"

@interface ViewController ()

@property (nonatomic) DGDistanceRequest *req;

@property (weak, nonatomic) IBOutlet UITextField *startLocation;
@property (weak, nonatomic) IBOutlet UITextField *endLocationA;
@property (weak, nonatomic) IBOutlet UITextField *endLocationB;
@property (weak, nonatomic) IBOutlet UITextField *endLocationC;

@property (weak, nonatomic) IBOutlet UILabel *distanceA;
@property (weak, nonatomic) IBOutlet UILabel *distanceB;
@property (weak, nonatomic) IBOutlet UILabel *distanceC;

@property (weak, nonatomic) IBOutlet UIButton *calculateButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *unitController;

@end

@implementation ViewController

- (IBAction)calculateButtonPressed:(id)sender {
    
    self.calculateButton.enabled = NO;
    
    self.req = [DGDistanceRequest alloc];
    NSString *start = self.startLocation.text;
    NSString *destA = self.endLocationA.text;
    NSString *destB = self.endLocationB.text;
    NSString *destC = self.endLocationC.text;
    NSArray *dests = @[destA,destB,destC];
    
    self.req = [self.req initWithLocationDescriptions:dests sourceDescription:start];
    
    __weak ViewController *weakSelf = self;
    
    self.req.callback = ^void(NSArray *responses){
        ViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        NSString* (^convertUnit)(float) = ^(float num) {
            if (strongSelf.unitController.selectedSegmentIndex == 0) {
                NSString *temp = [NSString stringWithFormat:@"%.2f meters", num];
                return temp;
            } else if (strongSelf.unitController.selectedSegmentIndex == 1) {
                NSString *temp = [NSString stringWithFormat:@"%.2f kilometers", num / 1000];
                return temp;
            } else if (strongSelf.unitController.selectedSegmentIndex == 2) {
                NSString *temp = [NSString stringWithFormat:@"%.2f miles", num * 0.000621371];
                return temp;
            } else {
                return @"Could not determine.";
            }
        };
        
        [responses enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSNull *badResult = [NSNull null];
            
            if (responses[idx] != badResult) {
                NSString *convertedUnit = convertUnit([responses[idx] floatValue]);
                if(idx == 0) strongSelf.distanceA.text = convertedUnit;
                if(idx == 1) strongSelf.distanceB.text = convertedUnit;
                if(idx == 2) strongSelf.distanceC.text = convertedUnit;
            } else {
                if(idx == 0) strongSelf.distanceA.text = @"Couldn't find that city.";
                if(idx == 1) strongSelf.distanceB.text = @"Couldn't find that city.";
                if(idx == 2) strongSelf.distanceC.text = @"Couldn't find that city.";
            }
        }];

        strongSelf.req = nil;
        strongSelf.calculateButton.enabled = YES;
        
    };
    
    [self.req start];
    
}

@end