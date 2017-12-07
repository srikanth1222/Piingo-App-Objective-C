//
//  AddItemsViewController.h
//  Park View
//
//  Created by STI-HYD-30 on 09/03/15.
//  Copyright (c) 2015 Chris Wagner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddItemsViewController : UIViewController

@property (nonatomic, retain) id parentDel;
@property (nonatomic, readwrite) NSInteger indexVal;
@property (nonatomic, strong) NSDictionary *orderDetailDic;

@property (nonatomic, strong) NSMutableArray *arrayConformedItems;


//-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetails andCountDetails:(NSArray *) countArray;
-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2;
-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2 andDetails3:(NSArray *) countArray3;

@end
