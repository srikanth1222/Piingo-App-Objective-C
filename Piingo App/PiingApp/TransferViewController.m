//
//  TransferViewController.m
//  Park View
//
//  Created by STI-HYD-30 on 09/03/15.
//  Copyright (c) 2015 Chris Wagner. All rights reserved.
//

#import "TransferViewController.h"

@interface TransferViewController ()
{
    UITableView *transerOrderTableView;
    
    NSInteger selectedIndex;
    NSIndexPath *previousIndex;
    
    NSInteger countVal;
}
@end

@implementation TransferViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Transfer Orders";
    self.view.backgroundColor = [UIColor whiteColor];
    
    selectedIndex = -1;
    countVal = arc4random()%10+1;
    
    transerOrderTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    transerOrderTableView.delegate = self;
    transerOrderTableView.dataSource = self;
    transerOrderTableView.backgroundColor = [UIColor clearColor];
    transerOrderTableView.backgroundView = nil;
    transerOrderTableView.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:transerOrderTableView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return countVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"OptionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionCell"];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        UILabel *jobType = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 20, 20.0)];
        jobType.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        jobType.text = @"P";
        jobType.textAlignment = NSTextAlignmentCenter;
        jobType.backgroundColor = [UIColor whiteColor];
        jobType.layer.borderColor = [UIColor greenColor].CGColor;
        jobType.layer.cornerRadius = 10.0;
        jobType.layer.borderWidth = 1.0;
        jobType.clipsToBounds = YES;
        jobType.tag = 1003;
        [cell addSubview:jobType];

        
        UILabel *orderName = [[UILabel alloc] initWithFrame:CGRectMake(10+25, 10, tableView.frame.size.width-50, 20.0)];
        orderName.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        orderName.text = @"Name of the Person";
        orderName.backgroundColor = [UIColor clearColor];
        orderName.tag = 1001;
        [cell addSubview:orderName];

        UILabel *orderID = [[UILabel alloc] initWithFrame:CGRectMake(10, 30+5, tableView.frame.size.width-30, 20.0)];
        orderID.textColor = [[UIColor blackColor] colorWithAlphaComponent:0.65];
        orderID.text = @"orderID: 12325672223";
        orderID.backgroundColor = [UIColor clearColor];
        orderID.tag = 1002;
        [cell addSubview:orderID];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *tagViewLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, tableView.frame.size.width-30, 40)];
        tagViewLbl.backgroundColor = [UIColor clearColor];
        tagViewLbl.text = @"Tags: 123124235245\n      3425878947598345";
        tagViewLbl.font = [UIFont fontWithName:APPFONT_ITALIC size:14.0];
        tagViewLbl.tag = 999;
        tagViewLbl.numberOfLines = 0;
        [cell addSubview:tagViewLbl];
        
    }
    UILabel *jobType = (UILabel *)[cell viewWithTag:1003];
    UILabel *tagViewLbl = (UILabel *)[cell viewWithTag:999];
    
//    UILabel *orderName = (UILabel *)[cell viewWithTag:1001];
//    UILabel *orderID = (UILabel *)[cell viewWithTag:1002];

    if (selectedIndex == indexPath.row)
        tagViewLbl.hidden = NO;
    else
        tagViewLbl.hidden = YES;
    
    if (indexPath.row %2 == 0)
    {
        jobType.text = @"P";
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        jobType.text = @"D";
        cell.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex == indexPath.row)
        return 100.0;
    return 60.0;
}
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (selectedIndex == indexPath.row)
    {
        selectedIndex = -1;
    }
    else
        selectedIndex = indexPath.row;
    
    if (previousIndex)
        [transerOrderTableView reloadRowsAtIndexPaths:@[previousIndex] withRowAnimation:UITableViewRowAnimationNone];
    
    NSArray* rowsToReload = [NSArray arrayWithObjects:indexPath, nil];
    
    previousIndex = indexPath;
    
    [transerOrderTableView reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationAutomatic];

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
