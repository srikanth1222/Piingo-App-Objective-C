//
//  ChangePasswordViewController.m
//  PiingApp
//
//  Created by Veedepu Srikanth on 11/12/17.
//  Copyright © 2017 shashank. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "AppDelegate.h"

@interface ChangePasswordViewController ()
{
    AppDelegate *appDel;
}

@end

@implementation ChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.title = @"Change Password";
    [self setupMenuBarButtonItems];

}

- (IBAction) changePasswordClicked:(id)sender
{
    if ([oldPassword.text length] && [newPassword.text length] && [confirmPassword.text length])
    {
        if ([newPassword.text isEqualToString:confirmPassword.text])
        {
            [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
            
            NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:                [[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"], @"email", oldPassword.text, @"oldpassword", newPassword.text, @"password", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/piingo/changepassword", BASE_URL];
            
            [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                
                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                {
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    oldPassword.text = @"";
                    newPassword.text = @"";
                    confirmPassword.text = @"";
                    
                    [appDel piingoLogout];
                    
                    [AppDelegate showAlertWithMessage:@"Password changed successfully. Please Login again." andTitle:@"Success" andBtnTitle:@"OK"];
                }
                else
                {
                    [appDel displayErrorMessagErrorResponse:responseObj];
                }
            }];
        }
        else
        {
            [AppDelegate showAlertWithMessage:@"New & confirm password must be same" andTitle:@"" andBtnTitle:@"OK"];
        }
    }
}


- (void)setupMenuBarButtonItems {
    
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    self.navigationItem.rightBarButtonItem = nil;
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"listButton"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    
    [appDel.sideMenuViewController presentLeftMenuViewController];
    
    // [self setupMenuBarButtonItems];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
