//
//  AddItemsViewController.m
//  Park View
//
//  Created by STI-HYD-30 on 09/03/15.
//  Copyright (c) 2015 Chris Wagner. All rights reserved.
//

#import "AddItemsViewController.h"
#import "CustomSegmentControl.h"
#import "SpacedSegmentController.h"

#define itemTxtTag 1000

@interface AddItemsViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    UITableView *wiITemsTableView, *dcITemsTableView, *irITemsTableView;
    NSMutableArray *itemsAray, *itemWICountArray, *itemDCCountArray, *itemIRCountArray;
    long int countVal;
    
    NSMutableArray *arrayWAI, *arrayDC, *arrayIRN;
    
    UIButton *cancelBtn, *adddetailsBtn;
    UIView *wfView;
    UITextField *wfTxtFeild,*tempTf;
    
    AppDelegate *appDel;
    
    UIToolbar *toolBar;
    SpacedSegmentController *selectBagTypeSegment;
    
    UIView *bgView;
    UIView *lineView;
    
    UISegmentedControl *segment_WashType;
    NSMutableArray *arrayWashType, *arraySelectedWashType;
}


@end

@implementation AddItemsViewController
@synthesize parentDel;
@synthesize orderDetailDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    countVal = arc4random()%10+1;
    itemWICountArray = [[NSMutableArray alloc] init];
    itemDCCountArray = [[NSMutableArray alloc] init];
    itemIRCountArray = [[NSMutableArray alloc] init];
    
    
    arraySelectedWashType = [[NSMutableArray alloc]init];
    
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
    
    
    
    
    
    
    selectBagTypeSegment = [[SpacedSegmentController alloc] initWithFrame:CGRectMake(0, 64.0, screen_width, 30+15) titles:@[@" Load Wash",@" WNI/DC/IRN"] unSelectedImages:@[@"radio_uncheck",@"radio_uncheck"] selectedImages:@[@"radio_check",@"radio_check"] seperatorSpacing:[NSNumber numberWithFloat:0.0] andDelegate:self];
    selectBagTypeSegment.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    NSString *strJTM = [orderDetailDic objectForKey:@"jtmid"];
    
    if ([strJTM hasSuffix:@","])
    {
        strJTM = [strJTM substringToIndex:[strJTM length]-1];
    }
    
    NSArray *arr = [strJTM componentsSeparatedByString:@","];
    
    if ([arr count] == 1)
    {
        if ([strJTM containsString:@"1"])
        {
            [selectBagTypeSegment setSelectedControlIndex:0];
        }
        else
        {
            [selectBagTypeSegment setSelectedControlIndex:1];
        }
        
        selectBagTypeSegment.userInteractionEnabled = NO;
        
    }
    else
    {
        if ([strJTM containsString:@"1"])
        {
            [selectBagTypeSegment setSelectedControlIndex:0];
            
            if ([strJTM isEqualToString:@"1"])
            {
                [selectBagTypeSegment setDisableSegmentIndex:1];
            }
        }
        else
        {
            [selectBagTypeSegment setDisableSegmentIndex:0];
            
            [selectBagTypeSegment setSelectedControlIndex:1];
        }
    }
    
    [selectBagTypeSegment setTargetSelector:@selector(spaceSegmentClicked:)];
    [self.view addSubview:selectBagTypeSegment];
    
    
    lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(bgView.frame)-1, screen_width , 1)];
    lineView.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:213.0/255.0 blue:213.0/255.0 alpha:1.0];
    [self.view addSubview:lineView];
    
    
    NSArray *arrayWashItems = @[@"W&I", @"DC", @"IRN"];
    
    segment_WashType = [[UISegmentedControl alloc]initWithItems:arrayWashItems];
    segment_WashType.frame = CGRectMake((screen_width-200)/2, CGRectGetMaxY(lineView.frame)+5, 200, 30);
    [self.view addSubview:segment_WashType];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [segment_WashType addTarget:self action:@selector(segmentWashTypeChange:) forControlEvents:UIControlEventValueChanged];
    segment_WashType.tintColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
    
    arrayWashType = [[NSMutableArray alloc]init];
    
    if ([strJTM containsString:@"2"])
    {
        [arrayWashType addObject:@"1"];
    }
    
    if ([strJTM containsString:@"3"])
    {
        [arrayWashType addObject:@"0"];
    }
    
    if ([strJTM containsString:@"4"])
    {
        [arrayWashType addObject:@"2"];
    }
    
    if ([arrayWashType count])
    {
        segment_WashType.selectedSegmentIndex = [[arrayWashType objectAtIndex:0]intValue];;
    }
    
    
    [self segmentWashTypeChange:segment_WashType];
    
    if (![strJTM containsString:@"2"])
    {
        [segment_WashType setEnabled:NO forSegmentAtIndex:1];
    }
    
    if (![strJTM containsString:@"3"])
    {
        [segment_WashType setEnabled:NO forSegmentAtIndex:0];
    }
    
    if (![strJTM containsString:@"4"])
    {
        [segment_WashType setEnabled:NO forSegmentAtIndex:2];
    }
    
    segment_WashType.hidden = YES;
    
    
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
    wfTxtFeild.keyboardType = UIKeyboardTypeDecimalPad;
    wfTxtFeild.delegate = self;
    [wfView addSubview:wfTxtFeild];
    
    [self.view addSubview:wfView];
    
    
    
    /// REMOVE FOR NEW SERVICE
    
