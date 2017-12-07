//
//  BagDetails.h
//  PiingApp
//
//  Created by SHASHANK on 27/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ItemsDetails, Order;

@interface BagDetails : NSManagedObject

@property (nonatomic, retain) NSNumber * bagType;
@property (nonatomic, retain) NSNumber * bagID;
@property (nonatomic, retain) NSString * bagTag;
@property (nonatomic, strong) NSString * manualBagTag;
@property (nonatomic, retain) NSNumber * isBagConfirmed;
@property (nonatomic, retain) NSString * bagDetailDic;
@property (nonatomic, retain) NSString * totalAmountOfBag;

@property (nonatomic, retain) NSNumber * isBagDeleted;
@property (nonatomic, retain) NSSet *items;
@property (nonatomic, retain) Order *order;

@end

@interface BagDetails (CoreDataGeneratedAccessors)

- (void)addItemsObject:(ItemsDetails *)value;
- (void)removeItemsObject:(ItemsDetails *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
