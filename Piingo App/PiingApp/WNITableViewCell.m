//
//  WashAndIronBagTableViewCell.m
//  PiingApp
//
//  Created by SHASHANK on 23/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "WNITableViewCell.h"
#import "ItemCollectionViewCell.h"
#import "ItemCollectionViewController.h"

#define CollectionViewTag 222

#define TEXT_LABEL_COLOR [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]

#define SPECIAL_REQ_NON_ACTIVE_COLOR [UIColor colorWithRed:173.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:1.0]
#define SPECIAL_REQ_SELECTED_COLOR [UIColor colorWithRed:210.0/255.0 green:187.0/255.0 blue:102.0/255.0 alpha:1.0]

@implementation WNITableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) parentDelegate{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        selectedIndex = -1;
        
        parentDel = parentDelegate;
        
        self.backgroundColor = [UIColor clearColor];//[[UIColor blackColor] colorWithAlphaComponent:0.05];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        wAndIronArrayDetails = [[NSDictionary alloc] init];
        dcArrayDetails = [[NSDictionary alloc] init];
        
        UIImage *bgImg = [UIImage imageNamed:@""];
        bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
        
        cellBGimage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, screen_width-20, 110.0)];
        cellBGimage.image = bgImg;
        cellBGimage.userInteractionEnabled = YES;
        [self addSubview:cellBGimage];
        
        itemTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+10, 10, screen_width, 20.0)];
        itemTypeLabel.backgroundColor = [UIColor clearColor];
        itemTypeLabel.font = [UIFont fontWithName:APPFONT_BOLD size:16.0];
        itemTypeLabel.textColor = APP_FONT_COLOR_GREY;
        [self addSubview:itemTypeLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25.0, CGRectGetMaxY(itemTypeLabel.frame)+2, CGRectGetWidth(cellBGimage.frame) - 50.0, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0];
        [self addSubview:lineView];
        
        tagTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(screen_width-100, 10.0, 78, 22.0)];
        tagTextFeild.backgroundColor = [UIColor clearColor];
        //        tagTextFeild.layer.borderWidth = 1.0;
        //        tagTextFeild.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
        //        tagTextFeild.placeholder = @"Enter tag No.";
        tagTextFeild.enabled = NO;
        tagTextFeild.textColor = [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:143.0/255.0 alpha:1.0];
        tagTextFeild.textAlignment = NSTextAlignmentCenter;
        tagTextFeild.font = [UIFont fontWithName:APPFONT_REGULAR size:14.0];
        tagTextFeild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:tagTextFeild];
        
        bagDetailsTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+10, cellBGimage.frame.size.width - 20, 10) style:UITableViewStylePlain];
        bagDetailsTableView.delegate = self;
        bagDetailsTableView.dataSource = self;
        bagDetailsTableView.backgroundColor = [UIColor clearColor];
        bagDetailsTableView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
        bagDetailsTableView.backgroundView = nil;
        bagDetailsTableView.scrollEnabled = NO;
        bagDetailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        bagDetailsTableView.showsVerticalScrollIndicator = NO;
        [cellBGimage addSubview:bagDetailsTableView];
        
        confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.backgroundColor = APP_GREEN_THEME_COLOR;
        confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
        //        confirmBtn.layer.cornerRadius = 5.0;
        confirmBtn.clipsToBounds = NO;
        //        confirmBtn.layer.borderColor = APPLE_BLUE_COLOR.CGColor;
        //        confirmBtn.layer.borderWidth = 0.5;
        confirmBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
        confirmBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [confirmBtn setTitle:@"Edit" forState:UIControlStateDisabled];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(conformBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [cellBGimage addSubview:confirmBtn];
        
        specialReqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        specialReqBtn.backgroundColor = SPECIAL_REQ_NON_ACTIVE_COLOR;
        specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
        //        specialReqBtn.layer.cornerRadius = 5.0;
        specialReqBtn.clipsToBounds = NO;
        //        specialReqBtn.layer.borderColor = APPLE_BLUE_COLOR.CGColor;
        //        specialReqBtn.layer.borderWidth = 0.5;
        specialReqBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
        specialReqBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [specialReqBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [specialReqBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        [specialReqBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [specialReqBtn setTitle:@"Spl.Request" forState:UIControlStateNormal];
        [specialReqBtn addTarget:self action:@selector(specialRequestClicked) forControlEvents:UIControlEventTouchUpInside];
        [cellBGimage addSubview:specialReqBtn];
        
    }
    return self;
}
-(void) setDetials:(id) itemDetailObj
{
    bagDetails = itemDetailObj;
    
    confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
    specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
    
    {
        
        NSData *data = [@"{\"bag\":\"bag1\",\"bagTag\":\"123460\",\"bagType\":\"1(optinal:Load Wash)\",\"no.ofkgs\":\"1.0\",\"Load Wash\":{\"WF\":{\"items\":[{\"cobid\":\"293\",\"odid\":\"9\",\"ic\":\"WF\",\"in\":\"Load Wash\",\"clr\":\"#CC66FF\",\"ip\":\"10.5\",\"ctmid\":\"1\",\"codimid\":\"5\",\"ct\":\"Cotton\",\"btmid\":\"1\",\"bn\":\"Dolce & Gabbana\",\"spc\":\"0\",\"aer\":\"No\",\"tagno\":\"7867861\",\"ds\":\"Y\",\"remarks\":\"dfg\"}]}}}" dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (itemDetailObj) {
            json =itemDetailObj;
        }
        
        cellBGimage.frame = CGRectMake(10, 5, screen_width-20, 110.0-15.0);
        
        wAndIronArrayDetails = [json objectForKey:@"Wash & Iron"];
        dcArrayDetails = [json objectForKey:@"Dry Cleaning"];
        
        wAndIronArray = [wAndIronArrayDetails allKeys];
        dcArray = [dcArrayDetails allKeys];
        
        if (wAndIronArrayDetails && dcArrayDetails)
        {
            bagDetailsTableView.frame = CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+10, cellBGimage.frame.size.width - 20, 44*([[wAndIronArrayDetails allKeys] count] + [[dcArrayDetails allKeys] count] )+55);
            cellBGimage.frame = CGRectMake(10, 5, screen_width-20, cellBGimage.frame.size.height+44*([[wAndIronArrayDetails allKeys] count] + [[dcArrayDetails allKeys] count]) +55 );
            
        }
        else if (wAndIronArrayDetails)
        {
            bagDetailsTableView.frame = CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+10, cellBGimage.frame.size.width - 20, 44*([[wAndIronArrayDetails allKeys] count]) +30);
            cellBGimage.frame = CGRectMake(10, 5, screen_width-20, cellBGimage.frame.size.height+44*([[wAndIronArrayDetails allKeys] count]) +30);
        }
        else
        {
            bagDetailsTableView.frame = CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+10, cellBGimage.frame.size.width - 20, 44*([[dcArrayDetails allKeys] count]) +30);
            cellBGimage.frame = CGRectMake(10, 5, screen_width-20, cellBGimage.frame.size.height+44*( [[dcArrayDetails allKeys] count] +30));
        }
        
        if ([[[[[[[json objectForKey:@"Load Wash"] objectForKey:@"WF"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"aer"] capitalizedString] isEqualToString:@"YES"])
        {
            confirmBtn.enabled = NO;
            specialReqBtn.backgroundColor = SPECIAL_REQ_SELECTED_COLOR;
        }
        else
        {
            confirmBtn.enabled = YES;
            specialReqBtn.backgroundColor = SPECIAL_REQ_NON_ACTIVE_COLOR;
        }
        
        tagTextFeild.text = [NSString stringWithFormat:@"#%@", [json objectForKey:@"bagtag"]];
        
        itemTypeLabel.text = @"WNI/DC/IRN";        
        
        confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
        specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
        
        specialReqBtn.hidden = YES;
        confirmBtn.hidden = YES;
        
        [bagDetailsTableView reloadData];
    }
}
-(void) specialRequestClicked
{
    
}
-(void) conformBtnClicked
{
    
}
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
//-(CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == selectedIndex) {
//        return 36.0 + 7*25;
//    }
//    return 36.0;
//}
//-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if ([bagDetails objectForKey:@"Dry Cleaning"] && [bagDetails objectForKey:@"Wash & Iron"])
//    {
//        if (section == 0)
//        {
//            return @"Wash & Iron";
//        }
//        else
//        {
//            return @"Dry Cleaning";
//        }
//    }
//    else
//    {
//        if ([bagDetails objectForKey:@"Wash & Iron"])
//        {
//            return @"Wash & Iron";
//        }
//        if ([bagDetails objectForKey:@"Dry Cleaning"])
//        {
//            return @"Dry Cleaning";
//        }
//    }
//    return @"";
//}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([bagDetails objectForKey:@"Dry Cleaning"] && [bagDetails objectForKey:@"Wash & Iron"])
    {
        if (section == 0)
        {
            UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
            titleLbl.backgroundColor = [UIColor clearColor];
            titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
            titleLbl.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:231.0/255.0];
            titleLbl.text = @"  Dry Cleaning";

            return titleLbl;
        }
        else
        {
            UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
            titleLbl.backgroundColor = [UIColor clearColor];
            titleLbl.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:231.0/255.0];
            titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
            titleLbl.text = @"  Wash & Iron";

            return titleLbl;
        }
    }
    else
    {
        if ([bagDetails objectForKey:@"Wash & Iron"])
        {
            UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
            titleLbl.backgroundColor = [UIColor clearColor];
            titleLbl.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:231.0/255.0];
            titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
            titleLbl.text = @"  Wash & Iron";

            return titleLbl;
        }
        if ([bagDetails objectForKey:@"Dry Cleaning"])
        {
            UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
            titleLbl.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:231.0/255.0];
            titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
            titleLbl.text = @"  Dry Cleaning";
            return titleLbl;
        }
    }
    
    return nil;
}
-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5.0;
}
-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([bagDetails objectForKey:@"Dry Cleaning"] && [bagDetails objectForKey:@"Wash & Iron"])
    {
        return 20.0;
    }
    else
    {
        if ([bagDetails objectForKey:@"Wash & Iron"])
        {
            return 20.0;
        }
        if ([bagDetails objectForKey:@"Dry Cleaning"])
        {
            return 20.0;
        }
    }

    return 0.01;
}
-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 15.0)];
    emptyView.backgroundColor = [UIColor clearColor];
    
    return emptyView;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([bagDetails objectForKey:@"Dry Cleaning"] && [bagDetails objectForKey:@"Wash & Iron"])
    {
        return 2;
    }
    else if ([bagDetails objectForKey:@"Dry Cleaning"] || [bagDetails objectForKey:@"Wash & Iron"])
    {
        return 1;
    }
    
    return 0;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([bagDetails objectForKey:@"Dry Cleaning"] && [bagDetails objectForKey:@"Wash & Iron"])
    {
        if (section == 0)
        {
            return [[dcArrayDetails allKeys] count];
        }
        else
        {
            return [[wAndIronArrayDetails allKeys] count];
        }
    }
    else if ([bagDetails objectForKey:@"Dry Cleaning"])
    {
        return [[dcArrayDetails allKeys] count];
    }
    else if ([bagDetails objectForKey:@"Wash & Iron"])
    {
        return [[wAndIronArrayDetails allKeys] count];
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    {
        
        static NSString *cellIdentifier = @"OrderCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.backgroundColor = [UIColor clearColor];
            
            UILabel *categoryLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 8, cellBGimage.frame.size.width-10, 20.0)];
            categoryLbl.tag = 10;
            categoryLbl.backgroundColor = [UIColor clearColor];
            categoryLbl.textColor = TEXT_LABEL_COLOR;
            categoryLbl.adjustsFontSizeToFitWidth = YES;
            categoryLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:15.0];
            [cell addSubview:categoryLbl];
            
            UILabel *countPriceDetailLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 8+19, cellBGimage.frame.size.width-10, 16.0)];
            countPriceDetailLbl.tag = 11;
            countPriceDetailLbl.backgroundColor = [UIColor clearColor];
            countPriceDetailLbl.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0];
            countPriceDetailLbl.font = [UIFont fontWithName:APPFONT_LIGHT size:12.0];
            countPriceDetailLbl.adjustsFontSizeToFitWidth = YES;
            [cell addSubview:countPriceDetailLbl];
            
            UILabel *categoryPriceLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellBGimage.frame.size.width-95.0, 5.0, 45, 34.0)];
            categoryPriceLbl.tag = 12;
            categoryPriceLbl.adjustsFontSizeToFitWidth = YES;
            categoryPriceLbl.backgroundColor = [UIColor clearColor];
            categoryPriceLbl.textAlignment = NSTextAlignmentRight;
            categoryPriceLbl.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0];
            categoryPriceLbl.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
            categoryPriceLbl.adjustsFontSizeToFitWidth = YES;
            [cell addSubview:categoryPriceLbl];
            
            cell.clipsToBounds = NO;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        UILabel *categoryLbl = (UILabel *)[cell viewWithTag:10];
        UILabel *countPriceDetailLbl = (UILabel *)[cell viewWithTag:11];
        UILabel *categoryPriceLbl = (UILabel *)[cell viewWithTag:12];
        
        
        if ([bagDetails objectForKey:@"Dry Cleaning"] && [bagDetails objectForKey:@"Wash & Iron"])
        {
            if (indexPath.section == 0)
            {
                priceListArray = [[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ic == %@",[dcArray objectAtIndex:indexPath.row]];
                NSArray *filterAry = [priceListArray filteredArrayUsingPredicate:predicate];
                
                categoryLbl.text = [NSString stringWithFormat:@"%@",[[filterAry objectAtIndex:0] objectForKey:@"in"]];
                countPriceDetailLbl.text = [NSString stringWithFormat:@"%ld at $%@ each",[[[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"] count],[[filterAry objectAtIndex:0] objectForKey:@"ip"]];
                categoryPriceLbl.text = [self calculateThePrice:[[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
            }
            else
            {
                priceListArray = [[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ic == %@",[wAndIronArray objectAtIndex:indexPath.row]];
                NSArray *filterAry = [priceListArray filteredArrayUsingPredicate:predicate];
                
                categoryLbl.text = [NSString stringWithFormat:@"%@",[[filterAry objectAtIndex:0] objectForKey:@"in"]];
                countPriceDetailLbl.text = [NSString stringWithFormat:@"%ld at $%@ each",[[[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"] count],[[filterAry objectAtIndex:0] objectForKey:@"ip"]];
                categoryPriceLbl.text = [self calculateThePrice:[[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
            }
        }
        else if ([bagDetails objectForKey:@"Dry Cleaning"] || [bagDetails objectForKey:@"Wash & Iron"])
        {
            if ([bagDetails objectForKey:@"Dry Cleaning"])
            {
                priceListArray = [[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ic == %@",[dcArray objectAtIndex:indexPath.row]];
                NSArray *filterAry = [priceListArray filteredArrayUsingPredicate:predicate];
                
                categoryLbl.text = [NSString stringWithFormat:@"%@",[[filterAry objectAtIndex:0] objectForKey:@"in"]];
                countPriceDetailLbl.text = [NSString stringWithFormat:@"%ld at $%@ each",[[[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"] count],[[filterAry objectAtIndex:0] objectForKey:@"ip"]];
                categoryPriceLbl.text = [self calculateThePrice:[[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
            }
            else if([bagDetails objectForKey:@"Wash & Iron"])
            {
                priceListArray = [[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"];
                
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ic == %@",[wAndIronArray objectAtIndex:indexPath.row]];
                NSArray *filterAry = [priceListArray filteredArrayUsingPredicate:predicate];
                
                categoryLbl.text = [NSString stringWithFormat:@"%@",[[filterAry objectAtIndex:0] objectForKey:@"in"]];
                countPriceDetailLbl.text = [NSString stringWithFormat:@"%ld at $%@ each",[[[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"] count],[[filterAry objectAtIndex:0] objectForKey:@"ip"]];
                categoryPriceLbl.text = [self calculateThePrice:[[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
            }
        }
        return cell;
    }
}
#pragma mark UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    
    //NSMutableDictionary *dic = [NSMutableDictionary alloc]initWithDictionary:<#(nonnull NSDictionary *)#>
    
    if ([bagDetails objectForKey:@"Dry Cleaning"] && [bagDetails objectForKey:@"Wash & Iron"])
    {
        if (indexPath.section == 0)
        {
            [selectedItems addObjectsFromArray:[[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
        }
        else
        {
            [selectedItems addObjectsFromArray:[[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
        }
    }
    else if ([bagDetails objectForKey:@"Dry Cleaning"] || [bagDetails objectForKey:@"Wash & Iron"])
    {
        if ([bagDetails objectForKey:@"Dry Cleaning"])
        {
            [selectedItems addObjectsFromArray:[[[bagDetails objectForKey:@"Dry Cleaning"] objectForKey:[dcArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
        }
        else if([bagDetails objectForKey:@"Wash & Iron"])
        {
            [selectedItems addObjectsFromArray:[[[bagDetails objectForKey:@"Wash & Iron"] objectForKey:[wAndIronArray objectAtIndex:indexPath.row]] objectForKey:@"items"]];
        }
    }
    ItemCollectionViewController *itemVC = [[ItemCollectionViewController alloc] init];
    itemVC.selecteItemisedArray = selectedItems;
    [((UIViewController *)parentDel).navigationController pushViewController:itemVC animated:YES];
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    ItemCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    
    [cell setDetails:nil];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(screen_width/3, 60.0);
//}
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCollectionViewCell *selectedCell = (ItemCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [selectedCell clickBtn];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(NSString *) calculateThePrice:(id) categoryDetails
{
    float totalVal = 0.0;
    for (int i = 0; i < [categoryDetails count]; i++)
    {
        if ([[[categoryDetails objectAtIndex:i] objectForKey:@"ds"] isEqualToString:@"Y"])
        {
            totalVal += [[[categoryDetails objectAtIndex:i] objectForKey:@"ip"] floatValue];
        }
    }
    return [NSString stringWithFormat:@"$%.2f",totalVal];
}
@end
