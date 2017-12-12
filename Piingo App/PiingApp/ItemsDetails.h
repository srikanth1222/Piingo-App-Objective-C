//
//  ItemsDetails.h
//  PiingApp
//
//  Created by SHASHANK on 27/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BagDetails;

@interface ItemsDetails : NSManagedObject

@property (nonatomic, retain) NSString * iTemDetailDic;
@property (nonatomic, retain) NSString * iTemCode;
@property (nonatomic, retain) NSNumber * iTemType;
@property (nonatomic, retain) NSNumber * itemUniqueID;
@property (nonatomic, retain) BagDetails *bag;

@end
