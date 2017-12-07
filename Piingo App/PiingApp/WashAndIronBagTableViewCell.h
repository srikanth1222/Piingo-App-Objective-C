//
//  WashAndIronBagTableViewCell.h
//  PiingApp
//
//  Created by SHASHANK on 23/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WashAndIronBagTableViewCell : UITableViewCell <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UILabel *itemTypeLabel;
    UIButton *confirmBtn, *specialReqBtn;
    id parentDel;
    
    AppDelegate *appDel;
    
    UITextField *tagTextFeild;
    
    UIImageView *cellBGimage;
        
    id bagDetails;
    
    UITableView *bagDetailsTableView;
    
    long int selectedIndex;
    
    NSMutableArray *arrayWashType;
    NSMutableArray *arrayWashTypeNames;    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) delegate;
-(void) setDetials:(id) itemDetailObj;

@end
