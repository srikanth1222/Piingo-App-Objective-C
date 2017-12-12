//
//  ScheduleLaterViewController.h
//  Piing
//
//  Created by Piing on 10/23/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SevenSwitch;

@interface ScheduleLaterViewController1 : UIViewController


@property (nonatomic, retain) NSArray *userAddresses;
@property (nonatomic, retain) NSArray *userSavedCards;

@property (nonatomic, strong) NSMutableDictionary *dictUpdateOrder;

@property (nonatomic, strong) NSMutableDictionary *dictChangedValues;

@property (nonatomic, assign) BOOL isFromCreateOrder;

@property (nonatomic, assign) BOOL isRewashOrder;
@property (nonatomic, strong) NSMutableArray *arrayRewashItems;

@property (nonatomic, strong) NSMutableDictionary *dictAllowFields;
@property (nonatomic, strong) NSMutableArray *arrayJobTypeOrg;

@property (nonatomic, assign) BOOL isDeliveryOrder;

@end
