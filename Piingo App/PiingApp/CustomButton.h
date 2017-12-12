//
//  CustomButton.h
//  Vendle
//
//  Created by Hema on 25/08/14.
//  Copyright (c) 2014 Riktam Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomButton : UIButton {
    
}

@property (nonatomic, copy) UIColor *normalBgColor;
@property (nonatomic, copy) UIColor *selectedBgColor;

-(void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)controlState;

@end
