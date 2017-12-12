//
//  CoreDataMethods.m
//  PiingApp
//
//  Created by SHASHANK on 15/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "CoreDataMethods.h"

static CoreDataMethods *sharedInstance = nil;

@implementation CoreDataMethods

+ (CoreDataMethods *)sharedInstance {
    
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

-(void) copyCoreDataDBintoDocumentsFolder
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];
}
-(Order *) isOIDAvalable:(NSString *) oid
{
    NSFetchRequest *fechReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Order" inManagedObjectContext:[appDelegate managedObjectContext]];
    [fechReq setEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"oid == %@",oid];
    [fechReq setPredicate:predicate];
    
    NSError *error1 = nil;
    NSArray *results = [[appDelegate managedObjectContext] executeFetchRequest:fechReq error:&error1];
    
    if ([results count] > 0)
    {
        return [results firstObject];
    }

    return nil;
}
-(NSNumber *) getBagUniqueCode;
{
    NSFetchRequest *fechReq = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"BagDetails" inManagedObjectContext:[appDelegate managedObjectContext]];
    [fechReq setEntity:entityDesc];
    
    NSSortDescriptor *sortDesc = [NSSortDescriptor sortDescriptorWithKey:@"bagID" ascending:NO];
    [fechReq setSortDescriptors:@[sortDesc]];
    
    NSError *error1 = nil;
    NSArray *results = [[appDelegate managedObjectContext] executeFetchRequest:fechReq error:&error1];
    
    if ([results count] > 0)
    {
        BagDetails *lastObj = [results firstObject];
        return [NSNumber numberWithInteger:[lastObj.bagID integerValue]+1];
    }

    
    return [NSNumber numberWithInteger:1];
}
#pragma mark Check the tag is alreadyExist
-(BOOL) checkTagisAlreadyExits:(Order *) orderObj andTagString:(NSString *) tagStr andManualTagString:(NSString *)manualTagStr
{
//    NSLog(@"%@",orderObj.bagsDetails);
    
    DLog(@"checkTagisAlreadyExits");
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:[orderObj.bagsDetails allObjects]];
    
    [array filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BagDetails *bagObj, NSDictionary *bindings) {
        return [bagObj.isBagConfirmed isEqualToNumber:[NSNumber numberWithBool:YES]];
    }]];
    
    [array filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BagDetails *bagObj, NSDictionary *bindings) {
        return [bagObj.bagTag isEqualToString:tagStr];
    }]];
    
    [array filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(BagDetails *bagObj, NSDictionary *bindings) {
        return [bagObj.manualBagTag isEqualToString:manualTagStr];
    }]];
    
    if ([array count] > 0)
        return YES;
    
    return NO;
}
@end
