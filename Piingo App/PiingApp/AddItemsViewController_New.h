//
//  AddItemsViewController_New.h
//  PiingApp
//
//  Created by Veedepu Srikanth on 17/06/16.
//  Copyright © 2016 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddItemsViewController_New : UIViewController

@property (nonatomic, retain) id parentDel;
@property (nonatomic, strong) NSDictionary *orderDetailDic;

-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2 andDetails3:(NSArray *) countArray3;

-(void) addItemDetails:(NSMutableDictionary *)dict;

@end
