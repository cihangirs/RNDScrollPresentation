//
//  RNDScrollPresentation.m
//  ScrollPresentation
//
//  Created by Vladimir Nabokov on 1/22/14.
//  Copyright (c) 2014 Evren Kanalici. All rights reserved.
//

#import "RNDScrollPresentation.h"
#import "BottomLabel.h"

#define DEBUG_COLORS    (0)

#define xPadding (10)
#define yPadding (10)


@implementation RNDScrollPresentationInfo

@end

@interface RNDScrollPresentation () {
    BOOL toolbarHidden;
    BOOL firstAppear;
    int numberOfPages;
}

@property (nonatomic, retain) NSTimer *autoScrollTimer;

@property (nonatomic, retain) NSArray *infoArray;
@property (nonatomic, retain) NSMutableArray *pagedTextViews;
@property (nonatomic, retain) NSArray *pagedImgViews;

@end

@implementation RNDScrollPresentation


- (id)initWithPageCount:(NSUInteger)pageCount {
    if(self = [self initWithNibName:nil bundle:nil]) {
        
        NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:pageCount];
        for(int i=0; i<pageCount; i++) {
            [tmpArray addObject:[NSNull null]];
        }
        
        self.infoArray = [NSArray arrayWithArray:tmpArray];
        
        
    }
    return self;
}

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
    
    
    
    self.view.autoresizingMask =    (UIViewAutoresizingFlexibleLeftMargin |
                                     UIViewAutoresizingFlexibleWidth  |
                                     UIViewAutoresizingFlexibleRightMargin |
                                     UIViewAutoresizingFlexibleTopMargin |
                                     UIViewAutoresizingFlexibleHeight  |
                                     UIViewAutoresizingFlexibleBottomMargin);
    
    self.view.autoresizesSubviews = YES;
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    if(DEBUG_COLORS){
        [self.scrollView setBackgroundColor:[UIColor colorWithRed:1.000 green:0.500 blue:0.000 alpha:0.360]];
    }
    
    CGFloat bottomPaddingY = (self.pageControllBottomPadding ? self.pageControllBottomPadding:38);
    CGRect pageControlFrame = CGRectMake(0, self.view.bounds.size.height - bottomPaddingY, self.view.bounds.size.width, 37);
    self.pageControl = [[UIPageControl alloc]initWithFrame:pageControlFrame];
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
    
    if([self.delegate respondsToSelector:@selector(scrollPresentationDidLoad:)]) {
        [self.delegate scrollPresentationDidLoad:self];
    }
    
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods {
    return NO;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
    [self.scrollView setDelegate:self];

    if(firstAppear) {
        [self changePage:nil];
    }
    if(!firstAppear) {
        firstAppear = YES;

    }
    [self checkTimer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.navigationController setToolbarHidden:toolbarHidden animated:YES];
    
    
    [self.scrollView setDelegate:nil];
    
    [self.autoScrollTimer invalidate];
    

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self updateContentSize:[self.navigationController interfaceOrientation]];
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
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTapped:)];
    longGesture.minimumPressDuration = 0.2f;
    [self.scrollView addGestureRecognizer:longGesture];
    
    NSMutableArray *tmpArray = [[NSMutableArray alloc]initWithCapacity:numberOfPages];
    for(int i=0; i<numberOfPages; i++) {
        UIView *bgView = nil;
        
        
        if([self.delegate respondsToSelector:@selector(scrollPresentation:backgroundViewForPage:withSize:)]) {
            bgView = [self.delegate scrollPresentation:self backgroundViewForPage:i withSize:self.view.bounds.size];
        }
        
        if(bgView == nil) {//use image array
            
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
            
            [imgView setContentMode:self.imgViewContentMode];
            
            RNDScrollPresentationInfo *info = self.infoArray[i];
            [imgView setImage:info.infoImage];
            
            bgView = imgView;
        }
        
        bgView.autoresizingMask =    (UIViewAutoresizingFlexibleLeftMargin |
                                      UIViewAutoresizingFlexibleWidth  |
                                      UIViewAutoresizingFlexibleRightMargin |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleHeight  |
                                      UIViewAutoresizingFlexibleBottomMargin);
        
        [bgView setBackgroundColor:[UIColor clearColor]];
        
        if(DEBUG_COLORS) {
            [bgView setBackgroundColor:[UIColor colorWithRed:1.000 green:0.500 blue:0.000 alpha:0.450]];
        }
        
        [bgView setAlpha:(i==0?1.0f:0.0f)];
        
        [tmpArray addObject:bgView];
        [self.view addSubview:bgView];
        
    }//end for
    
    
    
    self.pagedImgViews = [NSArray arrayWithArray:tmpArray];
    
    [self.view bringSubviewToFront:self.scrollView];
    [self.view bringSubviewToFront:self.pageControl];
    [self.scrollView setAlpha:0.0f];
    
    
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self loadScrollViewWithPage:0];
        [self loadScrollViewWithPage:1];
        
        [UIView animateWithDuration:0.6f animations:^{
            [self.scrollView setAlpha:1.0f];
        }];
    });
    
    
    
}

