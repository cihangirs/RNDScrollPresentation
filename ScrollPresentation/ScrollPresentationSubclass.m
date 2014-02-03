//
//  ScrollPresentationSubclass.m
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 2/3/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import "ScrollPresentationSubclass.h"

@interface ScrollPresentationSubclass ()

@end

@implementation ScrollPresentationSubclass

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(50, 70, 70, 20)];
    [label setBackgroundColor:[UIColor colorWithRed:0.554 green:0.561 blue:1.000 alpha:0.510]];
    [label setText:@"subclass"];
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
