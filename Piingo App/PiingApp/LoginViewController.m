//
//  LoginViewController.m
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "LoginViewController.h"
#import "ForgetViewController.h"

@interface LoginViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSString *emailString,*passwordString;
    UITextField *tempTf;
    AppDelegate *appDel;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Login";

    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    self.navigationItem.leftBarButtonItem = nil;
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg"];
    [self.view addSubview: animatedImageView];
    
    UITableView *logingDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(26.5, 10, screen_width - 53 , screen_height-64)];
    //    logingDetailTableView.scrollEnabled = YES;
    //    logingDetailTableView.layer.cornerRadius = 5.0;
    logingDetailTableView.delegate = self;
    logingDetailTableView.dataSource = self;
    logingDetailTableView.separatorColor = [UIColor clearColor];
    logingDetailTableView.backgroundColor = [UIColor clearColor];
    logingDetailTableView.backgroundView = nil;
    logingDetailTableView.showsVerticalScrollIndicator = NO;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
        logingDetailTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, logingDetailTableView.frame.size.width, 145+10)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15.0, 130, 80)];
    logoImage.backgroundColor = [UIColor clearColor];
    logoImage.image = [UIImage imageNamed:@"logo_login_page"];
    logoImage.center = CGPointMake(CGRectGetMidX(headerView.frame), CGRectGetMidY(headerView.frame));
    [headerView addSubview:logoImage];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, headerView.frame.size.height-25.0-10.0, headerView.frame.size.width, 25.0)];
    headerLabel.text = @"Dry Cleaning and Laundry delivered at a tap!";
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.textColor = [UIColor colorWithRed:94.0/255.0 green:95.0/255.0 blue:96.0/255.0 alpha:1.0];
    headerLabel.textColor = [UIColor colorWithRed:104.0/255.0 green:104.0/255.0 blue:104.0/255.0 alpha:1.0];
    headerLabel.font = [UIFont fontWithName:APPFONT_LIGHT size:16.0];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.backgroundColor= [UIColor clearColor];
    [headerView addSubview:headerLabel];
    
    logingDetailTableView.tableHeaderView = headerView;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, logingDetailTableView.frame.size.width, 100.0+35.0)];
    footerView.backgroundColor = [UIColor clearColor];
    footerView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:236.0/255.0 alpha:0.65];
    
        UIBezierPath *maskPath;
        maskPath = [UIBezierPath bezierPathWithRoundedRect:footerView.bounds
                                         byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                               cornerRadii:CGSizeMake(5.0, 5.0)];
    
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = footerView.bounds;
        maskLayer.path = maskPath.CGPath;

    footerView.layer.mask = maskLayer;
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    loginButton.frame = CGRectMake(15.0, 25.0+2.5, footerView.frame.size.width-30.0, 46.0);
    loginButton.layer.cornerRadius = 5.0;
//    UIImage *image1 = [UIImage imageNamed:@"green_btn"];
//    image1 = [image1 resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [loginButton setTitle:@"LOG IN" forState:UIControlStateNormal];
    [loginButton.titleLabel setFont:[UIFont fontWithName:APPFONT_SEMI_BOLD size:16.0]];
    loginButton.backgroundColor = APP_GREEN_THEME_COLOR;
    //[loginButton setBackgroundImage:image1 forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(loginBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:loginButton];
    
    UIButton *forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetButton.frame = CGRectMake(15.0, screen_height-50, 150, 50.0);
    forgetButton.center = CGPointMake(footerView.frame.size.width/2, footerView.frame.size.height-30);
    [forgetButton setTitle:@"Forgot password ?" forState:UIControlStateNormal];
//    [forgetButton setTitleColor:[UIColor colorWithRed:38.0/255.0 green:183.0/255.0 blue:251.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [forgetButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.75] forState:UIControlStateNormal];
    [forgetButton setTitleColor:[[UIColor colorWithRed:38.0/255.0 green:183.0/255.0 blue:251.0/255.0 alpha:1.0] colorWithAlphaComponent:0.85] forState:UIControlStateHighlighted];
    [forgetButton.titleLabel setFont:[UIFont fontWithName:APPFONT_LIGHT size:17.0]];
    forgetButton.backgroundColor = [UIColor clearColor];
    [forgetButton addTarget:self action:@selector(forgetPwdBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:forgetButton];
    
    logingDetailTableView.tableHeaderView = headerView;
    logingDetailTableView.tableFooterView = footerView;

    [self.view addSubview:logingDetailTableView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}
#pragma mark UIcontrol methods
-(void) viewTapped
{
    [self dismissKeyboard];
}
-(void) dismissKeyboard {
    [tempTf resignFirstResponder];
    
    //    [UITableView beginAnimations:nil context:nil];
    //    [UITableView setAnimationDuration:0.32];
    //
    //    [UITableView commitAnimations];
}
-(void) forgetPwdBtnClicked
{
    DLog(@"forgetPwdBtnClicked");
    
    ForgetViewController *forgetPwdVC = [[ForgetViewController alloc] initWithNibName:@"ForgetViewController" bundle:nil];
    [self.navigationController pushViewController:forgetPwdVC animated:YES];
}
-(void) loginBtnClicked
{
    [self.view endEditing:YES];
    
    if (Static_screens_Build)
    {
        [appDel setRootVC];
    }
    else
    {
        if (![self validateTextFieldWithText:emailString With:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
        if ([passwordString length] < 5)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Password should be at least 6 characters" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:emailString, @"email",passwordString, @"password", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/piingo/login", BASE_URL];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            if ([[responseObj objectForKey:@"s"] intValue] == 1)
            {
                
                NSString *strPid = [NSString stringWithFormat:@"%d", [[responseObj objectForKey:@"uid"] intValue]];
                
                [[NSUserDefaults standardUserDefaults] setObject:strPid forKey:PID];
                
                [[NSUserDefaults standardUserDefaults] setObject:[responseObj objectForKey:@"t"] forKey:PIINGO_TOEKN];
                
                [[NSUserDefaults standardUserDefaults] setObject:emailString forKey:@"userEmail"];
                
//                [[NSUserDefaults standardUserDefaults] setObject:[dictLogin objectForKey:@"fn"] forKey:@"piingoFirstName"];
//                [[NSUserDefaults standardUserDefaults] setObject:[dictLogin objectForKey:@"ln"] forKey:@"piingoLastName"];
//                [[NSUserDefaults standardUserDefaults] setObject:[dictLogin objectForKey:@"pp"] forKey:@"piingoImageURL"];
//                [[NSUserDefaults standardUserDefaults] setObject:[dictLogin objectForKey:@"mn"] forKey:@"piingoMobileNumber"];
                
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"registerDeviceForPNSWithDevToken" object:appDel];
                
                [appDel setRootVC];
                
            }
            else
            {
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
        }];
        
    }
}


