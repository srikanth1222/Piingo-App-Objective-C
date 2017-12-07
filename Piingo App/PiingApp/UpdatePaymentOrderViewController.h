//
//  UpdatePaymentOrderViewController.h
//  PiingApp
//
//  Created by SHASHANK on 17/08/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UpdatePaymentOrderViewControllerDelegate <NSObject>

-(void) didConformPatyment;


@end

@interface UpdatePaymentOrderViewController : UIViewController

@property (nonatomic, strong) id <UpdatePaymentOrderViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *strTotalAmount;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andIscurrentJobDetails:(id) jobDetails;

@end
