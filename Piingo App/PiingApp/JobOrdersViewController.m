//
//  JobOrdersViewController.m
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "JobOrdersViewController.h"
#import "JobdetailViewController.h"
#import "OrderTableViewCell.h"

#import "JobOrderTableViewCell.h"
#import "CustomSegmentControl.h"
#import <AVFoundation/AVFoundation.h>
#import "MapOrdersViewController.h"


@interface JobOrdersViewController () <UITableViewDataSource, UITableViewDelegate>
{
    UITableView *orderTableView;
    
    UISegmentedControl *segmentControl;
    AppDelegate *appDel;
    
    UIRefreshControl *refreshControl;
    
    BOOL isRefreshing;
    
    AVAudioPlayer *myAudioPlayer;
    
    NSMutableDictionary *dictBill;
    
    UIView *viewBG;
    
    NSDictionary *dictData;
    
    BOOL alreadyStartedOrder;
    
    NSString *strOrderId;
    
    NSMutableArray *arrTimeslots;
    
    UIView *mainView_Reasons;
    
    UITableView *tblResons;
    
    NSMutableArray *arrSelectedTimeslots;
}


@property (nonatomic, strong) NSMutableArray *displayOrders;

@end


@implementation JobOrdersViewController

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
}

-(void) somethod
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    NSLog(@"Activating audio session");
    if (![audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error]) {
        NSLog(@"Unable to set audio session category: %@", error);
    }
    BOOL result = [audioSession setActive:YES error:&error];
    if (!result) {
        NSLog(@"Error activating audio session: %@", error);
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    
    //start a background sound
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"notification_sound" ofType: @"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    
    if (!myAudioPlayer)
    {
        myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    }
    
    myAudioPlayer.numberOfLoops = -1; //infinite loop
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer play];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"saomr thing you got..."
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [myAudioPlayer stop];
                             
                             AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                             NSError *error = nil;
                             NSLog(@"Deactivating audio session");
                             BOOL result = [audioSession setActive:NO error:&error];
                             if (!result) {
                                 NSLog(@"Error deactivating audio session: %@", error);
                             }
                             
                         }];
    
    [alert addAction:ok];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:alert animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dictBill = [[NSMutableDictionary alloc]init];
    
