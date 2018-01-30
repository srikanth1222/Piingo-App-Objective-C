//
//  AddItemsViewController_New.m
//  PiingApp
//
//  Created by Veedepu Srikanth on 17/06/16.
//  Copyright © 2016 shashank. All rights reserved.
//

#import "AddItemsViewController_New.h"
#import "HMSegmentedControl.h"
#import "MCSwipeTableViewCell.h"
#import "CalculateViewController.h"
#import "NSNull+JSON.h"
#import "BagAndShoeDetailViewController.h"


#define ACCEPTABLE_CHARECTERS @"0123456789."
#define ACCEPTABLE_CHARECTERS_NO_DOT @"0123456789"


@interface AddItemsViewController_New () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, CalculateViewControllerDelegate, BagAndShoeDetailViewControllerDelegate>
{
    HMSegmentedControl *segmentImages;
    
    AppDelegate *appDel;
    
    NSMutableArray *arrImages;
    NSMutableArray *arrTitles;
    
    NSMutableArray *arrayCategory;
    
    NSMutableArray *arraykey;
    
    HMSegmentedControl *segmentCategory;
    
    UITableView *tblCategory;
    
    NSMutableArray *arrayRow;
    
    NSInteger selectedJobTypeIndex;
    NSInteger selectedCategoryIndex;
    
    NSString *strJobType;
    
    NSMutableDictionary *dictItemCount;
    NSMutableDictionary *dictTotalPrice;
    NSMutableDictionary *dictCountForType;
    NSMutableDictionary *dictViewBill;
    
    NSString *strOrderType;
    
    NSString *strJobName;
    
    UITextField *tfGlobal;
    
    NSMutableArray *arrayServiceType;
    
    UIView *view_BagShoe;
    
    NSInteger bagsCount;
    NSInteger shoeCount;
    
    BOOL isAlreadyAddedItems;
}

@end

@implementation AddItemsViewController_New

