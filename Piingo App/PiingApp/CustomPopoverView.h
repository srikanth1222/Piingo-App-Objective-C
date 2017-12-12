//
//  CustomPopoverView.h
//  Piing
//
//  Created by Veedepu Srikanth on 19/12/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>



@protocol  CustomPopoverViewDelegate <NSObject>

@optional

-(void) didSelectFromList:(NSString *) string AtIndex:(NSInteger) row;
-(void) closeCustomPopover;

@end

@interface CustomPopoverView : UIView <UITableViewDataSource, UITableViewDelegate>
{
    
}

@property (nonatomic, assign) int isFromTag;

@property (nonatomic, strong) UITableView *tblPopover;

@property(nonatomic,strong) id <CustomPopoverViewDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *arrayList;
@property (nonatomic, assign) BOOL isAddressSelected;
@property (nonatomic, assign) BOOL isPaymentSelected;

@property (nonatomic, strong) UIColor *textColor;

-(id) initWithArray:(NSArray *)arrayData IsAddressType:(BOOL) isAddressType;
-(id) initWithArray:(NSArray *)arrayData IsPaymentType:(BOOL) isPaymentType;
//-(id) initWithArray:(NSArray *)arrayData;
-(id) initWithArray:(NSArray *)arrayData SelectedRow:(NSInteger) row;
-(id) initWithArray:(NSArray *)arrayData;

-(void) reloadPopOverViewWithTag:(int) tag;

@end


