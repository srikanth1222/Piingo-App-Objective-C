//
//  ChangePasswordViewController.h
//  PiingApp
//
//  Created by Veedepu Srikanth on 11/12/17.
//  Copyright © 2017 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePasswordViewController : UIViewController
{
    
    IBOutlet UITextField *oldPassword;
    IBOutlet UITextField *newPassword;
    IBOutlet UITextField *confirmPassword;
}

- (IBAction) changePasswordClicked:(id)sender;

@end
