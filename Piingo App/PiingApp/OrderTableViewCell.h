//
//  OrderTableViewCell.h
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *orderTime;
@property (weak, nonatomic) IBOutlet UILabel *orderedName;
@property (weak, nonatomic) IBOutlet UILabel *orderAddress;
@property (weak, nonatomic) IBOutlet UILabel *isNewUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *isVIPuseLabel;
@property (weak, nonatomic) IBOutlet UILabel *jobType;
@property (weak, nonatomic) IBOutlet UILabel *Notes;
@property (weak, nonatomic) IBOutlet UILabel *orderStatus;


-(void) setDetials:(id) details;
@end