//    NSString *str = @"{\"bag\":{\"BagNo\":\"DE\",\"RFId\":\"\",\"totalClothes\":\"10\",\"weight\":\"0\",\"itemDetails\":[{\"iType\":\"TT\",\"qty\":\"1\"},{\"iType\":\"TS\",\"qty\":\"1\"}]},\"pid\":\"3\",\"t\":\"dd2tnhxlfs\",\"oid\":\"21100\",\"serviceTypesId\":\"DC\"}";
//    
//    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    id jsonItem = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//    
    
    self.title = @"Orders";
    [self setupMenuBarButtonItems];
    
    self.displayOrders = [[NSMutableArray alloc]init];
    arrTimeslots = [[NSMutableArray alloc]init];
    arrSelectedTimeslots = [[NSMutableArray alloc]init];
    
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg_dark"];
    [self.view addSubview:animatedImageView];
    
    
    CGFloat yAxis = 0;
    
    CGFloat sgX = 25 * MULTIPLYHEIGHT;
    CGFloat sgY = 60 * MULTIPLYHEIGHT;
    CGFloat sgH = 23 * MULTIPLYHEIGHT;
    
    segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"Orders",@"Completed orders"]];
    segmentControl.frame = CGRectMake(sgX, sgY, screen_width-(sgX * 2), sgH);
    [self.view addSubview:segmentControl];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [segmentControl addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    segmentControl.tintColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
    segmentControl.selectedSegmentIndex = 0;
    
    yAxis += sgY+sgH+10*MULTIPLYHEIGHT;
    
    orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yAxis, screen_width, screen_height-yAxis) style:UITableViewStylePlain];
    orderTableView.delegate = self;
    orderTableView.dataSource = self;
    orderTableView.backgroundColor = [UIColor clearColor];
    orderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:orderTableView];
    
    refreshControl = [[UIRefreshControl alloc]init];
    [orderTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [refreshControl endRefreshing];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [self segmentChange:segmentControl];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


-(void) refreshTable
{
    refreshControl.hidden = NO;
    
    orderTableView.userInteractionEnabled = NO;
    isRefreshing = YES;
    
    [self segmentChange:segmentControl];
}

-(void) getCurrentOrders
{
    segmentControl.selectedSegmentIndex = 0;
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"New", @"status", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSLog(@"current token : %@", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN]);
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/all", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        orderTableView.userInteractionEnabled = YES;
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            [self.displayOrders removeAllObjects];
            [arrTimeslots removeAllObjects];
            
            if ([[responseObj objectForKey:@"em"] count])
            {
                NSArray *arrayData = [responseObj objectForKey:@"em"];
                
                for (int i = 0; i < [arrayData count]; i++)
                {
                    NSDictionary *dict = [arrayData objectAtIndex:i];
                    
                    if ([[dict objectForKey:@"ol"] count])
                    {
                        [self.displayOrders addObject:dict];
                        
                        [arrTimeslots addObject:[dict objectForKey:@"slot"]];
                    }
                }
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No current orders found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
            
            [orderTableView reloadData];
            
            refreshControl.hidden = YES;
            
            if (isRefreshing)
            {
                isRefreshing = NO;
                [refreshControl endRefreshing];
            }
            
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
}

-(void) getPastOrders
{
    segmentControl.selectedSegmentIndex = 1;
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Complete", @"status", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/all", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        orderTableView.userInteractionEnabled = YES;
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            [self.displayOrders removeAllObjects];
            
            if ([[responseObj objectForKey:@"em"] count])
            {
                NSArray *arrayData = [responseObj objectForKey:@"em"];
                
                for (int i = 0; i < [arrayData count]; i++)
                {
                    NSDictionary *dict = [arrayData objectAtIndex:i];
                    
                    if ([[dict objectForKey:@"ol"] count])
                    {
                        [self.displayOrders addObject:dict];
                    }
                }
            }
            
            [orderTableView reloadData];
            
            refreshControl.hidden = YES;
            
            if (isRefreshing)
            {
                isRefreshing = NO;
                [refreshControl endRefreshing];
            }
            
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
}


#pragma mark - UIBarButtonItems
-(void) segmentChange:(UISegmentedControl *) segmentController
{
    alreadyStartedOrder = NO;
    strOrderId = @"";
    
    if (segmentController.selectedSegmentIndex == 0)
    {
        [self getCurrentOrders];
    }
    else
    {
        [self getPastOrders];
    }
}


- (void)setupMenuBarButtonItems {
    
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"listButton"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
//    return [[UIBarButtonItem alloc]
//            initWithImage:[UIImage imageNamed:@"listButton"] style:UIBarButtonItemStylePlain
//            target:self
//            action:@selector(mapOrdersClicked)];
    
    return [[UIBarButtonItem alloc]
            initWithTitle:@"Map" style:UIBarButtonItemStylePlain
            target:self
            action:@selector(mapOrdersClicked)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    
    [appDel.sideMenuViewController presentLeftMenuViewController];
    
   // [self setupMenuBarButtonItems];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    
    [appDel.sideMenuViewController presentRightMenuViewController];

   // [self setupMenuBarButtonItems];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblResons)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryNone)
        {
            [arrSelectedTimeslots addObject:[arrTimeslots objectAtIndex:indexPath.row]];
        }
        else
        {
            [arrSelectedTimeslots removeObject:[arrTimeslots objectAtIndex:indexPath.row]];
        }
        
        [tableView reloadData];
    }
    else
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        appDel.isBookNowPending = NO;
        
        if (Static_screens_Build)
        {
            JobdetailViewController *jobDetailVC = [[JobdetailViewController alloc] initWithNibName:@"JobdetailViewController" bundle:nil];
            [self.navigationController pushViewController:jobDetailVC animated:YES];
        }
        else
        {
            NSDictionary *dictMain = [self.displayOrders objectAtIndex:indexPath.section];
            
            NSDictionary *dictOrder = [[dictMain objectForKey:@"ol"] objectAtIndex:indexPath.row];
            
            NSDate *currentTime = [NSDate date];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd-MM-yyyy hh a"];
            
            NSString *strDate = @"";
            
            if ([[dictOrder objectForKey:@"direction"] isEqualToString:@"Pickup"])
            {
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"dd-MM-yyyy"];
                NSDate *date = [df dateFromString:[dictOrder objectForKey:@"pickUpDate"]];
                
                strDate = [df stringFromDate:date];
                strDate = [strDate stringByAppendingString:[NSString stringWithFormat:@" %@", [[[dictOrder objectForKey:@"pickUpSlotId"] componentsSeparatedByString:@"-"] objectAtIndex:0]]];
            }
            else
            {
                NSDateFormatter *df = [[NSDateFormatter alloc]init];
                [df setDateFormat:@"dd-MM-yyyy"];
                NSDate *date = [df dateFromString:[dictOrder objectForKey:@"deliveryDate"]];
                
                strDate = [df stringFromDate:date];
                strDate = [strDate stringByAppendingString:[NSString stringWithFormat:@" %@", [[[dictOrder objectForKey:@"deliverySlotId"] componentsSeparatedByString:@"-"] objectAtIndex:0]]];
            }
            
            NSDate *date = [dateFormatter dateFromString:strDate];
            
            NSTimeInterval timeint = [date timeIntervalSinceDate:currentTime];
            
            CGFloat minutes = timeint/60;
            
            //if (segmentControl.selectedSegmentIndex == 0)
            if (indexPath.section == 0 && segmentControl.selectedSegmentIndex == 0)
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] isEqualToString:@"0"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please checkin first before you start for any order in menu" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    return;
                }
                
                if (alreadyStartedOrder && [[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"P"] == NSOrderedSame)
                {
                    [appDel showAlertWithMessage:@"Please complete the order that you started." andTitle:@"" andBtnTitle:@"OK"];
                    
                    //return;
                }
                
                else if ([[dictOrder objectForKey:@"direction"] caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
                {
                    if ([[dictOrder objectForKey:@"recivedBags"] intValue] == 0)
                    {
                        [appDel showAlertWithMessage:@"Please receive atleast one bag to deliver this order" andTitle:@"" andBtnTitle:@"OK"];
                        
                        return;
                    }
                }
                
                appDel.totalBags = [[dictOrder objectForKey:@"Bags"] count];
                
                NSDictionary *dictDetail = [NSDictionary dictionaryWithObjectsAndKeys:[dictOrder objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/byid", BASE_URL];
                
                [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                
                [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dictDetail andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                    
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                    {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            JobdetailViewController *jobDetailVC = [[JobdetailViewController alloc] initWithNibName:@"JobdetailViewController" bundle:nil andIscurrentOrder:indexPath.section];
                            jobDetailVC.orderDetailDic = [[NSMutableDictionary alloc]initWithDictionary:[[responseObj objectForKey:@"em"]objectAtIndex:0]];
                            jobDetailVC.dictUpdatable = [[NSMutableDictionary alloc]initWithDictionary:[responseObj objectForKey:@"allowdUpdate"]];
                            jobDetailVC.strTaskId = [dictOrder objectForKey:@"taskId"];
                            jobDetailVC.strTaskStatus = [dictOrder objectForKey:@"taskStatus"];
                            jobDetailVC.strUserName = [dictOrder objectForKey:@"userName"];
                            jobDetailVC.strPaymentId = [dictOrder objectForKey:ORDER_CARD_ID];
                            jobDetailVC.strDirection = [dictOrder objectForKey:@"direction"];
                            jobDetailVC.userInteractionEnabled = YES;
                            
                            if (alreadyStartedOrder && [[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"P"] == NSOrderedSame)
                            {
                                jobDetailVC.userInteractionEnabled = NO;
                            }
                            
                            [self.navigationController pushViewController:jobDetailVC animated:YES];
                            
                        }];
                        
                    }
                    else {
                        
                        [appDel displayErrorMessagErrorResponse:responseObj];
                    }
                    
                }];
            }
            else if (minutes < 30)
            {
                
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] isEqualToString:@"0"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please checkin first before you start for any order in menu" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    return;
                }
                
                if (alreadyStartedOrder && [[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"P"] == NSOrderedSame)
                {
                    [appDel showAlertWithMessage:@"Please complete the order that you started." andTitle:@"" andBtnTitle:@"OK"];
                    
                    //return;
                }
                
                NSDictionary *dictDetail = [NSDictionary dictionaryWithObjectsAndKeys:[dictOrder objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/byid", BASE_URL];
                
                [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                
                [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dictDetail andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                    
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                    {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            JobdetailViewController *jobDetailVC = [[JobdetailViewController alloc] initWithNibName:@"JobdetailViewController" bundle:nil andIscurrentOrder:indexPath.section];
                            jobDetailVC.orderDetailDic = [[NSMutableDictionary alloc]initWithDictionary:[[responseObj objectForKey:@"em"]objectAtIndex:0]];
                            jobDetailVC.dictUpdatable = [[NSMutableDictionary alloc]initWithDictionary:[responseObj objectForKey:@"allowdUpdate"]];
                            jobDetailVC.strTaskId = [dictOrder objectForKey:@"taskId"];
                            jobDetailVC.strTaskStatus = [dictOrder objectForKey:@"taskStatus"];
                            jobDetailVC.strUserName = [dictOrder objectForKey:@"userName"];
                            jobDetailVC.strPaymentId = [dictOrder objectForKey:ORDER_CARD_ID];
                            jobDetailVC.strDirection = [dictOrder objectForKey:@"direction"];
                            jobDetailVC.userInteractionEnabled = YES;
                            
                            if (alreadyStartedOrder && [[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"P"] == NSOrderedSame)
                            {
                                jobDetailVC.userInteractionEnabled = NO;
                            }
                            
                            [self.navigationController pushViewController:jobDetailVC animated:YES];
                            
                        }];
                        
                    }
                    else {
                        
                        [appDel displayErrorMessagErrorResponse:responseObj];
                    }
                    
                }];
            }
            else if (segmentControl.selectedSegmentIndex == 1)
            {
                
                NSDictionary *dictDetail = [NSDictionary dictionaryWithObjectsAndKeys:[dictOrder objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/byid", BASE_URL];
                
                [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                
                [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dictDetail andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                    
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                    {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            JobdetailViewController *jobDetailVC = [[JobdetailViewController alloc] initWithNibName:@"JobdetailViewController" bundle:nil andIscurrentOrder:indexPath.section];
                            jobDetailVC.dictUpdatable = [[NSMutableDictionary alloc]initWithDictionary:[responseObj objectForKey:@"allowdUpdate"]];
                            jobDetailVC.orderDetailDic = [[NSMutableDictionary alloc]initWithDictionary:[[responseObj objectForKey:@"em"]objectAtIndex:0]];
                            jobDetailVC.strTaskId = [dictOrder objectForKey:@"taskId"];
                            jobDetailVC.strTaskStatus = [dictOrder objectForKey:@"taskStatus"];
                            jobDetailVC.strUserName = [dictOrder objectForKey:@"userName"];
                            jobDetailVC.strPaymentId = [dictOrder objectForKey:ORDER_CARD_ID];
                            jobDetailVC.strDirection = [dictOrder objectForKey:@"direction"];
                            jobDetailVC.userInteractionEnabled = YES;
                            
                            [self.navigationController pushViewController:jobDetailVC animated:YES];
                            
                        }];
                    }
                    else {
                        
                        [appDel displayErrorMessagErrorResponse:responseObj];
                    }
                    
                }];
            }
            else
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] isEqualToString:@"0"])
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please checkin first before you start for any order in menu" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    return;
                }
                else
                {
                    [appDel showAlertWithMessage:@"Please complete the previous timeslot orders." andTitle:@"" andBtnTitle:@"OK"];
                }
                
                NSDictionary *dictDetail = [NSDictionary dictionaryWithObjectsAndKeys:[dictOrder objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/byid", BASE_URL];
                
                [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                
                [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dictDetail andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                    
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                    {
                        
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            JobdetailViewController *jobDetailVC = [[JobdetailViewController alloc] initWithNibName:@"JobdetailViewController" bundle:nil andIscurrentOrder:indexPath.section];
                            jobDetailVC.orderDetailDic = [[NSMutableDictionary alloc]initWithDictionary:[[responseObj objectForKey:@"em"]objectAtIndex:0]];
                            jobDetailVC.dictUpdatable = [[NSMutableDictionary alloc]initWithDictionary:[responseObj objectForKey:@"allowdUpdate"]];
                            jobDetailVC.strTaskId = [dictOrder objectForKey:@"taskId"];
                            jobDetailVC.strTaskStatus = [dictOrder objectForKey:@"taskStatus"];
                            jobDetailVC.strUserName = [dictOrder objectForKey:@"userName"];
                            jobDetailVC.strPaymentId = [dictOrder objectForKey:ORDER_CARD_ID];
                            jobDetailVC.strDirection = [dictOrder objectForKey:@"direction"];
                            
                            jobDetailVC.userInteractionEnabled = NO;
                            
                            [self.navigationController pushViewController:jobDetailVC animated:YES];
                            
                        }];
                        
                    }
                    else {
                        
                        [appDel displayErrorMessagErrorResponse:responseObj];
                    }
                    
                }];
            }
        }
    }
}


