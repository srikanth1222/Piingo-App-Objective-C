//
//  CalculateViewController.m
//  PiingApp
//
//  Created by Veedepu Srikanth on 27/09/16.
//  Copyright © 2016 shashank. All rights reserved.
//

#import "CalculateViewController.h"
#import "AppDelegate.h"
#import "CustomSegmentControl.h"


@interface CalculateViewController () <UITextFieldDelegate>
{
    CustomSegmentControl *segmentC;
    
    AppDelegate *appDel;
    
    UIView *viewRect;
    UIView *viewCircle;
    
    UILabel *lblAV, *lblACV;
}

@end

@implementation CalculateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    segmentC = [[CustomSegmentControl alloc] initWithFrame:CGRectMake(0, 0, screen_width-170, 30.0) andButtonTitles2:@[@"Rectangle", @"Circle"] andWithSpacing:[NSNumber numberWithFloat:0.0] andSelectionColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] andDelegate:self andSelector:NSStringFromSelector(@selector(segmentChange:))];
    segmentC.layer.cornerRadius = 5.0;
    segmentC.layer.borderWidth = 1;
    segmentC.clipsToBounds = YES;
    segmentC.layer.borderColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
    segmentC.backgroundColor = [UIColor clearColor];
    [self.view addSubview:segmentC];
    self.navigationItem.titleView = segmentC;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butImage = [UIImage imageNamed:@"cancel_grey"];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setBackgroundImage:butImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 32, 31);
    
    UIBarButtonItem *back_BarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = back_BarButton;
    
    
    UIButton *forbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *forbutImage = [UIImage imageNamed:@"next_grey"];
    forbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [forbutton setBackgroundImage:forbutImage forState:UIControlStateNormal];
    [forbutton addTarget:self action:@selector(addItems) forControlEvents:UIControlEventTouchUpInside];
    forbutton.frame = CGRectMake(0, 0, 32, 31);
    
    UIBarButtonItem *for_BarButton = [[UIBarButtonItem alloc] initWithCustomView:forbutton];
    
    self.navigationItem.rightBarButtonItem = for_BarButton;
    
    viewRect = [[UIView alloc]initWithFrame:CGRectMake(0, 60, screen_width, screen_height-60)];
    viewRect.backgroundColor = [UIColor clearColor];
    [self.view addSubview:viewRect];
    
    NSArray *arraRect = @[@"Lenth", @"Width"];
    
    float yAxis = 30*MULTIPLYHEIGHT;
    
    for (int i = 0; i<[arraRect count]; i++)
    {
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(30*MULTIPLYHEIGHT, yAxis, 70*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT)];
        lbl.text = [arraRect objectAtIndex:i];
        lbl.textColor = [UIColor grayColor];
        lbl.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        [viewRect addSubview:lbl];
        
        float tfX = 10*MULTIPLYHEIGHT+70*MULTIPLYHEIGHT;
        
        UITextField *tf = [[UITextField alloc]init];
        tf.tag = i+1;
        tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        tf.borderStyle = UITextBorderStyleLine;
        tf.frame = CGRectMake(tfX, yAxis, 100*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT);
        tf.textAlignment = NSTextAlignmentCenter;
        tf.delegate = self;
        tf.textColor = APP_FONT_COLOR_GREY;
        tf.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        [viewRect addSubview:tf];
        
        yAxis += 25*MULTIPLYHEIGHT;
    }
    
    yAxis += 5*MULTIPLYHEIGHT;
    
    UILabel *lblA = [[UILabel alloc]initWithFrame:CGRectMake(30*MULTIPLYHEIGHT, yAxis, 70*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT)];
    lblA.text = @"Area";
    lblA.textColor = [UIColor darkGrayColor];
    lblA.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
    [viewRect addSubview:lblA];
    
    float tfX = 10*MULTIPLYHEIGHT+70*MULTIPLYHEIGHT;
    
    lblAV = [[UILabel alloc]initWithFrame:CGRectMake(tfX, yAxis, 100*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT)];
    lblAV.text = @"";
    lblAV.textAlignment = NSTextAlignmentCenter;
    lblAV.textColor = [UIColor darkGrayColor];
    lblAV.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
    [viewRect addSubview:lblAV];
    
    yAxis += 30*MULTIPLYHEIGHT;
    
    UILabel *lblFeet = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, 20*MULTIPLYHEIGHT)];
    lblFeet.text = @"**Please enter values in feets only";
    lblFeet.textAlignment = NSTextAlignmentCenter;
    lblFeet.textColor = [UIColor darkGrayColor];
    lblFeet.font = [UIFont fontWithName:APPFONT_SemiBold_Italic size:appDel.FONT_SIZE_CUSTOM-2];
    [viewRect addSubview:lblFeet];
    
    
    
    
    yAxis = 30*MULTIPLYHEIGHT;
    
    viewCircle = [[UIView alloc]initWithFrame:CGRectMake(0, 60, screen_width, screen_height-60)];
    viewCircle.hidden = YES;
    [self.view addSubview:viewCircle];
    
    for (int i=0; i<1; i++)
    {
        UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(30*MULTIPLYHEIGHT, yAxis, 70*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT)];
        lbl.text = @"Radius";
        lbl.textColor = [UIColor grayColor];
        lbl.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        [viewCircle addSubview:lbl];
        
        float tfX = 10*MULTIPLYHEIGHT+70*MULTIPLYHEIGHT;
        
        UITextField *tf = [[UITextField alloc]init];
        tf.tag = i+1;
        tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        tf.borderStyle = UITextBorderStyleLine;
        tf.frame = CGRectMake(tfX, yAxis, 100*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT);
        tf.textAlignment = NSTextAlignmentCenter;
        tf.delegate = self;
        tf.textColor = APP_FONT_COLOR_GREY;
        tf.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        [viewCircle addSubview:tf];
    }
    
    yAxis += 30*MULTIPLYHEIGHT;
    
    UILabel *lblAC = [[UILabel alloc]initWithFrame:CGRectMake(30*MULTIPLYHEIGHT, yAxis, 70*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT)];
    lblAC.text = @"Area";
    lblAC.textColor = [UIColor darkGrayColor];
    lblAC.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
    [viewCircle addSubview:lblAC];
    
    lblACV = [[UILabel alloc]initWithFrame:CGRectMake(tfX, yAxis, 100*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT)];
    lblACV.text = @"";
    lblACV.textAlignment = NSTextAlignmentCenter;
    lblACV.textColor = [UIColor darkGrayColor];
    lblACV.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
    [viewCircle addSubview:lblACV];
    
    yAxis += 30*MULTIPLYHEIGHT;
    
    UILabel *lblFeet1 = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, 20*MULTIPLYHEIGHT)];
    lblFeet1.text = @"**Please enter values in feets only";
    lblFeet1.textAlignment = NSTextAlignmentCenter;
    lblFeet1.textColor = [UIColor darkGrayColor];
    lblFeet1.font = [UIFont fontWithName:APPFONT_SemiBold_Italic size:appDel.FONT_SIZE_CUSTOM-2];
    [viewCircle addSubview:lblFeet1];
}