@synthesize parentDel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    arrImages = [[NSMutableArray alloc]init];
    arrTitles = [[NSMutableArray alloc]init];
    arrayCategory = [[NSMutableArray alloc]init];
    arraykey = [[NSMutableArray alloc]init];
    arrayServiceType = [[NSMutableArray alloc]init];
    
    
    dictItemCount = [[NSMutableDictionary alloc]init];
    dictTotalPrice = [[NSMutableDictionary alloc]init];
    dictCountForType = [[NSMutableDictionary alloc]init];
    dictViewBill = [[NSMutableDictionary alloc]init];
    
    arrayRow = [[NSMutableArray alloc]init];
    
    if ([[self.orderDetailDic objectForKey:@"orderSpeed"] caseInsensitiveCompare:@"R"] == NSOrderedSame)
    {
        strOrderType = @"R";
    }
    else
    {
        strOrderType = @"E";
    }
    
    NSArray *arraySer = [self.orderDetailDic objectForKey:@"serviceTypes"];
    
    if ([arraySer containsObject:@"WF"])
    {
        [arrImages addObject:[UIImage imageNamed:@"wash_fold_price"]];
        [arrTitles addObject:@"LOAD WASH"];
        [arrayServiceType addObject:@"WF"];
    }
    if ([arraySer containsObject:@"DC"])
    {
        [arrImages addObject:[UIImage imageNamed:@"dryclean_price"]];
        [arrTitles addObject:@"DRY CLEANING"];
        [arrayServiceType addObject:@"DC"];
    }
    if ([arraySer containsObject:@"DCG"])
    {
        [arrImages addObject:[UIImage imageNamed:@"dryclean_price"]];
        [arrTitles addObject:@"GREEN DRY CLEANING"];
        [arrayServiceType addObject:@"DCG"];
    }
    
    if ([arraySer containsObject:@"WI"])
    {
        [arrImages addObject:[UIImage imageNamed:@"wash_iron_price"]];
        [arrTitles addObject:@"WASH & IRON"];
        [arrayServiceType addObject:@"WI"];
    }
    if ([arraySer containsObject:@"IR"])
    {
        [arrImages addObject:[UIImage imageNamed:@"ironing_price"]];
        [arrTitles addObject:@"IRONING"];
        [arrayServiceType addObject:@"IR"];
    }
    if ([arraySer containsObject:@"LE"])
    {
        [arrImages addObject:[UIImage imageNamed:@"leather_price"]];
        [arrTitles addObject:@"LEATHER"];
        [arrayServiceType addObject:@"LE"];
    }
    if ([arraySer containsObject:@"CA"])
    {
        [arrImages addObject:[UIImage imageNamed:@"carpet_price"]];
        [arrTitles addObject:@"CARPET"];
        [arrayServiceType addObject:@"CA"];
    }
    if ([arraySer containsObject:@"CC_DC"] || [arraySer containsObject:@"CC_W_DC"] || [arraySer containsObject:@"CC_WI"] || [arraySer containsObject:@"CC_W_WI"])
    {
        [arrImages addObject:[UIImage imageNamed:@"curtains_price"]];
        [arrTitles addObject:@"CURTAINS"];
        
        if ([arraySer containsObject:@"CC_DC"])
        {
            [arrayServiceType addObject:@"CC_DC"];
        }
        else if ([arraySer containsObject:@"CC_W_DC"])
        {
            [arrayServiceType addObject:@"CC_W_DC"];
        }
        else if ([arraySer containsObject:@"CC_WI"])
        {
            [arrayServiceType addObject:@"CC_WI"];
        }
        else if ([arraySer containsObject:@"CC_W_WI"])
        {
            [arrayServiceType addObject:@"CC_W_WI"];
        }
    }
    if ([arraySer containsObject:SERVICETYPE_BAG])
    {
        [arrImages addObject:[UIImage imageNamed:@"bag_price"]];
        [arrTitles addObject:@"BAG"];
        [arrayServiceType addObject:SERVICETYPE_BAG];
    }
    if ([arraySer containsObject:SERVICETYPE_SHOE_CLEAN] || [arraySer containsObject:SERVICETYPE_SHOE_POLISH])
    {
        [arrImages addObject:[UIImage imageNamed:@"shoe_price"]];
        [arrTitles addObject:@"SHOES"];
        
        if ([arraySer containsObject:SERVICETYPE_SHOE_CLEAN])
        {
            [arrayServiceType addObject:SERVICETYPE_SHOE_CLEAN];
        }
        if ([arraySer containsObject:SERVICETYPE_SHOE_POLISH])
        {
            [arrayServiceType addObject:SERVICETYPE_SHOE_POLISH];
        }
    }
    
    CGFloat yAxis = 20*MULTIPLYHEIGHT;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(5*MULTIPLYHEIGHT, yAxis, 40.0, 40.0);
    [closeBtn setImage:[UIImage imageNamed:@"cancel_grey"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(backToPreviousScreen) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:closeBtn];
    
    if (![arrTitles count])
    {
        [self performSelector:@selector(showAlert) withObject:nil afterDelay:0.7];
        
        return;
    }
    
    strJobName = [arrTitles objectAtIndex:0];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(screen_width-60*MULTIPLYHEIGHT, yAxis, 60*MULTIPLYHEIGHT, 40.0);
    [addBtn setTitle:@"ADD" forState:UIControlStateNormal];
    [addBtn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    addBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:addBtn];
    
    yAxis += 40.0+5*MULTIPLYHEIGHT;
    
    float segmentHeight = 72*MULTIPLYHEIGHT;
    
    segmentImages = [[HMSegmentedControl alloc]initWithSectionImages:arrImages sectionSelectedImages:arrImages titlesForSections:arrTitles];
    //segmentImages.delegate = self;
    segmentImages.frame = CGRectMake(0, yAxis, screen_width, segmentHeight);
    
    float left = 35*MULTIPLYHEIGHT;
    float right = 35*MULTIPLYHEIGHT;
    
    segmentImages.segmentEdgeInset = UIEdgeInsetsMake(0, left, 0, right);
    segmentImages.backgroundColor = [UIColor clearColor];
    segmentImages.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    segmentImages.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    segmentImages.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-4]};
    segmentImages.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-4]};
    [segmentImages addTarget:self action:@selector(segmentedMainControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentImages];
    segmentImages.selectionStyle = HMSegmentedControlSelectionStyleBox;
    segmentImages.selectionIndicatorColor = BLUE_COLOR;
    segmentImages.selectionIndicatorBoxOpacity = 1.0f;
    segmentImages.selectedSegmentIndex = 0;
    
//    [segmentImages setIndexChangeBlock:^(NSInteger index) {
//        
//        [self performSelector:@selector(scrollAnimated) withObject:nil afterDelay:0.4];
//    }];
    
    //[self segmentedControlChangedValue:segmentImages];
    
    segmentImages.selectedSegmentIndex = selectedCategoryIndex;
    
    strJobType = [arrayServiceType objectAtIndex:0];
    
    [self getCategories];
    
    yAxis += segmentHeight+10*MULTIPLYHEIGHT;
    
    
    float segmentCHeight = 30*MULTIPLYHEIGHT;
    
    segmentCategory = [[HMSegmentedControl alloc]init];
    segmentCategory.frame = CGRectMake(0, yAxis, screen_width, segmentCHeight);
    //segmentCategory.delegate = self;
    segmentCategory.borderType = HMSegmentedControlBorderTypeNone;
    segmentCategory.backgroundColor = [UIColor clearColor];
    segmentCategory.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    segmentCategory.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    segmentCategory.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
    segmentCategory.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : BLUE_COLOR, NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
    [segmentCategory addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentCategory];
    
    yAxis += segmentCHeight+10*MULTIPLYHEIGHT;
    
    tblCategory = [[UITableView alloc]init];
    tblCategory.frame = CGRectMake(0, yAxis, screen_width, screen_height-yAxis);
    tblCategory.dataSource = self;
    tblCategory.delegate = self;
    tblCategory.separatorStyle = UITableViewCellSeparatorStyleNone;
    tblCategory.contentInset = UIEdgeInsetsMake(0, 0, 30*MULTIPLYHEIGHT, 0);
    [self.view addSubview:tblCategory];
}

-(void) showAlert
{
    [AppDelegate showAlertWithMessage:@"There is no service type, please check" andTitle:@"" andBtnTitle:@"OK"];
}


-(void) addBtnClicked
{
    if (isAlreadyAddedItems && ![dictViewBill count])
    {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (![dictViewBill count])
    {
        [AppDelegate showAlertWithMessage:@"Please add items" andTitle:@"" andBtnTitle:@"OK"];
        return;
    }
    
    [self checkEnteredGarments];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        if ([parentDel respondsToSelector:@selector(addItemDetails:)])
        {
            [parentDel addItemDetails:dictViewBill];
        }
    }];
}

