//
//  MenuViewController.m
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "MenuViewController.h"
#import "JobOrdersViewController.h"
#import "MyschduleViewController.h"
#import "MyAccountViewController.h"
#import "PanicViewController.h"
#import "PriceListViewController.h"
#import "TransferViewController.h"
#import "TFViewController.h"
#import "ReconcileViewController.h"

#import "SearchUserViewController.h"
#import "ReceiveBagsViewController.h"
#import "ChangePasswordViewController.h"


typedef enum
{
    MyOrdersMenuItem = 0,
    CreateAdochOrder,
    MyAccountMenuItem,
    ChangePasswordMenuItem,
    ReceiveBagsItem,
    PanicMenuItem,
    TransferMenuItem,
    ReconcileMenuItem,
    PriceListMenuItem,
    CallSupportMenuItem,
    SmsSupportMenuItem,
    LogoutMenuItem,
    MySchduleMenuItem
    
} menuItemList;

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL isAccountOpen;
    AppDelegate *appdel;
    
    NSArray *titles, *titleImages;
 
    NSInteger selectedIndex;
    

}
@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:32.0/255.0 blue:37.0/255.0 alpha:1.0];
    
    appdel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    isAccountOpen = NO;
    selectedIndex = 0;
    
//    titles = @[@"My Order", @"My Account", @"Panic", @"Transfer", @"Reconcile", @"Price list", @"Settings", @"Call Support", @"SMS Support", @"Log Out"];
    
    titles = @[@"My Order", @"Create Order", @"My Account", @"Change Password", @"Receive Bags", @"Panic", @"Transfer", @"Reconcile Cash", @"Price list", @"Call Support", @"SMS Support", @"Log Out"];
//    titleImages = @[@"ordersIcon", @"adcohIcon", @"AccountIcon", @"emergency", @"transferIcon", @"reconcile", @"PriceTag", @"callIcon", @"SMSIcon", @"LogoutIcon"];
    titleImages = @[@"my_order_icon", @"create_order", @"my_account", @"my_account", @"my_account", @"panic", @"transfer", @"recoicer", @"pricelist", @"call_icon", @"sms", @"logout"];
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height) style:UITableViewStylePlain];
//        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor blackColor];
        UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"side_menu_bg"]];
        tableView.backgroundView = bgImage;
//        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.separatorColor = [UIColor colorWithRed:188.0/255.0 green:188.0/255.0 blue:188.0/255.0 alpha:1.0];
//        tableView.bounces = NO;
        
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 90.0)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UIImageView *logoImage = [[UIImageView alloc] initWithFrame:CGRectMake(30+10.0, 15.0, 98.0, 60.0)];
        logoImage.backgroundColor = [UIColor clearColor];
        logoImage.image = [UIImage imageNamed:@"sidemenu_logo"];
        [headerView addSubview:logoImage];
        
        tableView.tableHeaderView = headerView;
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UILabel *checkinLbl = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 10, 100, 25.0)];
        checkinLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
        checkinLbl.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
        checkinLbl.text = @"Check In";
        checkinLbl.backgroundColor = [UIColor clearColor];
        [footerView addSubview:checkinLbl];
        
        appdel.checkInSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(checkinLbl.frame)+20.0, 5.0, 30, 40)];
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] isEqualToString:@"0"])
        {
            [appdel.checkInSwitch setOn:NO];
            appdel.checkInSwitch.enabled = YES;
        }
        else
        {
            [appdel.checkInSwitch setOn:YES];
            appdel.checkInSwitch.enabled = NO;
        }
        
        [appdel.checkInSwitch addTarget:self action:@selector(checkinBtnClicked) forControlEvents:UIControlEventValueChanged];
        [footerView addSubview:appdel.checkInSwitch];
        
        tableView.tableFooterView = footerView;

        tableView;
    });
    [self.view addSubview:self.tableView];

}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


