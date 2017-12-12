//
//  CustomPopoverView.m
//  Piing
//
//  Created by Veedepu Srikanth on 19/12/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import "CustomPopoverView.h"
#import <CardIO.h>
#import "EGOImageView.h"


@implementation CustomPopoverView
{
    AppDelegate *appDel;
    
    NSInteger selectedIndexPathRow;
}

@synthesize tblPopover;

#pragma mark - Table view data source

-(void) createTableView
{
    appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    self.backgroundColor = [UIColor whiteColor];
    
    tblPopover = [[UITableView alloc]init];
    tblPopover.backgroundColor = [UIColor clearColor];
    tblPopover.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tblPopover.delegate = self;
    tblPopover.contentInset = UIEdgeInsetsMake(8*MULTIPLYHEIGHT, 0, 40*MULTIPLYHEIGHT, 0);
    tblPopover.dataSource = self;
    [self addSubview:tblPopover];
    tblPopover.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(dismissPopoverView:)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];
    
}

-(id) initWithArray:(NSArray *)arrayData IsAddressType:(BOOL) isAddressType
{
    if (self == [super init])
    {
        self.isAddressSelected = isAddressType;
        self.arrayList = [[NSMutableArray alloc]initWithArray:arrayData];
        
        [self createTableView];
    }
    
    return self;
}

-(id) initWithArray:(NSArray *)arrayData IsPaymentType:(BOOL) isPaymentType
{
    if (self == [super init])
    {
        self.isPaymentSelected = isPaymentType;
        self.arrayList = [[NSMutableArray alloc]initWithArray:arrayData];
        
        [self createTableView];
    }
    
    return self;
}


-(id) initWithArray:(NSArray *)arrayData SelectedRow:(NSInteger)row
{
    if (self == [super init])
    {
        selectedIndexPathRow = row;
        self.arrayList = [[NSMutableArray alloc]initWithArray:arrayData];
        
        [self createTableView];
    }
    
    return self;
}

-(id) initWithArray:(NSArray *)arrayData
{
    if (self == [super init])
    {
        self.arrayList = [[NSMutableArray alloc]initWithArray:arrayData];
        
        [self createTableView];
    }
    
    return self;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:tblPopover]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

-(void)dismissPopoverView:(UIGestureRecognizer *)gestureRecognizer {
    
    UIEvent *event = [[UIEvent alloc] init];
    CGPoint location = [gestureRecognizer locationInView:self];
    
    //check actually view you hit via hitTest
    UIView *view = [self hitTest:location withEvent:event];
    
    if ([view.gestureRecognizers containsObject:gestureRecognizer]) {
        
        //your UIView
        //do something'
        
        if ([self.delegate respondsToSelector:@selector(closeCustomPopover)])
        {
            [self.delegate closeCustomPopover];
        }
    }
    else if (![tblPopover indexPathForRowAtPoint:location])
    {
        if ([self.delegate respondsToSelector:@selector(closeCustomPopover)])
        {
            [self.delegate closeCustomPopover];
        }
    }
    else
    {
        
    }
}


-(id) initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        CGRect tblFrame = frame;
        tblFrame.origin.y = 0;
        tblPopover.frame = tblFrame;
    }
    
    return self;
}

-(void) reloadPopOverViewWithTag:(int) tag
{
    if (tag == 1)
    {
        tblPopover.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
        
        [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:0 animations:^{
            
            tblPopover.frame = self.bounds;
            
        } completion:^(BOOL finished) {
            
            
        }];
        
    }
    else if (tag == 2)
    {
        
        [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:0 animations:^{
            
            tblPopover.frame = CGRectMake(0, self.frame.size.height, self.frame.size.width, self.frame.size.height);
            
        } completion:^(BOOL finished) {
            
            
        }];
        
    }
}


