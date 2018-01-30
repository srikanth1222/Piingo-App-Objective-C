//
//  WashAndIronBagTableViewCell.m
//  PiingApp
//
//  Created by SHASHANK on 23/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "WashAndIronBagTableViewCell.h"
#import "ItemCollectionViewCell.h"
#import "ItemCollectionViewController.h"
#import "JobdetailViewController.h"
#import "NSNull+JSON.h"


#define CollectionViewTag 222

#define TEXT_LABEL_COLOR [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]

#define SPECIAL_REQ_NON_ACTIVE_COLOR [UIColor colorWithRed:173.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:1.0]
#define SPECIAL_REQ_SELECTED_COLOR [UIColor colorWithRed:210.0/255.0 green:187.0/255.0 blue:102.0/255.0 alpha:1.0]

@implementation WashAndIronBagTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) parentDelegate{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        selectedIndex = -1;
        
        parentDel = parentDelegate;
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        arrayWashType = [[NSMutableArray alloc]init];
        arrayWashTypeNames = [[NSMutableArray alloc]init];
        
        UIImage *bgImg = [UIImage imageNamed:@""];
        bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
        
        cellBGimage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, screen_width-20, 110.0)];
        cellBGimage.image = bgImg;
        cellBGimage.userInteractionEnabled = YES;
        [self addSubview:cellBGimage];
        
        itemTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, screen_width-155, 20.0)];
        itemTypeLabel.backgroundColor = [UIColor clearColor];
        itemTypeLabel.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
        itemTypeLabel.textColor = APP_FONT_COLOR_GREY;
        [self addSubview:itemTypeLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25.0, CGRectGetMaxY(itemTypeLabel.frame)+2, CGRectGetWidth(cellBGimage.frame) - 50.0, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0];
        [self addSubview:lineView];
        
        tagTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(screen_width-140, 10.0, 135, 22.0)];
        tagTextFeild.backgroundColor = [UIColor clearColor];
        tagTextFeild.enabled = NO;
        tagTextFeild.textColor = [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:143.0/255.0 alpha:1.0];
        tagTextFeild.textAlignment = NSTextAlignmentCenter;
        tagTextFeild.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
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
        confirmBtn.clipsToBounds = NO;
        confirmBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
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
        specialReqBtn.clipsToBounds = NO;
        specialReqBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
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
        id json;
        
        if (itemDetailObj)
        {
            json = itemDetailObj;
        }
        
        cellBGimage.frame = CGRectMake(10, 5, screen_width-20, 110.0-15.0);
        
        
        [arrayWashType removeAllObjects];
        
        [arrayWashType addObject:[[[json objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"itemsDetailsFull"]];
        
        if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"WI"])
        {
            [arrayWashTypeNames addObject:@"Wash & Iron"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"DC"])
        {
            [arrayWashTypeNames addObject:@"Dry Cleaning"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"DCG"])
        {
            [arrayWashTypeNames addObject:@"Green Dry Cleaning"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"IR"])
        {
            [arrayWashTypeNames addObject:@"Ironing"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"HL_DC"])
        {
            [arrayWashTypeNames addObject:@"Home Linen - Dry Cleaning"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"HL_DCG"])
        {
            [arrayWashTypeNames addObject:@"Home Linen - Green Dry Cleaning"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"HL_WI"])
        {
            [arrayWashTypeNames addObject:@"Home Linen - Wash & Iron"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"LE"])
        {
            [arrayWashTypeNames addObject:@"Leather Cleaning"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] isEqualToString:@"CA"])
        {
            [arrayWashTypeNames addObject:@"Carpet Cleaning"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] containsString:@"CC"])
        {
            [arrayWashTypeNames addObject:@"Curtains"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] containsString:SERVICETYPE_BAG])
        {
            [arrayWashTypeNames addObject:@"Bag"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] containsString:SERVICETYPE_SHOE_CLEAN])
        {
            [arrayWashTypeNames addObject:@"Shoe Cleaning"];
        }
        else if ([[json objectForKey:@"serviceTypesId"] containsString:SERVICETYPE_SHOE_POLISH])
        {
            [arrayWashTypeNames addObject:@"Shoe Polishing"];
        }
        
        NSInteger countOfBags = 0;
        
        for (int i=0; i<[arrayWashType count]; i++)
        {
            NSDictionary *dictBagType = [arrayWashType objectAtIndex:i];
            
            countOfBags += [dictBagType count];
        }
        
        bagDetailsTableView.frame = CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+10, cellBGimage.frame.size.width - 20, (50*countOfBags));
        cellBGimage.frame = CGRectMake(10, 5, screen_width-20, 50+(50*countOfBags));
        
        
        confirmBtn.enabled = NO;
        specialReqBtn.backgroundColor = SPECIAL_REQ_SELECTED_COLOR;
        
