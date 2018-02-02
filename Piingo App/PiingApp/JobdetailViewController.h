//
//  JobdetailViewController.h
//  PiingApp
//
//  Created by SHASHANK on 04/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import <NMAKit/NMAKit.h>
#import "HSDNavigationManeuverView.h"


typedef NS_ENUM(NSUInteger, HSDNavigationState){
    HSDNavigationStateNavigation, //real time navigation
    HSDNavigationStateSimulation, //navigation simulation
    HSDNavigationStateTracking //guidance tracking
};

@interface JobdetailViewController : UIViewController
{
    UIButton *btnCloseMapView;
    UIButton *btnPhone;

    UIScrollView *mainScrollView;
    
    NSMutableArray *userAddresses;
    NSMutableArray *userSavedCards;
}

@property (nonatomic, strong) NSMutableDictionary *dictUpdatable;

@property (nonatomic, strong) NSMutableDictionary *orderDetailDic;

@property (nonatomic, strong) NSString *customerLatitude;
@property (nonatomic, strong) NSString *customerLongitude;


@property (nonatomic, strong) NSString *strTaskStatus;
@property (nonatomic, strong) NSString *strTaskId;
@property (nonatomic, strong) NSString *strUserName;
@property (nonatomic, strong) NSString *strPaymentId;
@property (nonatomic, strong) NSString *strDirection;

//@property(nonatomic, weak) NMAMapView* mapView;
//@property(nonatomic,strong) NMAMapRoute* mapRoute;
//@property(nonatomic,strong) NMARoute* route;
@property(nonatomic, weak) HSDNavigationManeuverView* maneuverView;
@property(nonatomic,strong) UIBarButtonItem* navigateBtn;
@property(nonatomic,assign) HSDNavigationState status;
//@property(nonatomic,strong) NMACoreRouter *router;

@property (nonatomic, assign) BOOL isFromCreateOrder;

@property (nonatomic, assign) BOOL userInteractionEnabled;

@property (nonatomic,strong) NSMutableArray *arrayBagTags;

//-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetails andCountDetails:(NSArray *) countArray;
-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2;
-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2 andDetails3:(NSArray *) countArray3;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andIscurrentOrder:(NSInteger) index;

-(void) updatedOrderAndRefresh;



-(void) addItemDetails:(NSMutableDictionary *) dictAllTypes;




@end
