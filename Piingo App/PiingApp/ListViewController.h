//
//  ListViewController.h
//  Piing
//
//  Created by Piing on 11/7/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListView.h"


@interface ListViewController : UIViewController

@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSArray *itemList;
@property (nonatomic, retain) NSString *isFrom;
@property (nonatomic, retain) NSString *selectedItem;
@end
