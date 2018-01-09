//
//  ReconcileViewController.m
//  PiingApp
//
//  Created by SHASHANK on 08/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "ReconcileViewController.h"

@interface ReconcileViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *reconcileTebleView;
    NSMutableArray *reconcileOrders;
    
    UILabel *totalAmount;
}
@end

@implementation ReconcileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Reconcile Cash";
    
    [self setupMenuBarButtonItems];
    
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg"];
    [self.view addSubview: animatedImageView];
    
    UIView *bgImg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    bgImg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    [self.view addSubview:bgImg];
    
//    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0, screen_width , 10+30+10)];
//    bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
//    [self.view addSubview:bgView];

    reconcileOrders = [[NSMutableArray alloc] init];
    
   reconcileTebleView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64.0, screen_width, screen_height-64-60) style:UITableViewStylePlain];
    reconcileTebleView.backgroundColor = [UIColor clearColor];
    reconcileTebleView.backgroundView = nil;
    reconcileTebleView.delegate = self;
    reconcileTebleView.dataSource = self;
    reconcileTebleView.allowsSelection = NO;
    reconcileTebleView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:reconcileTebleView];
    
    UIImageView *totalAmountView = [[UIImageView alloc] initWithFrame:CGRectMake(0, screen_height-60, screen_width, 60.0)];
    totalAmountView.backgroundColor = [UIColor colorWithRed:23.0/255.0 green:46.0/255.0 blue:56.0/255.0 alpha:1.0];
    
    UILabel *reconcileTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 15, screen_width - 150-15, 30.0)];
    reconcileTitleLbl.text = @"Reconcile Amount";
    reconcileTitleLbl.font = [UIFont fontWithName:APPFONT_LIGHT size:18.0];
    reconcileTitleLbl.backgroundColor = [UIColor clearColor];
    reconcileTitleLbl.textColor = [UIColor whiteColor];
    [totalAmountView addSubview:reconcileTitleLbl];
    
    totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(screen_width - 140.0, 15, 120, 30.0)];
    totalAmount.text = @"$0.0";
    totalAmount.textAlignment = NSTextAlignmentRight;
    totalAmount.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:20.0];
    totalAmount.backgroundColor = [UIColor clearColor];
    totalAmount.textColor = [UIColor colorWithRed:182.0/255.0 green:143.0/255.0 blue:7.0/255.0 alpha:1.0];
    [totalAmountView addSubview:totalAmount];
    
    [self.view addSubview:totalAmountView];
    
}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSDateFormatter *df1 = [[NSDateFormatter alloc] init];
    [df1 setDateFormat:@"YYYY-MM-d"];
    
    //NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[df1 stringFromDate:[NSDate date]],@"date",[[NSUserDefaults standardUserDefaults] objectForKey:PID],@"pid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"2016-07-15",@"date",[[NSUserDefaults standardUserDefaults] objectForKey:PID],@"pid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@getreconciliationcashdetails/services.do?", BASE_URL];
    
    for (NSString *key in [registrationDetailsDic allKeys])
    {
        NSString *value = [registrationDetailsDic objectForKey:key];
        
        urlStr = [urlStr stringByAppendingFormat:@"&%@=%@",key,value];
    }
    
    [[WebserviceMethods sharedWebRequest] getRequestWithParam:urlStr andWithDelegate:self andCallbackMethod:NSStringFromSelector(@selector(receivedResponse:))];
}
-(void) receivedResponse:(id) response
{
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
    
    {
        if ([[[response objectForKey:@"s"] lowercaseString] isEqualToString:@"y"])
        {
            if ([[response objectForKey:@"d"] count] > 0)
            {
                if (![[[response objectForKey:@"d"] objectAtIndex:0] isKindOfClass:[NSDictionary class]])
                    return;
                
                reconcileOrders = [NSMutableArray arrayWithArray:[response objectForKey:@"d"]];
                [reconcileTebleView reloadData];
            }
            else
            {
                [appDel showAlertWithMessage:@"No orders found" andTitle:@"" andBtnTitle:@"OK"];
            }
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:response];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    //    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"listButton"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"menu-icon.png"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(rightSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    [appDel.sideMenuViewController presentLeftMenuViewController];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    [appDel.sideMenuViewController presentRightMenuViewController];
}


#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return 3;
    
    return [reconcileOrders count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"OrderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:15.0];
        cell.textLabel.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.textColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
        cell.detailTextLabel.font  = [UIFont fontWithName:APPFONT_BOLD size:16.0];
        
    }
    
    cell.textLabel.text = [[reconcileOrders objectAtIndex:indexPath.row] objectForKey:@"orderno"];
    cell.detailTextLabel.text = [[reconcileOrders objectAtIndex:indexPath.row] objectForKey:@"amt"];

    return cell;
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
