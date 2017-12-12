//
//  LoaderView.h
//  ctsexytime2
//
//  Created by Srik on 5/21/12.
//  Copyright (c) 2012 Riktam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomLoaderView : UIView{
    UILabel *pleaseWaitLabel;
    UIView *labelView;
    UIImageView *loaderImageView;
}

@property(nonatomic, retain) UIActivityIndicatorView *loader;
@property(nonatomic, retain, readwrite) NSString *loaderText;

- (id)initWithFrame:(CGRect)frame andType:(int)type;
-(void)startLoading;
-(void)stopLoading;
-(void)setLoaderViewFrame;
-(void)setSmallLoaderViewFrame;

@end
