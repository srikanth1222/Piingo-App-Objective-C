//
//  AppDelegate.h
//  PiingApp
//
//  Created by SHASHANK on 02/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "CustomLoaderView.h"
#import "RESideMenu.h"
#import "PiingApp-Swift.h"
#import "LocationTracker.h"
#import "MBProgressHUD.h"
#import "GoogleMapView2.h"
#import "JobOrdersViewController.h"



@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, assign) CGFloat FONT_SIZE_CUSTOM;
@property (nonatomic, assign) CGFloat HEADER_LABEL_FONT_SIZE;

@property (nonatomic, assign) BOOL isPickupCompletedForCreatedOrder;

@property (nonatomic, strong) JobOrdersViewController *jobOrdersList;

@property (nonatomic, strong) NSString *strDeviceToken;

@property (nonatomic, assign) BOOL isBookNowPending;

@property (nonatomic, strong) MBProgressHUD *HUD;

@property (nonatomic, strong) GoogleMapView2 *piingo_GoogleMap;

@property (nonatomic, strong) NSMutableDictionary *dict_UserLocation;

@property (nonatomic, strong) UISwitch *checkInSwitch;

@property (nonatomic, strong) NSString *UUID;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) SocketIOClient* socketIO;
@property (nonatomic, assign) BOOL isFirstTimeConnected;

@property (nonatomic, strong) NSMutableDictionary *dictEachSegmentCount;

@property (nonatomic, assign) BOOL isPartialDelivery, isRewash;

@property (nonatomic, strong) NSMutableDictionary *dictPriceImages;
@property (nonatomic, strong) NSMutableDictionary *dictPriceSelectedImages;


@property (nonatomic, assign) NSInteger totalBags;
@property (nonatomic, assign) NSInteger scannedBagsCount;
@property (nonatomic, strong) NSMutableDictionary *dictScannedBags;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;

@property (nonatomic, assign) CLLocationDirection vehicle_direction;

@property (nonatomic, assign) CGFloat xValue;
@property (nonatomic, assign) CGFloat yValue;
@property (nonatomic, assign) CGFloat zValue;

@property (nonatomic, strong) LocationTracker * locationTracker;
@property (nonatomic, strong) NSTimer* locationUpdateTimer;

@property (nonatomic, strong) NSString *strCobId;

-(void) showLoader;
-(void)hideLoader;

-(void) piingoLogout;
-(void) setRootVC;
-(void) smsSupportClicked;
-(void) callSupportMethodClicked;

+ (NSString *)GetUUID;
-(void) checkCheckinStatus;

- (RESideMenu *)sideMenuViewController;
-(void) connectPiingobWhenLogin;

-(void)displayErrorMessagErrorResponse:(NSDictionary *)response;

-(void) refreshGoogleMapsDirections;
+ (UIImage *)imageWithColor:(UIColor *)color;

-(void) applyBlurEffectForView:(UIView *)vieww Style:(NSString *)style;
-(void) spacingForTitle:(UILabel *)lblTitle TitleString:(NSString *)strTitle;
-(void) applyCustomBlurEffetForView:(UIView *) view WithBlurRadius:(float)radius;

+(BOOL) validateTextFieldWithText :(NSString*)text With:(NSString*)validateText;


+(CGFloat) getLabelHeightForBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;
+(CGFloat) getLabelHeightForSemiBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;
+(CGFloat) getLabelHeightForMediumText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;
+(CGFloat) getLabelHeightForRegularText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;

+(CGSize) getLabelSizeForSemiBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;
+(CGSize) getLabelSizeForBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;
+(CGSize) getLabelSizeForRegularText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;
+(CGSize) getLabelSizeForMediumText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize;

+(CGSize) getAttributedTextHeightForText:(NSMutableAttributedString *)strText WithWidth:(CGFloat)width;

+ (void)showAlertWithMessage:(NSString *)msg andTitle:(NSString *)title andBtnTitle:(NSString *)btnTitle;

@end

