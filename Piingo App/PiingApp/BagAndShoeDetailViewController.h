//
//  BagAndShoeDetailViewController.h
//  PiingApp
//
//  Created by Veedepu Srikanth on 21/06/17.
//  Copyright © 2017 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BagAndShoeDetailViewControllerDelegate <NSObject>

-(void) didAddBagsAndShoes:(NSMutableDictionary *) dictItems;

@end


@interface BagAndShoeDetailViewController : UIViewController

@property (nonatomic, strong) id <BagAndShoeDetailViewControllerDelegate> delegate;

@property (nonatomic, assign) NSInteger countOfItems;
@property (nonatomic, strong) NSString *strServiceType;
@property (nonatomic, strong) NSString *strServiceTypeName;
@property (nonatomic, strong) NSMutableArray *arrayShoeServicetype;
@property (nonatomic, strong) NSMutableArray *arrayShoeServicetypeName;
@property (nonatomic, strong) NSString *strOrderType;

@property (nonatomic, strong) NSMutableArray *arrayCategories;

@end
