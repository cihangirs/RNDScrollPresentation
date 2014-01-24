//
//  RNDScrollPresentation.m
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 1/22/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import "RNDScrollPresentation.h"
#import "BottomLabel.h"


@implementation RNDScrollPresentationInfo


@end

@interface RNDScrollPresentation () {
    BOOL toolbarHidden;
    
    BOOL pageControlUsed;
    int numberOfPages;
}

@property (nonatomic, retain) NSArray *infoArray;
@property (nonatomic, retain) NSMutableArray *pagedTextViews;
@property (nonatomic, retain) NSArray *pagedImgViews;

@end

@implementation RNDScrollPresentation

- (id)initWithArray:(NSArray*)infoArray {
    if(self = [self initWithNibName:nil bundle:nil]) {
        
        [self setInfoArray:infoArray];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    toolbarHidden = self.navigationController.toolbarHidden;
    
    self.scrollView.autoresizingMask =    (UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight);
    
    self.pageControl.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    if([self.navigationController.viewControllers count] == 1) {
        UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
        self.navigationItem.rightBarButtonItem = dismissItem;
    }
    
    [self setupPagedViews];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.navigationController setToolbarHidden:toolbarHidden animated:YES];
    
}

- (void)updateContentSize:(UIInterfaceOrientation)toInterfaceOrientation {
    
    CGFloat w, h;
    CGFloat a = [UIScreen mainScreen].bounds.size.width;
    CGFloat b = [UIScreen mainScreen].bounds.size.height;

    w=a, h=b;
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        w=b, h=a;
    }
    
    self.scrollView.contentSize = CGSizeMake(w * numberOfPages, h);
    
    
    
}

#pragma mark - Rotations
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    
    [self updateContentSize:toInterfaceOrientation];
    
    int page = self.pageControl.currentPage;

    [self loadScrollViewWithPage:page-1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page+1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.scrollView setContentOffset:CGPointMake(0, 0)];
    });

}

#pragma mark - Util

- (void)setupPagedViews {
    
    numberOfPages = [self.infoArray count];

    NSMutableArray *imgViews = [[NSMutableArray alloc] init];
    for (unsigned i = 0; i < numberOfPages; i++) {
        [imgViews addObject:[NSNull null]];
    }
    self.pagedTextViews = imgViews;
    
    self.scrollView.pagingEnabled = YES;
    
    [self updateContentSize:[self.navigationController interfaceOrientation]];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.maximumZoomScale = 1;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.delegate = self;
    
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.currentPage = 0;
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:numberOfPages];
    for(int i=0; i<numberOfPages; i++) {
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        imgView.autoresizingMask =    (UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleWidth  |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleHeight  |
                                        UIViewAutoresizingFlexibleBottomMargin);
        [imgView setBackgroundColor:[UIColor clearColor]];
        RNDScrollPresentationInfo *info = self.infoArray[i];
        [imgView setImage:info.infoImage];
        [imgView setAlpha:(i==0?1.0f:0.0f)];
        [tmpArray addObject:imgView];
        [self.view addSubview:imgView];
    }
    self.pagedImgViews = [NSArray arrayWithArray:tmpArray];

    [self.view bringSubviewToFront:self.scrollView];
    [self.view bringSubviewToFront:self.pageControl];
    [self.scrollView setAlpha:0.0f];
    
    [self loadScrollViewWithPage:0];
    [self loadScrollViewWithPage:1];
    
    [UIView animateWithDuration:0.6f animations:^{
        [self.scrollView setAlpha:1.0f];
    }];
}

- (void)addTips {
    //TODO
}

- (void)loadScrollViewWithPage:(int)page {
    
    if (page < 0) return;
    if (page >= numberOfPages) return;
    
    const CGFloat xPadding = 30;
    const CGFloat yPadding = 15;
    
    BottomLabel *lblText = [self.pagedTextViews objectAtIndex:page];
    
    if ((NSNull *)lblText == [NSNull null]) {
        
        lblText = [[BottomLabel alloc] init];
        lblText.numberOfLines = 0;

        //label settings
        [lblText setFont:self.settingsLabel.font];
        [lblText setBackgroundColor:self.settingsLabel.backgroundColor];
        [lblText setTextColor:self.settingsLabel.textColor];
        [lblText setTextAlignment:self.settingsLabel.textAlignment];
        [lblText setLineBreakMode:self.settingsLabel.lineBreakMode];
        
        lblText.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                       UIViewAutoresizingFlexibleWidth  |
                                       UIViewAutoresizingFlexibleRightMargin |
                                       UIViewAutoresizingFlexibleTopMargin |
                                       UIViewAutoresizingFlexibleHeight  |
                                       UIViewAutoresizingFlexibleBottomMargin);
        
        CGFloat height = 300;
        
        if (lblText.superview == nil) {
            
            CGRect frame = self.scrollView.frame;
            
            frame.origin.x = frame.size.width * page + xPadding;
            frame.origin.y = self.pageControl.frame.origin.y - (yPadding + height);
            frame.size.width -= 2*xPadding;
            frame.size.height = height;
            [lblText setFrame:frame];
            
            [self.scrollView addSubview:lblText];
            
        }
        
        RNDScrollPresentationInfo *info = self.infoArray[page];
        [lblText setText:info.infoText];
        
        [self addTips];
        
        [self.pagedTextViews replaceObjectAtIndex:page withObject:lblText];
        
    }
    
    
}

- (void)offsetChanged:(CGFloat)offset {
    
    const CGFloat kMul = 1.0f;
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSUInteger page = floor((offset - pageWidth / 2) / pageWidth) + 1;
    CGFloat diff = offset - page * pageWidth;
    CGFloat perc = diff / pageWidth * kMul;
    
    NSUInteger otherPage;
    if(perc < 0) {
        otherPage  = page - 1;
    }
    else {
        otherPage = page + 1;
    }
    
    CGFloat otherAlpha = fabs(perc);
    CGFloat alpha = kMul - otherAlpha;
    

    NSLog(@"%d:%f - %d:%f",page, alpha, otherPage, otherAlpha);
    
    if(page < numberOfPages) {
        [self.pagedImgViews[page] setAlpha:alpha];
    }
    if(otherPage < numberOfPages) {
        [self.pagedImgViews[otherPage] setAlpha:otherAlpha];
    }
    
}

#pragma mark - Actions
- (IBAction)changePage:(id)sender {
    int page = self.pageControl.currentPage;
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    pageControlUsed = YES;
}


- (void)dismiss:(id)sender {
    if([self.navigationController.viewControllers count] == 1) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            ;
        }];

    }
    else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}


#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)sender {
 
    CGFloat pageWidth = self.scrollView.frame.size.width;
    CGFloat offset = self.scrollView.contentOffset.x;
    [self offsetChanged:offset];
    
    int page = floor((offset - pageWidth / 2) / pageWidth) + 1;
    
    if(self.pageControl.currentPage != page) {
        
        self.pageControl.currentPage = page;
        
        [self loadScrollViewWithPage:page - 1];
        [self loadScrollViewWithPage:page];
        [self loadScrollViewWithPage:page + 1];
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlUsed = NO;
}



@end