-(NSString *) setTitleForAddress:(NSIndexPath *)indexPath
{
    NSMutableString *str = [[NSMutableString alloc]init];
    
    NSDictionary *selectedAddressDic = [self.arrayList objectAtIndex:indexPath.row];
    
    if ([[selectedAddressDic objectForKey:@"name"]length])
    {
        [str appendString:[selectedAddressDic objectForKey:@"name"]];
    }
    
    if ([[selectedAddressDic objectForKey:@"line1"]length] > 1)
    {
        [str appendString:[NSString stringWithFormat:@", %@", [selectedAddressDic objectForKey:@"line1"]]];
    }
    else if ([[selectedAddressDic objectForKey:@"line2"]length])
    {
        [str appendString:[NSString stringWithFormat:@", %@", [selectedAddressDic objectForKey:@"line2"]]];
    }
    
    if ([[selectedAddressDic objectForKey:@"zipcode"]length])
    {
        [str appendString:[NSString stringWithFormat:@", %@", [selectedAddressDic objectForKey:@"zipcode"]]];
    }
    
    return str;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayList count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat bgHeight = 33*MULTIPLYHEIGHT;
    return bgHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        CGFloat bgHeight = 33*MULTIPLYHEIGHT;
        
        UILabel *lblText = [[UILabel alloc]init];
        lblText.tag = 10;
        float lblX = 7*MULTIPLYHEIGHT;
        lblText.textAlignment = NSTextAlignmentCenter;
        lblText.frame = CGRectMake(lblX, 0, self.frame.size.width-(lblX*2), bgHeight);
        lblText.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        [cell.contentView addSubview:lblText];
        
        
        float imgCX = 15*MULTIPLYHEIGHT;
        float imgCWidth = 22*MULTIPLYHEIGHT;
        
        EGOImageView *imgCard = [[EGOImageView alloc]initWithFrame:CGRectMake(imgCX, 0, imgCWidth, bgHeight)];
        imgCard.contentMode = UIViewContentModeScaleAspectFit;
        imgCard.tag = 11;
        [cell.contentView addSubview:imgCard];
        
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    
    UILabel *lblText = (UILabel *) [cell.contentView viewWithTag:10];
    EGOImageView *imgCard = (EGOImageView *) [cell.contentView viewWithTag:11];
    
    if (self.textColor)
    {
        lblText.textColor = self.textColor;
    }
    else
    {
        lblText.textColor = [UIColor blackColor];
    }
    
    NSString *strAddr = @"";
    
    if (self.isAddressSelected)
    {
        strAddr = [self setTitleForAddress:indexPath];
    }
    else if (self.isPaymentSelected)
    {
        strAddr = [[self.arrayList objectAtIndex:indexPath.row] objectForKey:@"maskedCardNo"];
        
        if ([[self.arrayList objectAtIndex:indexPath.row] objectForKey:@"cardTypeImage"])
        {
            imgCard.imageURL = [NSURL URLWithString:[[self.arrayList objectAtIndex:indexPath.row] objectForKey:@"cardTypeImage"]];
        }
        else
        {
            imgCard.image = [UIImage imageNamed:@"cash_icon"];
        }
    }
    else
    {
        strAddr = [self.arrayList objectAtIndex:indexPath.row];
        
        if (selectedIndexPathRow == indexPath.row)
        {
            lblText.textColor = BLUE_COLOR;
        }
    }
    
    lblText.text = strAddr;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.preservesSuperviewLayoutMargins = NO;
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.delegate respondsToSelector:@selector(didSelectFromList:AtIndex:)])
    {
        NSString *strAddr;
        
        if (self.isAddressSelected)
        {
            strAddr = [self setTitleForAddress:indexPath];
        }
        else if (self.isPaymentSelected)
        {
            strAddr = [[self.arrayList objectAtIndex:indexPath.row] objectForKey:@"maskednumber"];
        }
        else
        {
            strAddr = [self.arrayList objectAtIndex:indexPath.row];
        }
        
        [self.delegate didSelectFromList:strAddr AtIndex:indexPath.row];
    }
}



@end