-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != tblResons)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [UIView animateWithDuration:0.1f animations:^{
            cell.transform = CGAffineTransformMakeScale(0.9, 0.9);
        }];
    }
}


-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != tblResons)
    {
        UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        
        [UIView animateWithDuration:0.1f animations:^{
            cell.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == tblResons)
    {
        return 30*MULTIPLYHEIGHT;
    }
    else
    {
        return 30*MULTIPLYHEIGHT;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == tblResons)
    {
        return 0;
    }
    else
    {
        UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, 30*MULTIPLYHEIGHT)];
        view1.backgroundColor = [BLUE_COLOR colorWithAlphaComponent:0.6];
        
        NSDictionary *dict = [self.displayOrders objectAtIndex:section];
        
        UILabel *lblHeader = [[UILabel alloc]initWithFrame:CGRectMake(10*MULTIPLYHEIGHT, 0, screen_width, 30*MULTIPLYHEIGHT)];
        lblHeader.text = [NSString stringWithFormat:@"Slot : %@", [dict objectForKey:@"slot"]];
        lblHeader.textColor = [UIColor whiteColor];
        lblHeader.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
        [view1 addSubview:lblHeader];
        
        return view1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblResons)
    {
        return 35*MULTIPLYHEIGHT;
    }
    else
    {
        CGFloat yPos = 7*MULTIPLYHEIGHT;
        
        CGFloat lblDH = 15*MULTIPLYHEIGHT;
        
        yPos += lblDH+5*MULTIPLYHEIGHT;
        
        yPos += lblDH+5*MULTIPLYHEIGHT;
        
        yPos += lblDH+5*MULTIPLYHEIGHT;
        
        NSDictionary *dictMain = [self.displayOrders objectAtIndex:indexPath.section];
        
        NSDictionary *dictOrder = [[dictMain objectForKey:@"ol"] objectAtIndex:indexPath.row];
        
        NSMutableString *strAddr = [[NSMutableString alloc]initWithString:@""];
        
        NSDictionary *dictAddress = [[dictOrder objectForKey:@"currentAddress"] objectAtIndex:0];
        
        if ([[dictAddress objectForKey:@"line1"] length] > 1)
        {
            [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dictAddress objectForKey:@"line1"]]];
        }
        
        NSString *strFno;
        
        if ([[dictAddress objectForKey:@"floorNo"] isKindOfClass:[NSString class]])
        {
            strFno = [dictAddress objectForKey:@"floorNo"];
        }
        else
        {
            strFno = [NSString stringWithFormat:@"%d", [[dictAddress objectForKey:@"floorNo"] intValue]];
        }
        
        if ([strFno length])
        {
            if ([strFno length] == 1)
            {
                [strAddr appendString:[NSString stringWithFormat:@"#0%@", strFno]];
            }
            else
            {
                [strAddr appendString:[NSString stringWithFormat:@"#%@", [dictAddress objectForKey:@"floorNo"]]];
            }
        }
        
        NSString *strUno;
        
        if ([[dictAddress objectForKey:@"unitNo"] isKindOfClass:[NSString class]])
        {
            strUno = [dictAddress objectForKey:@"unitNo"];
        }
        else
        {
            strUno = [NSString stringWithFormat:@"%d", [[dictAddress objectForKey:@"unitNo"] intValue]];
        }
        
        if ([strUno length])
        {
            [strAddr appendString:[NSString stringWithFormat:@"-%@, ", strUno]];
        }
        
        if ([[dictAddress objectForKey:@"line2"] length])
        {
            [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dictAddress objectForKey:@"line2"]]];
        }
        if ([[dictAddress objectForKey:@"zipcode"] length])
        {
            [strAddr appendString:[NSString stringWithFormat:@"%@", [dictAddress objectForKey:@"zipcode"]]];
        }
        
        CGFloat xpos = 7*MULTIPLYHEIGHT;
        
        CGFloat addrW = screen_width-(xpos*2)-xpos-10*MULTIPLYHEIGHT;
        
        CGFloat height = [AppDelegate getLabelHeightForRegularText:strAddr WithWidth:addrW FontSize:appDel.FONT_SIZE_CUSTOM];
        
        yPos += height+5*MULTIPLYHEIGHT;
        
        if ([[dictOrder objectForKey:@"serviceTypes"] containsObject:SERVICETYPE_CC_W_DC] || [[dictOrder objectForKey:@"serviceTypes"] containsObject:SERVICETYPE_CC_DC])
        {
            yPos += lblDH+5*MULTIPLYHEIGHT;
        }
        
        if (segmentControl.selectedSegmentIndex == 0)
        {
            if ([[dictOrder objectForKey:@"direction"] caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
            {
                yPos += 30*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
            }
        }
        
        yPos += 25*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT;
        
        return yPos;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (Static_screens_Build)
    {
        return 7;
    }
    else
    {
        if (tableView == tblResons)
        {
            return 1;
        }
        else
        {
            return [self.displayOrders count];
        }
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblResons)
    {
        return [arrTimeslots count];
    }
    else
    {
        NSDictionary *dict = [self.displayOrders objectAtIndex:section];
        
        NSArray *array = [dict objectForKey:@"ol"];
        
        return [array count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblResons)
    {
        static NSString *cellIdentifier = @"TimeslotCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.text = [arrTimeslots objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
        
        if ([arrSelectedTimeslots containsObject:[arrTimeslots objectAtIndex:indexPath.row]])
        {
            cell.textLabel.textColor = BLUE_COLOR;
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else
        {
            cell.textLabel.textColor = [UIColor blackColor];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"OrderCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
            
            UIImageView *cellBg = [[UIImageView alloc] init];
            cellBg.tag = 1;
            cellBg.layer.cornerRadius = 2.0;
            cellBg.clipsToBounds = YES;
            
            UIImage *bgImage = [UIImage imageNamed:@"cell_bg"];
            bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
            
            cellBg.image = bgImage;
            cellBg.userInteractionEnabled = YES;
            [cell.contentView addSubview:cellBg];
            
            UIImageView *slotCloctImgV = [[UIImageView alloc] init];
            slotCloctImgV.tag = 12;
            slotCloctImgV.contentMode = UIViewContentModeScaleAspectFit;
            slotCloctImgV.image = [UIImage imageNamed:@"time_icon"];
            [cellBg addSubview:slotCloctImgV];
            
            
            UILabel *lblBookBow = [[UILabel alloc] init];
            lblBookBow.tag = 2;
            lblBookBow.layer.cornerRadius = 8.0;
            lblBookBow.text = @"B";
            lblBookBow.textAlignment = NSTextAlignmentCenter;
            lblBookBow.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2];
            lblBookBow.layer.borderWidth = 0.0;
            lblBookBow.layer.borderColor = [UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0].CGColor;
            lblBookBow.textColor = [UIColor blackColor];
            lblBookBow.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
            lblBookBow.clipsToBounds = YES;
            [cellBg addSubview:lblBookBow];
            
            
            UILabel *orderTypeLbl = [[UILabel alloc] init];
            orderTypeLbl.tag = 3;
            orderTypeLbl.layer.cornerRadius = 8.0;
            orderTypeLbl.text = @"P";
            orderTypeLbl.textAlignment = NSTextAlignmentCenter;
            orderTypeLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM];
            orderTypeLbl.layer.borderWidth = 0.0;
            orderTypeLbl.layer.borderColor = [UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0].CGColor;
            orderTypeLbl.textColor = [UIColor blackColor];
            orderTypeLbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
            orderTypeLbl.clipsToBounds = YES;
            [cellBg addSubview:orderTypeLbl];
            
            UILabel *orderReqTypeLbl = [[UILabel alloc] init];
            orderReqTypeLbl.tag = 4;
            orderReqTypeLbl.layer.cornerRadius = 8.0;
            orderReqTypeLbl.text = @"R";
            orderReqTypeLbl.textAlignment = NSTextAlignmentCenter;
            orderReqTypeLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM];
            orderReqTypeLbl.layer.borderWidth = 0.0;
            orderReqTypeLbl.layer.borderColor = [UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0].CGColor;
            orderReqTypeLbl.textColor = [UIColor blackColor];
            orderReqTypeLbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
            orderReqTypeLbl.clipsToBounds = YES;
            [cellBg addSubview:orderReqTypeLbl];
            
            UILabel *lblDate = [[UILabel alloc] init];
            lblDate.tag = 5;
            lblDate.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM];
            lblDate.backgroundColor = [UIColor clearColor];
            lblDate.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
            [cellBg addSubview:lblDate];
            
            UILabel *lblPaymentType = [[UILabel alloc] init];
            lblPaymentType.tag = 6;
            lblPaymentType.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
            lblPaymentType.backgroundColor = [UIColor clearColor];
            lblPaymentType.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
            [cellBg addSubview:lblPaymentType];
            
            UILabel *lblOrderId = [[UILabel alloc] init];
            lblOrderId.tag = 7;
            lblOrderId.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
            lblOrderId.backgroundColor = [UIColor clearColor];
            lblOrderId.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
            [cellBg addSubview:lblOrderId];
            
            UILabel *orderPersonNameLbl = [[UILabel alloc] init];
            orderPersonNameLbl.tag = 8;
            orderPersonNameLbl.text = @"piinguser";
            orderPersonNameLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM];
            orderPersonNameLbl.backgroundColor = [UIColor clearColor];
            orderPersonNameLbl.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
            [cellBg addSubview:orderPersonNameLbl];
            
            UILabel *orderAddressLbl = [[UILabel alloc] init];
            orderAddressLbl.tag = 9;
            orderAddressLbl.numberOfLines = 0;
            orderAddressLbl.text = @"address";
            orderAddressLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM];
            orderAddressLbl.backgroundColor = [UIColor clearColor];
            orderAddressLbl.textColor = [UIColor blackColor];
            [cellBg addSubview:orderAddressLbl];
            
            UILabel*lblCurtain = [[UILabel alloc]init];
            lblCurtain.tag = 17;
            lblCurtain.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
            lblCurtain.backgroundColor = [UIColor clearColor];
            lblCurtain.textColor = [UIColor blackColor];
            [cellBg addSubview:lblCurtain];
            
            UILabel*lblTotalBags = [[UILabel alloc]init];
            lblTotalBags.tag = 15;
            lblTotalBags.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
            lblTotalBags.backgroundColor = [UIColor clearColor];
            lblTotalBags.textColor = [UIColor blackColor];
            [cellBg addSubview:lblTotalBags];
            
            UILabel*lblReceivedBags = [[UILabel alloc]init];
            lblReceivedBags.tag = 16;
            lblReceivedBags.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
            lblReceivedBags.backgroundColor = [UIColor clearColor];
            lblReceivedBags.textColor = [UIColor blackColor];
            [cellBg addSubview:lblReceivedBags];
            
            UIButton *statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            statusBtn.tag = 10;
            [statusBtn setTitle:@"Start" forState:UIControlStateNormal];
            [statusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            statusBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM];
            [cellBg addSubview:statusBtn];
            
            UIButton *btnI = [UIButton buttonWithType:UIButtonTypeInfoDark];
            btnI.tag = 11;
            btnI.frame = CGRectMake(cellBg.frame.size.width-50, cellBg.frame.size.height-34, 35, 35);
            btnI.tintColor = [UIColor blackColor];
            [cellBg addSubview:btnI];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIImageView *cellBg = (UIImageView *) [cell.contentView viewWithTag:1];
        UILabel *lblBookBow = (UILabel *) [cell.contentView viewWithTag:2];
        UILabel *orderTypeLbl = (UILabel *) [cell.contentView viewWithTag:3];
        UILabel *orderReqTypeLbl = (UILabel *) [cell.contentView viewWithTag:4];
        UILabel *lblDate = (UILabel *) [cell.contentView viewWithTag:5];
        UILabel *lblPaymentType = (UILabel *) [cell.contentView viewWithTag:6];
        UILabel *lblOrderId = (UILabel *) [cell.contentView viewWithTag:7];
        UILabel *orderPersonNameLbl = (UILabel *) [cell.contentView viewWithTag:8];
        UILabel *orderAddressLbl = (UILabel *) [cell.contentView viewWithTag:9];
        UIButton *statusBtn = (UIButton *) [cell.contentView viewWithTag:10];
        UIButton *btnI = (UIButton *) [cell.contentView viewWithTag:11];
        UIImageView *slotCloctImgV = (UIImageView *) [cell.contentView viewWithTag:12];
        UILabel *lblTotalBags = (UILabel *) [cell.contentView viewWithTag:15];
        UILabel *lblReceivedBags = (UILabel *) [cell.contentView viewWithTag:16];
        UILabel *lblCurtain = (UILabel *) [cell.contentView viewWithTag:17];
        
        NSDictionary *dictMain = [self.displayOrders objectAtIndex:indexPath.section];
        
        NSDictionary *dictOrder = [[dictMain objectForKey:@"ol"] objectAtIndex:indexPath.row];
        
        CGFloat xpos = 7 * MULTIPLYHEIGHT;
        CGFloat yPos = 7*MULTIPLYHEIGHT;
        CGFloat imgDW = 10*MULTIPLYHEIGHT;
        CGFloat imgDH = 15*MULTIPLYHEIGHT;
        
        cellBg.frame = CGRectMake(xpos, 5*MULTIPLYHEIGHT, screen_width-(xpos*2), 0);
        
        slotCloctImgV.frame = CGRectMake(xpos, yPos, imgDW, imgDH);
        
        CGFloat lblDX = xpos+imgDW+5*MULTIPLYHEIGHT;
        CGFloat lblDW = 135*MULTIPLYHEIGHT;
        CGFloat lblDH = 15*MULTIPLYHEIGHT;
        
        lblDate.frame = CGRectMake(lblDX, yPos, lblDW, lblDH);
        
        CGFloat lblPX = lblDX+lblDW+10*MULTIPLYHEIGHT;
        CGFloat lblPW = 35*MULTIPLYHEIGHT;
        
        lblPaymentType.frame = CGRectMake(lblPX, yPos, lblPW, lblDH);
        
        CGFloat lblBX = lblPX+lblPW+20*MULTIPLYHEIGHT;
        CGFloat lblBW = 15*MULTIPLYHEIGHT;
        
        lblBookBow.frame = CGRectMake(lblBX, yPos, lblBW, lblDH);
        
        yPos += lblDH+5*MULTIPLYHEIGHT;
        
        lblOrderId.frame = CGRectMake(xpos, yPos, 200*MULTIPLYHEIGHT, lblDH);
        
        orderTypeLbl.frame = CGRectMake(lblBX, yPos, lblBW, lblDH);
        
        yPos += lblDH+5*MULTIPLYHEIGHT;
        
        orderPersonNameLbl.frame = CGRectMake(xpos, yPos, 200*MULTIPLYHEIGHT, lblDH);
        
        orderReqTypeLbl.frame = CGRectMake(lblBX, yPos, lblBW, lblDH);
        
        yPos += lblDH+5*MULTIPLYHEIGHT;
        
        NSMutableString *strAddr = [[NSMutableString alloc]initWithString:@""];
        
        NSDictionary *dictAddress = [[dictOrder objectForKey:@"currentAddress"] objectAtIndex:0];
        
        if ([[dictAddress objectForKey:@"line1"] length] > 1)
        {
            [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dictAddress objectForKey:@"line1"]]];
        }
        
        NSString *strFno;
        
        if ([[dictAddress objectForKey:@"floorNo"] isKindOfClass:[NSString class]])
        {
            strFno = [dictAddress objectForKey:@"floorNo"];
        }
        else
        {
            strFno = [NSString stringWithFormat:@"%d", [[dictAddress objectForKey:@"floorNo"] intValue]];
        }
        
        if ([strFno length])
        {
            if ([strFno length] == 1)
            {
                [strAddr appendString:[NSString stringWithFormat:@"#0%@", strFno]];
            }
            else
            {
                [strAddr appendString:[NSString stringWithFormat:@"#%@", [dictAddress objectForKey:@"floorNo"]]];
            }
        }
        
        NSString *strUno;
        
        if ([[dictAddress objectForKey:@"unitNo"] isKindOfClass:[NSString class]])
        {
            strUno = [dictAddress objectForKey:@"unitNo"];
        }
        else
        {
            strUno = [NSString stringWithFormat:@"%d", [[dictAddress objectForKey:@"unitNo"] intValue]];
        }
        
        if ([strUno length])
        {
            [strAddr appendString:[NSString stringWithFormat:@"-%@, ", strUno]];
        }
        
        if ([[dictAddress objectForKey:@"line2"] length])
        {
            [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dictAddress objectForKey:@"line2"]]];
        }
        if ([[dictAddress objectForKey:@"zipcode"] length])
        {
            [strAddr appendString:[NSString stringWithFormat:@"%@", [dictAddress objectForKey:@"zipcode"]]];
        }
        
        CGFloat addrW = cellBg.frame.size.width-xpos-10*MULTIPLYHEIGHT;
        
        CGFloat height = [AppDelegate getLabelHeightForRegularText:strAddr WithWidth:addrW FontSize:orderAddressLbl.font.pointSize];
        
        orderAddressLbl.frame = CGRectMake(xpos, yPos, addrW, height);
        orderAddressLbl.text = strAddr;
        
        yPos += height+5*MULTIPLYHEIGHT;
        
        if ([[dictOrder objectForKey:@"serviceTypes"] containsObject:SERVICETYPE_CC_W_DC])
        {
            lblCurtain.frame = CGRectMake(xpos, yPos, addrW, lblDH);
            yPos += lblDH+5*MULTIPLYHEIGHT;
            
            lblCurtain.text = @"CURTAIN ORDER WITH INSTALLATION";
        }
        else if ([[dictOrder objectForKey:@"serviceTypes"] containsObject:SERVICETYPE_CC_DC])
        {
            lblCurtain.frame = CGRectMake(xpos, yPos, addrW, lblDH);
            yPos += height+5*MULTIPLYHEIGHT;
            
            lblCurtain.text = @"CURTAIN ORDER WITHOUT INSTALLATION";
        }
        else
        {
            lblCurtain.text = @"";
        }
        
        if (segmentControl.selectedSegmentIndex == 0)
        {
            if ([[dictOrder objectForKey:@"direction"] caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
            {
                lblTotalBags.hidden = NO;
                lblReceivedBags.hidden = NO;
                
                lblTotalBags.text = @"Bags received :";
                
                lblTotalBags.frame = CGRectMake(xpos, yPos, 70*MULTIPLYHEIGHT, 24*MULTIPLYHEIGHT);
                
                lblReceivedBags.text = [NSString stringWithFormat:@"%d/%ld", [[dictOrder objectForKey:@"recivedBags"] intValue], [[dictOrder objectForKey:@"Bags"] count]];
                lblReceivedBags.frame = CGRectMake(xpos+70*MULTIPLYHEIGHT, yPos, 24*MULTIPLYHEIGHT, 24*MULTIPLYHEIGHT);
                
                lblReceivedBags.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
                lblReceivedBags.layer.cornerRadius = lblReceivedBags.frame.size.width/2;
                lblReceivedBags.clipsToBounds = YES;
                lblReceivedBags.textAlignment = NSTextAlignmentCenter;
                lblReceivedBags.backgroundColor = [UIColor whiteColor];
                yPos += 24*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
            }
            else
            {
                lblTotalBags.hidden = YES;
                lblReceivedBags.hidden = YES;
            }
        }
        
        statusBtn.frame = CGRectMake(0, yPos, cellBg.frame.size.width, 25*MULTIPLYHEIGHT);
        
        btnI.frame = CGRectMake(cellBg.frame.size.width-30*MULTIPLYHEIGHT, yPos, 25*MULTIPLYHEIGHT, 25*MULTIPLYHEIGHT);
        
        yPos += 25*MULTIPLYHEIGHT;
        
        CGRect frame = cellBg.frame;
        frame.size.height = yPos;
        cellBg.frame = frame;
        
        orderPersonNameLbl.text = [dictOrder objectForKey:@"userName"];
        
        lblOrderId.text = [NSString stringWithFormat:@"ORDER ID # %@", [dictOrder objectForKey:@"oid"]];
        lblOrderId.textColor = [UIColor blackColor];
        
        if ([[dictOrder objectForKey:@"orderType"] isEqualToString:@"B"])
        {
            lblBookBow.hidden = NO;
        }
        else
        {
            lblBookBow.hidden = YES;
        }
        
        if ([[dictOrder objectForKey:@"orderSpeed"] isEqualToString:@"R"])
        {
            orderReqTypeLbl.text = @"R";
        }
        else
        {
            orderReqTypeLbl.text = @"E";
        }
        
        NSString *strDate;
        
        if ([[dictOrder objectForKey:@"direction"] isEqualToString:@"Pickup"])
        {
            orderTypeLbl.text = @"P";
            
            NSDateFormatter *df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"dd-MM-yyyy"];
            NSDate *date = [df dateFromString:[dictOrder objectForKey:@"pickUpDate"]];
            
            strDate = [df stringFromDate:date];
            strDate = [strDate stringByAppendingString:[NSString stringWithFormat:@", %@", [dictOrder objectForKey:@"pickUpSlotId"]]];
        }
        else
        {
            orderTypeLbl.text = @"D";
            
            NSDateFormatter *df = [[NSDateFormatter alloc]init];
            [df setDateFormat:@"dd-MM-yyyy"];
            NSDate *date = [df dateFromString:[dictOrder objectForKey:@"deliveryDate"]];
            
            strDate = [df stringFromDate:date];
            strDate = [strDate stringByAppendingString:[NSString stringWithFormat:@", %@", [dictOrder objectForKey:@"deliverySlotId"]]];
        }
        
        lblDate.text = strDate;
        
        if ([[dictOrder objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] == NSOrderedSame || [[dictOrder objectForKey:ORDER_CARD_ID] intValue] == 0)
        {
            lblPaymentType.text = @"CASH";
        }
        else
        {
            lblPaymentType.text = @"CARD";
        }
        
        if (segmentControl.selectedSegmentIndex == 0)
        {
            
            if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"P"] != NSOrderedSame && [[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"DE"] != NSOrderedSame)
            {
                strOrderId = [dictOrder objectForKey:@"oid"];
                
                alreadyStartedOrder = YES;
            }
            
            [statusBtn setTitle:[self setStatusMessageWith:dictOrder] forState:UIControlStateNormal];
            
            //btnI.hidden = NO;
        }
        else
        {
            if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"C"] == NSOrderedSame && [[dictOrder objectForKey:@"statusCode"] caseInsensitiveCompare:@"OC"] == NSOrderedSame)
            {
                [statusBtn setTitle:@"Order Canceled" forState:UIControlStateNormal];
            }
            else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"C"] == NSOrderedSame)
            {
                [statusBtn setTitle:@"Order Rescheduled" forState:UIControlStateNormal];
            }
            else
            {
                [statusBtn setTitle:[dictOrder objectForKey:@"statusMsg"] forState:UIControlStateNormal];
            }
            
            //btnI.hidden = YES;
        }
        
        btnI.hidden = YES;
        
        [btnI addTarget:self action:@selector(btnIClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.backgroundColor = [UIColor clearColor];
        
        if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"DE"] == NSOrderedSame)
        {
            statusBtn.backgroundColor = [UIColor orangeColor];
        }
        else
        {
            statusBtn.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
        }
        
        if (segmentControl.selectedSegmentIndex == 0)
        {
            if ([[dictOrder objectForKey:@"direction"] caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
            {
                if ([[dictOrder objectForKey:@"recivedBags"] intValue] == 0)
                {
                    statusBtn.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
                }
            }
        }
        
        return cell;
    }
}