-(void) checkEnteredGarments {
    
    for (int i = 0; i < [dictViewBill count]; i++)
    {
        NSArray *arrayServiceType1 = [dictViewBill objectForKey:[[dictViewBill allKeys] objectAtIndex:i]];
        
        if ([[[dictViewBill allKeys] objectAtIndex:i] caseInsensitiveCompare:@"Curtains"] == NSOrderedSame)
        {
            for (long int j = 0; j < [arrayServiceType1 count]; j++)
            {
                NSDictionary *dict = [arrayServiceType1 objectAtIndex:j];
                
                if ([dict objectForKey:@"weight"])
                {
                    if (![dict objectForKey:@"quantity"])
                    {
                        [AppDelegate showAlertWithMessage:@"Please enter quantity and weight of items." andTitle:@"" andBtnTitle:@"OK"];
                        
                        return;
                    }
                }
                
                else if ([dict objectForKey:@"quantity"] && [[dict objectForKey:@"UOMId"]intValue] != 1)
                {
                    if (![dict objectForKey:@"weight"])
                    {
                        [AppDelegate showAlertWithMessage:@"Please enter quantity and weight of items." andTitle:@"" andBtnTitle:@"OK"];
                        
                        return;
                    }
                }
            }
        }
        else
        {
            
        }
    }
}

-(void) segmentedMainControlChangedValue:(HMSegmentedControl *)segment
{
    strJobType = [arrayServiceType objectAtIndex:segment.selectedSegmentIndex];
    
    selectedJobTypeIndex = segment.selectedSegmentIndex;
    
    selectedCategoryIndex = 0;
    
    strJobName = [arrTitles objectAtIndex:segment.selectedSegmentIndex];
    
    segmentCategory.hidden = YES;
    tblCategory.hidden = YES;
    view_BagShoe.hidden = YES;
    
    
    if ([strJobType isEqualToString:@"WF"] || [strJobType isEqualToString:@"CA"] || [strJobType containsString:@"CC"])
    {
        tblCategory.hidden = NO;
       
    }
    else if ([strJobType isEqualToString:SERVICETYPE_BAG] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH] || [strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
    {
        view_BagShoe.hidden = NO;
    }
    else
    {
        segmentCategory.hidden = NO;
        tblCategory.hidden = NO;
    }
    
    [self getCategories];
}


-(void) getCategories
{
    [self.view endEditing:YES];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:strOrderType, @"orderType", strJobType, @"serviceType", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@pricing/get", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [arrayCategory removeAllObjects];
            
            [arrayCategory addObjectsFromArray:[responseObj objectForKey:@"prices"]];
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if ([strJobType isEqualToString:SERVICETYPE_BAG] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH] || [strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
            {
                [self createBagAndShoe];
            }
            else if (![strJobType isEqualToString:@"WF"] && ![strJobType isEqualToString:@"CA"] && ![strJobType containsString:@"CC"])
            {
                [self createCategories];
            }
            else
            {
                [arrayRow removeAllObjects];
                
                [arrayRow addObjectsFromArray:[responseObj objectForKey:@"prices"]];
                
                [tblCategory reloadData];
            }
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

-(void) createBagAndShoe
{
    if (!view_BagShoe) {
        
        view_BagShoe = [[UIView alloc]initWithFrame:CGRectMake(0, segmentCategory.frame.origin.y, screen_width, screen_height-segmentCategory.frame.origin.y)];
        view_BagShoe.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:view_BagShoe];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewBagClicked:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [view_BagShoe addGestureRecognizer:tap];
    
    segmentCategory.hidden = YES;
    tblCategory.hidden = YES;
    
    view_BagShoe.hidden = NO;
    
    for (__strong id view in view_BagShoe.subviews)
    {
        [view removeFromSuperview];
        view = nil;
    }
    
    CGFloat lblX = 10*MULTIPLYHEIGHT;
    CGFloat lblW = 130*MULTIPLYHEIGHT;
    CGFloat lblHeight = 36*MULTIPLYHEIGHT;
    
    UILabel *lblQuantity = [[UILabel alloc]initWithFrame:CGRectMake(lblX, 0, lblW, lblHeight)];
    lblQuantity.text = @"Enter the quantity";
    lblQuantity.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM];
    lblQuantity.textColor = [UIColor grayColor];
    [view_BagShoe addSubview:lblQuantity];
    
    
    UITextField *tf = [[UITextField alloc]init];
    
    if ([strJobType isEqualToString:SERVICETYPE_BAG])
    {
        if (bagsCount)
        {
            tf.text = [NSString stringWithFormat:@"%ld", bagsCount];
        }
    }
    else if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH])
    {
        if (shoeCount)
        {
            tf.text = [NSString stringWithFormat:@"%ld", shoeCount];
        }
    }
    
    tf.keyboardType = UIKeyboardTypeNumberPad;
    tf.textAlignment = NSTextAlignmentCenter;
    tf.delegate = self;
    tf.tag = 20;
    tf.textColor = APP_FONT_COLOR_GREY;
    tf.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
    [view_BagShoe addSubview:tf];
    
    CALayer *layer = [[CALayer alloc]init];
    [layer setName:@"tf"];
    layer.backgroundColor = [UIColor grayColor].CGColor;
    [tf.layer addSublayer:layer];
    
    float tfWidth = 40*MULTIPLYHEIGHT;
    
    tf.frame = CGRectMake(lblX+lblW+20*MULTIPLYHEIGHT, 5*MULTIPLYHEIGHT, tfWidth, lblHeight-(5*MULTIPLYHEIGHT*2));
    
    for (CALayer *layer in [tf.layer sublayers])
    {
        if ([layer.name isEqualToString:@"tf"])
        {
            layer.frame = CGRectMake(0, tf.frame.size.height-1, tf.frame.size.width, 1);
        }
    }
    
    UIButton *btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSave setTitle:@"Save" forState:UIControlStateNormal];
    btnSave.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
    [btnSave setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSave.backgroundColor = BLUE_COLOR;
    [btnSave addTarget:self action:@selector(openBagsAndShoesScreen) forControlEvents:UIControlEventTouchUpInside];
    [view_BagShoe addSubview:btnSave];
    
    CGFloat btnW = 70*MULTIPLYHEIGHT;
    CGFloat btnX = screen_width/2-btnW/2;
    CGFloat btnY = 60*MULTIPLYHEIGHT;
    CGFloat btnH = 25*MULTIPLYHEIGHT;
    
    btnSave.frame = CGRectMake(btnX, btnY, btnW, btnH);
}

