//
//  ListView.h
//  Piing
//
//  Created by Piing on 10/25/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Item : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, readwrite) BOOL isSelected;

@end

#define PICK_DELIVERY_DATE @"PICK DELIVERY DATE"
#define PICK_DELIVERY_TIME @"PICK DELIVERY TIME"
#define PICK_PICK_UP_DATE @"PICK PICK-UP DATE"
#define PICK_PICK_UP_TIME @"PICK PICK-UP TIME"
#define FREQUENCY_TYPE @"FREQUENCY TYPE"

@interface ListView : UIView

@property (nonatomic, retain) NSArray *items;
@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) NSString *isFrom;
@property (nonatomic, retain) NSString *selectedItem;

- (id)initWithFrame:(CGRect)frame andDisplayList:(NSArray *)list;

@end