#pragma mark Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"%ldCell",(long)indexPath.section];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        cell.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:236.0/255.0 alpha:0.65];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(10+10, 0, tableView.frame.size.width-40, 46.0)];
        bgView.layer.cornerRadius = 5.0;
        bgView.backgroundColor = [UIColor whiteColor];
        [cell addSubview:bgView];
        //        cell.layer.cornerRadius = 5.0;
        
        UIImageView *cellimageView = [[UIImageView alloc] initWithFrame:CGRectMake(1.0, 3, 40, 40)];
        cellimageView.tag = 1235;
        cellimageView.contentMode = UIViewContentModeCenter;
        [bgView addSubview:cellimageView];
        
        UITextField *textFeild = [[UITextField alloc] initWithFrame:CGRectMake(45+15.0, 3.0, tableView.frame.size.width-70.0-10, 46-6.0)];
        textFeild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textFeild.tag = 1234;
        textFeild.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        textFeild.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textFeild.autocorrectionType = UITextAutocorrectionTypeNo;
        textFeild.delegate = self;
//        textFeild.backgroundColor =[UIColor redColor];
        textFeild.font = [UIFont fontWithName:APPFONT_REGULAR size:18.0];
        textFeild.returnKeyType = UIReturnKeyGo;
        [cell addSubview:textFeild];
    }
    UITextField *cellTextFeild = (UITextField *)[cell viewWithTag:1234];
    UIImageView *cellimageView = (UIImageView *)[cell viewWithTag:1235];
    
    if (indexPath.section == 0)
    {
        //        cell.imageView.image = [UIImage imageNamed:@"email"];
        cellimageView.image = [UIImage imageNamed:@"email_icon"];
        [cellTextFeild setSecureTextEntry:NO];
        cellTextFeild.placeholder = @"Email";
        cellTextFeild.text = emailString;
        cellTextFeild.keyboardType = UIKeyboardTypeEmailAddress;
    }
    else
    {
        //        cell.imageView.image = [UIImage imageNamed:@"password_icon"];
        cellimageView.image = [UIImage imageNamed:@"password_icon"];
        [cellTextFeild setSecureTextEntry:YES];
        cellTextFeild.placeholder = @"Password";
        cellTextFeild.text = passwordString;
        cellTextFeild.keyboardType = UIKeyboardTypeDefault;
    }
    
    return cell;
}

#pragma mark TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10.0)];
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:headerView.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft| UIRectCornerTopRight)
                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = headerView.bounds;
    maskLayer.path = maskPath.CGPath;
    if (section == 0)
        headerView.layer.mask = maskLayer;
    
    headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    
    headerView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:236.0/255.0 alpha:0.65];
    
    return headerView;
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;

    if (section == 0)
        return 0.01;
    else
        return 10.0;
    //    return 10.0;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    float heightValue;
    
    if (section == 0)
        heightValue = 0.01;
    else
        heightValue = 10.0;
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, heightValue)];
    
    //    UIBezierPath *maskPath;
    //    maskPath = [UIBezierPath bezierPathWithRoundedRect:footerView.bounds
    //                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
    //                                           cornerRadii:CGSizeMake(5.0, 5.0)];
    //
    //    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    //    maskLayer.frame = footerView.bounds;
    //    maskLayer.path = maskPath.CGPath;
    //
    //    if (section)
    //        footerView.layer.mask = maskLayer;
    
    footerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    footerView.backgroundColor = [UIColor colorWithRed:233.0/255.0 green:233.0/255.0 blue:236.0/255.0 alpha:0.65];
    
    return footerView;
}

#pragma mark - TextFeild Delegate methods
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    tempTf = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UITableView beginAnimations:nil context:nil];
    [UITableView setAnimationDuration:0.32];
    
    [UITableView commitAnimations];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([textField.placeholder isEqualToString:@"Email"])
    {
        emailString = str;
    }
    else if ([textField.placeholder isEqualToString:@"Password"])
    {
        passwordString = str;
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.placeholder isEqualToString:@"Email"])
    {
        emailString = textField.text;
    }
    else if ([textField.placeholder isEqualToString:@"Password"])
    {
        passwordString = textField.text;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self dismissKeyboard];
    [self loginBtnClicked];
    
    return YES;
}

#pragma mark ValidateMethod
-(BOOL) validateTextFieldWithText :(NSString*)text With:(NSString*)validateText  {
    
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validateText];
    return [test evaluateWithObject:text];
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
