//
//  EditItemsViewController.m
//  PiingApp
//
//  Created by SHASHANK on 28/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "EditItemsViewController.h"
#import "CustomSegmentControl.h"
#import "SpacedSegmentController.h"

#define itemTxtTag 1000

@interface EditItemsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITableView *wiITemsTableView, *dcITemsTableView;
    NSMutableArray *itemsAray, *itemWICountArray, *itemDCCountArray;
    long int countVal;
    CustomSegmentControl *segmentC;
    
    UIButton *cancelBtn, *adddetailsBtn;
    UIView *wfView;
    UITextField *wfTxtFeild,*tempTf;
    
    AppDelegate *appDel;
    
    UIToolbar *toolBar;
    SpacedSegmentController *selectBagTypeSegment;
    
    UIView *bgView;
    UIView *lineView;
}

@end

@implementation EditItemsViewController
@synthesize parentDel;
@synthesize orderDetailDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    countVal = arc4random()%10+1;
    itemWICountArray = [[NSMutableArray alloc] init];
    itemDCCountArray = [[NSMutableArray alloc] init];
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg"];
    [self.view addSubview: animatedImageView];
    
    UIView *bgImg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    bgImg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    [self.view addSubview:bgImg];
    
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0, screen_width , 10+30+10)];
    bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    [self.view addSubview:bgView];
    
    //    UINavigationBar *navBarView = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 64.0, screen_width, 64.0)];
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, screen_width, 64.0)];
    //    navBarView.bab
    toolBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *flexibleBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add Items" style:UIBarButtonItemStylePlain target:nil action:nil];
    cancelBarButton.enabled = NO;
    
    UIBarButtonItem *flexibleBarBtn2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(addItemDetail)];
    toolBar.items = @[flexibleBarBtn,cancelBarButton,flexibleBarBtn2];
    
    //    toolBar.items = @[cancelBarButton, flexibleBarBtn, doneBarButton];
    //    [self.view addSubview:navBarView];
    [self.view addSubview:toolBar];
    
    //    self.navigationController.navigationItem.leftBarButtonItem = cancelBarButton;
    //    self.navigationController.navigationItem.rightBarButtonItem = doneBarButton;
    
    selectBagTypeSegment = [[SpacedSegmentController alloc] initWithFrame:CGRectMake(0, 64.0, screen_width, 30+15) titles:@[@"",@""] unSelectedImages:@[@"wf_inactive",@"wi-dc_inactive"] selectedImages:@[@"wf_active",@"wi-dc_active"] seperatorSpacing:[NSNumber numberWithFloat:0.0] andDelegate:self];
    selectBagTypeSegment.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
    [selectBagTypeSegment setSelectedControlIndex:0];
    [selectBagTypeSegment setTargetSelector:@selector(spaceSegmentClicked:)];
    [self.view addSubview:selectBagTypeSegment];
    
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame)-1, screen_width , 1)];
    lineView.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    
    segmentC = [[CustomSegmentControl alloc] initWithFrame:CGRectMake((screen_width-200)/2, CGRectGetMaxY(lineView.frame)+5, 200, 30) andButtonTitles2:@[@"W&I",@"DC"] andWithSpacing:[NSNumber numberWithFloat:0.0] andSelectionColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] andDelegate:self andSelector:NSStringFromSelector(@selector(segmentChange2:))];
    segmentC.backgroundColor = [UIColor whiteColor];
    segmentC.layer.cornerRadius = 5.0;
    segmentC.layer.borderWidth = 1;
    segmentC.clipsToBounds = YES;
    segmentC.layer.borderColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
    [self.view addSubview:segmentC];
    segmentC.hidden =YES;
    
    lineView.hidden = YES;
    
    wfView = [[UIView alloc] initWithFrame:CGRectMake(10, 64.0+45.0+40+30, screen_width - 20, 250)];
    wfView.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];//[UIColor colorWithRed:3.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0];
    wfView.layer.cornerRadius = 1.0;
    wfView.clipsToBounds = YES;
    wfView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
    wfView.layer.shadowOffset = CGSizeMake(1,1);
    
    UILabel *wfTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screen_width-20-100-20, 250-20)];
    wfTitle.backgroundColor = [UIColor clearColor];
    wfTitle.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    wfTitle.numberOfLines = 0;
    wfTitle.font = [UIFont fontWithName:APPFONT_BOLD size:17.0];
    wfTitle.text = @"Please enter number of kgs of the bag:";
    [wfView addSubview:wfTitle];
    
    UIImageView *txtBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width - 100-10-1, (250-30)/2+15, 72, 15)];
    txtBGImgView.userInteractionEnabled = YES;
    txtBGImgView.image = [UIImage imageNamed:@"text_field_white"];
    [wfView addSubview:txtBGImgView];
    
    wfTxtFeild = [[UITextField alloc] initWithFrame:CGRectMake(screen_width - 100-10, (250-30)/2, 70, 30)];
    wfTxtFeild.backgroundColor = [UIColor clearColor];
    wfTxtFeild.textColor = [UIColor whiteColor];
    //    wfTxtFeild.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.65].CGColor;
    //    wfTxtFeild.layer.borderWidth = 1.0;
    //    wfTxtFeild.layer.cornerRadius = 5.0;
    wfTxtFeild.clipsToBounds = YES;
    wfTxtFeild.placeholder = @"0";
    wfTxtFeild.font = [UIFont fontWithName:APPFONT_BOLD size:15.0];
    wfTxtFeild.textAlignment = NSTextAlignmentCenter;
    wfTxtFeild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    wfTxtFeild.keyboardType = UIKeyboardTypeNumberPad;
    wfTxtFeild.delegate = self;
    [wfView addSubview:wfTxtFeild];
    
    [self.view addSubview:wfView];
    
    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PriceList" ofType:@"plist"]];
    
    NSData *data = [[dictRoot objectForKey:@"ListItems"] dataUsingEncoding:NSUTF8StringEncoding];
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    itemsAray = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"i"]];
    
    
    for (int i = 0; i< [itemsAray count]; i++)
    {
        [itemWICountArray addObject:[NSString stringWithFormat:@""]];
        [itemDCCountArray addObject:[NSString stringWithFormat:@""]];
    }
    self.title = @"Add Items";
    
    wiITemsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame)+40, screen_width, screen_height-CGRectGetMaxY(lineView.frame)-40-40)];
    wiITemsTableView.delegate = self;
    wiITemsTableView.dataSource = self;
    wiITemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    wiITemsTableView.backgroundColor = [UIColor clearColor];
    wiITemsTableView.backgroundView = nil;
    [self.view addSubview:wiITemsTableView];
    wiITemsTableView.hidden = YES;
    
    dcITemsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame)+40, screen_width, screen_height-CGRectGetMaxY(lineView.frame)-40-40)];
    dcITemsTableView.delegate = self;
    dcITemsTableView.dataSource = self;
    dcITemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    dcITemsTableView.backgroundColor = [UIColor clearColor];
    dcITemsTableView.backgroundView = nil;
    [self.view addSubview:dcITemsTableView];
    
    dcITemsTableView.hidden = YES;
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, screen_height-41, screen_width , 1)];
    lineView2.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0];
    [self.view addSubview:lineView2];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, screen_height-40.0, screen_width/2, 40);
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:APP_FONT_COLOR_GREY forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:18.0];
    [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    adddetailsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    adddetailsBtn.frame = CGRectMake(screen_width/2, screen_height-40.0, screen_width/2, 40);
    adddetailsBtn.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:157.0/255.0 blue:5.0/255.0 alpha:1.0];
    [adddetailsBtn setTitle:@"Add" forState:UIControlStateNormal];
    [adddetailsBtn setTitleColor:APP_FONT_COLOR_GREY forState:UIControlStateNormal];
    adddetailsBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:18.0];
    [adddetailsBtn addTarget:self action:@selector(addItemDetail) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:adddetailsBtn];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.indexVal)
    {
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnClicked)];
        
        UIBarButtonItem *flexibleBarBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIBarButtonItem *saveBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveBarButtonClicked)];
        
        toolBar.items = @[cancelBarButton, flexibleBarBtn, saveBarButton];
        
    }
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
-(void) spaceSegmentClicked:(UIButton *) sender
{
    if (selectBagTypeSegment.selectedIndex == 0)
    {
        wfView.hidden = NO;
        wiITemsTableView.hidden = YES;
        dcITemsTableView.hidden = YES;
        
        segmentC.hidden = YES;
        lineView.hidden = YES;
        bgView.hidden = YES;
        
        bgView.frame = CGRectMake(0, 64.0, screen_width , 10+30+10);
    }
    else if((selectBagTypeSegment.selectedIndex == 1))
    {
        bgView.frame = CGRectMake(0, 64.0, screen_width , 10+30+10+40);
        
        wfView.hidden = YES;
        //        wiITemsTableView.hidden = NO;
        //        dcITemsTableView.hidden = YES;
        
        segmentC.hidden = NO;
        lineView.hidden = NO;
        bgView.hidden = NO;
        
        [self segmentChange2:segmentC];
    }
    
    lineView.frame = CGRectMake(0, CGRectGetMaxY(bgView.frame)-1, screen_width , 1);
}
-(void) segmentChange2:(CustomSegmentControl *) sender
{
    if (sender.selectedIndex == 0)
    {
        wiITemsTableView.hidden = NO;
        dcITemsTableView.hidden = YES;
    }
    else if (sender.selectedIndex == 1)
    {
        wiITemsTableView.hidden = YES;
        dcITemsTableView.hidden = NO;
    }
}
-(void) addItemDetail
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([parentDel respondsToSelector:@selector(addItemDetails:withDetails:andCountDetails: anddetail2:)])
        {
            
            if (selectBagTypeSegment.selectedIndex == 0)
            {
                [parentDel addItemDetails:0 withDetails:itemsAray andCountDetails:@[wfTxtFeild.text] anddetail2:nil];
            }
            else if((selectBagTypeSegment.selectedIndex == 1))
            {
                //                if (segmentC.selectedIndex == 0)
                [parentDel addItemDetails:1 withDetails:itemsAray andCountDetails:itemWICountArray anddetail2:itemDCCountArray];
                //                else
                //                    [parentDel addItemDetails:2 withDetails:itemsAray andCountDetails:itemDCCountArray];
            }
            //            else if (segmentC.selectedIndex == 2)
            //            {
            //                [parentDel addItemDetails:2 withDetails:itemsAray andCountDetails:itemDCCountArray];
            //            }
        }
        
    }];
}
-(void) cancelBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void) saveBarButtonClicked
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (segmentC.selectedIndex == 0)
        {
            
        }
        else if((segmentC.selectedIndex == 1))
        {
        }
        else if (segmentC.selectedIndex == 2)
        {
        }
        
    }];
}
#pragma mark UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [itemWICountArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"OptionCell%lu",indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:14.0];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.frame = CGRectMake(10, 5, screen_width-100, 40.0);
        cell.textLabel.textColor = APP_FONT_COLOR_GREY;
        
        UIImageView *txtBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-100+30, 12.50+10, 50, 15)];
        txtBGImgView.userInteractionEnabled = YES;
        txtBGImgView.image = [UIImage imageNamed:@"text_field"];
        [cell addSubview:txtBGImgView];
        
        UITextField *countTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(screen_width-100+30, 12.50, 50, 30-5)];
        countTextFeild.backgroundColor = [UIColor clearColor];
        //        countTextFeild.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.65].CGColor;
        //        countTextFeild.layer.borderWidth = 1.0;
        //        countTextFeild.layer.cornerRadius = 5.0;
        countTextFeild.textColor = [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:143.0/255.0 alpha:1.0];
        countTextFeild.clipsToBounds = YES;
        countTextFeild.tag = itemTxtTag+indexPath.row;
        countTextFeild.placeholder = @"0";
        countTextFeild.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:13.0];
        countTextFeild.textAlignment = NSTextAlignmentCenter;
        countTextFeild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        countTextFeild.keyboardType = UIKeyboardTypeNumberPad;
        countTextFeild.delegate = self;
        [cell addSubview:countTextFeild];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UITextField *countTextFeild = (UITextField *) [cell viewWithTag:itemTxtTag+indexPath.row];
    
    //    countTextFeild.tag = itemTxtTag + indexPath.row;
    
    //    if (indexPath.row %2 == 0)
    //    {
    //        cell.backgroundColor = [UIColor whiteColor];
    //    }
    //    else
    //    {
    //        cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    //    }
    
    cell.textLabel.text = [[itemsAray objectAtIndex:indexPath.row] objectForKey:@"n"];
    //    countTextFeild.text = [NSString stringWithFormat:@"%ld", [[itemWICountArray objectAtIndex:indexPath.row] integerValue]];
    
    if (segmentC.selectedIndex == 0)
        countTextFeild.text = [itemWICountArray objectAtIndex:indexPath.row];
    else
        countTextFeild.text = [itemDCCountArray objectAtIndex:indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

#pragma mark UITextFeild Delegate Methods
-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    tempTf = textField;
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
    wiITemsTableView.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), screen_width, screen_height-CGRectGetMaxY(lineView.frame)-40-216);
    dcITemsTableView.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), screen_width, screen_height-CGRectGetMaxY(lineView.frame)-40-216);
    
    cancelBtn.frame = CGRectMake(0, screen_height-40.0-216, screen_width/2, 40);
    adddetailsBtn.frame = CGRectMake(screen_width/2, screen_height-40.0-216, screen_width/2, 40);
    
    //    textField
}
- (void)textFieldDidEndEditing:(UITextField *)textField             // may be called if forced even if
{
    wiITemsTableView.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), screen_width, screen_height-CGRectGetMaxY(lineView.frame)-40);
    dcITemsTableView.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), screen_width, screen_height-CGRectGetMaxY(lineView.frame)-40);
    
    cancelBtn.frame = CGRectMake(0, screen_height-40.0, screen_width/2, 40);
    adddetailsBtn.frame = CGRectMake(screen_width/2, screen_height-40.0, screen_width/2, 40);
    
    NSLog(@"%ld",textField.tag);
    
    if (selectBagTypeSegment.selectedIndex == 0)
    {
        //        Order *orderObj = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:[appDel managedObjectContext]];
        //
        //        [orderObj setOrderID:[orderDetailDic objectForKey:@"oid"]];
        //        [orderObj setUid:[orderDetailDic objectForKey:@"uid"]];
        //        [orderObj setCobID:[orderDetailDic objectForKey:@"cobid"]];
        //        [orderObj setIsOrderConformed:[NSNumber numberWithBool:NO]];
        //
        //        NSError *error;
        //        if (![[appDel managedObjectContext] save:&error]) {
        //            NSLog(@"error %@",error);
        //        }
    }
    else if((selectBagTypeSegment.selectedIndex == 1))
    {
        if (segmentC.selectedIndex == 0)
        {
            [itemWICountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:textField.text];
        }
        else if (segmentC.selectedIndex == 1)
        {
            [itemDCCountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:textField.text];
        }
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField             // called when 'return' key pressed.
{
    [wiITemsTableView reloadData];
    
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
