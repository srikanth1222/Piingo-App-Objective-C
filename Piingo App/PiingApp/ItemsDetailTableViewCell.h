//
//  ItemsDetailTableViewCell.h
//  PiingApp
//
//  Created by SHASHANK on 16/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemsDetailTableViewCell : UITableViewCell <UITextFieldDelegate>
{
    UILabel *itemTypeLabel;
    UIButton *confirmBtn, *specialReqBtn;
    BagDetails *selectedItemObj;
    
    UITextField *tagTextFeild, *strainCountTxt, *strachCountTxt, *manualTagTextFeild;
    
    AppDelegate *appDel;
    
    UIView *specilRequestView;
    id parentDel;
    
    UIImageView *cellBGimage;
    UIImageView *txtBGImgView;
    
    UIImageView *txtManualTagBGImgView;
    
    UIButton *deleteBtn;
    
    NSCharacterSet *blockedCharacters;
    
    UILabel *titleLbl;
}

@property (nonatomic, strong) NSMutableDictionary *orderInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) parentDelegate;
-(void) setDetials:(ItemsDetails *) itemDetailObj;

@end