-(NSString *) setStatusMessageWith:(NSDictionary *) dictOrder
{
    NSString *strStatus = @"";
    
    if ([[dictOrder objectForKey:@"direction"] caseInsensitiveCompare:@"Pickup"] == NSOrderedSame)
    {
        if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"P"] == NSOrderedSame || [[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"DE"] == NSOrderedSame)
        {
            strStatus = @"Piingo out for pickup";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"A"] == NSOrderedSame)
        {
            strStatus = @"Piingo started for pickup";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"AD"] == NSOrderedSame)
        {
            strStatus = @"Piingo at the door";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"C"] == NSOrderedSame)
        {
            strStatus = @"Order cancelled";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"U"] == NSOrderedSame)
        {
            strStatus = @"Piingo unable to serve";
        }
    }
    else
    {
        if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"P"] == NSOrderedSame || [[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"DE"] == NSOrderedSame)
        {
            strStatus = @"Piingo out for delivery";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"A"] == NSOrderedSame)
        {
            strStatus = @"Piingo started for delivery";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"AD"] == NSOrderedSame)
        {
            strStatus = @"Piingo at the door";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"C"] == NSOrderedSame)
        {
            strStatus = @"Order cancelled";
        }
        else if ([[dictOrder objectForKey:@"taskStatus"] caseInsensitiveCompare:@"U"] == NSOrderedSame)
        {
            strStatus = @"Piingo unable to serve";
        }
    }
    
    strStatus = [strStatus uppercaseString];
    
    return strStatus;
}

