//
//  LoaderView.m
//  ctsexytime2
//
//  Created by Srik on 5/21/12.
//  Copyright (c) 2012 Riktam. All rights reserved.
//

#import "CustomLoaderView.h"

@implementation CustomLoaderView
@synthesize loader, loaderText;

- (id)initWithFrame:(CGRect)frame andType:(int)type
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
        self.backgroundColor = [UIColor redColor];
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        self.backgroundColor=[UIColor clearColor];
//        CGPoint center = ;

        labelView = [[UIView alloc] initWithFrame:CGRectMake((screenSize.width/2)-75, screenSize.height/2-50, 150, 105)];
        labelView.backgroundColor = [UIColor blackColor];
        labelView.layer.cornerRadius = 10.0;
        labelView.alpha = 0.7;
        [self addSubview:labelView];
        
        
        if (type == 1) {
            self.loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            self.loader.frame = CGRectMake((labelView.frame.size.width/2)-13, (labelView.frame.size.height/2)-13, 26, 26);
        }
        else{
            self.loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.loader.frame = CGRectMake((labelView.frame.size.width/2)-13, (labelView.frame.size.height/2)-13, 26, 26);
        }
        
        self.hidden = YES;
        
        pleaseWaitLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelView.frame.size.width/2)-65, (labelView.frame.size.height)-40, 130, 35)];
        pleaseWaitLabel.backgroundColor = [UIColor clearColor];
        pleaseWaitLabel .textColor = [UIColor whiteColor];
        pleaseWaitLabel.numberOfLines = 0;
        pleaseWaitLabel.textAlignment = NSTextAlignmentCenter;
        pleaseWaitLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13];
        [labelView addSubview:pleaseWaitLabel];
        
        [labelView addSubview:self.loader];
        
//        loaderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, (screen_height-80)/2, 80, 80)];
//        //loaderImageView.center = self.center;
//        NSMutableArray *imageAry =[NSMutableArray array];
//        //for (int i=1; i<=48; i++) {
//        for (int i=1; i<=23; i++) {
//
//          //  [imageAry addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loader_redgif%d.png",i]]];
//            //loader_round
//            [imageAry addObject:[UIImage imageNamed:[NSString stringWithFormat:@"loader_round%d.png",i]]];
//
//        }
//        loaderImageView.animationImages = imageAry;
//        // all frames will execute in 1.75 seconds
//        loaderImageView.animationDuration = 0.8;
//        // repeat the animation forever
//        loaderImageView.animationRepeatCount = 0;
//
//        // add the animation view to the main window
//        [self addSubview:loaderImageView];

    }
    return self;
}

-(void)setLoaderViewFrame{
    
   // labelView.frame = CGRectMake((self.frame.size.width-150)/2, (self.frame.size.height-105)/2, 150, 105);
}
-(void)setSmallLoaderViewFrame{
//    labelView.frame = CGRectMake((self.frame.size.width-150)/2, (self.frame.size.height-50)/2, 150, 50);
// self.loader.frame = CGRectMake((labelView.frame.size.width/2)-13, (labelView.frame.size.height/2)-13-10, 26, 26);
//    pleaseWaitLabel.frame = CGRectMake((labelView.frame.size.width/2)-65, (labelView.frame.size.height)-30, 130, 35);

}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)startLoading{
    
    self.hidden = NO;

    if (self.loaderText.length>0) {
        pleaseWaitLabel.text = self.loaderText;
    }
    else{
        pleaseWaitLabel.text = @"Loading";
    }
    if(self.loader)
    [self.loader startAnimating];

//    self.hidden = NO;
//    [loaderImageView startAnimating];
}

-(void)stopLoading{
    
    [self.loader stopAnimating];
    self.hidden = YES;

//    [loaderImageView stopAnimating];
    
}

@end
