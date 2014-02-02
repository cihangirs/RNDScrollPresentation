//
//  ViewController.h
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 1/22/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNDScrollPresentation.h"

@interface ViewController : UIViewController <RNDScrollPresentationDelegate>

- (IBAction)buttonTouched:(id)sender;

@property (nonatomic, assign) IBOutlet UIButton *btnRemoveSubview;
- (IBAction)buttonRemoveTouched:(id)sender;

@end