-(void) btnIClicked:(UIButton *) sender
{
    CGPoint btnpoint = [sender convertPoint:CGPointZero toView:orderTableView];
    NSIndexPath *indexPath = [orderTableView indexPathForRowAtPoint:btnpoint];
    
    if (indexPath != nil)
    {
        NSDictionary *dictMain = [self.displayOrders objectAtIndex:indexPath.section];
        
        NSDictionary *dictOrder = [[dictMain objectForKey:@"ol"] objectAtIndex:indexPath.row];
        
        dictData = dictOrder;
        
        if ([[dictOrder objectForKey:@"direction"] caseInsensitiveCompare:@"Pickup"] == NSOrderedSame)
        {
            [self showPopup];
        }
        else
        {
            [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
            
            NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [dictOrder objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/bill", BASE_URL];
            
            [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                
                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                {
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    [dictBill removeAllObjects];
                    
                    if ([[responseObj objectForKey:@"em"] isKindOfClass:[NSArray class]])
                    {
                        [dictBill addEntriesFromDictionary:[[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"totalSum"]];
                    }
                    else
                    {
                        [dictBill setObject:[[responseObj objectForKey:@"em"] objectForKey:@"billAmount"] forKey:@"totalAmount"];
                    }
                    
                    [self showPopup];
                }
                else
                {
                    [appDel displayErrorMessagErrorResponse:responseObj];
                }
            }];
        }
    }
}

-(void) showPopup
{
    
    //    NSDate *currentTime = [NSDate date];
    //
    //    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //    [dateFormatter setDateFormat:@"YYYY-MM-dd hh a"];
    //
    //    NSString *str = [NSString stringWithFormat:@"%@ %@", [dictData objectForKey:@"d"], [[[dictData objectForKey:@"ep"]componentsSeparatedByString:@"-"]objectAtIndex:0]];
    //
    //    NSDate *date = [dateFormatter dateFromString:str];
    //
    //    NSTimeInterval timeint = [date timeIntervalSinceDate:currentTime];
    //
    //    CGFloat minutes = timeint/60;
    
    viewBG = [[UIView alloc]initWithFrame:appDel.window.bounds];
    viewBG.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [appDel.window addSubview:viewBG];
    
    float VX = 20*MULTIPLYHEIGHT;
    
    UIView *viewShow = [[UIView alloc]initWithFrame:CGRectMake(VX, 0, screen_width-(VX*2), 100)];
    viewShow.backgroundColor = [UIColor whiteColor];
    [viewBG addSubview:viewShow];
    
    float yAxis = 10*MULTIPLYHEIGHT;
    
    UILabel *lblOrder = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, viewShow.frame.size.width, 20*MULTIPLYHEIGHT)];
    lblOrder.textColor = [UIColor blackColor];
    lblOrder.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM];
    lblOrder.textAlignment = NSTextAlignmentCenter;
    lblOrder.text = [NSString stringWithFormat:@"ORDER ID # %@", [dictData objectForKey:@"oid"]];
    [viewShow addSubview:lblOrder];
    
    yAxis += 20*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT;
    
    UILabel *lblPT = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, viewShow.frame.size.width, 16*MULTIPLYHEIGHT)];
    lblPT.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
    lblPT.textColor = [UIColor grayColor];
    lblPT.textAlignment = NSTextAlignmentCenter;
    
    if ([[dictData objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] == NSOrderedSame)
    {
        lblPT.text = @"Payment Mode : CASH";
    }
    else
    {
        lblPT.text = @"Payment Mode : CARD";
    }
    
    [viewShow addSubview:lblPT];
    
    yAxis += 16*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
    
    if ([[dictData objectForKey:@"direction"] caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
    {
        UILabel *lblFA = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, viewShow.frame.size.width, 16*MULTIPLYHEIGHT)];
        lblFA.font = lblPT.font;
        lblFA.textColor = lblPT.textColor;
        lblFA.textAlignment = NSTextAlignmentCenter;
        
        if ([dictBill objectForKey:@"totalAmount"])
        {
            lblFA.text = [NSString stringWithFormat:@"Final Amount : $ %@", [dictBill objectForKey:@"totalAmount"]];
        }
        else
        {
            lblFA.text = @"Final Amount : NA";
        }
        
        [viewShow addSubview:lblFA];
        
        yAxis += 16*MULTIPLYHEIGHT+6*MULTIPLYHEIGHT;
    }
    
    
    //    if (minutes <= 30)
    //    {
    //        if ([[dictData objectForKey:@"p"] length])
    //        {
    //            UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    //            UIImage *butImage1 = [UIImage imageNamed:@"phone_icon_seleted_New.png"];
    //            rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //            [rightbutton setImage:butImage1 forState:UIControlStateNormal];
    //            [rightbutton addTarget:self action:@selector(callBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    //            [rightbutton setTitle:[dictData objectForKey:@"p"] forState:UIControlStateNormal];
    //            [rightbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //            rightbutton.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2.5];
    //            rightbutton.backgroundColor = BLUE_COLOR;
    //            [viewShow addSubview:rightbutton];
    //
    //            float btnW = 100*MULTIPLYHEIGHT;
    //            rightbutton.frame = CGRectMake(viewShow.frame.size.width/2-btnW/2, yAxis, btnW, 20*MULTIPLYHEIGHT);
    //
    //            yAxis += 20*MULTIPLYHEIGHT;
    //        }
    //    }
    
    if ([[dictData objectForKey:@"customerPhone"] length])
    {
        UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *butImage1 = [UIImage imageNamed:@"phone_icon_seleted_New.png"];
        rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [rightbutton setImage:butImage1 forState:UIControlStateNormal];
        [rightbutton addTarget:self action:@selector(callBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [rightbutton setTitle:[dictData objectForKey:@"customerPhone"] forState:UIControlStateNormal];
        [rightbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightbutton.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2.5];
        rightbutton.backgroundColor = BLUE_COLOR;
        [viewShow addSubview:rightbutton];
        
        float btnW = 100*MULTIPLYHEIGHT;
        rightbutton.frame = CGRectMake(viewShow.frame.size.width/2-btnW/2, yAxis, btnW, 20*MULTIPLYHEIGHT);
        
        yAxis += 20*MULTIPLYHEIGHT;
    }
    
    
    yAxis += 10*MULTIPLYHEIGHT;
    
    float btnDW = 80*MULTIPLYHEIGHT;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(viewShow.frame.size.width/2-btnDW/2, yAxis, btnDW, 22*MULTIPLYHEIGHT);
    [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2];
    [btnDone setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(btnDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    [viewShow addSubview:btnDone];
    btnDone.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnDone.layer.borderWidth = 1.0;
    
    
    yAxis += 22*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT;
    
    CGRect rect = viewShow.frame;
    rect.origin.y = screen_height/2-yAxis/2;
    rect.size.height = yAxis;
    viewShow.frame = rect;
}

-(void) callBtnClicked
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
    {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[dictData objectForKey:@"customerPhone"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
    } else {
        
        [appDel showAlertWithMessage:@"Your device doesn't support this feature." andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) btnDoneClicked
{
    [viewBG removeFromSuperview];
    viewBG = nil;
}

-(void) mapOrdersClicked
{
    
    if (mainView_Reasons)
    {
        [tblResons removeFromSuperview];
        tblResons = nil;
        
        [mainView_Reasons removeFromSuperview];
        mainView_Reasons = nil;
    }
    
    mainView_Reasons = [[UIView alloc]initWithFrame:self.view.bounds];
    mainView_Reasons.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    [self.view addSubview:mainView_Reasons];
    
    
    CGFloat height = 200*MULTIPLYHEIGHT;
    CGFloat yView = screen_height/2-height/2;
    
    UIView *view_Reasons = [[UIView alloc]initWithFrame:CGRectMake(0, yView, screen_width, height)];
    view_Reasons.backgroundColor = [UIColor whiteColor];
    [mainView_Reasons addSubview:view_Reasons];
    
    CGFloat yPos = 0;
    
    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10*MULTIPLYHEIGHT, yPos, screen_width-(10*MULTIPLYHEIGHT), 44)];
    lblTitle.text = @"Select Timeslots to show Map";
    lblTitle.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
    [view_Reasons addSubview:lblTitle];
    
    yPos += 44+5*MULTIPLYHEIGHT;
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    btnClose.frame = CGRectMake(screen_width-55, 5, 44, 44);
    [view_Reasons addSubview:btnClose];
    [btnClose addTarget:self action:@selector(closeReasonView) forControlEvents:UIControlEventTouchUpInside];
    
    
    tblResons = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screen_width, view_Reasons.frame.size.height-yPos)];
    tblResons.dataSource = self;
    tblResons.delegate = self;
    [view_Reasons addSubview:tblResons];
    
    yPos += tblResons.frame.size.height+5*MULTIPLYHEIGHT;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnDone setTitle:@"MAP" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
    [view_Reasons addSubview:btnDone];
    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(timeslotsSelected) forControlEvents:UIControlEventTouchUpInside];
    btnDone.backgroundColor = BLUE_COLOR;
    
    btnDone.frame = CGRectMake(screen_width/2-(80*MULTIPLYHEIGHT)/2, yPos, 80*MULTIPLYHEIGHT, 25*MULTIPLYHEIGHT);
    
    yPos += 25*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
    
    CGRect rect = view_Reasons.frame;
    rect.size.height = yPos;
    view_Reasons.frame = rect;
    
    
//    CGPoint btnpoint = [sender convertPoint:CGPointZero toView:orderTableView];
//    NSIndexPath *indexPath = [orderTableView indexPathForRowAtPoint:btnpoint];
//
//    if (indexPath != nil)
//    {
//        NSDictionary *dictMain = [self.displayOrders objectAtIndex:indexPath.section];
//    }
}

-(void) timeslotsSelected
{
    if (![arrSelectedTimeslots count])
    {
        [appDel showAlertWithMessage:@"Please select atleast one timeslot." andTitle:@"" andBtnTitle:@"OK"];
        return;
    }
    
    NSMutableArray *arraySend = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [self.displayOrders count]; i++)
    {
        NSDictionary *dict = [self.displayOrders objectAtIndex:i];
        
        NSString *strSlot = [dict objectForKey:@"slot"];
        
        for (int j = 0; j < [arrSelectedTimeslots count]; j++)
        {
            NSString *slot = [arrSelectedTimeslots objectAtIndex:j];
            
            if ([slot isEqualToString:strSlot])
            {
                [arraySend addObject:dict];
                
                break;
            }
        }
    }
    
    MapOrdersViewController *objMap = [[MapOrdersViewController alloc]init];
    objMap.arrOrders = [[NSMutableArray alloc]initWithArray:arraySend];
    [self.navigationController pushViewController:objMap animated:YES];
}

-(void) closeReasonView
{
    [tblResons removeFromSuperview];
    tblResons = nil;
    
    [mainView_Reasons removeFromSuperview];
    mainView_Reasons = nil;
    
    [arrSelectedTimeslots removeAllObjects];
}

@end
