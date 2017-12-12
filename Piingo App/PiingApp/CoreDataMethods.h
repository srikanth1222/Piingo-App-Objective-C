//
//  CoreDataMethods.h
//  PiingApp
//
//  Created by SHASHANK on 15/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Order.h"

@interface CoreDataMethods : NSObject
{
    AppDelegate *appDelegate;
}
+ (id)sharedInstance;
-(void) copyCoreDataDBintoDocumentsFolder;
-(Order *) isOIDAvalable:(NSString *) oid;
-(NSNumber *) getBagUniqueCode;

-(BOOL) checkTagisAlreadyExits:(Order *) orderObj andTagString:(NSString *) tagStr andManualTagString:(NSString *) manualTagStr;
@end