//        if ([[[[[[[json objectForKey:@"Load Wash"] objectForKey:@"WF"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"aer"] capitalizedString] isEqualToString:@"YES"])
//        {
//            confirmBtn.enabled = NO;
//            specialReqBtn.backgroundColor = SPECIAL_REQ_SELECTED_COLOR;
//        }
//        else
//        {
//            confirmBtn.enabled = YES;
//            specialReqBtn.backgroundColor = SPECIAL_REQ_NON_ACTIVE_COLOR;
//        }
        
        tagTextFeild.text = [NSString stringWithFormat:@"#%@", [[[json objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"BagNo"]];
        
        itemTypeLabel.text = [arrayWashTypeNames objectAtIndex:0];
        
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
    return 50.0;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20.0)];
//    titleLbl.backgroundColor = [UIColor clearColor];
//    titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
//    titleLbl.backgroundColor = [UIColor colorWithRed:231.0/255.0 green:231.0/255.0 blue:231.0/255.0 alpha:231.0/255.0];
//    titleLbl.text = [NSString stringWithFormat:@"   %@", [arrayWashTypeNames objectAtIndex:section]];
//    
//    return titleLbl;
//}


//-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 5.0;
//}


//-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 20;
//}


//-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 15.0)];
//    emptyView.backgroundColor = [UIColor clearColor];
//    
//    return emptyView;
//}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [arrayWashType count];
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[[arrayWashType objectAtIndex:section]allKeys]count];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"OrderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        
        UILabel *categoryLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, cellBGimage.frame.size.width-120, 20.0)];
        categoryLbl.tag = 10;
        categoryLbl.backgroundColor = [UIColor clearColor];
        categoryLbl.textColor = TEXT_LABEL_COLOR;
        categoryLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:15.0];
        [cell addSubview:categoryLbl];
        
        UILabel *countPriceDetailLbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 2+19, cellBGimage.frame.size.width-10, 16.0)];
        countPriceDetailLbl.tag = 11;
        countPriceDetailLbl.backgroundColor = [UIColor clearColor];
        countPriceDetailLbl.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0];
        countPriceDetailLbl.font = [UIFont fontWithName:APPFONT_LIGHT size:12.0];
        [cell addSubview:countPriceDetailLbl];
        
        UILabel *categoryPriceLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellBGimage.frame.size.width-155.0, 5.0, 100, 34.0)];
        categoryPriceLbl.tag = 12;
        categoryPriceLbl.backgroundColor = [UIColor clearColor];
        categoryPriceLbl.textAlignment = NSTextAlignmentRight;
        categoryPriceLbl.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0];
        categoryPriceLbl.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
        [cell addSubview:categoryPriceLbl];
        
        cell.clipsToBounds = NO;
    }
    
    UILabel *categoryLbl = (UILabel *)[cell viewWithTag:10];
    UILabel *countPriceDetailLbl = (UILabel *)[cell viewWithTag:11];
    UILabel *categoryPriceLbl = (UILabel *)[cell viewWithTag:12];
    
    
    NSArray *arr = [[arrayWashType objectAtIndex:indexPath.section] allKeys];
    
    NSArray *priceListArray = [[arrayWashType objectAtIndex:indexPath.section] objectForKey:[arr objectAtIndex:indexPath.row]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(itemType == %@) AND (selectedItem = %@)",[arr objectAtIndex:indexPath.row], @"Y"];
    NSArray *filterAry = [priceListArray filteredArrayUsingPredicate:predicate];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    if ([filterAry count])
    {
        if ([itemTypeLabel.text isEqualToString:@"Curtains"])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            categoryLbl.text = [NSString stringWithFormat:@"%@",[[filterAry objectAtIndex:0] objectForKey:@"itemName"]];
            
            if ([[[filterAry objectAtIndex:0] objectForKey:@"weight"] floatValue] == 0)
            {
                countPriceDetailLbl.text = [NSString stringWithFormat:@"%ld at $%.2f each",[filterAry count], [[[filterAry objectAtIndex:0] objectForKey:@"itemPrice"] floatValue]];
                categoryPriceLbl.text = [self calculateThePrice:filterAry];
            }
            else
            {
                countPriceDetailLbl.text = [NSString stringWithFormat:@"Number of kgs - %.2f", [[[filterAry objectAtIndex:0] objectForKey:@"weight"] floatValue]];
                
                categoryPriceLbl.text = [NSString stringWithFormat:@"$%.2f", [[[filterAry objectAtIndex:0] objectForKey:@"totalPrice"] floatValue] * [[[filterAry objectAtIndex:0] objectForKey:@"weight"] floatValue]];
            }
        }
        else
        {
            NSArray *arr = [[[filterAry objectAtIndex:0] objectForKey:@"itemName"] componentsSeparatedByString:@"^^"];
            
            NSString *strI = [arr objectAtIndex:0];
            
            categoryLbl.text = [NSString stringWithFormat:@"%@",strI];
            countPriceDetailLbl.text = [NSString stringWithFormat:@"%ld at $%.2f each",[filterAry count], [[[filterAry objectAtIndex:0] objectForKey:@"itemPrice"] floatValue]];
            categoryPriceLbl.text = [self calculateThePrice:filterAry];
        }
    }
    else
    {
        NSArray *arr = [[[priceListArray objectAtIndex:0] objectForKey:@"itemName"] componentsSeparatedByString:@"^^"];
        
        NSString *strI = [arr objectAtIndex:0];
        
        categoryLbl.text = [NSString stringWithFormat:@"%@",strI];
        countPriceDetailLbl.text = [NSString stringWithFormat:@"0 at $0.0 each"];
        categoryPriceLbl.text = [NSString stringWithFormat:@"$0.0"];
    }
    
    return cell;
}


