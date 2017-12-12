//
//  CalculateViewController.h
//  PiingApp
//
//  Created by Veedepu Srikanth on 27/09/16.
//  Copyright © 2016 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalculateViewControllerDelegate <NSObject>

-(void) didAdditems:(CGFloat) value;

@end


@interface CalculateViewController : UIViewController

@property (nonatomic, strong) id <CalculateViewControllerDelegate> delegate;

@end