//    [self showAddItems];
//    
//    return;
    
    ////
    
   // http://services.piing.com.sg/piing/piingogetitemmaster/services.do?jt=2&ort=O&istourist=Y&t=10A7FD612EC8E229ACD8FC97137B319F
    
    
    NSString *strOrderType;
    
    if ([[self.orderDetailDic objectForKey:@"ort"] caseInsensitiveCompare:@"Regular"] == NSOrderedSame)
    {
        strOrderType = @"R";
    }
    else
    {
        strOrderType = @"E";
    }
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
//    NSString *urlStr = [NSString stringWithFormat:@"%@piingogetitemmaster/services.do?", BASE_URL];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingogetallitemdetails/services.do?", BASE_URL];
    
    for (NSString *key in [registrationDetailsDic allKeys])
    {
        NSString *value = [registrationDetailsDic objectForKey:key];
        
        urlStr = [urlStr stringByAppendingFormat:@"&%@=%@",key,value];
    }
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"GET" withDetailsDictionary:nil andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] caseInsensitiveCompare:@"y"] == NSOrderedSame)
        {
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
           // NSArray *arra = [[responseObj objectForKey:@"r"]objectAtIndex:0];
            
            itemsAray = [[NSMutableArray alloc]initWithArray:[responseObj objectForKey:@"r"]];
            
            arrayWAI = [[NSMutableArray alloc]init];
            arrayDC = [[NSMutableArray alloc]init];
            arrayIRN = [[NSMutableArray alloc]init];
            
            for (int i=0; i<[itemsAray count]; i++)
            {
                NSDictionary *dic = [itemsAray objectAtIndex:i];
                
                if (![[dic objectForKey:@"wip"] isEqualToString:@"0.0"])
                {
                    [arrayWAI addObject:dic];
                    [itemWICountArray addObject:[NSString stringWithFormat:@""]];
                }
                if (![[dic objectForKey:@"dcp"] isEqualToString:@"0.0"])
                {
                    [arrayDC addObject:dic];
                    [itemDCCountArray addObject:[NSString stringWithFormat:@""]];
                }
                if (![[dic objectForKey:@"irp"] isEqualToString:@"0.0"])
                {
                    [arrayIRN addObject:dic];
                    [itemIRCountArray addObject:[NSString stringWithFormat:@""]];
                }
            }
            
            [self showAddItems];
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

-(void) showAddItems
{
//    /// REMOVE FOR NEW SERVICE
//    
//    NSDictionary *dictRoot = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PriceList" ofType:@"plist"]];
//    
//    NSData *data = [[dictRoot objectForKey:@"ListItems"] dataUsingEncoding:NSUTF8StringEncoding];
//    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    
//    itemsAray = [[NSMutableArray alloc] initWithArray:[json objectForKey:@"i"]];
//    
//    arrayWAI = [[NSMutableArray alloc]initWithArray:itemsAray];
//    arrayDC = [[NSMutableArray alloc]initWithArray:itemsAray];
//    arrayIRN = [[NSMutableArray alloc]initWithArray:itemsAray];
//    
//    for (int i = 0; i< [itemsAray count]; i++)
//    {
//        [itemWICountArray addObject:[NSString stringWithFormat:@""]];
//        [itemDCCountArray addObject:[NSString stringWithFormat:@""]];
//        [itemIRCountArray addObject:[NSString stringWithFormat:@""]];
//    }
//    
//    /////
    
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
    
    
    irITemsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lineView.frame)+40, screen_width, screen_height-CGRectGetMaxY(lineView.frame)-40-40)];
    irITemsTableView.delegate = self;
    irITemsTableView.dataSource = self;
    irITemsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    irITemsTableView.backgroundColor = [UIColor clearColor];
    irITemsTableView.backgroundView = nil;
    [self.view addSubview:irITemsTableView];
    irITemsTableView.hidden = YES;
    
    
    
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
    //[self.view addGestureRecognizer:tapGesture];
    
    [self spaceSegmentClicked:selectBagTypeSegment];
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
-(void) spaceSegmentClicked:(id) sender
{
    [self.view endEditing:YES];
    
    if (selectBagTypeSegment.selectedIndex == 0)
    {
        wfView.hidden = NO;
        wiITemsTableView.hidden = YES;
        dcITemsTableView.hidden = YES;
        irITemsTableView.hidden = YES;
        
        segment_WashType.hidden = YES;
        lineView.hidden = YES;
        bgView.hidden = YES;
        
        bgView.frame = CGRectMake(0, 64.0, screen_width , 10+30+10);
    }
    else if((selectBagTypeSegment.selectedIndex == 1))
    {
        bgView.frame = CGRectMake(0, 64.0, screen_width , 10+30+10+40);
        
        wfView.hidden = YES;
        
        segment_WashType.hidden = NO;
        lineView.hidden = NO;
        bgView.hidden = NO;
        
        
        
        
        
        
        //NSString *strJTM = [orderDetailDic objectForKey:@"jtmid"];
        //NSArray *arr = [strJTM componentsSeparatedByString:@","];
        
//        if ([arr count] == 1)
//        {
//            if ([[orderDetailDic objectForKey:@"jtmid"] isEqualToString:@"2"])
//            {
//                [segmentC setSelectedIndex:0];
//            }
//            else if ([[orderDetailDic objectForKey:@"jtmid"] isEqualToString:@"3"])
//            {
//                [segmentC setSelectedIndex:1];
//            }
//            else if ([[orderDetailDic objectForKey:@"jtmid"] isEqualToString:@"4"])
//                
//            {
//                [segmentC setSelectedIndex:2];
//            }
//            else
//            {
//                //By default
//                [segmentC setSelectedIndex:0];
//            }
//
//            segmentC.userInteractionEnabled = NO;
//        }
//        
        [self segmentWashTypeChange:segment_WashType];
    }
    
    lineView.frame = CGRectMake(0, CGRectGetMaxY(bgView.frame)-1, screen_width , 1);
    [wfTxtFeild resignFirstResponder];

}
-(void) segmentWashTypeChange:(UISegmentedControl *) sender
{
    
    [self.view endEditing:YES];
    
    if ([arraySelectedWashType count])
    {
        [AppDelegate showAlertWithMessage:@"Please add items in to current bag" andTitle:@"" andBtnTitle:@"OK"];
        
        sender.selectedSegmentIndex = [[arraySelectedWashType objectAtIndex:0]intValue];
        return;
    }
    
    if (sender.selectedSegmentIndex == 0)
    {
        wiITemsTableView.hidden = NO;
        dcITemsTableView.hidden = YES;
        irITemsTableView.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        wiITemsTableView.hidden = YES;
        dcITemsTableView.hidden = NO;
        irITemsTableView.hidden = YES;
    }
    else if (sender.selectedSegmentIndex == 2)
    {
        wiITemsTableView.hidden = YES;
        dcITemsTableView.hidden = YES;
        irITemsTableView.hidden = NO;
    }
    
    [wiITemsTableView reloadData];
    [dcITemsTableView reloadData];
    [irITemsTableView reloadData];
    
}


