//
//  MyschduleViewController.m
//  PiingApp
//
//  Created by SHASHANK on 04/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "MyschduleViewController.h"
#import "MyschduleTableViewCell.h"

@interface MyschduleViewController ()<UITableViewDataSource, UITableViewDelegate>

@end

@implementation MyschduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"My schdule";
    [self setupMenuBarButtonItems];
    
    UITableView *orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height) style:UITableViewStylePlain];
    //    orderTableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    orderTableView.delegate = self;
    orderTableView.dataSource = self;
    orderTableView.opaque = NO;
    orderTableView.backgroundColor = [UIColor clearColor];
    orderTableView.backgroundView = nil;
    //    orderTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //    orderTableView.bounces = NO;
    [self.view addSubview:orderTableView];
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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}
-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 85.0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"mySchduleCell";
    
    MyschduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        //        cell = [[OrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [tableView registerNib:[UINib nibWithNibName:@"MyschduleTableViewCell" bundle:nil] forCellReuseIdentifier:cellIdentifier];
        cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        cell.backgroundColor = [UIColor clearColor];
        //        cell.textLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:18.0];
        //        cell.textLabel.textColor = [UIColor whiteColor];
        //        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        //        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    if (indexPath.section%2 == 0)
        cell.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:247.0/255.0 blue:255.0/255.0 alpha:1.0];
    else
        cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    
    return cell;
}
-(void) tableView:(UITableView *)tableView willDisplayCell:(MyschduleTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section%2 == 0)
        cell.backgroundColor = [UIColor colorWithRed:234.0/255.0 green:247.0/255.0 blue:255.0/255.0 alpha:1.0];
    else
        cell.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    
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
