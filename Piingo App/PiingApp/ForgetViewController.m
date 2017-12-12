//
//  ForgetViewController.m
//  PiingApp
//
//  Created by SHASHANK on 08/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "ForgetViewController.h"

@interface ForgetViewController ()
{
    UITextField *emailTxtFeild;
}
@end

@implementation ForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Reset Password";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg"];
    [self.view addSubview: animatedImageView];

    UILabel *headingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 64+20, screen_width-60, 44.0)];
    headingLabel.text = @"Please enter your email address to get the password";
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.numberOfLines = 0;
    headingLabel.adjustsFontSizeToFitWidth = YES;
    headingLabel.textColor = [UIColor colorWithRed:94.0/255.0 green:95.0/255.0 blue:96.0/255.0 alpha:0.9];
    headingLabel.font = [UIFont fontWithName:APPFONT_LIGHT size:15.0];
    [self.view addSubview:headingLabel];
    
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(27, CGRectGetMaxY(headingLabel.frame)+20, screen_width-54, 120)];
    bgImgView.userInteractionEnabled = YES;
    UIImage *bgImg = [UIImage imageNamed:@"login_transparent_bg"];
    bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    bgImgView.image = bgImg;
    
    
    UIView *emailBG = [[UIView alloc] initWithFrame:CGRectMake(20, 15.0, bgImgView.frame.size.width-40 , 35.0)];
    emailBG.layer.cornerRadius = 2.5;
    emailBG.backgroundColor = [UIColor whiteColor];
    
    UIImageView *emailIconImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"email_icon"]];
    emailIconImgView.frame = CGRectMake(10, 10, 20, 14);
    emailIconImgView.backgroundColor = [UIColor clearColor];
    [emailBG addSubview:emailIconImgView];
    
    emailTxtFeild = [[UITextField alloc] initWithFrame:CGRectMake(45, 0, emailBG.frame.size.width-45, 35)];
    emailTxtFeild.textAlignment = NSTextAlignmentCenter;
    emailTxtFeild.backgroundColor = [UIColor whiteColor];
//    emailTxtFeild.layer.cornerRadius = 7.0;
//    emailTxtFeild.layer.borderWidth = 0.50;
//    emailTxtFeild.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor;
    emailTxtFeild.placeholder = @"Enter your email here";
    emailTxtFeild.font = [UIFont fontWithName:APPFONT_REGULAR size:16.0];
    [emailBG addSubview:emailTxtFeild];
    [bgImgView addSubview:emailBG];

    UIButton *submitPwdbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitPwdbtn.frame = CGRectMake(20, 15+35+15.0, CGRectGetWidth(emailBG.frame), 35);
//    submitPwdbtn.center = CGPointMake(screen_width/2, CGRectGetMaxY(emailTxtFeild.frame)+30);
//    [submitPwdbtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [submitPwdbtn setTitleColor:[[UIColor blueColor] colorWithAlphaComponent:0.9] forState:UIControlStateHighlighted];
    [submitPwdbtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:1] forState:UIControlStateNormal];
    
//    submitPwdbtn.backgroundColor = [UIColor whiteColor];
//    submitPwdbtn.layer.cornerRadius  = 7.0;
//    submitPwdbtn.layer.borderWidth = 0.50;
//    submitPwdbtn.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor;
    UIImage *image1 = [UIImage imageNamed:@"green_btn"];
    image1 = [image1 resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    [submitPwdbtn setBackgroundImage:image1 forState:UIControlStateNormal];
    [submitPwdbtn addTarget:self action:@selector(submitButtonCLicked) forControlEvents:UIControlEventTouchUpInside];
    [submitPwdbtn setTitle:@"Submit" forState:UIControlStateNormal];
    submitPwdbtn.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:16.0];
    
    [bgImgView addSubview:submitPwdbtn];
    
    [self.view addSubview:bgImgView];
    
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
    [emailTxtFeild resignFirstResponder];
}
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void) submitButtonCLicked
{
    [self dismissKeyboard];

    if (!([emailTxtFeild.text length] > 0))
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Email should not be empty" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    if (![self validateTextFieldWithText:emailTxtFeild.text With:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"Please enter a valid email address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
        return;
    }
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:emailTxtFeild.text, @"email", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingo/forgotpassword", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            emailTxtFeild.text = @"";
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"A link/password is sent your register mail address" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
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