-(void) addItemDetail
{
    [self.view endEditing:YES];
    
    if (selectBagTypeSegment.selectedIndex == 0)
    {
        if (![wfTxtFeild.text length])
        {
            [AppDelegate showAlertWithMessage:@"Please Add items" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
        }
    }
    
    else if (selectBagTypeSegment.selectedIndex == 1)
    {
        
        if (![arraySelectedWashType containsObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]])
        {
            [AppDelegate showAlertWithMessage:@"Please Add items" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
        }
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([parentDel respondsToSelector:@selector(addItemDetails:withDetails:andCountDetails: anddetail2:)])
        {
            
            if (selectBagTypeSegment.selectedIndex == 0)
            {
                [parentDel addItemDetails:0 withDetails:itemsAray andCountDetails:@[wfTxtFeild.text] anddetail2:nil];
            }
            else if((selectBagTypeSegment.selectedIndex == 1))
            {
                [parentDel addItemDetails:1 withDetails:itemsAray andCountDetails:itemWICountArray anddetail2:itemDCCountArray andDetails3:itemIRCountArray];
            }
        }
    }];
}
-(void) cancelBtnClicked
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void) saveBarButtonClicked
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if (segment_WashType.selectedSegmentIndex == 0)
        {
            
        }
        else if((segment_WashType.selectedSegmentIndex == 1))
        {
        }
        else if (segment_WashType.selectedSegmentIndex == 2)
        {
        }
        
    }];    
}
#pragma mark UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segment_WashType.selectedSegmentIndex == 0)
    {
        return [arrayWAI count];
    }
    else if(segment_WashType.selectedSegmentIndex == 1)
    {
        return [arrayDC count];
    }
    else if(segment_WashType.selectedSegmentIndex == 2)
    {
        return [arrayIRN count];
    }
    else
    {
        return 0;
    }
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
        
        UILabel *lblText = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, screen_width-100+20, 50.0)];
        [cell addSubview:lblText];
        lblText.numberOfLines = 0;
        lblText.tag = 10;
        lblText.textColor = [UIColor darkGrayColor];
        lblText.font = [UIFont fontWithName:APPFONT_MEDIUM size:14];
    }
    
    UITextField *countTextFeild = (UITextField *) [cell viewWithTag:itemTxtTag+indexPath.row];
    
    UILabel *lblText = (UILabel *) [cell viewWithTag:10];
    
