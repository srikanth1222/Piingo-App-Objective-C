//
//  DeliveryViewController.h
//  Piing
//
//  Created by Piing on 10/24/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DeliveryViewController1 : UIViewController

@property(nonatomic, retain) NSMutableDictionary *orderInfo;

@property (nonatomic, retain) NSMutableArray *userAddresses;

@property (nonatomic, retain) NSMutableArray *userSavedCards;

@property (nonatomic, retain) NSArray *deliverySlots;
@property (nonatomic, strong) NSMutableDictionary *dictChangedValues;
@property (nonatomic, strong) NSMutableDictionary *dictAllowFields;

@property (nonatomic, assign) BOOL isFromCreateOrder;

@property (nonatomic, assign) BOOL isRewashOrder;
@property (nonatomic, strong) NSMutableArray *arrayRewashItems;

@property (nonatomic, assign) BOOL isDeliveryOrder;

@property (nonatomic, strong) NSMutableDictionary *arrayAllOrderDetails;

@end
