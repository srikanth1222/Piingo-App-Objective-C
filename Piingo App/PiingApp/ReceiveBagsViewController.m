//
//  ReceiveBagsViewController.m
//  PiingApp
//
//  Created by Veedepu Srikanth on 25/03/17.
//  Copyright © 2017 shashank. All rights reserved.
//

#import "ReceiveBagsViewController.h"
#import "AppDelegate.h"
#import "ScanController.h"
#import "ScanViewController.h"


@interface ReceiveBagsViewController () <UITableViewDelegate, UITableViewDataSource, ScanControllerDelegate, ScanViewControllerDelegate>
{
    UISegmentedControl *segmentControl;
    
    NSMutableArray *arrayReceivableBags;
    
    UITableView *orderTableView;
    
    UIRefreshControl *refreshControl;
    
    AppDelegate *appDel;
    
    BOOL isRefreshing;
    
    NSMutableArray *arrayImageSelected;
    
    UIButton *btnSend;
    
    NSMutableArray *arrayAddBags;
}

@end

@implementation ReceiveBagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    arrayImageSelected = [[NSMutableArray alloc]init];
    arrayAddBags = [[NSMutableArray alloc]init];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Receive Bags";
    [self setupMenuBarButtonItems];
    
    arrayReceivableBags = [[NSMutableArray alloc]init];
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg_dark"];
    [self.view addSubview:animatedImageView];
    
    
    CGFloat yAxis = 0;
    
    CGFloat sgX = 25 * MULTIPLYHEIGHT;
    CGFloat sgY = 60 * MULTIPLYHEIGHT;
    CGFloat sgH = 23 * MULTIPLYHEIGHT;
    
    segmentControl = [[UISegmentedControl alloc]initWithItems:@[@"Receivable Bags", @"Received Bags"]];
    segmentControl.frame = CGRectMake(sgX, sgY, screen_width-(sgX * 2), sgH);
    [self.view addSubview:segmentControl];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    [segmentControl addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    segmentControl.tintColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
    segmentControl.selectedSegmentIndex = 0;
    
    yAxis += sgY+sgH+10*MULTIPLYHEIGHT;
    
    orderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, yAxis, screen_width, screen_height-(yAxis+50*MULTIPLYHEIGHT)) style:UITableViewStylePlain];
    orderTableView.delegate = self;
    orderTableView.dataSource = self;
    orderTableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:orderTableView];
    orderTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    yAxis += orderTableView.frame.size.height+10*MULTIPLYHEIGHT;
    
    CGFloat btnW = 100*MULTIPLYHEIGHT;
    CGFloat btnH = 30*MULTIPLYHEIGHT;
    
    btnSend = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSend setTitle:@"Start Scan" forState:UIControlStateNormal];
    btnSend.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
    btnSend.backgroundColor = BLUE_COLOR;
    btnSend.frame = CGRectMake(screen_width/2-btnW/2, yAxis, btnW, btnH);
    [self.view addSubview:btnSend];
    [btnSend addTarget:self action:@selector(sendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    refreshControl = [[UIRefreshControl alloc]init];
    [orderTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    [refreshControl endRefreshing];
    
    if (segmentControl.selectedSegmentIndex == 0)
    {
        [self getReceivableBags];
    }
    else
    {
        [self getReceivedBags];
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void) segmentChange:(UISegmentedControl *) segmentController
{
    if (segmentController.selectedSegmentIndex == 0)
    {
        [self getReceivableBags];
        
        CGRect frame = orderTableView.frame;
        frame.size.height = screen_height-(frame.origin.y + 50*MULTIPLYHEIGHT);
        orderTableView.frame = frame;
        
        btnSend.hidden = NO;
    }
    else
    {
        [self getReceivedBags];
        
        CGRect frame = orderTableView.frame;
        frame.size.height = screen_height-frame.origin.y;
        orderTableView.frame = frame;
        
        btnSend.hidden = YES;
    }
}

-(void) sendBtnClicked
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
//    ScanController *scanner = [storyboard instantiateViewControllerWithIdentifier:@"ScanController"];
//    scanner.delegate = self;
//    scanner.isFromReceiveBag = YES;
//    scanner.view.backgroundColor = [UIColor whiteColor];
//    [self presentViewController:scanner animated:YES completion:nil];
    
    ScanViewController *scanner = [storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    scanner.delegate = self;
    scanner.isFromReceiveBag = YES;
    scanner.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:scanner animated:YES completion:nil];
}

#pragma mark QRScannerDelegate

-(void) didScanCompleteWithBagNo:(NSString *)bagNo
{
    BOOL foundBagNo = NO;
    
    [arrayAddBags removeAllObjects];
    
    for (int i = 0; i < [arrayReceivableBags count]; i++)
    {
        NSDictionary *dict = [arrayReceivableBags objectAtIndex:i];
        
        if ([[dict objectForKey:@"bagNo"] isEqualToString:bagNo])
        {
            [arrayAddBags addObject:dict];
            
            foundBagNo = YES;
            
            break;
        }
    }
    
    if (foundBagNo)
    {
        NSString *strMsg = [NSString stringWithFormat:@"Do you want to receive bag id : %@?", bagNo];
        
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"" message:strMsg preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *trueAct = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self receiveBagFromService:bagNo];
            
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
        
        [alertCon addAction:trueAct];
        
        
        UIAlertAction *falseAct = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alertCon addAction:falseAct];
        
        [self presentViewController:alertCon animated:YES completion:nil];
    }
    else
    {
        [appDel showAlertWithMessage:@"This bag is not in your assigned list of bags" andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) receiveBagFromService:(NSString *) bagNo
{
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:arrayAddBags, @"bags", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/bag/receivbagtodeliver", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            [arrayAddBags removeAllObjects];
            [arrayImageSelected removeAllObjects];
            
            [self getReceivableBags];
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
}

-(void) refreshTable
{
    refreshControl.hidden = NO;
    
    orderTableView.userInteractionEnabled = NO;
    isRefreshing = YES;
    
    if (segmentControl.selectedSegmentIndex == 0)
    {
        [self getReceivableBags];
    }
    else
    {
        [self getReceivedBags];
    }
}

-(void) getReceivableBags
{
    segmentControl.selectedSegmentIndex = 0;
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/get/bags/getreceivablebags", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        orderTableView.userInteractionEnabled = YES;
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            [arrayReceivableBags removeAllObjects];
            
            if ([[responseObj objectForKey:@"bags"] count])
            {
                [arrayReceivableBags addObjectsFromArray:[responseObj objectForKey:@"bags"]];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"No receivable orders found" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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

-(void) getReceivedBags
{
    segmentControl.selectedSegmentIndex = 1;
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/get/bags/getreceivedbags", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        orderTableView.userInteractionEnabled = YES;
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            [arrayReceivableBags removeAllObjects];
            
            if ([[responseObj objectForKey:@"bags"] count])
            {
                [arrayReceivableBags addObjectsFromArray:[responseObj objectForKey:@"bags"]];
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


#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return;
    
    NSDictionary *dict = [arrayReceivableBags objectAtIndex:indexPath.row];
    
    if (segmentControl.selectedSegmentIndex == 0)
    {
        if ([[dict objectForKey:@"status"] caseInsensitiveCompare:@"SL"] == NSOrderedSame)
        {
            
        }
        else
        {
            if ([arrayImageSelected containsObject:indexPath])
            {
                [arrayImageSelected removeObject:indexPath];
                
                [arrayAddBags removeObject:dict];
            }
            else
            {
                [arrayImageSelected addObject:indexPath];
                
                [arrayAddBags addObject:dict];
            }
            
            [tableView reloadData];
        }
    }
}

-(void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [UIView animateWithDuration:0.1f animations:^{
        cell.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }];
    
}

-(void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    [UIView animateWithDuration:0.1f animations:^{
        cell.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [arrayReceivableBags objectAtIndex:indexPath.row];
    
    CGFloat yAxis = 5*MULTIPLYHEIGHT;
    CGFloat height = 20*MULTIPLYHEIGHT;
    
    yAxis += height;
    yAxis += height;
    yAxis += height;
    yAxis += height;
    
    if ([[dict objectForKey:@"status"] caseInsensitiveCompare:@"SL"] == NSOrderedSame)
    {
        yAxis += 35*MULTIPLYHEIGHT;
    }
    
    return yAxis + 5*MULTIPLYHEIGHT;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayReceivableBags count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"OrderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
        UILabel *lblOid = [[UILabel alloc]init];
        lblOid.tag = 1;
        lblOid.textColor = [UIColor blackColor];
        lblOid.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
        [cell.contentView addSubview:lblOid];
        
        UILabel *lblServiceType = [[UILabel alloc]init];
        lblServiceType.tag = 2;
        lblServiceType.textColor = [UIColor blackColor];
        lblServiceType.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
        [cell.contentView addSubview:lblServiceType];
        
        UILabel *lblBagNo = [[UILabel alloc]init];
        lblBagNo.tag = 3;
        lblBagNo.textColor = [UIColor blackColor];
        lblBagNo.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
        [cell.contentView addSubview:lblBagNo];
        
        UILabel *lblStatus = [[UILabel alloc]init];
        lblStatus.tag = 4;
        lblStatus.textColor = [UIColor blackColor];
        lblStatus.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
        [cell.contentView addSubview:lblStatus];
        
        UIImageView *imgCheckBox = [[UIImageView alloc]init];
        imgCheckBox.tag = 5;
        imgCheckBox.contentMode = UIViewContentModeScaleAspectFit;
        //[cell.contentView addSubview:imgCheckBox];
        
        UILabel *lblStatusText = [[UILabel alloc]init];
        lblStatusText.tag = 6;
        lblStatusText.numberOfLines = 0;
        lblStatusText.textColor = [UIColor blackColor];
        lblStatusText.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
        [cell.contentView addSubview:lblStatusText];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UILabel *lblOid = (UILabel *) [cell.contentView viewWithTag:1];
    UILabel *lblServiceType = (UILabel *) [cell.contentView viewWithTag:2];
    UILabel *lblBagNo = (UILabel *) [cell.contentView viewWithTag:3];
    UILabel *lblStatus = (UILabel *) [cell.contentView viewWithTag:4];
    UILabel *lblStatusText = (UILabel *) [cell.contentView viewWithTag:6];
    
    
    UIImageView *imgCheckBox = (UIImageView *) [cell.contentView viewWithTag:5];
    
    NSDictionary *dict = [arrayReceivableBags objectAtIndex:indexPath.row];
    
    lblOid.text = [NSString stringWithFormat:@"Order Id : %@", [dict objectForKey:@"oid"]];
    lblServiceType.text = [NSString stringWithFormat:@"Service Type : %@", [dict objectForKey:@"serviceType"]];
    lblBagNo.text = [NSString stringWithFormat:@"Bag No : %@", [dict objectForKey:@"bagNo"]];
    lblStatus.text = [NSString stringWithFormat:@"Status : %@", [dict objectForKey:@"status"]];
    
    CGFloat yAxis = 5*MULTIPLYHEIGHT;
    CGFloat height = 20*MULTIPLYHEIGHT;
    
    
    CGFloat xAxis;
    
    if (segmentControl.selectedSegmentIndex == 0)
    {
        xAxis = 20*MULTIPLYHEIGHT;
        
        if ([[dict objectForKey:@"status"] caseInsensitiveCompare:@"SL"] == NSOrderedSame)
        {
            cell.contentView.alpha = 0.5;
            imgCheckBox.hidden = YES;
            
            lblStatusText.text = @"Bag is still at the laundry.\nYou can not receive this bag";
        }
        else
        {
            cell.contentView.alpha = 1.0;
            imgCheckBox.hidden = NO;
            
            lblStatusText.text = @"";
        }
    }
    else
    {
        xAxis = 20*MULTIPLYHEIGHT;
        imgCheckBox.hidden = YES;
    }
    
    lblOid.frame = CGRectMake(xAxis, yAxis, screen_width-50*MULTIPLYHEIGHT, height);
    yAxis += height;
    
    lblServiceType.frame = CGRectMake(xAxis, yAxis, screen_width-50*MULTIPLYHEIGHT, height);
    yAxis += height;
    
    lblBagNo.frame = CGRectMake(xAxis, yAxis, screen_width-50*MULTIPLYHEIGHT, height);
    yAxis += height;
    
    lblStatus.frame = CGRectMake(xAxis, yAxis, screen_width-50*MULTIPLYHEIGHT, height);
    yAxis += height;
    
    lblStatusText.frame = CGRectMake(xAxis, yAxis, screen_width-10*MULTIPLYHEIGHT, 35*MULTIPLYHEIGHT);
    
    imgCheckBox.image = [UIImage imageNamed:@"uncheckmark"];
    imgCheckBox.highlightedImage = [UIImage imageNamed:@"checkmark"];
    
    CGFloat widthImg = 15*MULTIPLYHEIGHT;
    
    imgCheckBox.frame = CGRectMake(10*MULTIPLYHEIGHT, yAxis/2-widthImg/2, widthImg, widthImg);
    
    if ([arrayImageSelected containsObject:indexPath])
    {
        imgCheckBox.highlighted = YES;
    }
    else
    {
        imgCheckBox.highlighted = NO;
    }
    
    return cell;
}


- (void)setupMenuBarButtonItems {
    self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
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