//    countTextFeild.tag = itemTxtTag + indexPath.row;

//    if (indexPath.row %2 == 0)
//    {
//        cell.backgroundColor = [UIColor whiteColor];
//    }
//    else
//    {
//        cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
//    }
    
    
//    countTextFeild.text = [NSString stringWithFormat:@"%ld", [[itemWICountArray objectAtIndex:indexPath.row] integerValue]];
    
    if (segment_WashType.selectedSegmentIndex == 0)
    {
        lblText.text = [[arrayWAI objectAtIndex:indexPath.row] objectForKey:@"n"];
        
        countTextFeild.text = [itemWICountArray objectAtIndex:indexPath.row];
    }
    else if(segment_WashType.selectedSegmentIndex == 1)
    {
        lblText.text = [[arrayDC objectAtIndex:indexPath.row] objectForKey:@"n"];
        
        countTextFeild.text = [itemDCCountArray objectAtIndex:indexPath.row];
    }
    else if(segment_WashType.selectedSegmentIndex == 2)
    {
        lblText.text = [[arrayIRN objectAtIndex:indexPath.row] objectForKey:@"n"];
        
        countTextFeild.text = [itemIRCountArray objectAtIndex:indexPath.row];
    }
    
//    if ([countTextFeild.text intValue] > 0)
//    {
//        if (![arraySelectedWashType containsObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]])
//        {
//            [arraySelectedWashType addObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]];
//        }
//    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}

#pragma mark UITextFeild Delegate Methods

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    if (selectBagTypeSegment.selectedIndex == 1)
    {
        CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        //CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        
        CGRect keyboardFrameEnd = [self.view convertRect:keyboardEndFrame toView:nil];
        //CGRect keyboardFrameBegin = [self.view convertRect:keyboardBeginFrame toView:nil];
        
        CGFloat yAxis = 64.0+10+30+10+40;
        
        wiITemsTableView.frame = CGRectMake(0, yAxis, screen_width, keyboardFrameEnd.origin.y-yAxis-40);
        dcITemsTableView.frame = CGRectMake(0, yAxis, screen_width, keyboardFrameEnd.origin.y-yAxis-40);
        irITemsTableView.frame = CGRectMake(0, yAxis, screen_width, keyboardFrameEnd.origin.y-yAxis-40);
        
        cancelBtn.frame = CGRectMake(0, keyboardFrameEnd.origin.y-40, screen_width/2, 40);
        adddetailsBtn.frame = CGRectMake(screen_width/2, keyboardFrameEnd.origin.y-40, screen_width/2, 40);
        
        [UIView commitAnimations];
    }
    else
    {
        CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        //CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        
        CGRect keyboardFrameEnd = [self.view convertRect:keyboardEndFrame toView:nil];
        //CGRect keyboardFrameBegin = [self.view convertRect:keyboardBeginFrame toView:nil];
        
        cancelBtn.frame = CGRectMake(0, keyboardFrameEnd.origin.y-40, screen_width/2, 40);
        adddetailsBtn.frame = CGRectMake(screen_width/2, keyboardFrameEnd.origin.y-40, screen_width/2, 40);
        
        [UIView commitAnimations];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"0"] && [textField.text length] == 0)
    {
        return NO;
    }
    
    NSLog(@"tag: %ld",textField.tag);
    
    if (selectBagTypeSegment.selectedIndex == 0)
    {
        
    }
    else if((selectBagTypeSegment.selectedIndex == 1))
    {
        if (textField.tag != 0)
        {
            NSString *str = [textField.text stringByAppendingString:string];
            
            if ([string isEqualToString:@""])
            {
                if (segment_WashType.selectedSegmentIndex == 0)
                {
                    [itemWICountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:@""];
                }
                else if (segment_WashType.selectedSegmentIndex == 1)
                {
                    [itemDCCountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:@""];
                }
                else if (segment_WashType.selectedSegmentIndex == 2)
                {
                    [itemIRCountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:@""];
                }
            }
            else
            {
                if (segment_WashType.selectedSegmentIndex == 0)
                {
                    [itemWICountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:str];
                }
                else if (segment_WashType.selectedSegmentIndex == 1)
                {
                    [itemDCCountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:str];
                }
                else if (segment_WashType.selectedSegmentIndex == 2)
                {
                    [itemIRCountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:str];
                }
            }
            
            if ([string isEqualToString:@""] && [textField.text length] == 1)
            {
                [arraySelectedWashType removeObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]];
            }
            else
            {
                if (![arraySelectedWashType containsObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]])
                {
                    [arraySelectedWashType addObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]];
                }
            }
        }
        
    }
    
    return YES;
}