-(void) segmentChange:(CustomSegmentControl *)segment
{
    if (segment.selectedIndex == 0)
    {
        viewRect.hidden = NO;
        viewCircle.hidden = YES;
    }
    else
    {
        viewRect.hidden = YES;
        viewCircle.hidden = NO;
    }
}

-(void) addItems
{
    if ([self.delegate respondsToSelector:@selector(didAdditems:)])
    {
        if (segmentC.selectedIndex == 0)
        {
            [self.delegate didAdditems:lblAV.text.floatValue];
        }
        else
        {
            [self.delegate didAdditems:lblACV.text.floatValue];
        }
        
        [self gotoBack];
    }
}

-(void) gotoBack
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([string isEqualToString:@" "])
    {
        return NO;
    }
    
    if (segmentC.selectedIndex == 0)
    {
        if (textField.tag == 1)
        {
            NSString *str1 = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            UITextField *tf = [viewRect viewWithTag:2];
            
            if ([tf.text length] >= 1 && [str1 length] >= 1)
            {
                lblAV.text = [NSString stringWithFormat:@"%.2f", [str1 floatValue]*[tf.text floatValue]];
            }
        }
        else if (textField.tag == 2)
        {
            NSString *str2 = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            UITextField *tf = [viewRect viewWithTag:1];
            
            if ([tf.text length] >= 1 && [str2 length] >= 1)
            {
                lblAV.text = [NSString stringWithFormat:@"%.2f", [str2 floatValue]*[tf.text floatValue]];
            }
        }
    }
    else if (segmentC.selectedIndex == 1)
    {
        NSString *str1 = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        lblACV.text = [NSString stringWithFormat:@"%.2f", [str1 floatValue]*[str1 floatValue]*3.14159];
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
