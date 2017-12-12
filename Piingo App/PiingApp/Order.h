//
//  Order.h
//  PiingApp
//
//  Created by SHASHANK on 27/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BagDetails;

@interface Order : NSManagedObject

@property (nonatomic, retain) NSString * oid;
@property (nonatomic, retain) NSNumber * isOrderConformed;
@property (nonatomic, retain) NSString * orderID;
@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSSet *bagsDetails;

@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSString * starchCount;
@property (nonatomic, retain) NSString * stainCount;
@property (nonatomic, retain) NSString *starch;
@property (nonatomic, retain) NSString *stain;
@property (nonatomic, retain) NSString *folded;
@property (nonatomic, retain) NSString *hanger;
@property (nonatomic, retain) NSString *cliphanger;
@property (nonatomic, retain) NSString *starchType;
@property (nonatomic, retain) NSString *crease;


@end

@interface Order (CoreDataGeneratedAccessors)

- (void)addBagsDetailsObject:(BagDetails *)value;
- (void)removeBagsDetailsObject:(BagDetails *)value;
- (void)addBagsDetails:(NSSet *)values;
- (void)removeBagsDetails:(NSSet *)values;

@end