-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    tempTf = textField;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    cancelBtn.frame = CGRectMake(0, screen_height-40.0-216, screen_width/2, 40);
//    adddetailsBtn.frame = CGRectMake(screen_width/2, screen_height-40.0-216, screen_width/2, 40);
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
//    cancelBtn.frame = CGRectMake(0, screen_height-40.0, screen_width/2, 40);
//    adddetailsBtn.frame = CGRectMake(screen_width/2, screen_height-40.0, screen_width/2, 40);
    
//    NSLog(@"tag: %ld",textField.tag);
//    
//    if (selectBagTypeSegment.selectedIndex == 0)
//    {
//        
//    }
//    else if((selectBagTypeSegment.selectedIndex == 1))
//    {
//        if (textField.tag != 0)
//        {
//            if (segment_WashType.selectedSegmentIndex == 0)
//            {
//                [itemWICountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:textField.text];
//            }
//            else if (segment_WashType.selectedSegmentIndex == 1)
//            {
//                [itemDCCountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:textField.text];
//            }
//            else if (segment_WashType.selectedSegmentIndex == 2)
//            {
//                [itemIRCountArray replaceObjectAtIndex:textField.tag-itemTxtTag withObject:textField.text];
//            }
//            
//            if ([textField.text length])
//            {
//                if (![arraySelectedWashType containsObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]])
//                {
//                    [arraySelectedWashType addObject:[NSString stringWithFormat:@"%ld", (long)segment_WashType.selectedSegmentIndex]];
//                }
//            }
//            
//        }
//       
//    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [wiITemsTableView reloadData];

    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
 
 -(void) PlusMinusClicked:(UIButton *)sender
 {
 CGPoint position = [sender convertPoint:CGPointZero toView:tblCategory];
 NSIndexPath *indexPath = [tblCategory indexPathForRowAtPoint:position];
 
 UITableViewCell *cell = [tblCategory cellForRowAtIndexPath:indexPath];
 
 UILabel *lblCount = (UILabel *) [cell.contentView viewWithTag:14];
 
 if ([lblCount.text intValue] <= 0 && sender.tag == 13)
 {
 return;
 }
 
 NSDictionary *dictRow;
 
 if ([strJobType isEqualToString:@"WF"] || [strJobType isEqualToString:@"CA"])
 {
 dictRow = (NSDictionary *) [arrayCategory objectAtIndex:indexPath.row];
 }
 else
 {
 dictRow = (NSDictionary *) [arrayRow objectAtIndex:indexPath.row];
 }
 
 NSString *strCategoryName = [segmentCategory.sectionTitles objectAtIndex:selectedCategoryIndex];
 
 if ([strCategoryName caseInsensitiveCompare:@"HouseHold"] == NSOrderedSame || [strCategoryName caseInsensitiveCompare:@"HouseHold Items"] == NSOrderedSame)
 {
 for (int i = 0; i < [dictViewBill count]; i++)
 {
 NSMutableArray *arrayItemDetails = [[dictViewBill allValues]objectAtIndex:i];
 
 for (int j = 0; j < [arrayItemDetails count]; j++)
 {
 NSDictionary *dictItems = [arrayItemDetails objectAtIndex:j];
 
 if (([[dictItems objectForKey:@"categoryName"] caseInsensitiveCompare:@"HouseHold"] == NSOrderedSame || [[dictItems objectForKey:@"categoryName"] caseInsensitiveCompare:@"HouseHold Items"] == NSOrderedSame) && [[dictItems objectForKey:@"jd"] isEqualToString:strJobType])
 {
 
 UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"" message:@"Piingo can't add Household items into this bag. Please add Household items into separate bag." preferredStyle:UIAlertControllerStyleAlert];
 
 UIAlertAction *addBag = [UIAlertAction actionWithTitle:@"Add Bag" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
 
 [self checkEnteredGarments];
 
 if ([parentDel respondsToSelector:@selector(addItemDetails:)])
 {
 [parentDel addItemDetails:dictViewBill];
 }
 
 [dictViewBill removeAllObjects];
 [dictItemCount removeAllObjects];
 [dictTotalPrice removeAllObjects];
 [dictCountForType removeAllObjects];
 
 [tblCategory reloadData];
 
 }];
 
 UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
 
 }];
 
 [alertCon addAction:addBag];
 [alertCon addAction:cancel];
 
 [self presentViewController:alertCon animated:true completion:nil];
 
 return;
 }
 }
 }
 }
 else
 {
 for (int i = 0; i < [dictViewBill count]; i++)
 {
 NSMutableArray *arrayItemDetails = [[dictViewBill allValues]objectAtIndex:i];
 
 for (int j = 0; j < [arrayItemDetails count]; j++)
 {
 NSDictionary *dictItems = [arrayItemDetails objectAtIndex:j];
 
 if (([[dictItems objectForKey:@"categoryName"] caseInsensitiveCompare:@"HouseHold"] == NSOrderedSame || [[dictItems objectForKey:@"categoryName"] caseInsensitiveCompare:@"HouseHold Items"] == NSOrderedSame) && [[dictItems objectForKey:@"jd"] isEqualToString:strJobType])
 {
 [AppDelegate showAlertWithMessage:@"Please add Household items into separate bag." andTitle:@"" andBtnTitle:@"OK"];
 return;
 }
 }
 }
 }
 
 
 NSString *strTag = [NSString stringWithFormat:@"%@-%ld-%ld-%@", strJobType, selectedCategoryIndex, (long)indexPath.row, strOrderType];
 
 if (sender.tag == 13)
 {
 if ([dictItemCount objectForKey:strTag])
 {
 NSMutableDictionary *dictCountWeight = [dictItemCount objectForKey:strTag];
 
 NSString *strItemCount = [dictCountWeight objectForKey:@"count"];
 
 NSString *strSegmentIndex = [NSString stringWithFormat:@"%ld", (long)selectedJobTypeIndex];
 
 NSString *strTotalPrice = [dictTotalPrice objectForKey:strSegmentIndex];
 
 if ([strItemCount intValue] != 0)
 {
 strItemCount = [NSString stringWithFormat:@"%d", [strItemCount intValue]-1];
 
 if ([strItemCount isEqualToString:@"0"])
 {
 [dictCountWeight removeObjectForKey:@"count"];
 }
 else
 {
 [dictCountWeight setObject:strItemCount forKey:@"count"];
 }
 
 double pricevalue = [strTotalPrice doubleValue] - [[dictRow objectForKey:@"ip"]doubleValue];
 [dictTotalPrice setObject:[NSString stringWithFormat:@"%.2f", pricevalue] forKey:strSegmentIndex];
 
 int TotalCountForType = [[dictCountForType objectForKey:strSegmentIndex]intValue];
 
 TotalCountForType -= 1;
 
 [dictCountForType setObject:[NSString stringWithFormat:@"%d", TotalCountForType] forKey:strSegmentIndex];
 
 
 
 
 
 
 BOOL isTagFound = NO;
 
 for (int i=0; i<[dictViewBill count]; i++)
 {
 NSMutableArray *arrayItemDetails = [[dictViewBill allValues]objectAtIndex:i];
 
 for (int j=0; j<[arrayItemDetails count]; j++)
 {
 NSMutableDictionary *dictItemDetails = [arrayItemDetails objectAtIndex:j];
 
 NSString *strLocalTag = [dictItemDetails objectForKey:strTag];
 
 if ([strLocalTag isEqualToString:strTag])
 {
 isTagFound = YES;
 
 [dictItemDetails setObject:strItemCount forKey:@"quantity"];
 
 if ([strItemCount isEqualToString:@"0"])
 {
 if ([dictItemDetails objectForKey:@"weight"])
 {
 
 }
 else
 {
 [arrayItemDetails removeObject:dictItemDetails];
 }
 
 [dictItemDetails removeObjectForKey:@"quantity"];
 
 if (![arrayItemDetails count])
 {
 [dictViewBill removeObjectForKey:strJobName];
 }
 }
 
 break;
 }
 }
 
 }
 
 if (!isTagFound)
 {
 NSMutableArray *arrayItemDetails = [dictViewBill objectForKey:strJobName];
 
 if (!arrayItemDetails)
 {
 arrayItemDetails = [[NSMutableArray alloc]init];
 }
 
 NSMutableDictionary *dictItemDetails = [[NSMutableDictionary alloc]init];
 [dictItemDetails setObject:@"0123456789" forKey:@"orno"];
 [dictItemDetails setObject:strJobName forKey:@"jn"];
 
 NSMutableDictionary *dictCountWeight = [dictItemCount objectForKey:strTag];
 
 [dictItemDetails setObject:[dictCountWeight objectForKey:@"count"] forKey:@"quantity"];
 
 [dictItemDetails setObject:[dictRow objectForKey:@"ip"] forKey:@"ip"];
 [dictItemDetails setObject:[dictRow objectForKey:@"ic"] forKey:@"ic"];
 
 [dictItemDetails setObject:[dictRow objectForKey:@"uomid"] forKey:@"UOMId"];
 
 [dictItemDetails setObject:strJobType forKey:@"jd"];
 [dictItemDetails setObject:[dictRow objectForKey:@"n"] forKey:@"n"];
 [dictItemDetails setObject:strTag forKey:strTag];
 
 //Newly added
 [dictItemDetails setObject:strCategoryName forKey:@"categoryName"];
 
 [arrayItemDetails addObject:dictItemDetails];
 
 [dictViewBill setObject:arrayItemDetails forKey:strJobName];
 }
 }
 else
 {
 [dictCountWeight removeObjectForKey:@"count"];
 }
 }
 }
 else if (sender.tag == 15)
 {
 if ([dictItemCount objectForKey:strTag])
 {
 NSMutableDictionary *dictCountWeight = [dictItemCount objectForKey:strTag];
 
 NSString *strItemCount = [dictCountWeight objectForKey:@"count"];
 
 NSString *strSegmentIndex = [NSString stringWithFormat:@"%ld", (long)selectedJobTypeIndex];
 
 NSString *strTotalPrice = [dictTotalPrice objectForKey:strSegmentIndex];
 
 strItemCount = [NSString stringWithFormat:@"%d", [strItemCount intValue]+1];
 [dictCountWeight setObject:strItemCount forKey:@"count"];
 
 //[dictItemCount setObject:strItemCount forKey:strTag];
 
 double pricevalue = [[dictRow objectForKey:@"ip"]doubleValue] + [strTotalPrice doubleValue];
 
 [dictTotalPrice setObject:[NSString stringWithFormat:@"%.2f", pricevalue] forKey:strSegmentIndex];
 
 int TotalCountForType = [[dictCountForType objectForKey:strSegmentIndex]intValue];
 
 TotalCountForType += 1;
 
 [dictCountForType setObject:[NSString stringWithFormat:@"%d", TotalCountForType] forKey:strSegmentIndex];
 
 
 
 
 
 
 
 
 BOOL isTagFound = NO;
 
 for (int i=0; i<[dictViewBill count]; i++)
 {
 NSMutableArray *arrayItemDetails = [[dictViewBill allValues]objectAtIndex:i];
 
 for (int j=0; j<[arrayItemDetails count]; j++)
 {
 NSMutableDictionary *dictItemDetails = [arrayItemDetails objectAtIndex:j];
 
 NSString *strLocalTag = [dictItemDetails objectForKey:strTag];
 
 if ([strLocalTag isEqualToString:strTag])
 {
 isTagFound = YES;
 [dictItemDetails setObject:strItemCount forKey:@"quantity"];
 
 if ([strItemCount isEqualToString:@"0"])
 {
 if ([dictItemDetails objectForKey:@"weight"])
 {
 
 }
 else
 {
 [arrayItemDetails removeObject:dictItemDetails];
 }
 
 [dictItemDetails removeObjectForKey:@"quantity"];
 
 if (![arrayItemDetails count])
 {
 [dictViewBill removeObjectForKey:strJobName];
 }
 }
 
 break;
 }
 }
 }
 
 if (!isTagFound)
 {
 NSMutableArray *arrayItemDetails = [dictViewBill objectForKey:strJobName];
 
 if (!arrayItemDetails)
 {
 arrayItemDetails = [[NSMutableArray alloc]init];
 }
 
 NSMutableDictionary *dictItemDetails = [[NSMutableDictionary alloc]init];
 [dictItemDetails setObject:@"0123456789" forKey:@"orno"];
 [dictItemDetails setObject:strJobName forKey:@"jn"];
 
 NSMutableDictionary *dictCountWeight = [dictItemCount objectForKey:strTag];
 
 NSString *strItemCount = [dictCountWeight objectForKey:@"count"];
 
 [dictItemDetails setObject:strItemCount forKey:@"quantity"];
 
 [dictItemDetails setObject:[dictRow objectForKey:@"ip"] forKey:@"ip"];
 [dictItemDetails setObject:[dictRow objectForKey:@"ic"] forKey:@"ic"];
 [dictItemDetails setObject:[dictRow objectForKey:@"uomid"] forKey:@"UOMId"];
 
 [dictItemDetails setObject:strJobType forKey:@"jd"];
 [dictItemDetails setObject:[dictRow objectForKey:@"n"] forKey:@"n"];
 [dictItemDetails setObject:strTag forKey:strTag];
 
 //Newly added
 [dictItemDetails setObject:strCategoryName forKey:@"categoryName"];
 
 [arrayItemDetails addObject:dictItemDetails];
 
 [dictViewBill setObject:arrayItemDetails forKey:strJobName];
 }
 }
 else
 {
 NSMutableDictionary *dictCountWeight = [[NSMutableDictionary alloc]init];
 
 NSString *strItemCount = [NSString stringWithFormat:@"%d", 1];
 [dictCountWeight setObject:strItemCount forKey:@"count"];
 
 [dictItemCount setObject:dictCountWeight forKey:strTag];
 
 NSString *strSegmentIndex = [NSString stringWithFormat:@"%ld", (long)selectedJobTypeIndex];
 
 NSString *strTotalPrice = [dictTotalPrice objectForKey:strSegmentIndex];
 
 double pricevalue = [[dictRow objectForKey:@"ip"]doubleValue] + [strTotalPrice doubleValue];
 [dictTotalPrice setObject:[NSString stringWithFormat:@"%.2f", pricevalue] forKey:strSegmentIndex];
 
 int TotalCountForType = [[dictCountForType objectForKey:strSegmentIndex]intValue];
 
 TotalCountForType += 1;
 
 [dictCountForType setObject:[NSString stringWithFormat:@"%d", TotalCountForType] forKey:strSegmentIndex];
 
 
 
 
 
 BOOL isTagFound = NO;
 
 for (int i=0; i<[dictViewBill count]; i++)
 {
 NSMutableArray *arrayItemDetails = [[dictViewBill allValues]objectAtIndex:i];
 
 for (int j=0; j<[arrayItemDetails count]; j++)
 {
 NSMutableDictionary *dictItemDetails = [arrayItemDetails objectAtIndex:j];
 
 NSString *strLocalTag = [dictItemDetails objectForKey:strTag];
 
 if ([strLocalTag isEqualToString:strTag])
 {
 isTagFound = YES;
 [dictItemDetails setObject:strItemCount forKey:@"quantity"];
 
 if ([strItemCount isEqualToString:@"0"])
 {
 if ([dictItemDetails objectForKey:@"weight"])
 {
 
 }
 else
 {
 [arrayItemDetails removeObject:dictItemDetails];
 }
 
 [dictItemDetails removeObjectForKey:@"quantity"];
 
 if (![arrayItemDetails count])
 {
 [dictViewBill removeObjectForKey:strJobName];
 }
 }
 
 break;
 }
 }
 
 }
 
 if (!isTagFound)
 {
 NSMutableArray *arrayItemDetails = [dictViewBill objectForKey:strJobName];
 
 if (!arrayItemDetails)
 {
 arrayItemDetails = [[NSMutableArray alloc]init];
 }
 
 NSMutableDictionary *dictItemDetails = [[NSMutableDictionary alloc]init];
 [dictItemDetails setObject:@"0123456789" forKey:@"orno"];
 [dictItemDetails setObject:strJobName forKey:@"jn"];
 
 NSMutableDictionary *dictCountWeight = [dictItemCount objectForKey:strTag];
 
 [dictItemDetails setObject:[dictCountWeight objectForKey:@"count"] forKey:@"quantity"];
 
 [dictItemDetails setObject:[dictRow objectForKey:@"uomid"] forKey:@"UOMId"];
 
 [dictItemDetails setObject:[dictRow objectForKey:@"ip"] forKey:@"ip"];
 [dictItemDetails setObject:[dictRow objectForKey:@"ic"] forKey:@"ic"];
 [dictItemDetails setObject:strJobType forKey:@"jd"];
 [dictItemDetails setObject:[dictRow objectForKey:@"n"] forKey:@"n"];
 [dictItemDetails setObject:strTag forKey:strTag];
 
 //Newly added
 [dictItemDetails setObject:strCategoryName forKey:@"categoryName"];
 
 [arrayItemDetails addObject:dictItemDetails];
 
 [dictViewBill setObject:arrayItemDetails forKey:strJobName];
 }
 }
 }
 
 //NSString *strSegmentIndex = [NSString stringWithFormat:@"%ld", (long)selectedJobTypeIndex];
 
 //[appDel.dictEachSegmentCount setObject:[dictCountForType objectForKey:strSegmentIndex] forKey:strSegmentIndex];
 
 
 if ([dictTotalPrice count])
 {
 float totalPrice = 0;
 
 NSArray *array = [dictTotalPrice allKeys];
 
 for (int i=0; i<[dictTotalPrice count]; i++)
 {
 totalPrice += [[dictTotalPrice objectForKey:[array objectAtIndex:i]] floatValue];
 }
 }
 
 [tblCategory reloadData];
 }
 
 
 
 
 
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
