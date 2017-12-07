//
//  ItemCollectionViewController.h
//  PiingApp
//
//  Created by SHASHANK on 25/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemCollectionViewControllerDelegate <NSObject>

@optional

-(void) didUpdateToPartialDelivery:(NSArray *)arrayItems;

@end


@interface ItemCollectionViewController : UIViewController

@property (nonatomic, strong) id <ItemCollectionViewControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *selecteItemisedArray;


@end
