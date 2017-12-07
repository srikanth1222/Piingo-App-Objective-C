//
//  TFViewController.m
//  Park View
//
//  Created by STI-HYD-30 on 09/03/15.
//  Copyright (c) 2015 Chris Wagner. All rights reserved.
//

#import "TFViewController.h"
#import "TransferViewController.h"

@interface TFViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *transerTableView;
}
@end

@implementation TFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Transfer To";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupMenuBarButtonItems];

    transerTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    transerTableView.delegate = self;
    transerTableView.dataSource = self;
    transerTableView.backgroundColor = [UIColor clearColor];
    transerTableView.backgroundView = nil;
    transerTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:transerTableView];
}
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
    self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
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
            initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
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

#pragma mark UITableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return arc4random()%10+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"OptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.textLabel.numberOfLines = 0;
        
//        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height/2;
        cell.imageView.layer.borderWidth = 1.0;
        cell.imageView.clipsToBounds = YES;
        cell.imageView.layer.borderColor = [[UIColor blackColor]colorWithAlphaComponent:0.65].CGColor;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if (indexPath.row %2 == 0)
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    }
    
    cell.imageView.image = [UIImage imageNamed:@"transferUserImg"];
    cell.textLabel.text = @"Tranfer to the person name";
    cell.detailTextLabel.text = @"Person email/Piing ID";

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TransferViewController *transferDetailVC = [[TransferViewController alloc] init];
    [self.navigationController pushViewController:transferDetailVC animated:YES];
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