-(void) checkinBtnClicked
{
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appdel withObject:nil];
    
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", @"Start Shift", @"action", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", versionNumber, @"ver",  nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/piingo/saveshift", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appdel withObject:nil];
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [appdel.checkInSwitch setOn:YES];
            appdel.checkInSwitch.enabled = NO;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You are successfully Checked in" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"checkInStatus"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                JobOrdersViewController *jobsController = [[JobOrdersViewController alloc] initWithNibName:@"JobOrdersViewController" bundle:nil];
                appdel.jobOrdersList = jobsController;
                
                UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
                NSArray *controllers = [NSArray arrayWithObject:jobsController];
                navigationController.viewControllers = controllers;
                
                [appdel.sideMenuViewController hideMenuViewController];
            }
        }
        else
        {
            [appdel.checkInSwitch setOn:NO];
            
            [appdel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}


#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    selectedIndex = indexPath.row;
    
    switch (indexPath.row) {
        case MyOrdersMenuItem:
            //            [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[[DEMOFirstViewController alloc] init]]
            //                                                         animated:YES];
        {
            JobOrdersViewController *jobsController = [[JobOrdersViewController alloc] initWithNibName:@"JobOrdersViewController" bundle:nil];
            appdel.jobOrdersList = jobsController;
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:jobsController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }
            break;
        case MyAccountMenuItem:
        {
            MyAccountViewController *myAccController = [[MyAccountViewController alloc] init];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:myAccController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }
            break;
            
        case ChangePasswordMenuItem:
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            ChangePasswordViewController *objChange = [storyBoard instantiateViewControllerWithIdentifier:@"ChangePasswordViewController"];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:objChange];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];

        }
            break;
        case ReceiveBagsItem:
        {
            ReceiveBagsViewController *myAccController = [[ReceiveBagsViewController alloc] init];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:myAccController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }
            break;
        case MySchduleMenuItem:
        {
            [appdel showAlertWithMessage:@"Panic not available" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
            
            
            MyschduleViewController *mySchduleController = [[MyschduleViewController alloc] initWithNibName:@"MyschduleViewController" bundle:nil];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:mySchduleController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }
            break;
        case PanicMenuItem:
        {
            [appdel showAlertWithMessage:@"Panic not available" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
            
            
            PanicViewController *panicController = [[PanicViewController alloc] init];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:panicController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }
            break;
        case TransferMenuItem:
        {
            [appdel showAlertWithMessage:@"Transfer not available" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
            
            TFViewController *transferVController = [[TFViewController alloc] init];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:transferVController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }            break;
        case ReconcileMenuItem:
        {
            [appdel showAlertWithMessage:@"Reconcile not available" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
            
            ReconcileViewController *reconcileVController = [[ReconcileViewController alloc] init];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:reconcileVController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }            break;
        case PriceListMenuItem:
        {
//            [appdel showAlertWithMessage:@"Price list not available" andTitle:@"" andBtnTitle:@"OK"];
//            
//            return;
            
            PriceListViewController *priceListController = [[PriceListViewController alloc] init];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:priceListController];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }
            break;
        case CallSupportMenuItem:
            
            [appdel callSupportMethodClicked];
            break;
        case SmsSupportMenuItem:
            
            [appdel showAlertWithMessage:@"SMS not available" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
            
            
            [appdel smsSupportClicked];
            break;
        case LogoutMenuItem:
            
            [self logoutClicked];
            
            break;
            
        default:
            break;
        case CreateAdochOrder:
        {
//            [appdel showAlertWithMessage:@"Create order not available" andTitle:@"" andBtnTitle:@"OK"];
//            
//            return;
            
            SearchUserViewController *searchUserVC = [[SearchUserViewController alloc] init];
            
            UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
            NSArray *controllers = [NSArray arrayWithObject:searchUserVC];
            navigationController.viewControllers = controllers;
            
            [appdel.sideMenuViewController hideMenuViewController];
        }
            break;
    }
    
    [tableView reloadData];
}

-(void) logoutClicked
{
    UIAlertController * alert = [UIAlertController
                                  alertControllerWithTitle:@""
                                  message:@"Are you sure you want to logout?"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [appdel.sideMenuViewController hideMenuViewController];
                             [appdel piingoLogout];
                             
                         }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];

}


#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titleImages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:APPFONT_LIGHT size:14.0];
        cell.textLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    if (indexPath.row == selectedIndex)
    {
        cell.textLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        cell.textLabel.font = [UIFont fontWithName:APPFONT_LIGHT size:14.0];
        cell.textLabel.textColor = [UIColor colorWithRed:142.0/255.0 green:142.0/255.0 blue:142.0/255.0 alpha:1.0];
    }
    cell.textLabel.text = titles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:titleImages[indexPath.row]];
    
    return cell;
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