- (void)addTips {
    //TODO
}

- (void)loadScrollViewWithPage:(int)page {
    
    if (page < 0) return;
    if (page >= numberOfPages) return;
    
    
    CGFloat height = self.view.frame.size.height;
    
    UIView *presentationView = [self.pagedTextViews objectAtIndex:page];
    
    
    CGRect frame = self.scrollView.frame;
    CGFloat bottom = height - self.pageControl.frame.origin.y;
    
    frame.origin.x = frame.size.width * page + xPadding;
    frame.origin.y = yPadding;
    frame.size.width -= 2*xPadding;
    frame.size.height = height - (bottom + yPadding);
    
    if ((NSNull *)presentationView == [NSNull null]) {
        
        if([self.delegate respondsToSelector:@selector(scrollPresentation:viewForPage:withSize:)]) {
            presentationView = [self.delegate scrollPresentation:self viewForPage:page withSize:frame.size];
        }
        
        if(presentationView == nil || (NSNull*)presentationView == [NSNull null]) {
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
                
                
                [presentationView setAlpha:0];
                [self.scrollView addSubview:presentationView];
                
                if(DEBUG_COLORS) {
                    [presentationView setBackgroundColor:[UIColor colorWithRed:0.000 green:0.000 blue:1.000 alpha:0.810]];
                }
                
            }
            
            [self addTips];
            
            [self.pagedTextViews replaceObjectAtIndex:page withObject:presentationView];
        }
        
    }
    
    if(presentationView) {
        
        [presentationView setFrame:frame];
        if(presentationView.alpha < 1) {
            
            [UIView animateWithDuration:0.3f animations:^{
                [presentationView setAlpha:1];
                
            }completion:nil];
            
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

- (void)checkTimer {
    
    if(numberOfPages < 2)   { return;   }
    
    if (self.autoScrollDelay && !self.autoScrollTimer.isValid) {
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
    UILabel *lblText = nil;
    
    if((NSNull*)info != [NSNull null]) {
        if(info.infoText) {
            //...
            
            if(self.textOnMiddle) {
                lblText = [[UILabel alloc] init];
            }
            else {
                lblText = [[BottomLabel alloc] init];
            }
            
            CGRect frame = self.scrollView.frame;
            frame.size.width -= 2*xPadding;
            [lblText setFrame:frame];
            
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
                for(int i = 1; i < numberOfPages; i++) {
                    [self.pagedImgViews[i] setAlpha:0.0f];
                }
                
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
        if([self.delegate respondsToSelector:@selector(scrollPresentation:presentationTouched:)]) {
            [self.delegate scrollPresentation:self  presentationTouched:self.pageControl.currentPage];
        }
    }
}

- (void)longTapped:(UIGestureRecognizer*)gesture {
    if(gesture.state == UIGestureRecognizerStateEnded) {
        if([self.delegate respondsToSelector:@selector(scrollPresentation:presentationLongTouched:)]) {
            [self.delegate scrollPresentation:self presentationLongTouched:self.pageControl.currentPage];
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
