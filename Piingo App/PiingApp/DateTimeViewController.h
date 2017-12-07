//
//  DateTimeViewController.h
//  Piing
//
//  Created by Veedepu Srikanth on 16/09/16.
//  Copyright © 2016 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateTimeViewControllerDelegate <NSObject>

-(void) didSelectDateAndTime:(NSArray *) array;

@end

@interface DateTimeViewController : UIViewController

@property (nonatomic, strong) id <DateTimeViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableDictionary *dictDatesAndTimes;

@property (nonatomic, strong) NSMutableArray *arrayDates;
@property (nonatomic, strong) NSMutableArray *arrayTimes;
@property (nonatomic, strong) NSMutableDictionary *orderInfo;
@property (nonatomic, strong) NSMutableDictionary *selectedAddress;

@property (nonatomic, strong) NSString *selectedDate;
@property (nonatomic, strong) NSString *strColocated;
@property (nonatomic, strong) NSString *strSelectedTimeSlot;

@property (nonatomic, strong) NSMutableDictionary *dictAllowFields;
@property (nonatomic, assign) BOOL isFromUpdateOrder;

@property (nonatomic, assign) BOOL isFromDelivery;
@property (nonatomic, assign) BOOL isFromRecurring;

@property (nonatomic, assign) BOOL isFromBookNow;


@end



