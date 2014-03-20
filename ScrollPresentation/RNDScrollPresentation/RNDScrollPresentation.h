//
//  RNDScrollPresentation.h
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 1/22/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RNDScrollPresentation;

@protocol RNDScrollPresentationDelegate <NSObject>

@optional
- (UIView*)scrollPresentation:(RNDScrollPresentation*)scrollPresentation viewForPage:(NSUInteger)page withSize:(CGSize)size;
- (UIView*)scrollPresentation:(RNDScrollPresentation*)scrollPresentation backgroundViewForPage:(NSUInteger)page withSize:(CGSize)size;
- (void)scrollPresentationDidLoad:(RNDScrollPresentation*)scrollPresentation;

- (void)scrollPresentation:(RNDScrollPresentation*)scrollPresentation presentationTouched:(NSUInteger)page;
- (void)scrollPresentation:(RNDScrollPresentation*)scrollPresentation presentationLongTouched:(NSUInteger)page;

@end

@interface RNDScrollPresentationInfo : NSObject

@property (nonatomic, retain) UIImage *infoImage;
@property (nonatomic, retain) NSString *infoText;
@property (nonatomic, retain) NSArray *infoTips;



@end

@interface RNDScrollPresentation : UIViewController <UIScrollViewDelegate>

- (id)initWithArray:(NSArray*)infoArray;

//implement <scrollPresentation:backgroundViewForPage:withSize:> if you want to use this initializer!
- (id)initWithPageCount:(NSUInteger)pageCount;



@property (nonatomic) BOOL textOnMiddle;
@property (nonatomic) BOOL showImgOnTap;

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;

@property (nonatomic, assign) id<RNDScrollPresentationDelegate>delegate;

@property (nonatomic, retain) UILabel *settingsLabel;
@property (nonatomic) CGFloat autoScrollDelay;
@property (nonatomic) CGFloat pageControllBottomPadding;
@property (nonatomic) UIViewContentMode imgViewContentMode;


@end
