//
//  RNDScrollPresentation.h
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 1/22/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RNDScrollPresentationDelegate <NSObject>

@required
- (UIView*)presentationViewForPage:(NSUInteger)page withSize:(CGSize)size;

@optional
- (void)presentationTouched:(NSUInteger)page;

@end

@interface RNDScrollPresentationInfo : NSObject

@property (nonatomic, retain) UIImage *infoImage;
@property (nonatomic, retain) NSString *infoText;
@property (nonatomic, retain) NSArray *infoTips;

@end

@interface RNDScrollPresentation : UIViewController <UIScrollViewDelegate>

- (id)initWithArray:(NSArray*)infoArray;


@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, assign) id<RNDScrollPresentationDelegate>delegate;

@property (nonatomic, retain) UILabel *settingsLabel;
@property (nonatomic) CGFloat autoScrollDelay;
@property (nonatomic) CGFloat pageControllBottomPadding;


@end
