//
//  EditItemsViewController.h
//  PiingApp
//
//  Created by SHASHANK on 28/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditItemsViewController : UIViewController

@property (nonatomic, retain) id parentDel;
@property (nonatomic, readwrite) NSInteger indexVal;
@property (nonatomic, strong) NSDictionary *orderDetailDic;

@property (nonatomic, strong) BagDetails *selectedBag;

-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2;


@end
