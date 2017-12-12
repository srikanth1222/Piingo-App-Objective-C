//
//  MyAccountViewController.m
//  PiingApp
//
//  Created by SHASHANK on 08/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "MyAccountViewController.h"

@interface MyAccountViewController () <UITableViewDataSource, UITableViewDelegate>

@end

@implementation MyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"My Account";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupMenuBarButtonItems];
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.userInteractionEnabled = YES;
    animatedImageView.image = [UIImage imageNamed:@"app_bg"];
    [self.view addSubview:animatedImageView];
    
    UIView *bgImg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    bgImg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.60];
    [self.view addSubview:bgImg];

    self.piingUserImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(15, 64.0+15, 128.0, 128.0)];
    self.piingUserImageView.center = CGPointMake(screen_width/2, 64+35+64.0);
    self.piingUserImageView.placeholderImage = [UIImage imageNamed:@"profile_image_circle_placeholder"];
    self.piingUserImageView.imageURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"piingoImageURL"]];
    self.piingUserImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.piingUserImageView.layer.cornerRadius = 128.0/2.0;
    self.piingUserImageView.layer.cornerRadius = self.piingUserImageView.frame.size.width/2;
//    self.piingUserImageView.layer.borderWidth = 1.0;
    self.piingUserImageView.clipsToBounds = YES;
//    self.piingUserImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:self.piingUserImageView];

    UILabel *userNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.piingUserImageView.frame)+10.0, screen_width, 25.0)];
    userNameLbl.font = [UIFont fontWithName:APPFONT_BOLD size:22.0];
    userNameLbl.textAlignment = NSTextAlignmentCenter;
    userNameLbl.text = [NSString stringWithFormat:@"%@ %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"piingoFirstName"],[[NSUserDefaults standardUserDefaults] objectForKey:@"piingoLastName"]];
    if (Static_screens_Build)
        userNameLbl.text = @"Tony Chain";
    userNameLbl.textColor = [UIColor whiteColor];
    userNameLbl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:userNameLbl];

    UILabel *pingoIDlbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(userNameLbl.frame)+3.0, screen_width, 20.0)];
    pingoIDlbl.font = [UIFont fontWithName:APPFONT_REGULAR size:16.0];
    pingoIDlbl.textAlignment = NSTextAlignmentCenter;
    pingoIDlbl.text = [NSString stringWithFormat:@"#%@",[[NSUserDefaults standardUserDefaults] objectForKey:PID]];
    if (Static_screens_Build)
        pingoIDlbl.text = [NSString stringWithFormat:@"#%@",@"11134"];
    pingoIDlbl.textColor = [UIColor colorWithRed:204.0/255.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0];
    pingoIDlbl.backgroundColor = [UIColor clearColor];
    [self.view addSubview:pingoIDlbl];

    UILabel *mobileNumberLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(pingoIDlbl.frame)+20.0, screen_width, 20.0)];
    mobileNumberLbl.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:18.0];
    mobileNumberLbl.textAlignment = NSTextAlignmentCenter;
    mobileNumberLbl.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"piingoMobileNumber"];
    if (Static_screens_Build)
        mobileNumberLbl.text = @"+91 9000922322";
    mobileNumberLbl.textColor = [UIColor whiteColor];
    mobileNumberLbl.backgroundColor = [UIColor clearColor];
    
    CGSize widthOfMobileStr = [mobileNumberLbl.text sizeWithAttributes:@{NSFontAttributeName: mobileNumberLbl.font}];
    
//    CGFloat widthOfMobileStr = [self widthOfString:[[NSUserDefaults standardUserDefaults] objectForKey:@"piingoMobileNumber"] withFont:mobileNumberLbl.font];
    mobileNumberLbl.frame = CGRectMake(0, CGRectGetMaxY(pingoIDlbl.frame)+20.0, widthOfMobileStr.width, 20.0);
    
    mobileNumberLbl.center = CGPointMake(screen_width/2 +12.0, CGRectGetMaxY(pingoIDlbl.frame)+20.0+10.0);
    [self.view addSubview:mobileNumberLbl];
    
    UIImageView *cellIconImgView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(mobileNumberLbl.frame) -20, CGRectGetMinY(mobileNumberLbl.frame), 9, 20)];
    cellIconImgView.image = [UIImage imageNamed:@"phone_icon2"];
    [self.view addSubview:cellIconImgView];

    
//    [[NSUserDefaults standardUserDefaults] objectForKey:@"piingoMobileNumber"]
    
//    UITableView *piingUserDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64.0+100+20+50, screen_width, screen_height-230.0) style:UITableViewStylePlain];
//    piingUserDetailTableView.delegate = self;
//    piingUserDetailTableView.dataSource = self;
//    piingUserDetailTableView.bounces = NO;
//    piingUserDetailTableView.backgroundColor = [UIColor clearColor];
//    piingUserDetailTableView.backgroundView = nil;
//    piingUserDetailTableView.allowsSelection = NO;
//    piingUserDetailTableView.separatorStyle = UITableViewCellSelectionStyleNone;
//    [self.view addSubview:piingUserDetailTableView];

}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
        cell.detailTextLabel.textColor = [[UIColor grayColor] colorWithAlphaComponent:0.65];
        cell.detailTextLabel.font = [UIFont fontWithName:APPFONT_ITALIC size:12.0];
        
        UIView *cellLine = [[UIView alloc] initWithFrame:CGRectMake(20, 44, tableView.frame.size.width-20, 1.0)];
        cellLine.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0];
        [cell addSubview:cellLine];
    }
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"piingoFirstName"];
        cell.detailTextLabel.text = @"First name";
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"piingoLastName"];
        cell.detailTextLabel.text = @"piingoLastName";

    }
    else if (indexPath.row == 2)
    {
        cell.textLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"piingoMobileNumber"];
        cell.detailTextLabel.text = @"Mobile Number";

    }
    else if (indexPath.row == 3)
    {
        cell.textLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:PID];
        cell.detailTextLabel.text = @"Piing ID";
        
    }
    
    cell.detailTextLabel.textAlignment = NSTextAlignmentRight;

    
    return cell;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
//    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
//}

@end