-(void) viewBagClicked:(id) sender
{
    [self.view endEditing:YES];
}

-(void) openBagsAndShoesScreen
{
    UITextField *tf = (UITextField *) [view_BagShoe viewWithTag:20];
    
    if ([tf.text length])
    {
        BagAndShoeDetailViewController *obj = [[BagAndShoeDetailViewController alloc]init];
        obj.delegate = self;
        obj.arrayCategories = [[NSMutableArray alloc]initWithArray:arrayCategory];
        obj.strOrderType = strOrderType;
        
        if ([strJobName isEqualToString:@"SHOES"])
        {
            obj.arrayShoeServicetype = [[NSMutableArray alloc]init];
            obj.arrayShoeServicetypeName = [[NSMutableArray alloc]init];
            
            if ([arrayServiceType containsObject:SERVICETYPE_SHOE_CLEAN])
            {
                [obj.arrayShoeServicetype addObject:SERVICETYPE_SHOE_CLEAN];
                [obj.arrayShoeServicetypeName addObject:@"SHOE CLEAN"];
            }
            if ([arrayServiceType containsObject:SERVICETYPE_SHOE_POLISH])
            {
                [obj.arrayShoeServicetype addObject:SERVICETYPE_SHOE_POLISH];
                [obj.arrayShoeServicetypeName addObject:@"SHOE POLISH"];
            }
            
            if ([arrayServiceType containsObject:SERVICETYPE_SHOE_CLEAN])
            {
                obj.strServiceType = SERVICETYPE_SHOE_CLEAN;
                obj.strServiceTypeName = @"SHOE CLEAN";
            }
            else if ([arrayServiceType containsObject:SERVICETYPE_SHOE_POLISH])
            {
                obj.strServiceType = SERVICETYPE_SHOE_POLISH;
                obj.strServiceTypeName = @"SHOE POLISH";
            }
        }
        else
        {
            obj.strServiceType = strJobType;
            obj.strServiceTypeName = strJobName;
        }
        
        obj.countOfItems = [tf.text integerValue];
        [self presentViewController:obj animated:YES completion:nil];
    }
    else
    {
        [AppDelegate showAlertWithMessage:@"Please enter count" andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) didAddBagsAndShoes:(NSMutableDictionary *) dictItems
{
    if ([dictItems objectForKey:SERVICETYPE_BAG])
    {
        bagsCount = [[dictItems objectForKey:@"totalCount"] integerValue];
    }
    else
    {
        shoeCount = [[dictItems objectForKey:@"totalCount"] integerValue];
    }
    
    if ([strJobName isEqualToString:@"SHOES"])
    {
        if ([arrayServiceType containsObject:SERVICETYPE_SHOE_POLISH])
        {
            if ([dictItems objectForKey:@"SHOE POLISH"])
            {
                [dictViewBill setObject:[dictItems objectForKey:@"SHOE POLISH"] forKey:@"SHOE POLISH"];
            }
        }
        
        if ([arrayServiceType containsObject:SERVICETYPE_SHOE_CLEAN])
        {
            if ([dictItems objectForKey:@"SHOE CLEAN"])
            {
                [dictViewBill setObject:[dictItems objectForKey:@"SHOE CLEAN"] forKey:@"SHOE CLEAN"];
            }
        }
    }
    else
    {
        [dictViewBill setObject:[dictItems objectForKey:strJobName] forKey:strJobName];
    }
}


-(void) createCategories
{
    [arraykey removeAllObjects];
    
    for (int i=0; i<[arrayCategory count]; i++)
    {
        NSArray *arr = [[arrayCategory objectAtIndex:i]allKeys];
        
        for (NSString *str in arr)
        {
            if ([str isEqualToString:@"imgpath"])
            {
                //[arrayImagePath addObject:[[arrayCategory objectAtIndex:i] objectForKey:str]];
            }
            else if ([str isEqualToString:@"imgpathblue"])
            {
                //[arrayImagePathSelected addObject:[[arrayCategory objectAtIndex:i] objectForKey:str]];
            }
            else
            {
                [arraykey addObject:str];
            }
        }
    }
    
    [segmentCategory initWithSectionTitles:arraykey];
    
    [arrayRow removeAllObjects];
    
    NSDictionary *dictRow = [arrayCategory objectAtIndex:selectedCategoryIndex];
    [arrayRow addObjectsFromArray:[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]]];
    
    [tblCategory reloadData];
}

-(void) didStartScroll:(HMSegmentedControl *)segmentControl Scroller:(UIScrollView *)scrollView
{
   
}

-(void) backToPreviousScreen
{
    [appDel.dictEachSegmentCount removeAllObjects];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) segmentedControlChangedValue:(HMSegmentedControl *) segment
{
    [arrayRow removeAllObjects];
    
    NSDictionary *dictRow = [arrayCategory objectAtIndex:segment.selectedSegmentIndex];
    [arrayRow addObjectsFromArray:[dictRow objectForKey:[arraykey objectAtIndex:segment.selectedSegmentIndex]]];
    
    selectedCategoryIndex = segment.selectedSegmentIndex;
    
    [tblCategory reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30*MULTIPLYHEIGHT;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([strJobType isEqualToString:@"WF"] || [strJobType isEqualToString:@"CA"])
    {
        if ([arrayCategory count])
        {
            return 1;
        }
        
        return 0;
    }
    else if ([strJobType containsString:@"CC"])
    {
        return [arrayCategory count];
    }
    else
    {
        return [arrayRow count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCell = @"Cell";
    
    MCSwipeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:strCell];
    
    if (cell == nil)
    {
        cell = [[MCSwipeTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCell];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblWash = [[UILabel alloc]init];
        lblWash.tag = 10;
        lblWash.numberOfLines = 0;
        lblWash.textColor = APP_FONT_COLOR_GREY;
        lblWash.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
        [cell.contentView addSubview:lblWash];
        
        UILabel *lblPrice = [[UILabel alloc]init];
        lblPrice.tag = 11;
        lblPrice.textColor = APP_FONT_COLOR_GREY;
        lblPrice.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM];
        [cell.contentView addSubview:lblPrice];
        
        UILabel *lblWeight = [[UILabel alloc]init];
        lblWeight.tag = 12;
        lblWeight.textColor = APP_FONT_COLOR_GREY;
        lblWeight.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        [cell.contentView addSubview:lblWeight];
        
        
        UILabel *lblCount = [[UILabel alloc]init];
        lblCount.tag = 14;
        lblCount.text = @"0";
        lblCount.textAlignment = NSTextAlignmentCenter;
        lblCount.textColor = APP_FONT_COLOR_GREY;
        lblCount.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM];
        [cell.contentView addSubview:lblCount];
        
        UIButton *btnMinus = [UIButton buttonWithType:UIButtonTypeCustom];
        btnMinus.tag = 13;
        [btnMinus setTitle:@"-" forState:UIControlStateNormal];
        btnMinus.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE+10];
        [btnMinus setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        [btnMinus addTarget:self action:@selector(PlusMinusClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnMinus];
        //btnMinus.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        
        
        UIButton *btnPlus = [UIButton buttonWithType:UIButtonTypeCustom];
        btnPlus.tag = 15;
        [btnPlus setTitle:@"+" forState:UIControlStateNormal];
        btnPlus.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE+10];
        [btnPlus setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        [btnPlus addTarget:self action:@selector(PlusMinusClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnPlus];
        //btnPlus.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        
        UITextField *tf = [[UITextField alloc]init];
        tf.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        tf.textAlignment = NSTextAlignmentCenter;
        tf.delegate = self;
        tf.tag = 16;
        tf.textColor = APP_FONT_COLOR_GREY;
        tf.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
        [cell.contentView addSubview:tf];
        
        CALayer *layer = [[CALayer alloc]init];
        [layer setName:@"tf"];
        layer.backgroundColor = [UIColor grayColor].CGColor;
        [tf.layer addSublayer:layer];
    }
    
    UIView *checkView = [self viewWithImageName:@"plus_icon"];
    UIColor *greenColor = [UIColor colorWithRed:85.0 / 255.0 green:213.0 / 255.0 blue:80.0 / 255.0 alpha:1.0];
    
    UIView *crossView = [self viewWithImageName:@"minus_icon"];
    UIColor *redColor = [UIColor colorWithRed:232.0 / 255.0 green:61.0 / 255.0 blue:14.0 / 255.0 alpha:1.0];
    
    cell.firstTrigger = 0.1;
    
    [cell setSwipeGestureWithView:checkView color:greenColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        
        
    }];
    
    [cell setSwipeGestureWithView:crossView color:redColor mode:MCSwipeTableViewCellModeSwitch state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode) {
        
        
    }];
    
    cell.backgroundColor = [UIColor clearColor];
    
    NSDictionary *dict;
    
    if ([strJobType isEqualToString:@"WF"] || [strJobType isEqualToString:@"CA"] || [strJobType containsString:@"CC"])
    {
        dict = (NSDictionary *) [arrayCategory objectAtIndex:indexPath.row];
    }
    else
    {
        dict = (NSDictionary *) [arrayRow objectAtIndex:indexPath.row];
    }
    
    UILabel *lblWash = (UILabel *) [cell.contentView viewWithTag:10];
    
    UILabel *lblPrice = (UILabel *) [cell.contentView viewWithTag:11];
    
    UILabel *lblWeight = (UILabel *) [cell.contentView viewWithTag:12];
    
    UIButton *btnMinus = (UIButton *) [cell.contentView viewWithTag:13];
    UILabel *lblCount = (UILabel *) [cell.contentView viewWithTag:14];
    UIButton *btnPlus = (UIButton *) [cell.contentView viewWithTag:15];
    
    UITextField *tf = (UITextField *) [cell.contentView viewWithTag:16];
    tf.hidden = YES;
    
    lblWeight.hidden = YES;
    
    lblCount.hidden = YES;
    btnPlus.hidden = YES;
    btnMinus.hidden = YES;
    
    float lblHeight = 36*MULTIPLYHEIGHT;
    
    NSString *strTag = [NSString stringWithFormat:@"%@-%ld-%ld-%@", strJobType, selectedCategoryIndex, (long)indexPath.row, strOrderType];
    
    NSMutableDictionary *dictCountWeight;
    
    if ([dictItemCount objectForKey:strTag])
    {
        dictCountWeight = [dictItemCount objectForKey:strTag];
    }
    
    if ([strJobType isEqualToString:@"WF"] || [strJobType isEqualToString:@"CA"])
    {
        lblWash.text = [dict objectForKey:@"n"];
        lblWash.hidden = YES;
        
        lblWeight.text = [NSString stringWithFormat:@"%@ - %@", [dict objectForKey:@"fwt"],[dict objectForKey:@"twt"]];
        lblWeight.hidden = NO;
        
        
        float xAxis = 10;
        float lblWWidth = 100*MULTIPLYHEIGHT;
        
        lblWeight.frame = CGRectMake(xAxis, 0, lblWWidth, lblHeight);
        xAxis += lblWWidth+5*MULTIPLYHEIGHT;
        
        
        float lblPWidth = 43*MULTIPLYHEIGHT;
        
        lblPrice.frame = CGRectMake(xAxis, 0, lblPWidth, lblHeight);
        xAxis += lblPWidth+35*MULTIPLYHEIGHT;
        
        float tfWidth = 40*MULTIPLYHEIGHT;
        
        tf.text = [dictCountWeight objectForKey:@"weight"];
        
        tf.hidden = NO;
        tf.frame = CGRectMake(screen_width-tfWidth-10*MULTIPLYHEIGHT, 5*MULTIPLYHEIGHT, tfWidth, lblHeight-(5*MULTIPLYHEIGHT*2));
        
        for (CALayer *layer in [tf.layer sublayers])
        {
            if ([layer.name isEqualToString:@"tf"])
            {
                layer.frame = CGRectMake(0, tf.frame.size.height-1, tf.frame.size.width, 1);
            }
        }
    }
    else
    {
        
        lblWash.text = [dict objectForKey:@"n"];
        lblWash.hidden = NO;
        
        float xAxis = 10;
        
        if ([strJobType containsString:@"CC"])
        {
            
            if ([[dict objectForKey:@"uomid"] intValue] == 1)
            {
                float lblWWidth = 110*MULTIPLYHEIGHT;
                
                lblWash.frame = CGRectMake(xAxis, 0, lblWWidth, lblHeight);
                xAxis += lblWWidth+10*MULTIPLYHEIGHT;
                
                
                float lblPWidth = 43*MULTIPLYHEIGHT;
                
                lblPrice.frame = CGRectMake(xAxis, 0, lblPWidth, lblHeight);
                xAxis += lblPWidth+20*MULTIPLYHEIGHT;
                
                lblCount.hidden = NO;
                btnPlus.hidden = NO;
                btnMinus.hidden = NO;
                
                float btnWidth = 40*MULTIPLYHEIGHT;
                
                btnMinus.frame = CGRectMake(xAxis, 0, btnWidth, lblHeight);
                xAxis += btnWidth;
                
                btnPlus.frame = CGRectMake(xAxis, 0, btnWidth, lblHeight);
                
                lblCount.frame = CGRectMake(btnMinus.frame.origin.x, 0, btnWidth*2, lblHeight);
            }
            else
            {
                float lblWWidth = 90*MULTIPLYHEIGHT;
                
                lblWash.frame = CGRectMake(xAxis, 0, lblWWidth, lblHeight);
                xAxis += lblWWidth+5*MULTIPLYHEIGHT;
                
                float lblPWidth = 35*MULTIPLYHEIGHT;
                
                lblPrice.frame = CGRectMake(xAxis, 0, lblPWidth, lblHeight);
                
                xAxis += lblPWidth;
                
                float tfWidth = 40*MULTIPLYHEIGHT;
                
                tf.hidden = NO;
                tf.frame = CGRectMake(screen_width-tfWidth-10*MULTIPLYHEIGHT, 5*MULTIPLYHEIGHT, tfWidth, lblHeight-(5*MULTIPLYHEIGHT*2));
                
                for (CALayer *layer in [tf.layer sublayers])
                {
                    if ([layer.name isEqualToString:@"tf"])
                    {
                        layer.frame = CGRectMake(0, tf.frame.size.height-1, tf.frame.size.width, 1);
                    }
                }
                
                lblCount.hidden = NO;
                btnPlus.hidden = NO;
                btnMinus.hidden = NO;
                
                float btnWidth = 40*MULTIPLYHEIGHT;
                
                btnMinus.frame = CGRectMake(xAxis, 0, btnWidth, lblHeight);
                
                xAxis += btnWidth;
                
                btnPlus.frame = CGRectMake(xAxis, 0, btnWidth, lblHeight);
                
                lblCount.frame = CGRectMake(btnMinus.frame.origin.x, 0, btnWidth*2, lblHeight);
            }
        }
        else if ([[dict objectForKey:@"uomid"] intValue] == 2 || [[dict objectForKey:@"uomid"] intValue] == 3)
        {
            float lblWWidth = 110*MULTIPLYHEIGHT;
            
            lblWash.frame = CGRectMake(xAxis, 0, lblWWidth, lblHeight);
            xAxis += lblWWidth+10*MULTIPLYHEIGHT;
            
            
            float lblPWidth = 43*MULTIPLYHEIGHT;
            
            lblPrice.frame = CGRectMake(xAxis, 0, lblPWidth, lblHeight);
            xAxis += lblPWidth+20*MULTIPLYHEIGHT;
            
            float tfWidth = 40*MULTIPLYHEIGHT;
            
            tf.hidden = NO;
            tf.frame = CGRectMake(screen_width-tfWidth-10*MULTIPLYHEIGHT, 5*MULTIPLYHEIGHT, tfWidth, lblHeight-(5*MULTIPLYHEIGHT*2));
            
            for (CALayer *layer in [tf.layer sublayers])
            {
                if ([layer.name isEqualToString:@"tf"])
                {
                    layer.frame = CGRectMake(0, tf.frame.size.height-1, tf.frame.size.width, 1);
                }
            }
        }
        else
        {
            float lblWWidth = 110*MULTIPLYHEIGHT;
            
            lblWash.frame = CGRectMake(xAxis, 0, lblWWidth, lblHeight);
            xAxis += lblWWidth+10*MULTIPLYHEIGHT;
            
            
            float lblPWidth = 43*MULTIPLYHEIGHT;
            
            lblPrice.frame = CGRectMake(xAxis, 0, lblPWidth, lblHeight);
            xAxis += lblPWidth+20*MULTIPLYHEIGHT;
            
            lblCount.hidden = NO;
            btnPlus.hidden = NO;
            btnMinus.hidden = NO;
            
            float btnWidth = 40*MULTIPLYHEIGHT;
            
            btnMinus.frame = CGRectMake(xAxis, 0, btnWidth, lblHeight);
            xAxis += btnWidth;
            
            btnPlus.frame = CGRectMake(xAxis, 0, btnWidth, lblHeight);
            
            lblCount.frame = CGRectMake(btnMinus.frame.origin.x, 0, btnWidth*2, lblHeight);
        }
    }
    
    if ([strJobType containsString:@"CC"])
    {
        if ([dictCountWeight objectForKey:@"count"])
        {
            lblCount.text = [dictCountWeight objectForKey:@"count"];
        }
        else
        {
            lblCount.text = @"0";
        }
        
        if ([dictCountWeight objectForKey:@"weight"])
        {
            tf.text = [dictCountWeight objectForKey:@"weight"];
        }
        else
        {
            tf.text = @"";
        }
    }
    
    else if ([dictCountWeight objectForKey:@"count"])
    {
        if ([[dict objectForKey:@"uomid"] intValue] == 2 || [[dict objectForKey:@"uomid"] intValue] == 3)
        {
            tf.text = [dictCountWeight objectForKey:@"count"];
        }
        else
        {
            lblCount.text = [dictCountWeight objectForKey:@"count"];
        }
    }
    else if ([dictCountWeight objectForKey:@"weight"])
    {
        
    }
    else
    {
        tf.text = @"";
        
        lblCount.text = @"0";
    }
    
    lblPrice.text = [NSString stringWithFormat:@"$%.2f", [[dict objectForKey:@"ip"] floatValue]];
    
    return cell;
}


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
    
    if (strCategoryName == nil)
    {
        strCategoryName = @"";
    }
    
    if ([strCategoryName caseInsensitiveCompare:@"HouseHold"] == NSOrderedSame || [strCategoryName caseInsensitiveCompare:@"HouseHold Items"] == NSOrderedSame)
    {
        for (int i = 0; i < [dictViewBill count]; i++)
        {
            NSMutableArray *arrayItemDetails = [[dictViewBill allValues]objectAtIndex:i];
            
            for (int j = 0; j < [arrayItemDetails count]; j++)
            {
                NSDictionary *dictItems = [arrayItemDetails objectAtIndex:j];
                
                if (![[dictItems objectForKey:@"categoryName"] isEqualToString:strCategoryName])
                {
                    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"" message:@"Piingo can't add Household items into this bag. Please add Household items into separate bag." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *addBag = [UIAlertAction actionWithTitle:@"Add Bag" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [self checkEnteredGarments];
                        
                        if ([parentDel respondsToSelector:@selector(addItemDetails:)])
                        {
                            [parentDel addItemDetails:dictViewBill];
                        }
                        
                        isAlreadyAddedItems = YES;
                        
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
                
                if ([dictItems objectForKey:@"categoryName"] && ([[dictItems objectForKey:@"categoryName"] caseInsensitiveCompare:@"HouseHold"] == NSOrderedSame || [[dictItems objectForKey:@"categoryName"] caseInsensitiveCompare:@"HouseHold Items"] == NSOrderedSame) && [[dictItems objectForKey:@"jd"] isEqualToString:strJobType])
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

-(void) addTfdata:(UITextField *)tf value:(NSString *) str
{
    CGPoint position = [tf convertPoint:CGPointZero toView:tblCategory];
    NSIndexPath *indexPath = [tblCategory indexPathForRowAtPoint:position];
    
    NSDictionary *dictRow;
    
    if ([strJobType isEqualToString:@"WF"] || [strJobType isEqualToString:@"CA"])
    {
        dictRow = (NSDictionary *) [arrayCategory objectAtIndex:indexPath.row];
    }
    else
    {
        dictRow = (NSDictionary *) [arrayRow objectAtIndex:indexPath.row];
    }
    
    NSString *strTag = [NSString stringWithFormat:@"%@-%ld-%ld-%@", strJobType, selectedCategoryIndex, (long)indexPath.row, strOrderType];
    
    NSMutableDictionary *dictCountWeight;
    
    if ([dictItemCount objectForKey:strTag])
    {
        dictCountWeight = [dictItemCount objectForKey:strTag];
    }
    else
    {
        dictCountWeight = [[NSMutableDictionary alloc]init];
    }
    
    [dictCountWeight setObject:str forKey:@"weight"];
    
    [dictItemCount setObject:dictCountWeight forKey:strTag];
    
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
                
                [dictItemDetails setObject:str forKey:@"weight"];
                
                if ([str isEqualToString:@""] || [str floatValue] == 0.0)
                {
                    if ([dictItemDetails objectForKey:@"quantity"])
                    {
                        
                    }
                    else
                    {
                        [arrayItemDetails removeObject:dictItemDetails];
                    }
                    
                    [dictItemDetails removeObjectForKey:@"weight"];
                    
                    [dictCountWeight removeObjectForKey:@"weight"];
                    
                    //[dictItemCount removeObjectForKey:strTag];
                    
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
        if ([str isEqualToString:@""] || [str floatValue] == 0.0)
        {
            [dictCountWeight removeObjectForKey:@"weight"];
            
            return;
        }
        
        NSMutableArray *arrayItemDetails = [dictViewBill objectForKey:strJobName];
        
        if (!arrayItemDetails)
        {
            arrayItemDetails = [[NSMutableArray alloc]init];
        }
        
        NSMutableDictionary *dictItemDetails = [[NSMutableDictionary alloc]init];
        [dictItemDetails setObject:@"0123456789" forKey:@"orno"];
        [dictItemDetails setObject:strJobName forKey:@"jn"];
        
        [dictItemDetails setObject:str forKey:@"weight"];
        
        [dictItemDetails setObject:[dictRow objectForKey:@"ip"] forKey:@"ip"];
        [dictItemDetails setObject:[dictRow objectForKey:@"ic"] forKey:@"ic"];
        
        [dictItemDetails setObject:[dictRow objectForKey:@"uomid"] forKey:@"UOMId"];
        
        [dictItemDetails setObject:strJobType forKey:@"jd"];
        [dictItemDetails setObject:[dictRow objectForKey:@"n"] forKey:@"n"];
        [dictItemDetails setObject:strTag forKey:strTag];
        
        [arrayItemDetails addObject:dictItemDetails];
        
        [dictViewBill setObject:arrayItemDetails forKey:strJobName];
    }
}

-(void) didAdditems:(CGFloat)value
{
    tfGlobal.text = [NSString stringWithFormat:@"%.2f", value];
    
    if (value == 0.0)
    {
        tfGlobal.text = @"";
    }
    
    [self addTfdata:tfGlobal value:tfGlobal.text];
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    CGPoint position = [textField convertPoint:CGPointZero toView:tblCategory];
    NSIndexPath *indexPath = [tblCategory indexPathForRowAtPoint:position];
    
    NSDictionary *dictRow;
    
    if ([strJobType isEqualToString:SERVICETYPE_BAG] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH] || [strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
    {
        return YES;
    }
    else if ([strJobType isEqualToString:@"WF"] || [strJobType isEqualToString:@"CA"])
    {
        dictRow = (NSDictionary *) [arrayCategory objectAtIndex:indexPath.row];
    }
    else
    {
        dictRow = (NSDictionary *) [arrayRow objectAtIndex:indexPath.row];
    }
    
    if ([strJobType containsString:@"CC"])
    {
        CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tblCategory];
        CGPoint contentOffset = tblCategory.contentOffset;
        
        contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
        
        NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
        
        [tblCategory setContentOffset:contentOffset animated:YES];
        
        return YES;
    }
    else if ([[dictRow objectForKey:@"uomid"] isEqualToString:@"3"])
    {
        tfGlobal = textField;
        
        CalculateViewController *objCal = [[CalculateViewController alloc]init];
        objCal.delegate = self;
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:objCal];
        
        [self presentViewController:nav animated:YES completion:nil];
        
        return NO;
    }
    else
    {
        CGPoint pointInTable = [textField.superview convertPoint:textField.frame.origin toView:tblCategory];
        CGPoint contentOffset = tblCategory.contentOffset;
        
        contentOffset.y = (pointInTable.y - textField.inputAccessoryView.frame.size.height);
        
        NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
        
        [tblCategory setContentOffset:contentOffset animated:YES];
        
        return YES;
    }
}


-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if ([strJobType isEqualToString:SERVICETYPE_BAG] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH] || [strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
    {
        return YES;
    }
    
    else if ([textField.superview.superview isKindOfClass:[UITableViewCell class]])
    {
        UITableViewCell *cell = (UITableViewCell*)textField.superview.superview;
        NSIndexPath *indexPath = [tblCategory indexPathForCell:cell];
        
        [tblCategory scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:TRUE];
    }
    
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs;
    
    if ([strJobType isEqualToString:SERVICETYPE_BAG] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH] || [strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
    {
        cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS_NO_DOT] invertedSet];
    }
    else
    {
        cs = [[NSCharacterSet characterSetWithCharactersInString:ACCEPTABLE_CHARECTERS] invertedSet];
    }
    
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if ([string isEqualToString:filtered])
    {
        NSString *str1 = [textField.text stringByReplacingCharactersInRange:range withString:string];
        
        if ([str1 isEqualToString:@"0"])
        {
            return NO;
        }
        
        if ([strJobType isEqualToString:SERVICETYPE_BAG] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH] || [strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
        {
            
        }
        else
        {
            [self addTfdata:textField value:str1];
        }
        
        [textField becomeFirstResponder];
        
        return YES;
    }
    else
    {
        return NO;
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


#pragma mark - MCSwipeTableViewCellDelegate


// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    // NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    // NSLog(@"Did end swiping the cell!");
}

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage {
    // NSLog(@"Did swipe with percentage : %f", percentage);
}

- (UIView *)viewWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    return imageView;
}


@end