#pragma mark UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([itemTypeLabel.text isEqualToString:@"Curtains"])
    {
        return;
    }
    
    if (!appDel.isPartialDelivery && !appDel.isRewash)
    {
        [AppDelegate showAlertWithMessage:@"Please select options, in that select partial or rewash." andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    NSArray *arr = [[arrayWashType objectAtIndex:indexPath.section] allKeys];
    
    NSArray *priceListArray = [[arrayWashType objectAtIndex:indexPath.section] objectForKey:[arr objectAtIndex:indexPath.row]];
    
    NSMutableArray *selectedItems = [[NSMutableArray alloc] init];
    
    [selectedItems addObjectsFromArray:priceListArray];
    
    UITableView *tblView;
    
    if ([self.superview isKindOfClass:[UITableView class]])
    {
        tblView = (UITableView *) self.superview;
    }
    else
    {
        tblView = (UITableView *) self.superview.superview;
    }
    
    JobdetailViewController *obj = (JobdetailViewController *) tblView.dataSource;
    
    ItemCollectionViewController *itemVC = [[ItemCollectionViewController alloc] init];
    itemVC.delegate = obj;
    itemVC.selecteItemisedArray = [[NSMutableArray alloc]initWithArray:selectedItems];
    [((UIViewController *)parentDel).navigationController pushViewController:itemVC animated:YES];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


-(NSString *) calculateThePrice:(id) categoryDetails
{
    float totalVal = 0.0;
    
    for (int i = 0; i < [categoryDetails count]; i++)
    {
        totalVal += [[[categoryDetails objectAtIndex:i] objectForKey:@"totalPrice"] floatValue];
    }
    
    return [NSString stringWithFormat:@"$%.2f",totalVal];
}

@end


