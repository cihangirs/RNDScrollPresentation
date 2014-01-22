//
//  RNDScrollPresentation.h
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 1/22/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RNDScrollPresentationInfo : NSObject

@property (nonatomic, retain) UIImage *infoImage;
@property (nonatomic, retain) NSString *infoText;
@property (nonatomic, retain) NSArray *infoTips;

@end

@interface RNDScrollPresentation : UIViewController <UIScrollViewDelegate>

- (id)initWithArray:(NSArray*)infoArray;



@property (nonatomic, assign) IBOutlet UIScrollView *scrollView;
@property (nonatomic, assign) IBOutlet UIPageControl *pageControl;

@property (nonatomic, retain) UILabel *settingsLabel;


@end
