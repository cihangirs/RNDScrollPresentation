//
//  MerchantTableHeaderCell.m
//  OdeAlClient
//
//  Created by Vladimir Nabokov on 12/26/13.
//  Copyright (c) 2013 Anil Can Baykal. All rights reserved.
//

#import "BottomLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation BottomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    
    }
    return self;
}

- (void)awakeFromNib {
    [self setup];
}

- (void)setup {
    
    [self.layer setMasksToBounds:YES];
    [self.layer setCornerRadius:5.0f];
    
    [self setBackgroundColor:[UIColor clearColor]];
    [self setTextColor:[UIColor colorWithWhite:0.390 alpha:1.000]];
   
    [self setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [self setTextAlignment:NSTextAlignmentCenter];
}

- (void)setText:(NSString *)text {
    
    if([text isEqualToString:self.text])  {   return; }
    
    text = [NSString stringWithFormat:@" %@ ",text];
    [super setText:text];
    

    CGSize constraint = CGSizeMake(self.frame.size.width, INT_MAX);
    
    CGSize size = [text sizeWithFont:self.font constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGRect frame = self.frame;
    
    CGFloat yTop = frame.origin.y + frame.size.height - size.height;
    frame.origin.y = yTop;
    frame.size.height = size.height;
    
    [self setFrame:frame];
    
}


@end
