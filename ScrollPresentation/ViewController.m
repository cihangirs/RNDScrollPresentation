//
//  ViewController.m
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 1/22/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import "ViewController.h"
#import "RNDScrollPresentation.h"

@interface ViewController ()

@property (nonatomic, retain) RNDScrollPresentation *vc;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTouched:(id)sender {
    [self present:[(UIButton*)sender tag]];
}

- (IBAction)buttonRemoveTouched:(id)sender {
    [self.vc.view removeFromSuperview];
    self.vc = nil;
    [self.btnRemoveSubview setEnabled:NO];
}

#pragma mark - Util
- (void)present:(NSUInteger)type {
    
    RNDScrollPresentationInfo *info0 = [RNDScrollPresentationInfo new];
    info0.infoImage = [UIImage imageNamed:@"img0"];
    info0.infoText = @"Apple was established on April 1, 1976, by Steve Jobs, Steve Wozniak and Ronald Wayne[17][18] to sell the Apple I personal computer kit, a computer single handedly designed by Wozniak.";
    
    RNDScrollPresentationInfo *info1 = [RNDScrollPresentationInfo new];
    info1.infoImage = [UIImage imageNamed:@"img1"];
    info1.infoText = @"Apple was incorporated January 3, 1977,[29] without Wayne, who sold his share of the company back to Jobs and Wozniak for US$800";
    
    RNDScrollPresentationInfo *info2 = [RNDScrollPresentationInfo new];
    info2.infoImage = [UIImage imageNamed:@"img2"];
    info2.infoText = @"Jobs and several Apple employees, including Jef Raskin, visited Xerox PARC in December 1979 to see the Xerox Alto. Xerox granted Apple engineers three days of access to the PARC facilities in return for the option to buy 100,000 shares (800,000 split-adjusted shares) of Apple at the pre-IPO price of $10 a shar";
    
    self.vc = [[RNDScrollPresentation alloc]initWithArray:@[info0,info1,info2]];
   
    UILabel *dummyLabel = [[UILabel alloc]init];
    dummyLabel.backgroundColor = [UIColor clearColor];
    dummyLabel.textColor = [UIColor whiteColor];
    dummyLabel.font = [UIFont systemFontOfSize:15];
    dummyLabel.textAlignment = NSTextAlignmentCenter;
    [self.vc setSettingsLabel:dummyLabel];
    
    if(type == 0) {
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:self.vc];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else if(type == 1) {
        [self.navigationController pushViewController:self.vc animated:YES];
    }
    else if(type == 2) {
        [self.vc.view setFrame:CGRectMake(20, 100, 280, 280)];
        [self.view addSubview:self.vc.view];
        [self.btnRemoveSubview setEnabled:YES];
        
    }
}

@end
