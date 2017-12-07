//
//  OrderTableViewCell.m
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "OrderTableViewCell.h"
#import "NSNull+JSON.h"

@implementation OrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.jobType.layer.borderColor = [UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0].CGColor;
    self.jobType.layer.cornerRadius = self.jobType.frame.size.height/2;
    self.jobType.layer.borderWidth = 1.0;
    self.jobType.clipsToBounds = YES;
    
    self.Notes.layer.cornerRadius = 3.0;
    self.Notes.clipsToBounds = YES;
    
    self.isVIPuseLabel.layer.cornerRadius = 3.0;
    self.isVIPuseLabel.clipsToBounds = YES;
    
    self.isNewUserLabel.layer.cornerRadius = 3.0;
    self.isNewUserLabel.clipsToBounds = YES;
}

-(void) setDetials:(id) details
{
    self.orderedName.text = [details objectForKey:@"n"];
    self.orderAddress.text = [details objectForKey:@"a"];
    if ([[details objectForKey:@"jt"] isEqualToString:@"Pickup"])
    {
        self.jobType.text = @"P";
    }
    else
    {
        self.jobType.text = @"D";
    }
    
    if ([[details objectForKey:@"ct"] isEqualToString:@"vip"])
    {
        self.isVIPuseLabel.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:221.0/255.0 blue:145.0/255.0 alpha:1.0];
    }
    else
    {
        self.isNewUserLabel.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:221.0/255.0 blue:145.0/255.0 alpha:1.0];
    }
    self.orderTime.text = [details objectForKey:@"ep"];
    self.orderStatus.text = [details objectForKey:@"os"];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
