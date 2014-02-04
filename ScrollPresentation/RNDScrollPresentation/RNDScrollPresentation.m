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
    
    int numberOfPages;
}

@property (nonatomic, retain) NSTimer *autoScrollTimer;

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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.scrollView setDelegate:self];
    [self.view addSubview:self.scrollView];
    
    CGFloat bottomPaddingY = (self.pageControllBottomPadding ? self.pageControllBottomPadding:38);
    CGRect pageControlFrame = CGRectMake(0, self.view.bounds.size.height - bottomPaddingY, self.view.bounds.size.width, 37);
    self.pageControl = [[UIPageControl alloc]initWithFrame:pageControlFrame];
    [self.view addSubview:self.pageControl];
    
    [self.view addSubview:self.pageControl];
    
    self.scrollView.autoresizingMask =    (UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight);
    
    self.pageControl.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleRightMargin);
    

    
    if([self.navigationController.viewControllers count] == 1) {
        UIBarButtonItem *dismissItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss:)];
        self.navigationItem.rightBarButtonItem = dismissItem;
    }
    
    [self setupPagedViews];
    
    [self checkTimer];
    
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateContentSize:[self.navigationController interfaceOrientation]];
}

- (void)updateContentSize:(UIInterfaceOrientation)toInterfaceOrientation {
    
    CGFloat w, h;
 
    CGFloat a = self.scrollView.bounds.size.width;
    CGFloat b = self.scrollView.bounds.size.height;
    
    w=a, h=b;
    
//    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
//        w=b, h=a;
//    }
    
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
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self.scrollView addGestureRecognizer:gesture];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:numberOfPages];
    for(int i=0; i<numberOfPages; i++) {
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        imgView.autoresizingMask =    (UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleWidth  |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleHeight  |
                                        UIViewAutoresizingFlexibleBottomMargin);
        
        [imgView setContentMode:UIViewContentModeScaleAspectFit];
        
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
    const CGFloat height = 300;
    
    UIView *presentationView = [self.pagedTextViews objectAtIndex:page];
    
    if ((NSNull *)presentationView == [NSNull null]) {
        
        presentationView = [self.delegate presentationViewForPage:page withSize:CGSizeMake(self.scrollView.frame.size.width - 2*xPadding, height)];
        
        if(!presentationView) {
            presentationView = [self defaultPresentationView:page];
        }
        
        if(presentationView) {
            presentationView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
                                        UIViewAutoresizingFlexibleWidth  |
                                        UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleHeight  |
                                        UIViewAutoresizingFlexibleBottomMargin);
            
            if (presentationView.superview == nil) {
                
                CGRect frame = self.scrollView.frame;
                
                frame.origin.x = frame.size.width * page + xPadding;
                frame.origin.y = self.pageControl.frame.origin.y - (yPadding + height);
                frame.size.width -= 2*xPadding;
                frame.size.height = height;
                [presentationView setFrame:frame];
                
                [self.scrollView addSubview:presentationView];
                
            }
            
            [self addTips];
            
            [self.pagedTextViews replaceObjectAtIndex:page withObject:presentationView];
        }
        
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
    

    //NSLog(@"%d:%f - %d:%f",page, alpha, otherPage, otherAlpha);
    
    if(page < numberOfPages) {
        [self.pagedImgViews[page] setAlpha:alpha];
    }
    if(otherPage < numberOfPages) {
        [self.pagedImgViews[otherPage] setAlpha:otherAlpha];
    }
    
}

- (void)checkTimer {
    if (self.autoScrollDelay) {
        self.autoScrollTimer = [NSTimer timerWithTimeInterval:self.autoScrollDelay
                                                       target:self
                                                     selector:@selector(autoScroll:)
                                                     userInfo:nil
                                                      repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.autoScrollTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)autoScroll:(id)sender {
    [self changePage:nil];
}

- (UIView*)defaultPresentationView:(NSUInteger)page {
    
    RNDScrollPresentationInfo *info = self.infoArray[page];
    BottomLabel *lblText = nil;
    
    if(info.infoText) {
        //...
        
        lblText = [[BottomLabel alloc] init];
        lblText.numberOfLines = 0;
        
        if(self.settingsLabel) {
            //label settings
            [lblText setFont:self.settingsLabel.font];
            [lblText setBackgroundColor:self.settingsLabel.backgroundColor];
            [lblText setTextColor:self.settingsLabel.textColor];
            [lblText setTextAlignment:self.settingsLabel.textAlignment];
            [lblText setLineBreakMode:self.settingsLabel.lineBreakMode];
        }
        
        [lblText setText:info.infoText];
        //...
    }
    
    return lblText;
}

#pragma mark - Actions
- (IBAction)changePage:(id)sender {
    
    int page = self.pageControl.currentPage;
    if(++page == numberOfPages) {
        double delayInSeconds = 0.2;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [UIView animateWithDuration:0.4f animations:^{
                [self.pagedImgViews[numberOfPages-1] setAlpha:0.0f];
            }];
        });
        page = 0;
    }
    
    [self loadScrollViewWithPage:page - 1];
    [self loadScrollViewWithPage:page];
    [self loadScrollViewWithPage:page + 1];
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];

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

- (void)tapped:(UIGestureRecognizer*)gesture {
    if(gesture.state == UIGestureRecognizerStateEnded) {
        if([self.delegate respondsToSelector:@selector(presentationTouched:)]) {
            [self.delegate presentationTouched:self.pageControl.currentPage];
        }
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

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.autoScrollTimer invalidate];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self checkTimer];
}

@end
