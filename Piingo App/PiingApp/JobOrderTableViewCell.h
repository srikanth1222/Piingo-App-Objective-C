//
//  JobOrderTableViewCell.h
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobOrderTableViewCell : UITableViewCell
{
    UILabel *orderTypeLbl; // P or D
    UILabel *orderReqTypeLbl; // R or E (Regular or express)
    UILabel *orderPersonNameLbl;
    UILabel *orderAddressLbl;
    
    UIButton *isNotesAvailbelBtn;
    UIButton *isVipUserBtn;
    UIButton *isNewUserBtn;
    
    UIButton *statusBtn;
    
    UILabel *lblDate;
    UILabel *lblBookBow;
    UILabel *lblPaymentType;
    
    UILabel *lblOrderId;
    
    NSMutableDictionary *dictData;
    
    UIView *viewBG;
    NSDictionary *dictBill;
    
    UIImageView *cellBg;
    
    UIButton *btnI;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) delegate;
-(void) setDetails:(id) details withCurrentIndex:(NSInteger) index;

@end
