//
//  SerachUserViewController.m
//  PiingApp
//
//  Created by SHASHANK on 11/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "SearchUserViewController.h"
#import "ScheduleLaterViewController1.h"


#define ORDER_Conform_BTN_TAG 13

@interface SearchUserViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UISearchBarDelegate>
{
    UISearchBar *phoneNumberSearchBar;
    NSMutableArray *responseUserArray;
    
    UITableView *usersTableView;
    AppDelegate *appDel;
    
    NSArray *userAddresses;
    NSMutableArray *userSavedCards;
    
    UIImageView *bgImgView;
}
@end

@implementation SearchUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Search User";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupMenuBarButtonItems];
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    userAddresses = [[NSArray alloc]init];
    userSavedCards = [[NSMutableArray alloc]init];
    
    responseUserArray = [[NSMutableArray alloc]init];
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg_dark"];
    [self.view addSubview: animatedImageView];
    
    if ([[UIScreen mainScreen] nativeBounds].size.height == 2436)
    {
        bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 85.0, screen_width, 41)];
        
        usersTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 85.0+41.0+15.0, screen_width, screen_height-85.0-41.0-20.0) style:UITableViewStylePlain];
    }
    else {
        bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64.0, screen_width, 41)];
        
        usersTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64.0+41.0+15.0, screen_width, screen_height-64.0-41.0-20.0) style:UITableViewStylePlain];
    }
    
    bgImgView.userInteractionEnabled = YES;
    UIImage *bgImg = [UIImage imageNamed:@"login_transparent_bg"];
    bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    bgImgView.image = bgImg;
    
    phoneNumberSearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0.0, screen_width, 40)];
    phoneNumberSearchBar.placeholder = @"Email or mobile number";
    phoneNumberSearchBar.delegate = self;
    phoneNumberSearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //phoneNumberSearchBar.showsCancelButton = YES;
    UITextField *textField = [[[[phoneNumberSearchBar subviews] objectAtIndex:0] subviews]objectAtIndex:1];
    [textField setFont:[UIFont fontWithName:APPFONT_REGULAR size:16.0]];
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Search" style:UIBarButtonItemStyleDone target:self action:@selector(searchWithNumberPad)],
                           nil];
    [numberToolbar sizeToFit];
    textField.inputAccessoryView = numberToolbar;
    [bgImgView addSubview:phoneNumberSearchBar];

    [self.view addSubview:bgImgView];
    
    usersTableView.delegate = self;
    usersTableView.dataSource = self;
    usersTableView.backgroundView = nil;
    usersTableView.backgroundColor = [UIColor clearColor];
    usersTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:usersTableView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    [tapGesture setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:tapGesture];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    if (appDel.isPickupCompletedForCreatedOrder)
    {
        appDel.isPickupCompletedForCreatedOrder = NO;
        
        JobOrdersViewController *jobsController = [[JobOrdersViewController alloc] initWithNibName:@"JobOrdersViewController" bundle:nil];
        appDel.jobOrdersList = jobsController;
        
        UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
        NSArray *controllers = [NSArray arrayWithObject:jobsController];
        navigationController.viewControllers = controllers;
        
        [appDel.sideMenuViewController hideMenuViewController];
    }
}

#pragma mark UIcontrol methods
-(void)cancelNumberPad
{
    [phoneNumberSearchBar resignFirstResponder];
    phoneNumberSearchBar.text = @"";
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchWithNumberPad];
}

-(void)searchWithNumberPad
{
    [phoneNumberSearchBar resignFirstResponder];
    
    if ([phoneNumberSearchBar.text length] < 5)
    {
        [AppDelegate showAlertWithMessage:@"Search field should not be empty" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic;
    
    if ([AppDelegate validateTextFieldWithText:phoneNumberSearchBar.text With:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"])
    {
        registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:phoneNumberSearchBar.text, @"email",[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    }
    else
    {
        registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:phoneNumberSearchBar.text, @"phone",[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/check/user", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [responseUserArray removeAllObjects];
            
            [responseUserArray addObject:[responseObj objectForKey:@"user"]];
            
            [usersTableView reloadData];
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

-(void) viewTapped
{
    [self dismissKeyboard];
}

-(void) dismissKeyboard {
    [phoneNumberSearchBar resignFirstResponder];
}


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
    return [responseUserArray count];
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
        
        UIImageView *cellBg = [[UIImageView alloc] init];
        cellBg.layer.cornerRadius = 2.0;
        cellBg.clipsToBounds = YES;
        UIImage *bgImage = [UIImage imageNamed:@"cell_bg"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        
        cellBg.image = bgImage;
        cellBg.userInteractionEnabled = YES;
        
        cell.backgroundView = cellBg;
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[responseUserArray objectAtIndex:indexPath.row] objectForKey:@"name"]];
    
    return cell;
}

#pragma mark UITableView Delegate Methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] isEqualToString:@"0"])
    {
        [AppDelegate showAlertWithMessage:@"Please checkin from Menu first before you create for any order" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    [self getAddress];
}

-(void) getAddress
{
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *verificationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[responseUserArray objectAtIndex:0] objectForKey:@"userId"], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/address/get", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:verificationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            if ([[responseObj objectForKey:@"addresses"] count] == 0)
            {
                [AppDelegate showAlertWithMessage:@"There are no address in your address book please add at least one address." andTitle:@"" andBtnTitle:@"OK"];
                
                return;
            }
            
            userAddresses = [responseObj objectForKey:@"addresses"];
            
            [self getCards];
            
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}


-(void) getCards
{
    NSMutableDictionary *verificationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[responseUserArray objectAtIndex:0] objectForKey:@"userId"], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/payment/getallpaymentmethods", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:verificationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            NSDictionary *dict = [responseObj objectForKey:@"paymentMethod"];
            
            NSMutableArray *arrayCards = [[NSMutableArray alloc]init];
            
            NSDictionary *dictCash = nil;
            
            if ([[[dict objectForKey:@"cash"] objectForKey:@"default"]intValue] == 1)
            {
                dictCash = [NSDictionary dictionaryWithObjectsAndKeys:@"CASH ON DELIVERY", @"maskedCardNo", @"Cash", @"_id", @"1", @"default", nil];
            }
            else
            {
                dictCash = [NSDictionary dictionaryWithObjectsAndKeys:@"CASH ON DELIVERY", @"maskedCardNo", @"Cash", @"_id", @"0", @"default", nil];
            }
            
            [arrayCards addObject:dictCash];
            
            if ([[[dict objectForKey:@"card"] objectForKey:@"cardList"] count])
            {
                [arrayCards addObjectsFromArray:[[dict objectForKey:@"card"] objectForKey:@"cardList"]];
            }
            
            [userSavedCards addObjectsFromArray:arrayCards];
            
            ScheduleLaterViewController1 *obj = [[ScheduleLaterViewController1 alloc]init];
            obj.userAddresses = userAddresses;
            obj.userSavedCards = userSavedCards;
            obj.isFromCreateOrder = YES;
            obj.dictUpdateOrder = [[NSMutableDictionary alloc]initWithDictionary:[responseUserArray objectAtIndex:0]];
            
            [self.navigationController pushViewController:obj animated:YES];
        }
        else {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
    
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
    [appDel.sideMenuViewController presentLeftMenuViewController];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    [appDel.sideMenuViewController presentRightMenuViewController];
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
