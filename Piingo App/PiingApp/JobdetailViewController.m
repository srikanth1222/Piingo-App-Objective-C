//
//  JobdetailViewController.m
//  PiingApp
//
//  Created by SHASHANK on 04/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "JobdetailViewController.h"
#import "CustomSegmentControl.h"
#import "AddItemsViewController.h"
#import <MapKit/MapKit.h>

#import "ItemsDetailTableViewCell.h"
#import "GoogleMapView2.h"

#import "WashAndFoldBagTableViewCell.h"
#import "WashAndIronBagTableViewCell.h"

#import "UpdatePaymentOrderViewController.h"
#import "UIButton+Position.h"
#import "ScheduleLaterViewController1.h"
#import "OpenInGoogleMapsController.h"
#import "WNFTableViewCell.h"
#import "WNITableViewCell.h"

#import "AddItemsViewController_New.h"
#import "PPSSignatureView.h"
#import "CustomPopoverView.h"
#import "NSData+Base64.h"
#import "PreferencesViewController.h"
#import "HMSegmentedControl.h"
#import "NSNull+JSON.h"
#import "ScanController.h"
#import "ScanViewController.h"




#define CANCEL_ORDER_BTN_TAG 11
#define DOOR_LOCKED_ORDER_BTN_TAG 18


#define AFTER_ORDER_CONFORMED 17


static const NSTimeInterval routingTimeLimit = 300;
static const NSTimeInterval timeIncrement = 1;

static NSString * const kOpenInMapsSampleURLScheme = @"OpenInGoogleMapsSample://";



@interface JobdetailViewController () <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIAlertViewDelegate, CustomPopoverViewDelegate, PreferencesViewControllerDelegate, HMSegmentedControlDelegate, UpdatePaymentOrderViewControllerDelegate, UITextFieldDelegate, UITextViewDelegate, ScanControllerDelegate, ScanViewControllerDelegate>
{
    
    UIView *viewMap;
    
    NSMutableArray *itemDetailArray, *itemsArray;
    UITableView *itemDetailsTableView;
    UIView *jobDetailsView, *itemDetailsView;
    
    UIView *fullJobDetailView;
    
    //Job detail items
    UILabel *orderPersonNameLbl, *addressLbl, *orderTypeLbl;
    MKMapView *myMapView;
    
    UIButton *statusDisplayButton, *directionBtn, *callBtn;
    UIButton *dismissViewBtn;
    
    AppDelegate *appDel;
    
    UIButton *isVipUserImg;
    Order *orderObj;
    
    UIButton *addBtn;
    
    UILabel *totalAmount;
    UILabel *reconcileTitleLbl;
    
    UIButton *conformOrderBtn;
    UIButton *doorLockedBtn;
    UIButton *cancelOrderBtn;
    
    NSMutableArray *deliveryDetaildArray, *deliveryPartialArray;
    
    UIImageView *paymentTypeImg;
    
    BOOL enableAllAction;
    CustomSegmentControl *segmentC;
    UIBarButtonItem *phone_BarButton;
    UIBarButtonItem *back_BarButton;
    
    UIView *washTypesView, *deliveryDetailsView;
    
    UIView *progressView_Blue, *progressView_Grey;
    UILabel *LblDaysToDeliver;
    
    UIButton *addressBtn;
    
    UILabel *lblPromocode;
    
    UIView *view_Popup, *view_Tourist;
    
    UIButton *backBtn;
    UIButton *btnNanv;
    
    UIScrollView *whiteBG;
    
    UIButton *editbutton;
    
    NSMutableArray *arrayPriceList;
    BOOL _routingInProgress;
    
    NSMutableArray *arrayReason;
    UITableView *tblResons;
    
    UIView *mainView_Reasons;
    
    int selectedIndex;
    
    int ReasonId;
    
    NSString *strReasonName;
    
    UIView *view_Custom;
    PPSSignatureView *signatureView;
    
    NSString *strOSType;
    
    UIView *view_Popover;
    
    CustomPopoverView *customPopOverView;
    
    UITextField *tempTf;
    BOOL isEditable;

    BOOL automaticStartOrder;
    
    CLRegion *bridge;
    
    UILabel *lblDiscountAmount;
    
    UILabel *lblWalletText, *lblWalletAmount;
    UILabel *lblGSTAmountText, *lblGSTAmountValue;
    
    UIButton *btnPrefs, *btnOptions, *btnStartScan;
    UIScrollView *scrollViewWashType;
    
    HMSegmentedControl *segmentCleaning;
    
    NSDictionary *dictJobTypes;
    
    NSDictionary *dictPickupAddress;
    NSDictionary *dictDeliveryAddress;
    
    NSDictionary *dictAddress;
    
    NSDictionary *selectedCardDict;
    UIImageView *totalAmountView;
    
    NSMutableArray *arrayUndeliveredItems, *arrayRewashItems;
    
    NSString *strBilldId;
    
    UIButton *confirmWOPayment;
    
    UIButton *confirmOrderWithoutBags;
    
    UIButton *btnSpecialCare;
    
    UITextView *tvSpecialCare, *tvPaymentNotes;
    
    NSMutableArray *arrayCustomizedData;
}

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSMutableDictionary *orderInfo;
@property (nonatomic, strong) NSArray *deliveryDates;
@property (nonatomic, strong) NSArray *deliverySlots;


@end

@implementation JobdetailViewController
@synthesize orderDetailDic;


-(void) gotoBack
{
    [self.locationManager stopMonitoringForRegion:bridge];
    self.locationManager = nil;
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andIscurrentOrder:(NSInteger) index
{
    self = [super init];
    if (self) {
        
        if (index > 0 )
            enableAllAction = YES;//Fot testing to acces any order make 'YES'
        else
            enableAllAction = YES;
    }
    return self;
}

-(void) getAddress
{
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *verificationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"uid"], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/address/get", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:verificationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            if ([[responseObj objectForKey:@"addresses"] count] == 0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"There are no address in your address book please add at least one address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                return;
            }
            
            userAddresses = [responseObj objectForKey:@"addresses"];
            
            [self getCards];
            
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}


-(void) getCards
{
    NSMutableDictionary *verificationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"uid"], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/payment/getallpaymentmethods", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:verificationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            NSDictionary *dict = [responseObj objectForKey:@"paymentMethod"];
            
            NSMutableArray *arrayCards = [[NSMutableArray alloc]init];
            
            NSDictionary *dictCash = nil;
            
            if ([[[dict objectForKey:@"cash"] objectForKey:@"default"]intValue] == 1)
            {
                dictCash = [NSDictionary dictionaryWithObjectsAndKeys:@"CASH ON DELIVERY", @"maskedCardNo", @"Cash", @"_id", @"1", @"default", nil];
            }
            else
            {
                dictCash = [NSDictionary dictionaryWithObjectsAndKeys:@"CASH ON DELIVERY", @"maskedCardNo", @"Cash", @"_id", @"0", @"default", nil];
            }
            
            [arrayCards addObject:dictCash];
            
            if ([[[dict objectForKey:@"card"] objectForKey:@"cardList"] count])
            {
                [arrayCards addObjectsFromArray:[[dict objectForKey:@"card"] objectForKey:@"cardList"]];
            }
            
            [userSavedCards addObjectsFromArray:arrayCards];
            
            [self loadOrderDetails];
        }
        else {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.userInteractionEnabled = self.userInteractionEnabled;
    
    //self.view.userInteractionEnabled = YES;
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    appDel.isPartialDelivery = NO;
    appDel.isRewash = NO;
    
    arrayPriceList = [[NSMutableArray alloc]init];
    arrayCustomizedData = [[NSMutableArray alloc]init];
    
    arrayReason = [[NSMutableArray alloc]init];
    
    userAddresses = [[NSMutableArray alloc]init];
    userSavedCards = [[NSMutableArray alloc]init];
    
    arrayUndeliveredItems = [[NSMutableArray alloc]init];
    arrayRewashItems = [[NSMutableArray alloc]init];
    
    self.arrayBagTags = [[NSMutableArray alloc]init];
    
    
    NSMutableArray *arrayServiceTypes = [[NSMutableArray alloc]initWithArray:[orderDetailDic objectForKey:ORDER_JOB_TYPE]];
    
    if ([arrayServiceTypes containsObject:SERVICETYPE_HL_WI])
    {
        if (![arrayServiceTypes containsObject:SERVICETYPE_WI])
        {
            [arrayServiceTypes replaceObjectAtIndex:[arrayServiceTypes indexOfObject:SERVICETYPE_HL_WI] withObject:SERVICETYPE_WI];
        }
        else
        {
            [arrayServiceTypes removeObject:SERVICETYPE_HL_WI];
        }
    }
    
    if ([arrayServiceTypes containsObject:SERVICETYPE_HL_DC])
    {
        if (![arrayServiceTypes containsObject:SERVICETYPE_DC])
        {
            [arrayServiceTypes replaceObjectAtIndex:[arrayServiceTypes indexOfObject:SERVICETYPE_HL_DC] withObject:SERVICETYPE_DC];
        }
        else
        {
            [arrayServiceTypes removeObject:SERVICETYPE_HL_DC];
        }
    }
    
    if ([arrayServiceTypes containsObject:SERVICETYPE_HL_DCG])
    {
        if (![arrayServiceTypes containsObject:SERVICETYPE_DCG])
        {
            [arrayServiceTypes replaceObjectAtIndex:[arrayServiceTypes indexOfObject:SERVICETYPE_HL_DCG] withObject:SERVICETYPE_DCG];
        }
        else
        {
            [arrayServiceTypes removeObject:SERVICETYPE_HL_DCG];
        }
    }
    
//    if ([arrayServiceTypes containsObject:SERVICETYPE_DCG] && [arrayServiceTypes containsObject:SERVICETYPE_DC])
//    {
//        [arrayServiceTypes removeObject:SERVICETYPE_DCG];
//    }
    
    [orderDetailDic setObject:arrayServiceTypes forKey:ORDER_JOB_TYPE];
    
    
    if ([[orderDetailDic objectForKey:ORDER_CARD_ID] intValue] == 0)
    {
        [orderDetailDic setObject:@"Cash" forKey:ORDER_CARD_ID];
    }
    
    if ([[CoreDataMethods sharedInstance] isOIDAvalable:[orderDetailDic objectForKey:@"oid"]])
    {
        orderObj = [[CoreDataMethods sharedInstance] isOIDAvalable:[orderDetailDic objectForKey:@"oid"]];
    }
    
    self.orderInfo = [[NSMutableDictionary alloc]initWithDictionary:orderDetailDic];
    
    appDel.strCobId = [orderDetailDic objectForKey:@"oid"];
    
    [self getAddress];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.menuContainerViewController.rightMenuViewController = nil;
    
    self.navigationController.navigationBarHidden = NO;
    
    if ([[appDel.dictScannedBags objectForKey:[NSString stringWithFormat:@"%@-%@",appDel.strCobId, @"BagsCount"]] intValue] > 0)
    {
        confirmWOPayment.hidden = NO;
        conformOrderBtn.hidden = NO;
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    appDel.piingo_GoogleMap = nil;
    
    [appDel.dict_UserLocation removeAllObjects];
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    segmentC.userInteractionEnabled = enableAllAction;
    
    @synchronized(self)
    {
        if ([[CoreDataMethods sharedInstance] isOIDAvalable:[orderDetailDic objectForKey:@"oid"]])
        {
            DLog(@"old order");
            
            orderObj = [[CoreDataMethods sharedInstance] isOIDAvalable:[orderDetailDic objectForKey:@"oid"]];
        }
        else
        {
            DLog(@"New order");
            
            orderObj = [NSEntityDescription insertNewObjectForEntityForName:@"Order" inManagedObjectContext:[appDel managedObjectContext]];
            
            NSString *strOID = [NSString stringWithFormat:@"%d", [[orderDetailDic objectForKey:@"oid"]intValue]];
            
            [orderObj setOrderID:strOID];
            
            NSString *strUID = [NSString stringWithFormat:@"%d", [[orderDetailDic objectForKey:@"uid"]intValue]];
            
            [orderObj setUid:strUID];
            
            NSString *strCobid = [NSString stringWithFormat:@"%d", [[orderDetailDic objectForKey:@"oid"]intValue]];
            
            [orderObj setOid:strCobid];
            [orderObj setIsOrderConformed:[NSNumber numberWithBool:NO]];
            
            if ([[orderDetailDic objectForKey:@"prf"] caseInsensitiveCompare:@"Y"] == NSOrderedSame)
            {
                //                [orderObj setFolded:[orderDetailDic objectForKey:FOLDED_SELECTED]];
                //                [orderObj setHanger:[orderDetailDic objectForKey:HANGER_SELECTED]];
                //                [orderObj setCliphanger:[orderDetailDic objectForKey:CLIPHANGER_SELECTED]];
                //                [orderObj setCrease:[orderDetailDic objectForKey:CREASE_SELECTED]];
                //                [orderObj setStarch:[orderDetailDic objectForKey:STARCH_SELECTED]];
                //                [orderObj setStain:[orderDetailDic objectForKey:STAIN_SELECTED]];
                //                [orderObj setStarchType:[orderDetailDic objectForKey:STARCH_TYPE]];
                //[orderObj setNotes:[orderDetailDic objectForKey:@"pnotes"]];
            }
            else
            {
//                [orderObj setFolded:@"N"];
//                [orderObj setHanger:@"Y"];
//                [orderObj setCliphanger:@"N"];
//                [orderObj setCrease:@"N"];
//                [orderObj setStarch:@"N"];
//                [orderObj setStain:@"N"];
//                [orderObj setStarchType:@"N"];
//                [orderObj setNotes:@""];
            }
            
//            [orderObj setStainCount:@"0"];
//            [orderObj setStarchCount:@"0"];
            
            NSError *error;
            if (![[appDel managedObjectContext] save:&error]) {
                NSLog(@"error %@",error);
            }
        }
    }
    
//    if (isDeliveryOrder)
//    {
//        NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[orderDetailDic objectForKey:@"oid"],@"cobid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
//        
//        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
//        
//        //NSString *urlStr = [NSString stringWithFormat:@"%@itemizedorderdetails/services.do?", BASE_URL];
//        
//        NSString *urlStr;
//        
//        if (self.isCompletedOrder)
//        {
//            urlStr = [NSString stringWithFormat:@"%@viewbill/services.do?", BASE_URL];
//        }
//        else
//        {
//            urlStr = [NSString stringWithFormat:@"%@viewitemizedbilldetails/services.do?", BASE_URL];
//        }
//        
//        for (NSString *key in [registrationDetailsDic allKeys])
//        {
//            NSString *value = [registrationDetailsDic objectForKey:key];
//            urlStr = [urlStr stringByAppendingFormat:@"&%@=%@",key,value];
//        }
//        
//        [[WebserviceMethods sharedWebRequest] getRequestWithParam:urlStr andWithDelegate:self andCallbackMethod:nil];
//    }
}


-(void) updateUIdetails
{
    statusDisplayButton.enabled = NO;
    doorLockedBtn.enabled = NO;
    
//    if ([[[self.orderDetailDic objectForKey:@"status"] objectForKey:@"itsaRewash"] intValue] == 1)
//    {
//        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
//
//        NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
//
//        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/bags/getbyorderid", BASE_URL];
//
//        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
//
//            btnOptions.hidden = NO;
//            //            confirmWOPayment.hidden = NO;
//            //            conformOrderBtn.hidden = NO;
//            btnStartScan.hidden = NO;
//
//            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
//            {
//                [deliveryDetaildArray removeAllObjects];
//
//                [deliveryDetaildArray addObjectsFromArray:[responseObj objectForKey:@"em"]];
//
//                [self getDeliveryDataToPartial];
//
//                [itemDetailsTableView reloadData];
//
//
//                //////// To get Bill
//
//                NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
//
//                NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/bill", BASE_URL];
//
//                [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
//
//                    if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
//                    {
//                        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
//
//                        //////
//
//                        if ([[self.orderDetailDic objectForKey:@"partial"] intValue] == 1)
//                        {
//                            NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/billpartial", BASE_URL];
//
//                            [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
//
//                                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
//                                {
//                                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
//
//                                    if ([[responseObj objectForKey:@"em"] isKindOfClass:[NSArray class]])
//                                    {
//                                        NSDictionary *dictDetail = [[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"totalSum"];
//
//                                        CGFloat amount = [[[totalAmount.text componentsSeparatedByString:@" "] objectAtIndex:1] floatValue];
//
//                                        totalAmount.text = [NSString stringWithFormat:@"$ %.2f", amount - [[dictDetail objectForKey:@"totalAmount"] floatValue]];
//                                    }
//                                    else
//                                    {
//                                        if ([[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"])
//                                        {
//                                            totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"] floatValue]];
//                                        }
//                                        else
//                                        {
//                                            totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"billAmount"] floatValue]];
//                                        }
//                                    }
//                                }
//                                else
//                                {
//                                    [appDel displayErrorMessagErrorResponse:responseObj];
//                                }
//                            }];
//                        }
//
//
//
//                        ///////
//
//                        if ([[responseObj objectForKey:@"em"] isKindOfClass:[NSArray class]])
//                        {
//                            strBilldId = [[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"billId"];
//
//                            NSDictionary *dictDetail = [[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"totalSum"];
//
//                            totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[dictDetail objectForKey:@"totalAmount"] floatValue]];
//
//                            float discountVal = [[dictDetail objectForKey:@"promoAmount"] floatValue] + [[dictDetail objectForKey:@"freeWashAmount"] floatValue];
//
//                            lblDiscountAmount.text = [NSString stringWithFormat:@"-$ %.2f", discountVal];
//
//                            lblWalletAmount.text = [NSString stringWithFormat:@"-$ %.2f", [[dictDetail objectForKey:@"walletAmount"]floatValue]];
//                            lblGSTAmountValue.text = [NSString stringWithFormat:@"+$ %.2f", [[dictDetail objectForKey:@"gstAmount"]floatValue]];
//                        }
//                        else
//                        {
//                            if ([[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"])
//                            {
//                                totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"] floatValue]];
//                            }
//                            else
//                            {
//                                totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"billAmount"] floatValue]];
//                            }
//                        }
//                    }
//                    else
//                    {
//                        [appDel displayErrorMessagErrorResponse:responseObj];
//                    }
//                }];
//            }
//            else
//            {
//                [appDel displayErrorMessagErrorResponse:responseObj];
//            }
//        }];
//    }
    if ([self.strTaskStatus caseInsensitiveCompare:@"P"] == NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"U"] == NSOrderedSame)
    {
        [statusDisplayButton setTitle:@"START" forState:UIControlStateNormal];
        statusDisplayButton.enabled = YES;
        
        doorLockedBtn.enabled = NO;
        cancelOrderBtn.enabled = NO;
        addBtn.hidden = YES;
        btnPrefs.hidden = YES;
        conformOrderBtn.hidden = YES;
    }
    else if ([self.strTaskStatus caseInsensitiveCompare:@"A"] == NSOrderedSame)
    {
        UIImage *butImage1 = [UIImage imageNamed:@"door_locked.png"];
        [statusDisplayButton setImage:butImage1 forState:UIControlStateNormal];
        
        [statusDisplayButton setTitle:@"AT THE DOOR" forState:UIControlStateNormal];
        statusDisplayButton.enabled = YES;
        
        doorLockedBtn.enabled = NO;
        cancelOrderBtn.enabled = NO;
        addBtn.hidden = YES;
        btnPrefs.hidden = YES;
        conformOrderBtn.hidden = YES;
    }
    else if ([self.strTaskStatus caseInsensitiveCompare:@"AD"] == NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"DE"] == NSOrderedSame)
    {
        UIImage *butImage1 = [UIImage imageNamed:@"door_locked.png"];
        [statusDisplayButton setImage:butImage1 forState:UIControlStateNormal];
        
        [statusDisplayButton setTitle:@"AT THE DOOR" forState:UIControlStateNormal];
        
        doorLockedBtn.enabled = YES;
        addBtn.hidden = NO;
        btnPrefs.hidden = NO;
        conformOrderBtn.hidden = NO;
        
        if ([self.strDirection caseInsensitiveCompare:@"Pickup"] == NSOrderedSame)
        {
            cancelOrderBtn.enabled = YES;
        }
    }
    else if ([self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame)
    {
        ///// Order placed by Piingo....
        
        conformOrderBtn.hidden = YES;
        addBtn.hidden = YES;
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
        
        NSString *urlStr = @"";
        
        if ([[self.orderDetailDic objectForKey:@"partial"] intValue] == 1)
        {
            urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/billpartial", BASE_URL];
        }
        else
        {
            urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/bill", BASE_URL];
        }
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
            {
                [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                
                [arrayPriceList removeAllObjects];
                
                if ([[responseObj objectForKey:@"em"] isKindOfClass:[NSArray class]])
                {
                    [arrayPriceList addObjectsFromArray:[[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"r"]];
                    
                    NSDictionary *dictDetail = [[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"totalSum"];
                    
                    totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[dictDetail objectForKey:@"totalAmount"] floatValue]];
                    
                    float discountVal = [[dictDetail objectForKey:@"promoAmount"] floatValue] + [[dictDetail objectForKey:@"freeWashAmount"] floatValue];
                    
                    lblDiscountAmount.text = [NSString stringWithFormat:@"-$ %.2f", discountVal];
                    
                    lblWalletAmount.text = [NSString stringWithFormat:@"-$ %.2f", [[dictDetail objectForKey:@"walletAmount"]floatValue]];
                    lblGSTAmountValue.text = [NSString stringWithFormat:@"+$ %.2f", [[dictDetail objectForKey:@"gstAmount"]floatValue]];
                }
                else
                {
                    [arrayPriceList addObjectsFromArray:[[responseObj objectForKey:@"em"] objectForKey:@"r"]];
                    
                    if ([[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"])
                    {
                        totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"] floatValue]];
                    }
                    else
                    {
                        totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"billAmount"] floatValue]];
                    }
                }
                
                [self getCustomizedData];
                
                [itemDetailsTableView reloadData];
                
            }
            else
            {
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
            
        }];
    }
    else
    {
        
    }
    
    if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame && [self.strTaskStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
    {
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/bags/getbyorderid", BASE_URL];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            btnOptions.hidden = NO;
//            confirmWOPayment.hidden = NO;
//            conformOrderBtn.hidden = NO;
            btnStartScan.hidden = NO;
            
            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
            {
                [deliveryDetaildArray removeAllObjects];
                
                [deliveryDetaildArray addObjectsFromArray:[responseObj objectForKey:@"em"]];
                
                [self getDeliveryDataToPartial];
                
                [itemDetailsTableView reloadData];
                
                
                //////// To get Bill
                
                NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
                
                NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/bill", BASE_URL];
                
                [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                    
                    if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                    {
                        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                        
                        //////
                        
                        if ([[self.orderDetailDic objectForKey:@"partial"] intValue] == 1)
                        {
                            NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/get/billpartial", BASE_URL];
                            
                            [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                                
                                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                                {
                                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                                    
                                    if ([[responseObj objectForKey:@"em"] isKindOfClass:[NSArray class]])
                                    {
                                        NSDictionary *dictDetail = [[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"totalSum"];
                                        
                                        CGFloat amount = [[[totalAmount.text componentsSeparatedByString:@" "] objectAtIndex:1] floatValue];
                                        
                                        totalAmount.text = [NSString stringWithFormat:@"$ %.2f", amount - [[dictDetail objectForKey:@"totalAmount"] floatValue]];
                                    }
                                    else
                                    {
                                        if ([[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"])
                                        {
                                            totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"] floatValue]];
                                        }
                                        else
                                        {
                                            totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"billAmount"] floatValue]];
                                        }
                                    }
                                }
                                else
                                {
                                    [appDel displayErrorMessagErrorResponse:responseObj];
                                }
                            }];
                        }
                        
                        
                        
                        ///////
                        
                        if ([[responseObj objectForKey:@"em"] isKindOfClass:[NSArray class]])
                        {
                            strBilldId = [[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"billId"];
                            
                            NSDictionary *dictDetail = [[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"totalSum"];
                            
                            totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[dictDetail objectForKey:@"totalAmount"] floatValue]];
                            
                            float discountVal = [[dictDetail objectForKey:@"promoAmount"] floatValue] + [[dictDetail objectForKey:@"freeWashAmount"] floatValue];
                            
                            lblDiscountAmount.text = [NSString stringWithFormat:@"-$ %.2f", discountVal];
                            
                            lblWalletAmount.text = [NSString stringWithFormat:@"-$ %.2f", [[dictDetail objectForKey:@"walletAmount"]floatValue]];
                            lblGSTAmountValue.text = [NSString stringWithFormat:@"+$ %.2f", [[dictDetail objectForKey:@"gstAmount"]floatValue]];
                        }
                        else
                        {
                            if ([[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"])
                            {
                                totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"totalAmount"] floatValue]];
                            }
                            else
                            {
                                totalAmount.text = [NSString stringWithFormat:@"$ %.2f", [[[responseObj objectForKey:@"em"] objectForKey:@"billAmount"] floatValue]];
                            }
                        }
                    }
                    else
                    {
                        [appDel displayErrorMessagErrorResponse:responseObj];
                    }
                }];
            }
            else
            {
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
        }];
    }
    
    [statusDisplayButton centerImageAndTextWithSpacing:6.0];
}

-(void) getCustomizedData
{
    for (int i = 0; i < [arrayPriceList count]; i++)
    {
        NSDictionary *dictBag = [arrayPriceList objectAtIndex:i];
        
        if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_WF])
        {
            NSArray *arrayItems = [dictBag objectForKey:@"STItems"];
            
            if ([arrayItems count])
            {
                NSMutableDictionary *dictItemType = [[NSMutableDictionary alloc]init];
                [dictItemType setObject:[[arrayItems objectAtIndex:0] objectForKey:@"weight"] forKey:@"weight"];
                [dictItemType setObject:[[arrayItems objectAtIndex:0] objectForKey:@"totalPrice"] forKey:@"totalPrice"];
                
                NSMutableArray *arrayBag = [[NSMutableArray alloc]initWithObjects:dictItemType, nil];
                
                NSMutableDictionary *dictBagPar = [[NSMutableDictionary alloc]initWithObjectsAndKeys:arrayBag, @"STItems", nil];
                [dictBagPar setObject:[dictBag objectForKey:@"serviceType"] forKey:@"serviceType"];
                
                [dictBagPar setObject:@"Load Wash" forKey:@"serviceTypeName"];
                
                [arrayCustomizedData addObject:dictBagPar];
            }
        }
        else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_CA])
        {
            NSArray *arrayItems = [dictBag objectForKey:@"STItems"];
            
            if ([arrayItems count])
            {
                NSMutableDictionary *dictItemType = [[NSMutableDictionary alloc]init];
                [dictItemType setObject:[[arrayItems objectAtIndex:0] objectForKey:@"weight"] forKey:@"weight"];
                [dictItemType setObject:[[arrayItems objectAtIndex:0] objectForKey:@"totalPrice"] forKey:@"totalPrice"];
                
                NSMutableArray *arrayBag = [[NSMutableArray alloc]initWithObjects:dictItemType, nil];
                
                NSMutableDictionary *dictBagPar = [[NSMutableDictionary alloc]initWithObjectsAndKeys:arrayBag, @"STItems", nil];
                [dictBagPar setObject:[dictBag objectForKey:@"serviceType"] forKey:@"serviceType"];
                
                [dictBagPar setObject:@"Carpet Cleaning" forKey:@"serviceTypeName"];
                
                [arrayCustomizedData addObject:dictBagPar];
            }
        }
        else
        {
            NSArray *arrayItems = [dictBag objectForKey:@"STItems"];
            
            NSMutableDictionary *dictItemType = [[NSMutableDictionary alloc]init];
            
            for (int j = 0; j < [arrayItems count]; j++)
            {
                NSDictionary *dictItem = [arrayItems objectAtIndex:j];
                
                NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]initWithDictionary:dictItem];
                
                NSString *strItemCode = [dictItem objectForKey:@"itemCode"];
                
                if (![dictItemType objectForKey:strItemCode])
                {
                    NSMutableArray *arrayItemCode = [[NSMutableArray alloc]initWithObjects:dict1, nil];
                    
                    [dictItemType setObject:arrayItemCode forKey:strItemCode];
                }
                else
                {
                    NSMutableArray *arrayItemCode = [dictItemType objectForKey:strItemCode];
                    
                    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]initWithDictionary:dictItem];
                    
                    [arrayItemCode addObject:dict1];
                }
            }
            
            NSMutableArray *arrayBag = [[NSMutableArray alloc]initWithObjects:dictItemType, nil];
            
            NSMutableDictionary *dictBagPar = [[NSMutableDictionary alloc]initWithObjectsAndKeys:arrayBag, @"STItems", nil];
            [dictBagPar setObject:[dictBag objectForKey:@"serviceType"] forKey:@"serviceType"];
            
            if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_DC])
            {
                [dictBagPar setObject:@"Dry Cleaning" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_DCG])
            {
                [dictBagPar setObject:@"Green Dry Cleaning" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_WI])
            {
                [dictBagPar setObject:@"Wash & Iron" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_IR])
            {
                [dictBagPar setObject:@"Ironing" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_LE])
            {
                [dictBagPar setObject:@"Leather Cleaning" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_CC_DC])
            {
                [dictBagPar setObject:@"Curtains without installation - Dry Cleaning" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_CC_W_DC])
            {
                [dictBagPar setObject:@"Curtains with installation - Dry Cleaning" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_CC_WI])
            {
                [dictBagPar setObject:@"Curtains without installation - Wash & Iron" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_CC_W_WI])
            {
                [dictBagPar setObject:@"Curtains with installation - Wash & Iron" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_BAG])
            {
                [dictBagPar setObject:@"Bag" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_SHOE_CLEAN])
            {
                [dictBagPar setObject:@"Shoe cleaning" forKey:@"serviceTypeName"];
            }
            else if ([[dictBag objectForKey:@"serviceType"] isEqualToString:SERVICETYPE_SHOE_POLISH])
            {
                [dictBagPar setObject:@"Shoe polishing" forKey:@"serviceTypeName"];
            }
            
            [arrayCustomizedData addObject:dictBagPar];
        }
    }
}


-(void) loadOrderDetails
{
    self.view.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1.0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butImage = [UIImage imageNamed:@"back_grey"];
    button.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [button setBackgroundImage:butImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, 0, 32, 31);
    
    back_BarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = back_BarButton;
    
    UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *butImage1 = [UIImage imageNamed:@"phone_icon_seleted_New.png"];
    rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [rightbutton setBackgroundImage:butImage1 forState:UIControlStateNormal];
    [rightbutton addTarget:self action:@selector(callBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    rightbutton.frame = CGRectMake(0, 0, 34, 34);
    
    phone_BarButton = [[UIBarButtonItem alloc] initWithCustomView:rightbutton];
    self.navigationItem.rightBarButtonItem = phone_BarButton;
    self.navigationItem.hidesBackButton = YES;
    
    phone_BarButton.enabled = self.userInteractionEnabled;
    
    itemDetailArray = [[NSMutableArray alloc] init];
    itemsArray = [[NSMutableArray alloc] init];
    deliveryDetaildArray = [[NSMutableArray alloc] init];
    deliveryPartialArray = [[NSMutableArray alloc] init];
    
    
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg"];
    //[self.view addSubview: animatedImageView];
    
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64.0, screen_width , 10+30+10)];
    bgView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    //[self.view addSubview:bgView];
    
    segmentC = [[CustomSegmentControl alloc] initWithFrame:CGRectMake(0, 0, screen_width-170, 30.0) andButtonTitles2:@[@"Job Detail", @"Items"] andWithSpacing:[NSNumber numberWithFloat:0.0] andSelectionColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] andDelegate:self andSelector:NSStringFromSelector(@selector(segmentChange:))];
    //segmentC.center = CGPointMake(screen_width/2, 64+10+15.0);
    segmentC.layer.cornerRadius = 5.0;
    segmentC.layer.borderWidth = 1;
    segmentC.clipsToBounds = YES;
    segmentC.layer.borderColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0].CGColor;
    segmentC.backgroundColor = [UIColor clearColor];
    self.navigationItem.titleView = segmentC;
    
    
    mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, screen_width, screen_height-64)];
    mainScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:mainScrollView];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UILabel *lblOrderId = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screen_width, 40.0)];
    lblOrderId.text = [NSString stringWithFormat:@"ORDER ID# %@", [orderDetailDic objectForKey:@"oid"]];
    lblOrderId.textAlignment = NSTextAlignmentCenter;
    lblOrderId.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:16.0];
    lblOrderId.backgroundColor = [UIColor clearColor];
    lblOrderId.textColor = [UIColor colorWithRed:140.0/255.0 green:140.0/255.0 blue:140.0/255.0 alpha:1.0];
    [mainScrollView addSubview:lblOrderId];
    
    
    // Status Details
    
    UIView *view_Status = [[UIView alloc]initWithFrame:CGRectMake(10, 40, screen_width-20, 70)];
    view_Status.backgroundColor = [UIColor whiteColor];
    [mainScrollView addSubview:view_Status];
    
    float customWidth = view_Status.frame.size.width;
    
    float xAxis = 0;
    
    for (int i=0; i<3; i++)
    {
        
        UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        rightbutton.frame = CGRectMake(xAxis, 0, customWidth/3, 70);
        [rightbutton setTitleColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        rightbutton.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:11.0];
        
        if (i==0)
        {
            [rightbutton setTitle:@"START" forState:UIControlStateNormal];
            UIImage *butImage1 = [UIImage imageNamed:@"start.png"];
            [rightbutton setImage:butImage1 forState:UIControlStateNormal];
            [rightbutton addTarget:self action:@selector(start_OR_AtTheDoorClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            statusDisplayButton = rightbutton;
        }
        
        else if (i==1)
        {
            [rightbutton setTitle:@"UNABLE TO SERVE" forState:UIControlStateNormal];
            //[rightbutton setTitle:@"DOOR LOCKED" forState:UIControlStateNormal];
            UIImage *butImage1 = [UIImage imageNamed:@"door_locked.png"];
            [rightbutton setImage:butImage1 forState:UIControlStateNormal];
            [rightbutton addTarget:self action:@selector(unabletoserveClicked) forControlEvents:UIControlEventTouchUpInside];
            
            rightbutton.enabled = NO;
            doorLockedBtn = rightbutton;
        }
        
        else if (i==2)
        {
            [rightbutton setTitle:@"CANCEL ORDER" forState:UIControlStateNormal];
            UIImage *butImage1 = [UIImage imageNamed:@"cancelorder_grey.png"];
            [rightbutton setImage:butImage1 forState:UIControlStateNormal];
            [rightbutton addTarget:self action:@selector(cancelOrderClicked) forControlEvents:UIControlEventTouchUpInside];
            
            rightbutton.enabled = NO;
            cancelOrderBtn = rightbutton;
        }
        
        [view_Status addSubview:rightbutton];
        
        [rightbutton centerImageAndTextWithSpacing:5.0];
        
        xAxis += customWidth/3;
    }
    
    
    // Piingo Details
    
    NSArray *sortedArray1 = [[NSMutableArray alloc]initWithArray:userAddresses];
    NSPredicate *getDefaultAddPredicate1 = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", [orderDetailDic objectForKey:ORDER_PICKUP_ADDRESS_ID]]];
    
    sortedArray1 = [sortedArray1 filteredArrayUsingPredicate:getDefaultAddPredicate1];
    
    if ([sortedArray1 count] > 0)
    {
        dictPickupAddress = [sortedArray1 objectAtIndex:0];
    }
    
    NSArray *sortedArray2 = [[NSMutableArray alloc]initWithArray:userAddresses];
    NSPredicate *getDefaultAddPredicate2 = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", [orderDetailDic objectForKey:ORDER_DELIVERY_ADDRESS_ID]]];
    
    sortedArray2 = [sortedArray2 filteredArrayUsingPredicate:getDefaultAddPredicate2];
    
    if ([sortedArray2 count] > 0)
    {
        dictDeliveryAddress = [sortedArray2 objectAtIndex:0];
    }
    
    NSArray *sortedArray3 = [[NSMutableArray alloc]initWithArray:userSavedCards];
    NSPredicate *getDefaultAddPredicate3 = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", self.strPaymentId]];
    
    sortedArray3 = [sortedArray3 filteredArrayUsingPredicate:getDefaultAddPredicate3];
    
    if ([sortedArray3 count] > 0)
    {
        selectedCardDict = [sortedArray3 objectAtIndex:0];
    }
    else
    {
        selectedCardDict = [userSavedCards objectAtIndex:0];
    }
    
    
    UIView *view_PiingoDetails = [[UIView alloc]initWithFrame:CGRectMake(10, view_Status.frame.origin.y+view_Status.frame.size.height+6, screen_width-20, 50)];
    view_PiingoDetails.backgroundColor = [UIColor whiteColor];
    [mainScrollView addSubview:view_PiingoDetails];
    
    UILabel *lblPiingoName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view_PiingoDetails.frame.size.width-20, 30.0)];
    
    if ([self.strDirection caseInsensitiveCompare:@"pickup"] == NSOrderedSame)
    {
        dictAddress = dictPickupAddress;
    }
    else
    {
        dictAddress = dictDeliveryAddress;
    }
    
    lblPiingoName.text = [NSString stringWithFormat:@"%@", [dictAddress objectForKey:@"name"]];
    
    lblPiingoName.textAlignment = NSTextAlignmentLeft;
    lblPiingoName.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM];
    lblPiingoName.backgroundColor = [UIColor clearColor];
    lblPiingoName.textColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1.0];
    [view_PiingoDetails addSubview:lblPiingoName];
    
    NSMutableString *strAddr = [[NSMutableString alloc]initWithString:@""];
    
    if ([[dictAddress objectForKey:@"line1"] length] > 1)
    {
        [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dictAddress objectForKey:@"line1"]]];
    }
    
    NSString *strFno;
    
    if ([[dictAddress objectForKey:@"floorNo"] isKindOfClass:[NSString class]])
    {
        strFno = [dictAddress objectForKey:@"floorNo"];
    }
    else
    {
        strFno = [NSString stringWithFormat:@"%d", [[dictAddress objectForKey:@"floorNo"] intValue]];
    }
    
    if ([strFno length])
    {
        if ([strFno length] == 1)
        {
            [strAddr appendString:[NSString stringWithFormat:@"#0%@", strFno]];
        }
        else
        {
            [strAddr appendString:[NSString stringWithFormat:@"#%@", [dictAddress objectForKey:@"floorNo"]]];
        }
    }
    
    NSString *strUno;
    
    if ([[dictAddress objectForKey:@"unitNo"] isKindOfClass:[NSString class]])
    {
        strUno = [dictAddress objectForKey:@"unitNo"];
    }
    else
    {
        strUno = [NSString stringWithFormat:@"%d", [[dictAddress objectForKey:@"unitNo"] intValue]];
    }
    
    if ([strUno length])
    {
        [strAddr appendString:[NSString stringWithFormat:@"-%@, ", strUno]];
    }
    
    if ([[dictAddress objectForKey:@"line2"] length])
    {
        [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dictAddress objectForKey:@"line2"]]];
    }
    if ([[dictAddress objectForKey:@"zipcode"] length])
    {
        [strAddr appendString:[NSString stringWithFormat:@"%@", [dictAddress objectForKey:@"zipcode"]]];
    }
    
    UILabel *lblAddr = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, view_PiingoDetails.frame.size.width-20, 20.0)];
    lblAddr.text = strAddr;
    lblAddr.numberOfLines = 0;
    lblAddr.textAlignment = NSTextAlignmentLeft;
    lblAddr.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM];
    lblAddr.backgroundColor = [UIColor clearColor];
    lblAddr.textColor = [UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0];
    [view_PiingoDetails addSubview:lblAddr];
    
    CGFloat height = [AppDelegate getLabelHeightForRegularText:strAddr WithWidth:lblAddr.frame.size.width FontSize:lblAddr.font.pointSize];
    CGRect frame = lblAddr.frame;
    frame.size.height = height;
    lblAddr.frame = frame;
    
    
    frame = view_PiingoDetails.frame;
    frame.size.height = 25+lblAddr.frame.size.height+5;
    //frame.size.height = 25+100+5;
    view_PiingoDetails.frame = frame;
    
    
    
    // Pickup and Delivery Details
    
    UIView *view_Time = [[UIView alloc]initWithFrame:CGRectMake(10, view_PiingoDetails.frame.origin.y+view_PiingoDetails.frame.size.height+6, screen_width-20, 100)];
    view_Time.backgroundColor = [UIColor whiteColor];
    [mainScrollView addSubview:view_Time];
    
    customWidth = view_Time.frame.size.width/2;
    
    xAxis = 0;
    
    for (int i=0; i<2; i++)
    {
        
        UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        rightbutton.frame = CGRectMake(xAxis, 0, customWidth/1, 60);
        [rightbutton setTitleColor:[UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        rightbutton.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:13.0];
        [view_Time addSubview:rightbutton];
        
        UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(xAxis, 45, customWidth/1, 20.0)];
        lblTime.textAlignment = NSTextAlignmentCenter;
        lblTime.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:19.0];
        lblTime.backgroundColor = [UIColor clearColor];
        lblTime.textColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255.0 alpha:1.0];
        [view_Time addSubview:lblTime];
        
        
        UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(xAxis, 65, customWidth/1, 20.0)];
        lblDate.textAlignment = NSTextAlignmentCenter;
        lblDate.font = [UIFont fontWithName:APPFONT_REGULAR size:12.0];
        lblDate.backgroundColor = [UIColor clearColor];
        lblDate.textColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0];
        [view_Time addSubview:lblDate];
        
        
        if (i==0)
        {
            
            [rightbutton setTitle:@"PICKUP" forState:UIControlStateNormal];
            
            UIImage *butImage1 = [UIImage imageNamed:@"pickup.png"];
            [rightbutton setImage:butImage1 forState:UIControlStateNormal];
            
            lblTime.text = [orderDetailDic objectForKey:ORDER_PICKUP_SLOT];
            lblDate.text = [orderDetailDic objectForKey:ORDER_PICKUP_DATE];
        }
        
        else if (i==1)
        {
            
            UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(xAxis, 0, 1, view_Time.frame.size.height)];
            imgLine.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
            [view_Time addSubview:imgLine];
            
            [rightbutton setTitle:@"DELIVERY" forState:UIControlStateNormal];
            UIImage *butImage1 = [UIImage imageNamed:@"dropoff.png"];
            [rightbutton setImage:butImage1 forState:UIControlStateNormal];
            
            lblTime.text = [orderDetailDic objectForKey:ORDER_DELIVERY_SLOT];
            lblDate.text = [orderDetailDic objectForKey:ORDER_DELIVERY_DATE];
        }
        
        xAxis += customWidth;
    }
    
    if ([[dictAddress objectForKey:@"zipcode"] length])
    {
        [self getLatAndLongOfUser:[dictAddress objectForKey:@"zipcode"]];
    }
    
    
    // Wash Details
    
//    UIView *view_Wash = [[UIView alloc] initWithFrame:CGRectMake(10, view_Time.frame.origin.y+view_Time.frame.size.height+6, screen_width-20, 100*MULTIPLYHEIGHT)];
//    view_Wash.backgroundColor = [UIColor whiteColor];
//    [mainScrollView addSubview:view_Wash];
//    
//    scrollViewWashType = [[UIScrollView alloc]initWithFrame:view_Wash.bounds];
//    scrollViewWashType.delegate = self;
//    [view_Wash addSubview:scrollViewWashType];
//    //scrollView.scrollEnabled = NO;
//    scrollViewWashType.pagingEnabled = YES;
    
    //////////////
    
    
//    NSArray *arrCleaning = @[CATEGORY_SERVICETYPE_GENERAL, CATEGORY_SERVICETYPE_HOME, CATEGORY_SERVICETYPE_SPECIALCARE];
//    
//    float segmentHeight = 23*MULTIPLYHEIGHT;
//    
//    segmentCleaning = [[HMSegmentedControl alloc]initWithSectionTitles:arrCleaning];
//    segmentCleaning.delegate = self;
//    segmentCleaning.frame = CGRectMake(0, 0, view_Wash.frame.size.width, segmentHeight);
//    
//    float left = 5*MULTIPLYHEIGHT;
//    float right = 5*MULTIPLYHEIGHT;
//    
//    segmentCleaning.type = HMSegmentedControlTypeText;
//    segmentCleaning.segmentEdgeInset = UIEdgeInsetsMake(0, left, 0, right);
//    segmentCleaning.backgroundColor = [UIColor clearColor];
//    segmentCleaning.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
//    segmentCleaning.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
//    segmentCleaning.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(1)};
//    segmentCleaning.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : BLUE_COLOR, NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(1)};
//    [segmentCleaning addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
//    [view_Wash addSubview:segmentCleaning];
//    segmentCleaning.selectionStyle = HMSegmentedControlSelectionStyleBox;
//    segmentCleaning.selectionIndicatorColor = [UIColor clearColor];
//    segmentCleaning.selectionIndicatorBoxOpacity = 1.0f;
//    segmentCleaning.selectedSegmentIndex = 0;
//    segmentCleaning.verticalDividerEnabled = YES;
//    segmentCleaning.verticalDividerColor = BLUE_COLOR;
//    segmentCleaning.verticalDividerWidth = 1;
//    segmentCleaning.selectionIndicatorHeight = 7*MULTIPLYHEIGHT;
//    
//    [segmentCleaning setIndexChangeBlock:^(NSInteger index) {
//        
//        //[self scrollAnimated];
//        
//    }];
//    
//    [self segmentedControlChangedValue:segmentCleaning];
    
//    [self performSelector:@selector(offsetChange) withObject:nil afterDelay:0.5];
//    
//    float widthe = 28*MULTIPLYHEIGHT;
//    segmentCleaning.scrollView.contentInset = UIEdgeInsetsMake(0, widthe, 0, widthe);
    
    
    
//    NSArray *btnTitlesPersonal = @[@"LOAD WASH", @"DRY CLEANING", @"WASH & IRON", @"IRONING"];
//    NSArray *btnIconsPersonal = @[@"load_wash", @"dry_cleaning", @"wash_and_iron", @"ironing"];
//    NSArray *btnSelIconsPersonal = @[@"load_wash_selected", @"dry_cleaning_selected", @"wash_and_iron_selected", @"ironing_selected"];
//    
//    NSArray *btnTitlesHome = @[@"CARPET", @"CURTAINS"];
//    NSArray *btnIconsHome = @[@"carpet", @"curtains"];
//    NSArray *btnSelIconsHome = @[@"carpet_selected", @"curtains_selected"];
//    
//    NSArray *btnTitlesSpecial = @[@"BAGS", @"SHOES", @"LEATHER"];
//    NSArray *btnIconsSpecial = @[ @"bags", @"shoes", @"leather"];
//    NSArray *btnSelIconsSpecial = @[@"bags_selected", @"shoes_selected", @"leather_selected"];
//
//    dictJobTypes = [[NSDictionary alloc]initWithObjectsAndKeys:btnTitlesPersonal, @"1", btnTitlesHome, @"2", btnTitlesSpecial, @"3", nil];
//    
//    NSDictionary *dictJobTypesIcons = [[NSDictionary alloc]initWithObjectsAndKeys:btnIconsPersonal, @"1", btnIconsHome, @"2", btnIconsSpecial, @"3", nil];
//    
//    NSDictionary *dictJobTypesSelIcons = [[NSDictionary alloc]initWithObjectsAndKeys:btnSelIconsPersonal, @"1", btnSelIconsHome, @"2", btnSelIconsSpecial, @"3", nil];
//    
//    float viewX = 0.0;
//    int tagValue = 0;
//    
//    for (int k=0; k < [dictJobTypes count]; k++)
//    {
//        
//        float btnWidth = 0.0;
//        
//        float minusWidth = 0.0;
//        
//        if (k == 0)
//        {
//            minusWidth = 0.0;
//            
//            btnWidth = CGRectGetWidth(view_Wash.bounds)/4;
//            viewX = k*view_Wash.frame.size.width;
//        }
//        else if (k == 1)
//        {
//            minusWidth = 40*MULTIPLYHEIGHT;
//            
//            btnWidth = CGRectGetWidth(view_Wash.bounds)/2;
//            viewX = k*view_Wash.frame.size.width;
//        }
//        else if (k == 2)
//        {
//            minusWidth = 20*MULTIPLYHEIGHT;
//            
//            btnWidth = CGRectGetWidth(view_Wash.bounds)/3;
//            viewX = k*view_Wash.frame.size.width;
//        }
//        
//        NSArray *arrTitles = [dictJobTypes objectForKey:[NSString stringWithFormat:@"%d", k+1]];
//        NSArray *arrIcons = [dictJobTypesIcons objectForKey:[NSString stringWithFormat:@"%d", k+1]];
//        NSArray *arrSelIcons = [dictJobTypesSelIcons objectForKey:[NSString stringWithFormat:@"%d", k+1]];
//        
//        NSMutableArray *arrayData = [NSMutableArray arrayWithArray:[self.orderInfo objectForKey:ORDER_JOB_TYPE]];
//        
//        NSMutableArray *arrayJobTypeOrg = [NSMutableArray array];
//        
//        for (int i = 0; i < [arrayData count]; i++)
//        {
//            NSString *str = [arrayData objectAtIndex:i];
//            
//            if ([str length])
//            {
//                [arrayJobTypeOrg addObject:str];
//            }
//        }
//        
//        UIView *viewType = [[UIView alloc]initWithFrame:CGRectMake(viewX+minusWidth, 25.0, scrollViewWashType.frame.size.width-(minusWidth*2), 100*MULTIPLYHEIGHT-20)];
//        viewType.tag = k+1;
//        viewType.backgroundColor = [UIColor clearColor];
//        [scrollViewWashType addSubview:viewType];
//        
//        float Width = viewType.frame.size.width/[arrTitles count];
//        
//        for (int i=0; i<arrTitles.count; i++) {
//            
//            UIButton *washBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            washBtn.frame = CGRectMake(i*(Width), 0, Width, viewType.frame.size.height);
//            washBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
//            [washBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//            [washBtn setTitleColor:BLUE_COLOR forState:UIControlStateSelected];
//            [washBtn setTitle:[arrTitles objectAtIndex:i] forState:UIControlStateNormal];
//            [washBtn setImage:[UIImage imageNamed:[arrIcons objectAtIndex:i]] forState:UIControlStateNormal];
//            [washBtn setImage:[UIImage imageNamed:[arrSelIcons objectAtIndex:i]] forState:UIControlStateSelected];
//            [viewType addSubview:washBtn];
//            
//            if (k == 0)
//            {
//                if (i == 0 && [arrayJobTypeOrg containsObject:SERVICETYPE_WF])
//                {
//                    washBtn.selected = YES;
//                }
//                else if (i == 1 && ([arrayJobTypeOrg containsObject:SERVICETYPE_DC] || [arrayJobTypeOrg containsObject:SERVICETYPE_DCG]))
//                {
//                    washBtn.selected = YES;
//                    
//                    if ([arrayJobTypeOrg containsObject:SERVICETYPE_DCG])
//                    {
//                        [washBtn setImage:[UIImage imageNamed:@"dcg_selected"] forState:UIControlStateSelected];
//                        [washBtn setTitleColor:RGBCOLORCODE(105, 151, 20, 1.0) forState:UIControlStateSelected];
//                    }
//                }
//                else if (i == 2 && [arrayJobTypeOrg containsObject:SERVICETYPE_WI])
//                {
//                    washBtn.selected = YES;
//                }
//                else if (i == 3 && [arrayJobTypeOrg containsObject:SERVICETYPE_IR])
//                {
//                    washBtn.selected = YES;
//                }
//            }
//            
//            else if (k == 1)
//            {
//                if (i == 0 && [arrayJobTypeOrg containsObject:SERVICETYPE_CA])
//                {
//                    washBtn.selected = YES;
//                }
//                else if (i == 1 && ([arrayJobTypeOrg containsObject:SERVICETYPE_CC_DC] || [arrayJobTypeOrg containsObject:SERVICETYPE_CC_W_DC] || [arrayJobTypeOrg containsObject:SERVICETYPE_CC_WI] || [arrayJobTypeOrg containsObject:SERVICETYPE_CC_W_WI]))
//                {
//                    washBtn.selected = YES;
//                }
//            }
//            
//            else if (k == 2)
//            {
//                if (i == 0 && [arrayJobTypeOrg containsObject:SERVICETYPE_BAG])
//                {
//                    washBtn.selected = YES;
//                }
//                else if (i == 1 && ([arrayJobTypeOrg containsObject:SERVICETYPE_SHOE_POLISH] || [arrayJobTypeOrg containsObject:SERVICETYPE_SHOE_CLEAN]))
//                {
//                    washBtn.selected = YES;
//                }
//                else if (i == 2 && [arrayJobTypeOrg containsObject:SERVICETYPE_LE])
//                {
//                    washBtn.selected = YES;
//                }
//            }
//            
//            [washBtn centerImageAndTextWithSpacing:10*MULTIPLYHEIGHT];
//            
//            if (k == 0)
//            {
//                if (i != 3)
//                {
//                    UIEdgeInsets titleEdgaeInsets = washBtn.titleEdgeInsets;
//                    titleEdgaeInsets.right -= 10;
//                    washBtn.titleEdgeInsets = titleEdgaeInsets;
//                }
//            }
//            
//            tagValue ++;
//        }
//    }
//    
//    scrollViewWashType.contentSize = CGSizeMake(viewX+view_Wash.frame.size.width, scrollViewWashType.frame.size.height);
    
    
    /////////////
    
    NSMutableArray *arrayWashTypes = [[NSMutableArray alloc]init];
    NSMutableArray *arrayWashImages = [[NSMutableArray alloc]init];
    
    NSArray *arrayServiceTypes = [self.orderInfo objectForKey:ORDER_JOB_TYPE];
    
    if ([arrayServiceTypes containsObject:SERVICETYPE_WF])
    {
        [arrayWashTypes addObject:@"LOAD WASH"];
        [arrayWashImages addObject:@"load_wash_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_WI])
    {
        [arrayWashTypes addObject:@"WASH & IRON"];
        [arrayWashImages addObject:@"wash_and_iron_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_IR])
    {
        [arrayWashTypes addObject:@"IRONING"];
        [arrayWashImages addObject:@"ironing_selected"];
    }
    
    if ([arrayServiceTypes containsObject:SERVICETYPE_DC] && [arrayServiceTypes containsObject:SERVICETYPE_DCG])
    {
        [arrayWashTypes addObject:@"DRY CLEANING"];
        [arrayWashImages addObject:@"dc_dcg_selected"];
    }
    else if ([arrayServiceTypes containsObject:SERVICETYPE_DC])
    {
        [arrayWashTypes addObject:@"DRY CLEANING"];
        [arrayWashImages addObject:@"dry_cleaning_selected"];
    }
    else if ([arrayServiceTypes containsObject:SERVICETYPE_DCG])
    {
        [arrayWashTypes addObject:@"GREEN DRY CLEANING"];
        [arrayWashImages addObject:@"dcg_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_LE])
    {
        [arrayWashTypes addObject:@"LEATHER CLEANING"];
        [arrayWashImages addObject:@"leather_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_CA])
    {
        [arrayWashTypes addObject:@"CARPET CLEANING"];
        [arrayWashImages addObject:@"carpet_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_CC_W_DC] || [arrayServiceTypes containsObject:SERVICETYPE_CC_DC] || [arrayServiceTypes containsObject:SERVICETYPE_CC_WI] || [arrayServiceTypes containsObject:SERVICETYPE_CC_W_WI])
    {
        [arrayWashTypes addObject:@"CURTAINS"];
        [arrayWashImages addObject:@"curtains_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_BAG])
    {
        [arrayWashTypes addObject:@"BAGS CLEANING"];
        [arrayWashImages addObject:@"bags_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_SHOE_CLEAN])
    {
        [arrayWashTypes addObject:@"SHOE CLEANING"];
        [arrayWashImages addObject:@"shoes_selected"];
    }
    if ([arrayServiceTypes containsObject:SERVICETYPE_SHOE_POLISH])
    {
        [arrayWashTypes addObject:@"SHOE POLISH"];
        [arrayWashImages addObject:@"shoes_selected"];
    }
    
    float lblWTHeight = 100*MULTIPLYHEIGHT;
    
    int xAxisWT = 5*MULTIPLYHEIGHT;
    
    UIScrollView *view_WashTypes = [[UIScrollView alloc]initWithFrame:CGRectMake(10, view_Time.frame.origin.y+view_Time.frame.size.height+6, screen_width-20, lblWTHeight)];
    view_WashTypes.backgroundColor = [UIColor whiteColor];
    [mainScrollView addSubview:view_WashTypes];
    view_WashTypes.delegate = self;
    
    for (int i=0; i<[arrayWashTypes count]; i++)
    {
        UIButton *btnWashType = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnWashType setTitle:[arrayWashTypes objectAtIndex:i] forState:UIControlStateNormal];
        [btnWashType setImage:[UIImage imageNamed:[arrayWashImages objectAtIndex:i]] forState:UIControlStateNormal];
        [btnWashType setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        btnWashType.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-4];
        [view_WashTypes addSubview:btnWashType];
        
        btnWashType.frame = CGRectMake(xAxisWT, 0, 90*MULTIPLYHEIGHT, view_WashTypes.frame.size.height);
        [btnWashType centerImageAndTextWithSpacing:5*MULTIPLYHEIGHT];
        
        xAxisWT += 90*MULTIPLYHEIGHT;
    }
    
    view_WashTypes.contentSize = CGSizeMake(xAxisWT+10*MULTIPLYHEIGHT, view_WashTypes.frame.size.height);
    
    float btnAWidth = 25*MULTIPLYHEIGHT;
    
    UIButton *btnArrowType = [UIButton buttonWithType:UIButtonTypeCustom];
    btnArrowType.frame = CGRectMake((screen_width-btnAWidth)+5*MULTIPLYHEIGHT, view_WashTypes.frame.origin.y, btnAWidth, view_WashTypes.frame.size.height);
    //btnArrowType.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btnArrowType setImage:[UIImage imageNamed:@"right_arrow1"] forState:UIControlStateNormal];
    btnArrowType.backgroundColor = view_WashTypes.backgroundColor;
    [view_WashTypes addSubview:btnArrowType];
    
    if (view_WashTypes.contentSize.width < view_WashTypes.frame.size.width)
    {
        btnArrowType.hidden = YES;
    }
    
    ///////////////////////
    
    editbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    editbutton.backgroundColor = [UIColor clearColor];
    editbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    editbutton.frame = CGRectMake(view_WashTypes.frame.size.width-30, view_WashTypes.frame.origin.y, 40, 40);
    [editbutton addTarget:self action:@selector(editOrderClicked) forControlEvents:UIControlEventTouchUpInside];
    [editbutton setImage:[UIImage imageNamed:@"edit.png"] forState:UIControlStateNormal];
    [mainScrollView addSubview:editbutton];
    
    if ([self.strTaskStatus caseInsensitiveCompare:@"P"] == NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"A"] == NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame)
    {
        editbutton.hidden = YES;
    }
    else if ([self.strTaskStatus caseInsensitiveCompare:@"AD"] == NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"DE"] == NSOrderedSame)
    {
        editbutton.hidden = NO;
    }
    else
    {
        editbutton.hidden = YES;
    }
    
    [self updateUIdetails];
    
    // Bottom Details
    
    UIView *view_bottom = [[UIView alloc]initWithFrame:CGRectMake(10, view_WashTypes.frame.origin.y+view_WashTypes.frame.size.height+10, screen_width-20, 70)];
    view_bottom.backgroundColor = [UIColor whiteColor];
    [mainScrollView addSubview:view_bottom];
    
    
    NSMutableArray *arrayTitles = [[NSMutableArray alloc]init];
    NSMutableArray *arrayImages = [[NSMutableArray alloc]init];
    
    if ([self.strDirection caseInsensitiveCompare:@"pickup"] == NSOrderedSame)
    {
        [arrayTitles addObject:@"PICKUP"];
        [arrayImages addObject:@"pickup_selected.png"];
    }
    else if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
    {
        [arrayTitles addObject:@"DELIVERY"];
        [arrayImages addObject:@"pickup_selected.png"];
    }
    
    if ([[orderDetailDic objectForKey:@"ctype"] caseInsensitiveCompare:@"vip"] == NSOrderedSame)
    {
        [arrayTitles addObject:@"VIP"];
        [arrayImages addObject:@"star_selected.png"];
    }
    else if ([[orderDetailDic objectForKey:@"ctype"] caseInsensitiveCompare:@"first time"] == NSOrderedSame)
    {
        [arrayTitles addObject:@"FIRST TIME"];
        [arrayImages addObject:@"firsttime_user.png"];
    }
    
    if ([[orderDetailDic objectForKey:@"isrecorder"] intValue] == 1)
    {
        [arrayTitles addObject:@"RECURRING"];
        [arrayImages addObject:@"recurring_selected"];
    }
    
    if ([[orderDetailDic objectForKey:@"deliverAtDoor"] intValue] == 1)
    {
        [arrayTitles addObject:@"DROP AT DOOR"];
        [arrayImages addObject:@"dropatdoor_selected.png"];
    }
    
    if ([[orderDetailDic objectForKey:@"istourist"] intValue] == 1)
    {
        [arrayTitles addObject:@"TOURIST"];
        [arrayImages addObject:@"dropatdoor_selected.png"];
    }
    
    if ([[orderDetailDic objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] == NSOrderedSame)
    {
        [arrayTitles addObject:@"COD"];
        [arrayImages addObject:@"cash_icon"];
    }
    else
    {
        [arrayTitles addObject:@"CARD"];
        [arrayImages addObject:@"creditcard"];
    }
    
    NSInteger count;
    
    if ([arrayTitles count] >= 4)
    {
        count = 4;
    }
    else
    {
        count = [arrayTitles count];
    }
    
    customWidth = view_bottom.frame.size.width/count;
    
    float yAxis = 0;
    
    for (int i=0; i<[arrayTitles count];)
    {
        
        xAxis = 0;
        
        if (i == count)
        {
            count = [arrayTitles count]-count;
        }
        
        for (int j = 0; j<count; j++, i++)
        {
            UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
            rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
            rightbutton.frame = CGRectMake(xAxis, yAxis, customWidth, 70);
            [rightbutton setTitleColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            rightbutton.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:11.0];
            rightbutton.userInteractionEnabled = NO;
            [rightbutton setTitle:[arrayTitles objectAtIndex:i] forState:UIControlStateNormal];
            [rightbutton setImage:[UIImage imageNamed:[arrayImages objectAtIndex:i]] forState:UIControlStateNormal];
            [view_bottom addSubview:rightbutton];
            
            [rightbutton centerImageAndTextWithSpacing:7.0];
            
            xAxis += customWidth;
            
        }
        
        yAxis += 70;
        
    }
    
    CGRect frame_Bottom = view_bottom.frame;
    frame_Bottom.size.height = yAxis;
    view_bottom.frame = frame_Bottom;
    
    float yPos = view_bottom.frame.origin.y+view_bottom.frame.size.height+10;
    
    if ([[orderDetailDic objectForKey:PROMO_CODE] length])
    {
        UIButton *promocodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        promocodeBtn.frame = CGRectMake(10, yPos, screen_width-20, 45);
        promocodeBtn.backgroundColor = [UIColor clearColor];
        [promocodeBtn setBackgroundImage:[UIImage imageNamed:@"promocode_bg"] forState:UIControlStateNormal];
        [mainScrollView addSubview:promocodeBtn];
        
        NSString *str1 = [orderDetailDic objectForKey:PROMO_CODE];
        NSString *str2 = [orderDetailDic objectForKey:@"pcmsg"];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@", str1, str2]];
        
        [attr setAttributes:@{NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:14.0], NSForegroundColorAttributeName : BLUE_COLOR} range:NSMakeRange(0, str1.length)];
        
        [attr setAttributes:@{NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:13.0], NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(str1.length+1, str2.length)];
        
        [promocodeBtn setAttributedTitle:attr forState:UIControlStateNormal];
        
        yPos += 55;
    }
    
    //    if ([[orderDetailDic objectForKey:@"prf"] caseInsensitiveCompare:@"Y"] == NSOrderedSame)
    //    {
    //        UIButton *btnPre = [UIButton buttonWithType:UIButtonTypeCustom];
    //        btnPre.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //        btnPre.frame = CGRectMake(10, yPos, screen_width-20, 40);
    //        [btnPre setTitle:@"PREFERENCES" forState:UIControlStateNormal];
    //        [btnPre setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0]];
    //        [btnPre setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //        btnPre.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:14.0];
    //        [btnPre addTarget:self action:@selector(openPreferences:) forControlEvents:UIControlEventTouchUpInside];
    //        [mainScrollView addSubview:btnPre];
    //
    //
    //        yPos += 50;
    //    }
    
    UIButton *btnPre = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPre.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btnPre.frame = CGRectMake(10, yPos, screen_width-20, 40);
    [btnPre setTitle:@"PREFERENCES" forState:UIControlStateNormal];
    [btnPre setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0]];
    [btnPre setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnPre.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:14.0];
    [btnPre addTarget:self action:@selector(openPreferences:) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:btnPre];
    
    
    yPos += 50;
    
    
    UIButton *btnDirection = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDirection.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btnDirection.frame = CGRectMake(10, yPos, screen_width-20, 50);
    [btnDirection setImage:[UIImage imageNamed:@"get_direction_white.png"] forState:UIControlStateNormal];
    [btnDirection setTitle:@"GET DIRECTION" forState:UIControlStateNormal];
    [btnDirection setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0]];
    [btnDirection setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnDirection.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:14.0];
    //[btnDirection addTarget:self action:@selector(getDirectionClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [btnDirection addTarget:self action:@selector(openInMapsWasClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [mainScrollView addSubview:btnDirection];
    
    [mainScrollView setContentSize:CGSizeMake(mainScrollView.frame.size.width, btnDirection.frame.origin.y+btnDirection.frame.size.height+30)];
    
    
    btnCloseMapView = [UIButton buttonWithType:UIButtonTypeCustom];
    btnCloseMapView.imageView.contentMode = UIViewContentModeScaleAspectFit;
    btnCloseMapView.frame = CGRectMake(screen_width-50, 30, 44, 44);
    [btnCloseMapView setImage:[UIImage imageNamed:@"cancelorder_blue.png"] forState:UIControlStateNormal];
    [btnCloseMapView addTarget:self action:@selector(closeMapviewClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCloseMapView];
    btnCloseMapView.hidden = YES;
    
    btnPhone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPhone.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btnPhone setImage:[UIImage imageNamed:@"phone_icon_seleted_New.png"] forState:UIControlStateNormal];
    [btnPhone addTarget:self action:@selector(callBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    btnPhone.frame = CGRectMake(screen_width-50, 70, 44, 44);
    [self.view addSubview:btnPhone];
    btnPhone.hidden = YES;
    
    
    
    // ADD ITEMS
    
    {
        itemDetailsView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, screen_width, screen_height- 64)];
        itemDetailsView.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
        
        whiteBG = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screen_width, 40)];
        whiteBG.backgroundColor = [UIColor whiteColor];
        [itemDetailsView addSubview:whiteBG];
        
        float xAxis = 0;
        float width = 0;
        
        if ([self.strDirection caseInsensitiveCompare:@"Pickup"] == NSOrderedSame)
        {
            width = 60*MULTIPLYHEIGHT;
            
            addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addBtn.frame = CGRectMake(0, 0, width, whiteBG.frame.size.height);
            addBtn.backgroundColor = [UIColor clearColor];
            addBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
            [addBtn setTitle:@"+ Add bag" forState:UIControlStateNormal];
            [addBtn setTitleColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [addBtn setTitleColor:[[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
            [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:addBtn];
            
            xAxis += width;
            width = 75*MULTIPLYHEIGHT;
            
            btnPrefs = [UIButton buttonWithType:UIButtonTypeCustom];
            btnPrefs.frame = CGRectMake(xAxis, 0, width, whiteBG.frame.size.height);
            btnPrefs.backgroundColor = [UIColor clearColor];
            btnPrefs.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
            [btnPrefs setTitle:@"+ Preferences" forState:UIControlStateNormal];
            [btnPrefs setTitleColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [btnPrefs setTitleColor:[[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
            [btnPrefs addTarget:self action:@selector(btnPrefsClicked) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:btnPrefs];
            
            xAxis += width;
            width = 70*MULTIPLYHEIGHT;
            
            btnSpecialCare = [UIButton buttonWithType:UIButtonTypeCustom];
            btnSpecialCare.frame = CGRectMake(xAxis, 0, width, whiteBG.frame.size.height);
            btnSpecialCare.backgroundColor = [UIColor clearColor];
            btnSpecialCare.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
            [btnSpecialCare setTitle:@"Special Care" forState:UIControlStateNormal];
            [btnSpecialCare setTitleColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [btnSpecialCare setTitleColor:[[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
            [btnSpecialCare addTarget:self action:@selector(btnSpecialCareClicked) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:btnSpecialCare];
            
            xAxis += width;
            width = 80*MULTIPLYHEIGHT;
            
            conformOrderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            conformOrderBtn.frame = CGRectMake(xAxis, 3, width, whiteBG.frame.size.height-6);
            conformOrderBtn.backgroundColor = [UIColor clearColor];
            conformOrderBtn.backgroundColor = BLUE_COLOR;
            conformOrderBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
            [conformOrderBtn setTitle:@"Confirm order" forState:UIControlStateNormal];
            conformOrderBtn.titleLabel.numberOfLines = 0;
            [conformOrderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [conformOrderBtn addTarget:self action:@selector(conformOrderBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:conformOrderBtn];
            
            xAxis += width+5*MULTIPLYHEIGHT;
            width = 100*MULTIPLYHEIGHT;
            
            confirmOrderWithoutBags = [UIButton buttonWithType:UIButtonTypeCustom];
            confirmOrderWithoutBags.frame = CGRectMake(xAxis, 3, width, whiteBG.frame.size.height-6);
            confirmOrderWithoutBags.backgroundColor = [UIColor clearColor];
            confirmOrderWithoutBags.backgroundColor = BLUE_COLOR;
            confirmOrderWithoutBags.titleLabel.textAlignment = NSTextAlignmentCenter;
            confirmOrderWithoutBags.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3];
            [confirmOrderWithoutBags setTitle:@"Confirm order\nWithout entering bags" forState:UIControlStateNormal];
            confirmOrderWithoutBags.titleLabel.numberOfLines = 0;
            [confirmOrderWithoutBags setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [confirmOrderWithoutBags addTarget:self action:@selector(confirmOrderWithoutBagsEntering) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:confirmOrderWithoutBags];
        }
        else
        {
            
            width = 60*MULTIPLYHEIGHT;
            
            btnOptions = [UIButton buttonWithType:UIButtonTypeCustom];
            btnOptions.frame = CGRectMake(xAxis, 0, width, whiteBG.frame.size.height);
            btnOptions.titleLabel.textAlignment = NSTextAlignmentLeft;
            btnOptions.backgroundColor = [UIColor clearColor];
            btnOptions.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
            [btnOptions setTitle:@"Options" forState:UIControlStateNormal];
            [btnOptions setTitleColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [btnOptions setTitleColor:[[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
            [btnOptions addTarget:self action:@selector(btnOptionsClicked:) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:btnOptions];
            btnOptions.hidden = YES;
            
            
            xAxis += width;
            width = 80*MULTIPLYHEIGHT;
            
            btnStartScan = [UIButton buttonWithType:UIButtonTypeCustom];
            btnStartScan.frame = CGRectMake(xAxis, 3, width, whiteBG.frame.size.height-6);
            btnStartScan.backgroundColor = [UIColor clearColor];
            btnStartScan.backgroundColor = BLUE_COLOR;
            btnStartScan.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
            [btnStartScan setTitle:@"Start Scan" forState:UIControlStateNormal];
            btnStartScan.titleLabel.numberOfLines = 0;
            [btnStartScan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnStartScan addTarget:self action:@selector(startScanClicked) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:btnStartScan];
            btnStartScan.hidden = YES;
            
            xAxis += width+5*MULTIPLYHEIGHT;
            width = 80*MULTIPLYHEIGHT;
            
            conformOrderBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            conformOrderBtn.frame = CGRectMake(xAxis, 3, width, whiteBG.frame.size.height-6);
            conformOrderBtn.backgroundColor = [UIColor clearColor];
            conformOrderBtn.backgroundColor = BLUE_COLOR;
            conformOrderBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
            [conformOrderBtn setTitle:@"Confirm order" forState:UIControlStateNormal];
            conformOrderBtn.titleLabel.numberOfLines = 0;
            [conformOrderBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [conformOrderBtn addTarget:self action:@selector(conformOrderBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [whiteBG addSubview:conformOrderBtn];
            
            if ([appDel.dictScannedBags objectForKey:[self.orderDetailDic objectForKey:@"oid"]])
            {
                
            }
            else
            {
                conformOrderBtn.hidden = YES;
            }
            
            if ([[self.orderDetailDic objectForKey:@"partial"] intValue] == 0)
            {
                xAxis += width+5*MULTIPLYHEIGHT;
                width = 140*MULTIPLYHEIGHT;
                
                confirmWOPayment = [UIButton buttonWithType:UIButtonTypeCustom];
                confirmWOPayment.frame = CGRectMake(xAxis, 3, width, whiteBG.frame.size.height-6);
                confirmWOPayment.titleLabel.textAlignment = NSTextAlignmentCenter;
                confirmWOPayment.backgroundColor = BLUE_COLOR;
                confirmWOPayment.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3];
                [confirmWOPayment setTitle:@"Confirm order\nwithout payment" forState:UIControlStateNormal];
                confirmWOPayment.titleLabel.numberOfLines = 0;
                [confirmWOPayment setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [confirmWOPayment addTarget:self action:@selector(confirmOrderWithoutPayment) forControlEvents:UIControlEventTouchUpInside];
                [whiteBG addSubview:confirmWOPayment];
                
                if ([appDel.dictScannedBags objectForKey:[self.orderDetailDic objectForKey:@"oid"]])
                {
                    
                }
                else
                {
                    confirmWOPayment.hidden = YES;
                }
            }
        }
        
        xAxis += width+10*MULTIPLYHEIGHT;
        
        whiteBG.contentSize = CGSizeMake(xAxis, whiteBG.frame.size.height);
        
        
        itemDetailsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, screen_width, screen_height-240.0) style:UITableViewStylePlain];
        itemDetailsTableView.delegate = self;
        itemDetailsTableView.dataSource = self;
        itemDetailsTableView.opaque = NO;
        itemDetailsTableView.backgroundColor = [UIColor clearColor];
        itemDetailsTableView.backgroundView = nil;
        itemDetailsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [itemDetailsView addSubview:itemDetailsTableView];
        
        if ([self.strDirection caseInsensitiveCompare:@"Pickup"] != NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame)
        {
            totalAmountView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(itemDetailsView.frame)-120, screen_width, 120.0)];
            totalAmountView.backgroundColor = [UIColor colorWithRed:23.0/255.0 green:46.0/255.0 blue:56.0/255.0 alpha:1.0];
            
            float yAx = 0;
            
            lblWalletText = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yAx, screen_width - 150-15, 30.0)];
            lblWalletText.text = @"PIING! CREDITS";
            lblWalletText.font = [UIFont fontWithName:APPFONT_LIGHT size:13.0];
            lblWalletText.backgroundColor = [UIColor clearColor];
            lblWalletText.textColor = [UIColor whiteColor];
            [totalAmountView addSubview:lblWalletText];
            
            lblWalletAmount = [[UILabel alloc] initWithFrame:CGRectMake(screen_width - 140.0, 0, 120, 30.0)];
            lblWalletAmount.text = @"$0.00";
            lblWalletAmount.textAlignment = NSTextAlignmentRight;
            lblWalletAmount.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:14.0];
            lblWalletAmount.backgroundColor = [UIColor clearColor];
            lblWalletAmount.textColor = [UIColor colorWithRed:182.0/255.0 green:143.0/255.0 blue:7.0/255.0 alpha:1.0];
            [totalAmountView addSubview:lblWalletAmount];
            
            yAx += 30;
            
            UILabel *lblDiscountText = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yAx, screen_width - 150-15, 30.0)];
            lblDiscountText.text = @"Discount Amount";
            lblDiscountText.font = [UIFont fontWithName:APPFONT_LIGHT size:13.0];
            lblDiscountText.backgroundColor = [UIColor clearColor];
            lblDiscountText.textColor = [UIColor whiteColor];
            [totalAmountView addSubview:lblDiscountText];
            
            lblDiscountAmount = [[UILabel alloc] initWithFrame:CGRectMake(screen_width - 140.0, yAx, 120, 30.0)];
            lblDiscountAmount.text = @"$0.00";
            lblDiscountAmount.textAlignment = NSTextAlignmentRight;
            lblDiscountAmount.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:14.0];
            lblDiscountAmount.backgroundColor = [UIColor clearColor];
            lblDiscountAmount.textColor = [UIColor colorWithRed:182.0/255.0 green:143.0/255.0 blue:7.0/255.0 alpha:1.0];
            [totalAmountView addSubview:lblDiscountAmount];
            
            yAx += 30;
            
            lblGSTAmountText = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yAx, screen_width - 150-15, 30.0)];
            lblGSTAmountText.text = @"GST";
            lblGSTAmountText.font = [UIFont fontWithName:APPFONT_LIGHT size:13.0];
            lblGSTAmountText.backgroundColor = [UIColor clearColor];
            lblGSTAmountText.textColor = [UIColor whiteColor];
            [totalAmountView addSubview:lblGSTAmountText];
            
            lblGSTAmountValue = [[UILabel alloc] initWithFrame:CGRectMake(screen_width - 140.0, yAx, 120, 30.0)];
            lblGSTAmountValue.text = @"$0.00";
            lblGSTAmountValue.textAlignment = NSTextAlignmentRight;
            lblGSTAmountValue.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:14.0];
            lblGSTAmountValue.backgroundColor = [UIColor clearColor];
            lblGSTAmountValue.textColor = [UIColor colorWithRed:182.0/255.0 green:143.0/255.0 blue:7.0/255.0 alpha:1.0];
            [totalAmountView addSubview:lblGSTAmountValue];
            
            yAx += 30;
            
            reconcileTitleLbl = [[UILabel alloc] initWithFrame:CGRectMake(15.0, yAx, screen_width - 150-15, 30.0)];
            //reconcileTitleLbl.text = @"Estimated Amount";
            reconcileTitleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:18.0];
            reconcileTitleLbl.backgroundColor = [UIColor clearColor];
            reconcileTitleLbl.textColor = [UIColor whiteColor];
            [totalAmountView addSubview:reconcileTitleLbl];
            
            //Itemdetails
            if ([self.strDirection caseInsensitiveCompare:@"Pickup"] == NSOrderedSame)
            {
                reconcileTitleLbl.text = @"Estimated Amount";
            }
            else
            {
                reconcileTitleLbl.text = @"Final Amount";
            }
            
            
            totalAmount = [[UILabel alloc] initWithFrame:CGRectMake(screen_width - 140.0, yAx, 120, 30.0)];
            totalAmount.text = @"$0.00";
            totalAmount.textAlignment = NSTextAlignmentRight;
            totalAmount.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:20.0];
            totalAmount.backgroundColor = [UIColor clearColor];
            totalAmount.textColor = [UIColor colorWithRed:182.0/255.0 green:143.0/255.0 blue:7.0/255.0 alpha:1.0];
            [totalAmountView addSubview:totalAmount];
            
            [itemDetailsView addSubview:totalAmountView];
        }
        else
        {
            itemDetailsTableView.frame = CGRectMake(0, 50, screen_width, screen_height-120);
        }
        
        [self.view addSubview:itemDetailsView];
        
        itemDetailsView.hidden = YES;
    }
    
    
    [self reloadTableView];
    
    appDel.piingo_GoogleMap = [[GoogleMapView2 alloc] initWithFrame:CGRectMake(0, screen_height+10, screen_width, screen_height-64)];
    //[self.view addSubview:appDel.piingo_GoogleMap];
    appDel.piingo_GoogleMap.hidden = YES;
    
    [appDel.dict_UserLocation setObject:[dictAddress objectForKey:@"lat"] forKey:@"lat"];
    [appDel.dict_UserLocation setObject:[dictAddress objectForKey:@"lon"] forKey:@"lon"];
    
    
    //    // And let's set our callback URL right away!
    //    [OpenInGoogleMapsController sharedInstance].callbackURL =
    //    [NSURL URLWithString:kOpenInMapsSampleURLScheme];
    //
    //    // If the user doesn't have Google Maps installed, let's try Chrome. And if they don't
    //    // have Chrome installed, let's use Apple Maps. This gives us the best chance of having an
    //    // x-callback-url that points back to our application.
    //    [OpenInGoogleMapsController sharedInstance].fallbackStrategy =
    //    kGoogleMapsFallbackChromeThenAppleMaps;
    
    
    viewMap = [[UIView alloc]initWithFrame:CGRectMake(0, screen_height+10, screen_width, screen_height-64)];
    viewMap.backgroundColor = [UIColor grayColor];
    [self.view addSubview:viewMap];
    
    
    
    //    //map view
    //    NMAMapView* mapView = [[NMAMapView alloc] initWithFrame:CGRectMake(0, screen_height+10, screen_width, screen_height-64)];
    //    [self.view addSubview:mapView];
    //    self.mapView = mapView;
    //    self.mapView.delegate = self;
    //
    //
    //    self.mapView.extrudedBuildingsVisible = YES;
    //    self.mapView.copyrightLogoPosition = NMALayoutPositionBottomRight;
    //    [self.mapView setOrientation:0 withAnimation:NMAMapAnimationNone];
    //    [self.mapView setTilt:0];
    //    self.mapView.zoomLevel = 14.68;
    //    self.mapView.positionIndicator.visible = YES;
    //    self.mapView.positionIndicator.accuracyIndicatorVisible = YES;
    //    
    //    //center map to current location
    //    [self centerBtnClicked:nil];
    
    
    [self setUpGeofences];
}


-(void) moveScrollLast
{
    CGPoint bottomOffset = CGPointMake(whiteBG.contentSize.width - whiteBG.bounds.size.width, 0);
    
    [whiteBG setContentOffset:bottomOffset animated:YES];
    
    [self performSelector:@selector(moveScrolltoOriginal) withObject:nil afterDelay:1.0f];
}

-(void) moveScrolltoOriginal
{
    [whiteBG setContentOffset:CGPointZero animated:YES];
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    
    CGFloat pageWidth = scrollViewWashType.frame.size.width;
    float fractionalPage = scrollViewWashType.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    [segmentCleaning setSelectedSegmentIndex:page animated:YES];
    
    float widthe = 0.0;
    float offset = 0.0;
    
    if (page == 0)
    {
        widthe = 28*MULTIPLYHEIGHT;
        offset = -60*MULTIPLYHEIGHT;
    }
    else if (page == 1)
    {
        widthe = 10*MULTIPLYHEIGHT;
        offset = 65*MULTIPLYHEIGHT;
    }
    else if (page == 2)
    {
        widthe = 28*MULTIPLYHEIGHT;
        offset = 185*MULTIPLYHEIGHT;
    }
    
    //[segmentCleaning.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

-(void) offsetChange
{
    //[segmentCleaning.scrollView setContentOffset:CGPointMake(-60*MULTIPLYHEIGHT, 0) animated:YES];
}

-(void) segmentedControlChangedValue:(HMSegmentedControl *)segment
{
    float widthe = 0.0;
    float offset = 0.0;
    
    if (segment.selectedSegmentIndex == 0)
    {
        widthe = 28*MULTIPLYHEIGHT;
        offset = -60*MULTIPLYHEIGHT;
    }
    else if (segment.selectedSegmentIndex == 1)
    {
        widthe = 10*MULTIPLYHEIGHT;
        offset = 65*MULTIPLYHEIGHT;
    }
    else if (segment.selectedSegmentIndex == 2)
    {
        widthe = 28*MULTIPLYHEIGHT;
        offset = 185*MULTIPLYHEIGHT;
    }
    
    [scrollViewWashType setContentOffset:CGPointMake(scrollViewWashType.frame.size.width*segment.selectedSegmentIndex, 0) animated:YES];
    
    //[segmentCleaning.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

-(void) didStartScroll:(HMSegmentedControl *)segmentControl Scroller:(UIScrollView *)scrollView
{
    //    float scrollViewWidth = scrollView.frame.size.width;
    //    float scrollContentSizeWidth = scrollView.contentSize.width;
    //    float scrollOffset = scrollView.contentOffset.x;
    //
    //    //    if (scrollOffset == 0)
    //    //    {
    //    //        // then we are at the top
    //    //    }
    //    if (scrollOffset + scrollViewWidth < scrollContentSizeWidth)
    //    {
    //        //viewArrow.hidden = NO;
    //    }
    //    else if (scrollOffset + scrollViewWidth >= scrollContentSizeWidth)
    //    {
    //        //viewArrow.hidden = YES;
    //    }
}

-(void) scrollAnimated
{
    return;
    
    float scrollViewWidth = segmentCleaning.scrollView.frame.size.width;
    float scrollContentSizeWidth = segmentCleaning.scrollView.contentSize.width;
    float scrollOffset = segmentCleaning.scrollView.contentOffset.x;
    
    segmentCleaning.scrollView.contentOffset = CGPointMake(scrollOffset+30*MULTIPLYHEIGHT, segmentCleaning.scrollView.contentOffset.y);
    
    //    if (scrollOffset == 0)
    //    {
    //        // then we are at the top
    //    }
    if (scrollOffset + scrollViewWidth < scrollContentSizeWidth)
    {
        //viewArrow.hidden = NO;
    }
    else if (scrollOffset + scrollViewWidth >= scrollContentSizeWidth)
    {
        //viewArrow.hidden = YES;
    }
}


-(void) btnSpecialCareClicked
{
    NSArray *array1 = [self.orderInfo objectForKey:PREFERENCES_SELECTED];
    
    BOOL specialCareNoteFound = NO;
    NSString *strSpecialCare = @"";
    
    for (NSDictionary *dict2 in array1)
    {
        if ([[dict2 objectForKey:@"name"] caseInsensitiveCompare:@"specialCareNote"] == NSOrderedSame)
        {
            strSpecialCare = [dict2 objectForKey:@"value"];
            
            specialCareNoteFound = YES;
        }
    }
    
    if (!specialCareNoteFound)
    {
        NSMutableArray *array2 = [[NSMutableArray alloc]initWithArray:array1];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
        [dict setObject:@"specialCareNote" forKey:@"name"];
        [dict setObject:@"" forKey:@"value"];
        
        [array2 addObject:dict];
        
        [self.orderInfo setObject:array2 forKey:PREFERENCES_SELECTED];
    }
    
    view_Custom = [[UIView alloc]initWithFrame:appDel.window.bounds];
    view_Custom.backgroundColor = [UIColor whiteColor];
    [appDel.window addSubview:view_Custom];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"cancel_grey"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(btnCloseClicked) forControlEvents:UIControlEventTouchUpInside];
    [view_Custom addSubview:btnClose];
    
    btnClose.frame = CGRectMake(screen_width-50, 20, 44, 44);
    
    float yAxis = 20*MULTIPLYHEIGHT;
    UILabel *lblt = [[UILabel alloc]init];
    lblt.text = @"Special care notes:";
    lblt.textColor = [UIColor grayColor];
    lblt.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
    [view_Custom addSubview:lblt];
    
    float lblX = 10*MULTIPLYHEIGHT;
    float lblHeight = 20*MULTIPLYHEIGHT;
    
    lblt.frame = CGRectMake(lblX, yAxis, screen_width-(lblX*2), lblHeight);
    
    yAxis += lblHeight+5*MULTIPLYHEIGHT;
    
    float tvX = 25*MULTIPLYHEIGHT;
    float tvW = 220*MULTIPLYHEIGHT;
    float tvH = 190*MULTIPLYHEIGHT;
    
    tvSpecialCare = [[UITextView alloc]initWithFrame:CGRectMake(tvX, yAxis, tvW, tvH)];
    tvSpecialCare.delegate = self;
    tvSpecialCare.backgroundColor = RGBCOLORCODE(240, 240, 240, 1.0);
    tvSpecialCare.textColor = [UIColor darkGrayColor];
    [view_Custom addSubview:tvSpecialCare];
    
    tvSpecialCare.textColor = [UIColor darkGrayColor];
    tvSpecialCare.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
    tvSpecialCare.text = strSpecialCare;
    
    UIToolbar* tvToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    tvToolbar.barTintColor = [UIColor whiteColor];
    tvToolbar.items = [NSArray arrayWithObjects:
                       [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                       [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)], nil];
    [tvToolbar sizeToFit];
    tvSpecialCare.inputAccessoryView = tvToolbar;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [view_Custom addSubview:btnDone];
    [btnDone setImage:[UIImage imageNamed:@"save_pref"] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
    [btnDone addTarget:self action:@selector(saveSpecialCareNotes) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"SAVE"];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:RGBCOLORCODE(170, 170, 170, 1.0)} range:NSMakeRange(0, [attr length])];
    float spacing = 1.0f;
    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
    [btnDone setAttributedTitle:attr forState:UIControlStateNormal];
    
    [btnDone centerImageAndTextWithSpacing:5*MULTIPLYHEIGHT];
    
    UIEdgeInsets titleInsets = btnDone.titleEdgeInsets;
    titleInsets.left -= 3*MULTIPLYHEIGHT;
    btnDone.titleEdgeInsets = titleInsets;
    
    float btnDW = 100*MULTIPLYHEIGHT;
    
    btnDone.frame = CGRectMake(screen_width/2-btnDW/2, screen_height-50*MULTIPLYHEIGHT, btnDW, 40*MULTIPLYHEIGHT);
    
    [tvSpecialCare becomeFirstResponder];

}

-(void) saveSpecialCareNotes
{
    if ([tvSpecialCare.text length])
    {
        NSArray *array1 = [self.orderInfo objectForKey:PREFERENCES_SELECTED];
        
        NSMutableArray *arra = [[NSMutableArray alloc]init];
        
        for (NSDictionary *dict2 in array1)
        {
            NSMutableDictionary *dictMain  = [[NSMutableDictionary alloc]init];
            
            if ([[dict2 objectForKey:@"name"] caseInsensitiveCompare:@"specialCareNote"] == NSOrderedSame)
            {
                [dictMain setObject:tvSpecialCare.text forKey:@"value"];
                [dictMain setObject:@"specialCareNote" forKey:@"name"];
            }
            else
            {
                [dictMain setObject:[dict2 objectForKey:@"value"] forKey:@"value"];
                [dictMain setObject:[dict2 objectForKey:@"name"] forKey:@"name"];
            }
            
            [arra addObject:dictMain];
        }
        
        [self.orderInfo setObject:arra forKey:PREFERENCES_SELECTED];
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        
        [dic setObject:appDel.strCobId forKey:@"oid"];
        [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN] forKey:@"t"];
        [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"pid"];
        [dic setObject:arra forKey:@"preferences"];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/save/preferences", BASE_URL];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if([[responseObj objectForKey:@"s"] intValue] == 1)
            {
                [appDel showAlertWithMessage:@"Special care saved." andTitle:@"" andBtnTitle:@"OK"];
                
                for (UIView *view in view_Custom.subviews)
                {
                    [view removeFromSuperview];
                }
                
                [view_Custom removeFromSuperview];
                view_Custom = nil;
            }
            else {
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
            
        }];
    }
    else
    {
        [appDel showAlertWithMessage:@"Please enter special care notes." andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) doneClicked
{
    [tvPaymentNotes resignFirstResponder];
    [tvSpecialCare resignFirstResponder];
}



-(void) btnPrefsClicked
{
    if (statusDisplayButton.enabled == NO)
    {
        NSArray *array1 = [self.orderInfo objectForKey:PREFERENCES_SELECTED];
        
        NSMutableDictionary *dictMain  = [[NSMutableDictionary alloc]init];
        
        for (NSDictionary *dict2 in array1)
        {
            if ([dict2 objectForKey:@"value"])
            {
                [dictMain setObject:[dict2 objectForKey:@"value"] forKey:[dict2 objectForKey:@"name"]];
            }
            else
            {
                [dictMain setObject:@"" forKey:[dict2 objectForKey:@"name"]];
            }
        }
        
        NSMutableString *strPref = [@"" mutableCopy];
        
        if ([dictMain count])
        {
            [strPref appendString:@"["];
            
            for (NSString *strakey in dictMain)
            {
                [strPref appendFormat:@"%@", [NSString stringWithFormat:@"{\"name\":\"%@\",\"value\":\"%@\"},", strakey, [dictMain objectForKey:strakey]]];
            }
            
            if ([strPref hasSuffix:@","])
            {
                strPref = [[strPref substringToIndex:[strPref length]-1]mutableCopy];
            }
            
            [strPref appendString:@"]"];
        }
        
        PreferencesViewController *objPre = [[PreferencesViewController alloc]init];
        objPre.delegate = self;
        objPre.strPrefs = strPref;
        [self presentViewController:objPre animated:YES completion:nil];
    }
    else
    {
        [appDel showAlertWithMessage:@"Please check that you are At The Door." andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) openPreferences:(UIButton *) btn
{
    NSArray *array1 = [self.orderInfo objectForKey:PREFERENCES_SELECTED];
    
    NSMutableDictionary *dictMain  = [[NSMutableDictionary alloc]init];
    
    for (NSDictionary *dict2 in array1)
    {
        if ([dict2 objectForKey:@"value"])
        {
            [dictMain setObject:[dict2 objectForKey:@"value"] forKey:[dict2 objectForKey:@"name"]];
        }
        else
        {
            [dictMain setObject:@"" forKey:[dict2 objectForKey:@"name"]];
        }
    }
    
    NSMutableString *strPref = [@"" mutableCopy];
    
    if ([dictMain count])
    {
        [strPref appendString:@"["];
        
        for (NSString *strakey in dictMain)
        {
            [strPref appendFormat:@"%@", [NSString stringWithFormat:@"{\"name\":\"%@\",\"value\":\"%@\"},", strakey, [dictMain objectForKey:strakey]]];
        }
        
        if ([strPref hasSuffix:@","])
        {
            strPref = [[strPref substringToIndex:[strPref length]-1]mutableCopy];
        }
        
        [strPref appendString:@"]"];
    }
    
    PreferencesViewController *objPre = [[PreferencesViewController alloc]init];
    objPre.strPrefs = strPref;
    [self presentViewController:objPre animated:YES completion:nil];
}

-(void) didAddPreferences:(NSString *)strPref
{
    NSData *data = [strPref dataUsingEncoding:NSUTF8StringEncoding];
    id jsonItem = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    
    [dic setObject:appDel.strCobId forKey:@"oid"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN] forKey:@"t"];
    [dic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"pid"];
    [dic setObject:jsonItem forKey:@"preferences"];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/save/preferences", BASE_URL];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if([[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [appDel showAlertWithMessage:@"Preferences saved." andTitle:@"" andBtnTitle:@"OK"];
        }
        else {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
}


-(void) setUpGeofences
{
//    self.locationManager = [CLLocationManager new];
//    
//    CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[appDel.dict_UserLocation objectForKey:@"lat"] doubleValue],
//                                                               [[appDel.dict_UserLocation objectForKey:@"lon"] doubleValue]);
//    
//    bridge = [[CLCircularRegion alloc]initWithCenter:center radius:100.0 identifier:@"Bridge"];
//    
//    [self.locationManager startMonitoringForRegion:bridge];
}

//- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
//{
//    NSLog(@"Entered Region - %@", region.identifier);
//    
//    if ([[orderDetailDic objectForKey:@"osid"] intValue] == 3 || [[orderDetailDic objectForKey:@"osid"] intValue] == 18 || [[orderDetailDic objectForKey:@"osid"] intValue] == 32)
//    {
//        automaticStartOrder = YES;
//        
//        [self startServiceCalled];
//    }
//    
//    else if ([[orderDetailDic objectForKey:@"osid"] intValue] == 28 || [[orderDetailDic objectForKey:@"osid"] intValue] == 29)
//    {
//        [self atTheDoorClicked];
//    }
//    
//    [appDel showAlertWithMessage:@"You are At the Door of customer." andTitle:@"" andBtnTitle:@"OK"];
//}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"Exited Region - %@", region.identifier);
    // post a notification
}

//-(void)centerBtnClicked:(id)sender
//{
//    NMAGeoCoordinates *geoCoordCenter = nil;
//    //NMAGeoPosition* pos = [[NMAPositioningManager sharedPositioningManager] currentPosition];
//
//    geoCoordCenter = [NMAGeoCoordinates geoCoordinatesWithLatitude:[appDel.latitude doubleValue] longitude:[appDel.longitude doubleValue]];
//
////    if (pos)
////    {
////        geoCoordCenter = pos.coordinates;
////    }
////    else
////    {
////        geoCoordCenter = [NMAGeoCoordinates geoCoordinatesWithLatitude:[appDel.latitude doubleValue] longitude:[appDel.longitude doubleValue]];
////    }
//
//    [self.mapView setGeoCenter:geoCoordCenter withAnimation:NMAMapAnimationNone];
//}


-(void) updatedOrderAndRefresh
{
    [self gotoBack];
}


-(void) editOrderClicked
{
    [self editOrder];
    
    return;
    
    strOSType = @"E";
    
    [self createSignatureView];
}

//-(void) getDirectionClicked:(id)sender
//{
//    
//    NSMutableArray* stopList = [NSMutableArray array];
//    
//    NMAGeoCoordinates *piingo_coordinate = [NMAGeoCoordinates geoCoordinatesWithLatitude:[appDel.latitude doubleValue] longitude:[appDel.longitude doubleValue]];
//    
//    NMAGeoCoordinates *user_coordinate = [NMAGeoCoordinates geoCoordinatesWithLatitude:[[appDel.dict_UserLocation objectForKey:@"lat"] doubleValue] longitude:[[appDel.dict_UserLocation objectForKey:@"lon"] doubleValue]];
//    
//    [stopList addObject:piingo_coordinate];
//    [stopList addObject:user_coordinate];
//    
//    NSLog(@"routing from [%.5f,%.5f] to [%.5f,%.5f]", ((NMAGeoCoordinates*)stopList[0]).latitude, ((NMAGeoCoordinates*)stopList[0]).longitude,
//          ((NMAGeoCoordinates*)stopList[1]).latitude, ((NMAGeoCoordinates*)stopList[1]).longitude);
//    
//    if (!self.router) {
//        self.router = [[NMACoreRouter alloc] init];
//    }
//    
//    _routingInProgress = YES;
//    
//    NMATransportMode transport = NMATransportModeCar;
//    
//    NMARoutingMode* routingMode = [[NMARoutingMode alloc] initWithRoutingType:NMARoutingTypeShortest
//                                                                transportMode:transport
//                                                               routingOptions:0];
//    
//    NSProgress *progress = [self.router calculateRouteWithStops:stopList routingMode:routingMode
//                                                completionBlock:^(NMARouteResult *routeResult, NMARoutingError error) {
//                                                    
//                                                    _routingInProgress = NO;
//                                                    
//                                                    if(error){
//                                                        NSLog(@"routing failed with error %lu", (unsigned long)error);
//                                                    }
//                                                    else if(!routeResult.routes || routeResult.routes.count == 0){
//                                                        NSLog(@"cannot obtain routes");
//                                                    }
//                                                    else{
//                                                        NSLog(@"%lu routes obtained", (unsigned long)routeResult.routes.count);
//                                                        
//                                                        self.route = routeResult.routes[0];
//                                                        
//                                                        if(self.mapRoute)
//                                                            [self.mapView removeMapObject:self.mapRoute];
//                                                        self.mapRoute = [NMAMapRoute mapRouteWithRoute:self.route];
//                                                        [self.mapView addMapObject:self.mapRoute];
//                                                        
//                                                        //focus on route
//                                                        [self.mapView setBoundingBox:self.route.boundingBox withAnimation:NMAMapAnimationLinear];
//                                                    }
//                                                }];
//    
//   
//    
//    NSTimeInterval timeElapsed = 0;
//    
//    while ((timeElapsed < routingTimeLimit) && _routingInProgress) {
//        NSLog(@"CoreRouter route calculation progress %f", progress.fractionCompleted);
//        [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:timeIncrement]];
//        timeElapsed += timeIncrement;
//    }
//    
//    if (_routingInProgress) {
//        // route calculation time-out, cancel the request
//        [self.router cancel];
//        NSLog(@"CoreRouter route calculation is cancelled");
//    }
//    
//    [self.view bringSubviewToFront:viewMap];
//    
//    [self.view bringSubviewToFront:self.mapView];
//    [self.view bringSubviewToFront:btnCloseMapView];
//    [self.view bringSubviewToFront:btnPhone];
//    
//    btnCloseMapView.hidden = NO;
//    btnPhone.hidden = NO;
//    
//    if (!btnNanv)
//    {
//        btnNanv = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnNanv.frame = CGRectMake(0, screen_height-50-20, screen_width, 50);
//        [btnNanv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btnNanv setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0]];
//        [btnNanv setTitle:@"Start turn by trun navigation" forState:UIControlStateNormal];
//        [btnNanv addTarget:self action:@selector(navigationBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//        
//        //[btnNanv addTarget:self action:@selector(openInMapsWasClicked:) forControlEvents:UIControlEventTouchUpInside];
//        
//        //[self.mapView addSubview:btnNanv];
//        
//        [viewMap addSubview:btnNanv];
//    }
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        viewMap.frame =  CGRectMake(0, 20, screen_width, screen_height-20);
//        
//        self.mapView.frame =  CGRectMake(0, 20, screen_width, screen_height-20);
//        self.navigationController.navigationBarHidden = YES;
//        
//    }];
//    
//    
//    return;
//    
//    
//    NSMutableDictionary *dictPiingo = [[NSMutableDictionary alloc]initWithObjectsAndKeys:appDel.latitude,@"lat",appDel.longitude,@"lon", nil];
//    
//    [appDel.piingo_GoogleMap addPiingoMarkder:dictPiingo];
//    
//    [appDel.piingo_GoogleMap addClientMarker:appDel.dict_UserLocation];
//    
//    
//    //[appDel.piingo_GoogleMap addMarker:dictPiingo withIndex:1];
//    
//    [appDel.piingo_GoogleMap focusMapToShowAllMarkers];
//    
//    [appDel performSelector:@selector(refreshGoogleMapsDirections) withObject:nil afterDelay:3];
//    
//    [self.view bringSubviewToFront:appDel.piingo_GoogleMap];
//    [self.view bringSubviewToFront:btnCloseMapView];
//    [self.view bringSubviewToFront:btnPhone];
//    
//    btnCloseMapView.hidden = NO;
//    btnPhone.hidden = NO;
//    
//    
//    if (!btnNanv)
//    {
//        btnNanv = [UIButton buttonWithType:UIButtonTypeCustom];
//        btnNanv.frame = CGRectMake(screen_width-120, screen_height-70, 100, 40);
//        [btnNanv setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [btnNanv setBackgroundColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0]];
//        [btnNanv setTitle:@"Map It!" forState:UIControlStateNormal];
//        [btnNanv addTarget:self action:@selector(openInMapsWasClicked:) forControlEvents:UIControlEventTouchUpInside];
//        [appDel.piingo_GoogleMap addSubview:btnNanv];
//    }
//    
//    
//    [UIView animateWithDuration:0.3 animations:^{
//        
//        viewMap.frame =  CGRectMake(0, 20, screen_width, screen_height-20);
//        
//        self.mapView.frame =  CGRectMake(0, 20, screen_width, screen_height-20);
//        
//        appDel.piingo_GoogleMap.frame = CGRectMake(0, 20, screen_width, screen_height-20);
//        self.navigationController.navigationBarHidden = YES;
//        [appDel.piingo_GoogleMap changeFrame];
//        
//    }];
//    
//}


//- (void)navigationManager:(NMANavigationManager*)navigationManager hasCurrentManeuver:(NMAManeuver*)maneuver nextManeuver:(NMAManeuver*)nextManeuver
//{
//    //if in background and navigation is running, send text guidance as local push notification
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
//       navigationManager.navigationState == NMANavigationStateRunning){
//
//        //update maneuver instruction
//        if(maneuver.nextRoadName && maneuver.nextRoadName.length > 0)
//        {
//            NSString* notiStr = [NSString stringWithFormat:@"next: %@ to %@", [self textForManeuverTurn:maneuver.turn], maneuver.nextRoadName];
//            [self postLocalNotification:notiStr];
//        }
//    }
//}
//
//- (void)navigationManagerDidLosePosition:(NMANavigationManager*)navigationManager
//{
//    //if in background and navigation is running, send text guidance as local push notification
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
//       navigationManager.navigationState == NMANavigationStateRunning){
//        [self postLocalNotification:@"GPS lost"];
//    }
//}
//
//- (void)navigationManagerDidFindPosition:(NMANavigationManager*)navigationManager
//{
//    //if in background and navigation is running, send text guidance as local push notification
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
//       navigationManager.navigationState == NMANavigationStateRunning){
//        [self postLocalNotification:@"GPS recovered"];
//    }
//}
//
//-(void)navigationManager:(NMANavigationManager *)navigationManager didUpdateRoute:(NMARoute *)route
//{
//    //remove existing route
//    if(self.mapRoute){
//        [self.mapView removeMapObject:self.mapRoute];
//    }
//
//    //add the new route
//    self.route = route;
//    self.mapRoute = [NMAMapRoute mapRouteWithRoute:self.route];
//    [self.mapView addMapObject:self.mapRoute];
//
//    //if in background and navigation is running, send text guidance as local push notification
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
//       navigationManager.navigationState == NMANavigationStateRunning){
//        [self postLocalNotification:@"Route updated"];
//    }
//}
//
//- (void)navigationManagerDidReachDestination:(NMANavigationManager*)navigationManager
//{
//    NSLog(@"navigationManagerDidReachDestination");
//    self.maneuverView.instructionLbl.text = @"Reached your destination";
//
//    //if in background and navigation is running, send text guidance as local push notification
//    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
//        [self postLocalNotification:@"Destination reached"];
//    }
//}
//
//-(void)handlePositionDidUpdate
//{
//    NMAManeuver* currentManeuver = [NMANavigationManager sharedNavigationManager].currentManeuver;
//
//    //if maneuver available and maneuver view visible, update distance
//    if(currentManeuver && self.maneuverView.hidden == NO){
//
//        //update distance from current to maneuver post
//        if([NMAPositioningManager sharedPositioningManager].currentPosition){
//            double distance = [NMANavigationManager sharedNavigationManager].distanceToCurrentManeuver;
//            if(distance < 1000)
//                self.maneuverView.distanceLbl.text = [NSString stringWithFormat:@"%.0f M", distance];
//            else
//                self.maneuverView.distanceLbl.text = [NSString stringWithFormat:@"%.2f KM", distance/1000.0f];
//        }
//
//        //update maneuver instruction
//        if(currentManeuver.nextRoadName && currentManeuver.nextRoadName.length > 0)
//            self.maneuverView.instructionLbl.text = [NSString stringWithFormat:@"%@ to %@", [self textForManeuverTurn:currentManeuver.turn], currentManeuver.nextRoadName];
//        else
//            self.maneuverView.instructionLbl.text = @"";
//
//        //update on road
//        if(currentManeuver.roadName && currentManeuver.roadName.length > 0)
//            self.maneuverView.onRoadLbl.text = [NSString stringWithFormat:@"on %@", currentManeuver.roadName];
//        else
//            self.maneuverView.onRoadLbl.text = @"";
//    }
//}
//
//-(void)handlePositionDidLost
//{
//    NSLog(@"handlePositionDidLost");
//}
//
//#pragma mark - Notification Handle
//
//-(void)handleNavigateStateChange
//{
//    switch ([NMANavigationManager sharedNavigationManager].navigationState) {
//        case NMANavigationStateIdle:
//        {
//            NSLog(@"NMANavigationStateIdle");
//
//            //resume screen autodim and locking
//            [UIApplication sharedApplication].idleTimerDisabled = NO;
//
//            self.navigateBtn.title = @"Start";
//
//            self.navigationController.navigationBarHidden = NO;
//            self.maneuverView.hidden = YES;
//            self.mapView.tilt = 0.0f;
//            self.mapView.transformCenter = CGPointMake(0.5f, 0.5f);
//            //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(routingBtnClicked:)];
//            self.navigationItem.rightBarButtonItem.tintColor = self.view.tintColor;
//
//            //reset route
//            if(self.mapRoute)
//                [self.mapView removeMapObject:self.mapRoute];
//            self.mapRoute = nil;
//            self.route = nil;
//
//            //reset navigation source to using actual device location
//            [NMAPositioningManager sharedPositioningManager].dataSource = nil;
//
//            //clean up panel
//            self.maneuverView.instructionLbl.text = @"";
//            self.maneuverView.distanceLbl.text = @"";
//            self.maneuverView.onRoadLbl.text = @"";
//
//        }break;
//
//        case NMANavigationStatePaused:
//        {
//            NSLog(@"NMANavigationStatePaused");
//
//            self.navigateBtn.title = @"Resume";
//            self.navigationController.navigationBarHidden = NO;
//            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopNavigationClicked:)];
//            self.navigationItem.rightBarButtonItem.tintColor = [UIColor purpleColor];
//        }break;
//
//        case NMANavigationStateRunning:
//        {
//            NSLog(@"NMANavigationStateRunning");
//
//            //by default, NMAMapSchemeCarNavigationDay will be used after navigation started
//            //if you would like to use another map scheme you can do something like this to use NMAMapSchemeNormalDay for instance:
//            //self.mapView.mapScheme = NMAMapSchemeNormalDay;
//
//            self.navigateBtn.title = @"Pause";
//            self.navigationController.navigationBarHidden = YES;
//
//
//            self.maneuverView.hidden = NO;
//
//            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopNavigationClicked:)];
//            self.navigationItem.rightBarButtonItem.tintColor = [UIColor purpleColor];
//
//            //center indictor at bottom of screen for nav / pedestrian navigation
//            //for tracking, center the position indicator on map
//            self.mapView.transformCenter = CGPointMake(0.5f, 0.85f);
//
//            //disable screen auto dim when in navigation
//            [UIApplication sharedApplication].idleTimerDisabled = YES;
//
//        }break;
//    }
//}
//
//-(void)stopNavigationClicked:(id)sender
//{
//    NMANavigationState navState = [NMANavigationManager sharedNavigationManager].navigationState;
//    if(navState == NMANavigationStatePaused || navState == NMANavigationStateRunning){
//        [[NMANavigationManager sharedNavigationManager] stop];
//    }
//}
//
//-(void)navigationBtnClicked:(id)sender
//{
//    //start navigation
//    [NMANavigationManager sharedNavigationManager].map = self.mapView;
//    [NMANavigationManager sharedNavigationManager].delegate = self;
//
//    [NMANavigationManager sharedNavigationManager].mapTrackingAutoZoomEnabled = YES;
//    [NMANavigationManager sharedNavigationManager].mapTrackingEnabled = YES;
//    [NMANavigationManager sharedNavigationManager].mapTrackingOrientation = NMAMapTrackingOrientationDynamic;
//    [NMANavigationManager sharedNavigationManager].speedWarningEnabled = YES;
//    [NMANavigationManager sharedNavigationManager].mapTrackingTilt = NMAMapTrackingTilt3D;
//
//    NSLog(@"starting turn by turn navigation");
//    NSError* error = [[NMANavigationManager sharedNavigationManager] startTurnByTurnNavigationWithRoute:self.route];
//    if(error && error.code != NMANavigationErrorNone){
//        NSLog(@"ERROR: failed to start simulation with error code %ld", (long)error.code);
//        return;
//    }
//
//    return;
//
//    switch (self.status) {
//
//        case HSDNavigationStateNavigation:
//        {
//            NMANavigationState navState = [NMANavigationManager sharedNavigationManager].navigationState;
//            switch (navState) {
//                case NMANavigationStateIdle:
//                {
//                    //start navigation
//                    [NMANavigationManager sharedNavigationManager].map = self.mapView;
//                    [NMANavigationManager sharedNavigationManager].delegate = self;
//
//                    [NMANavigationManager sharedNavigationManager].mapTrackingAutoZoomEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingOrientation = NMAMapTrackingOrientationDynamic;
//                    [NMANavigationManager sharedNavigationManager].speedWarningEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingTilt = NMAMapTrackingTilt3D;
//
//                    NSLog(@"starting turn by turn navigation");
//                    NSError* error = [[NMANavigationManager sharedNavigationManager] startTurnByTurnNavigationWithRoute:self.route];
//                    if(error && error.code != NMANavigationErrorNone){
//                        NSLog(@"ERROR: failed to start simulation with error code %ld", (long)error.code);
//                        return;
//                    }
//
//
//                }break;
//
//                case NMANavigationStatePaused:
//                {
//                    //resume the nav
//                    [[NMANavigationManager sharedNavigationManager] setPaused:NO];
//
//                }break;
//
//                case NMANavigationStateRunning:
//                {
//                    //pasue the nav
//                    [[NMANavigationManager sharedNavigationManager] setPaused:YES];
//
//                }break;
//            }
//
//        }break;
//
//        case HSDNavigationStateSimulation:
//        {
//
//            [[NMAPositioningManager sharedPositioningManager] stopPositioning];
//            NMARoutePositionSource* routeSource = [[NMARoutePositionSource alloc] initWithRoute:self.route];
//
//            //5m/s for walking speed and 20m/s for driving
//            if(self.route.routingMode.transportMode == NMATransportModePedestrian)
//                routeSource.movementSpeed = 5.0f;
//            else
//                routeSource.movementSpeed = 20.0f;
//
//            routeSource.updateInterval = 1.0f;
//            routeSource.stationary = NO;
//
//            [NMAPositioningManager sharedPositioningManager].dataSource = routeSource;
//            [[NMAPositioningManager sharedPositioningManager] startPositioning];
//
//            NMANavigationState navState = [NMANavigationManager sharedNavigationManager].navigationState;
//            switch (navState) {
//                case NMANavigationStateIdle:
//                {
//                    //start navigation
//                    [NMANavigationManager sharedNavigationManager].map = self.mapView;
//                    [NMANavigationManager sharedNavigationManager].delegate = self;
//
//                    [NMANavigationManager sharedNavigationManager].mapTrackingAutoZoomEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingOrientation = NMAMapTrackingOrientationDynamic;
//                    [NMANavigationManager sharedNavigationManager].speedWarningEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingTilt = NMAMapTrackingTilt3D;
//
//                    NSLog(@"starting navigation simulation");
//                    NSError* error = [[NMANavigationManager sharedNavigationManager] startTurnByTurnNavigationWithRoute:self.route];
//                    if(error && error.code != NMANavigationErrorNone){
//                        NSLog(@"ERROR: failed to start simulation with error code %ld", (long)error.code);
//                        return;
//                    }
//                }break;
//
//                case NMANavigationStatePaused:
//                {
//                    //resume the nav
//                    [[NMANavigationManager sharedNavigationManager] setPaused:NO];
//
//                    //resume simulated route source
//                    NMARoutePositionSource* routeSource = [NMAPositioningManager sharedPositioningManager].dataSource;
//                    routeSource.stationary = NO;
//                }break;
//
//                case NMANavigationStateRunning:
//                {
//                    //pasue the nav
//                    [[NMANavigationManager sharedNavigationManager] setPaused:YES];
//
//                    //pause simulated route source
//                    NMARoutePositionSource* routeSource = [NMAPositioningManager sharedPositioningManager].dataSource;
//                    routeSource.stationary = YES;
//                }break;
//            }
//
//
//        }break;
//
//        case HSDNavigationStateTracking:
//        {
//            NMANavigationState navState = [NMANavigationManager sharedNavigationManager].navigationState;
//            switch (navState) {
//                case NMANavigationStateIdle:
//                {
//                    [NMANavigationManager sharedNavigationManager].map = self.mapView;
//                    [NMANavigationManager sharedNavigationManager].delegate = self;
//
//                    [NMANavigationManager sharedNavigationManager].mapTrackingAutoZoomEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingEnabled = YES;
//                    [NMANavigationManager sharedNavigationManager].mapTrackingOrientation = NMAMapTrackingOrientationDynamic;
//                    [NMANavigationManager sharedNavigationManager].speedWarningEnabled = YES;
//
//                    //for tracking mode, tilt slightly smaller than navigation
//                    [NMANavigationManager sharedNavigationManager].mapTrackingTilt = NMAMapTrackingTiltCustom;
//                    self.mapView.tilt = 50.0f;
//
//                    NSLog(@"starting navigation tracking");
//                    NSError* error = [[NMANavigationManager sharedNavigationManager] startTrackingWithTransportMode:NMATransportModeCar];
//                    if(error && error.code != NMANavigationErrorNone){
//                        NSLog(@"ERROR: failed to start simulation with error code %ld", (long)error.code);
//                        return;
//                    }
//                }break;
//
//                case NMANavigationStatePaused:
//                {
//                    //resume the nav
//                    [[NMANavigationManager sharedNavigationManager] setPaused:NO];
//                }break;
//
//                case NMANavigationStateRunning:
//                {
//                    //pasue the nav
//                    [[NMANavigationManager sharedNavigationManager] setPaused:YES];
//                }break;
//            }
//
//        }break;
//    }
//}

#pragma mark - Utility

-(void)postLocalNotification:(NSString*)notificationMsg
{
    // Post a new local notification
    UILocalNotification *notif = [[UILocalNotification alloc] init];
    notif.alertBody = notificationMsg;
    notif.fireDate = [NSDate date]; // now
    notif.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:notif];
}


//-(NSString*)textForManeuverTurn:(NMAManeuverTurn)turn
//{
//    NSDictionary* dict = @{@(NMAManeuverTurnUndefined) : @"",
//                           @(NMAManeuverTurnNone) : @"continue",
//                           @(NMAManeuverTurnKeepMiddle) : @"keep middle",
//                           @(NMAManeuverTurnKeepRight) : @"keep right",
//                           @(NMAManeuverTurnLightRight) : @"slight right turn",
//                           @(NMAManeuverTurnQuiteRight) : @"right turn",
//                           @(NMAManeuverTurnHeavyRight) : @"full right turn",
//                           @(NMAManeuverTurnKeepLeft) : @"keep left",
//                           @(NMAManeuverTurnLightLeft) : @"slight left turn",
//                           @(NMAManeuverTurnQuiteLeft) : @"left turn",
//                           @(NMAManeuverTurnHeavyLeft) : @"full left turn",
//                           @(NMAManeuverTurnReturn) : @"turn around",
//                           @(NMAManeuverTurnRoundabout1) : @"take the first exit",
//                           @(NMAManeuverTurnRoundabout2) : @"take the second exit",
//                           @(NMAManeuverTurnRoundabout3) : @"take the third exit",
//                           @(NMAManeuverTurnRoundabout4) : @"take the fourth exit",
//                           @(NMAManeuverTurnRoundabout5) : @"take the fifth exit",
//                           @(NMAManeuverTurnRoundabout6) : @"take the sixth exit",
//                           @(NMAManeuverTurnRoundabout7) : @"take the seventh exit",
//                           @(NMAManeuverTurnRoundabout8) : @"take the eighth exit",
//                           @(NMAManeuverTurnRoundabout9) : @"take the ninth exit",
//                           @(NMAManeuverTurnRoundabout10) : @"take the tenth exit",
//                           @(NMAManeuverTurnRoundabout11) : @"take the eleventh exit",
//                           @(NMAManeuverTurnRoundabout12) : @"take the twelfth exit",
//                           };
//    return dict[@(turn)];
//}


//-(void) getNewDirections
//{
//    [appDel.piingo_GoogleMap getDirectionRoutesFrom:[NSString stringWithFormat:@"%lf,%lf", [appDel.latitude doubleValue], [appDel.longitude doubleValue]] to:[NSString stringWithFormat:@"%lf,%lf", [[orderDetailDic objectForKey:@"clat"] doubleValue], [[orderDetailDic objectForKey:@"clon"] doubleValue]] withTravelMode:@"driving" andWithUsingWaypoints:nil];
//}

//
//-(void) navClicked:(id)sender
//{
//    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
//        
//        //            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&q=%f,%f",[appDel.latitude doubleValue],[appDel.longitude doubleValue], [[orderDetailDic objectForKey:@"clat"] doubleValue],[[orderDetailDic objectForKey:@"clon"] doubleValue]]];
//        
//        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?center=%f,%f&q=%f,%f", [[orderDetailDic objectForKey:@"clat"] doubleValue],[[orderDetailDic objectForKey:@"clon"] doubleValue],[appDel.latitude doubleValue],[appDel.longitude doubleValue]]];
//        
//        [[UIApplication sharedApplication] openURL:url];
//    } else {
//        
//        [appDel showAlertWithMessage:@"no navigation" andTitle:@"" andBtnTitle:@"OK"];
//        
//        NSLog(@"Can't use comgooglemaps://");
//    }
//}
//


-(void) closeMapviewClicked:(id)sender
{
    
    [self.view bringSubviewToFront:appDel.piingo_GoogleMap];
    btnCloseMapView.hidden = YES;
    btnPhone.hidden = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        viewMap.frame = CGRectMake(0, screen_height+10, screen_width, screen_height-20);
        
        //self.mapView.frame = CGRectMake(0, screen_height+10, screen_width, screen_height-20);
        
        appDel.piingo_GoogleMap.frame = CGRectMake(0, screen_height+10, screen_width, screen_height-20);
        self.navigationController.navigationBarHidden = NO;
        
        [appDel.piingo_GoogleMap changeFrame];
        
    }];
}

-(void)getLatAndLongOfUser:(NSString *)strPostalCode
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:strPostalCode completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        
        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        
        NSString *strLat = [NSString stringWithFormat:@"%f", placemark.location.coordinate.latitude];
        NSString *strLong = [NSString stringWithFormat:@"%f", placemark.location.coordinate.longitude];
        
        [orderDetailDic setObject:strLat forKey:@"clat"];
        [orderDetailDic setObject:strLong forKey:@"clon"];
        
    }];
    
}


- (void)openDirectionsInGoogleMaps
{
    GoogleDirectionsDefinition *directionsDefinition = [[GoogleDirectionsDefinition alloc] init];
    
    GoogleDirectionsWaypoint *startingPoint = [[GoogleDirectionsWaypoint alloc] init];
    
    CLLocationCoordinate2D coordinatesStart;
    coordinatesStart.latitude = [appDel.latitude doubleValue];
    coordinatesStart.longitude = [appDel.longitude doubleValue];
    
    startingPoint.location = coordinatesStart;
    directionsDefinition.startingPoint = startingPoint;
    
    
    
    GoogleDirectionsWaypoint *destination = [[GoogleDirectionsWaypoint alloc] init];
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[orderDetailDic objectForKey:@"clat"] doubleValue];
    coordinates.longitude = [[orderDetailDic objectForKey:@"clon"] doubleValue];
    
    destination.location = coordinates;
    directionsDefinition.destinationPoint = destination;
    
    directionsDefinition.travelMode = kGoogleMapsTravelModeDriving;
    [[OpenInGoogleMapsController sharedInstance] openDirections:directionsDefinition];
}


- (void)openInMapsWasClicked:(id)sender
{
    if (![[OpenInGoogleMapsController sharedInstance] isGoogleMapsInstalled]) {
        NSLog(@"Google Maps not installed, but using our fallback strategy");
    }
    
    [self openDirectionsInGoogleMaps];
}



-(void) segmentChange:(CustomSegmentControl *) sender
{
//    if (!enableAllAction) {
//        
////        [sender setSelectedIndex:0];
//        return;
//    }
    
    [self.view endEditing:YES];
    
    if (sender.selectedIndex == 1)
    {
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"Scroll_Horizantal"])
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"Scroll_Horizantal"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if ([self.strDirection caseInsensitiveCompare:@"pickup"] == NSOrderedSame)
            {
                [self performSelector:@selector(moveScrollLast) withObject:nil afterDelay:0.4f];
            }
        }
        
        if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
        {
            if ([self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"C"] == NSOrderedSame)
            {
                conformOrderBtn.hidden = YES;
                addBtn.hidden = YES;
                btnPrefs.hidden = YES;
                
                whiteBG.hidden = YES;
                
                itemDetailsTableView.frame = CGRectMake(0, 0, screen_width, screen_height-190.0);
            }
            else
            {
                addBtn.hidden = YES;
                btnPrefs.hidden = YES;
            }
        }
        else
        {
            if ([self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame || [self.strTaskStatus caseInsensitiveCompare:@"C"] == NSOrderedSame)
            {
                conformOrderBtn.hidden = YES;
                addBtn.hidden = YES;
                btnPrefs.hidden = YES;
                
                whiteBG.hidden = YES;
                
                itemDetailsTableView.frame = CGRectMake(0, 0, screen_width, screen_height-190.0);
            }
        }
        
        itemDetailsView.hidden = NO;
        mainScrollView.hidden = YES;
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        itemDetailsView.hidden = YES;
        mainScrollView.hidden = NO;
        
        self.navigationItem.leftBarButtonItem = back_BarButton;
        self.navigationItem.rightBarButtonItem = phone_BarButton;
    }
}



-(void) reloadTableView
{
    
    NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"bagID" ascending:YES];
    
    [itemsArray removeAllObjects];
    [itemsArray addObjectsFromArray:[orderObj.bagsDetails sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]]];
    
    for (int i =0; i<[itemsArray count]; i++)
    {
        BagDetails *bagjet = [itemsArray objectAtIndex:i];
        
        if (![self.arrayBagTags containsObject:bagjet.bagTag])
        {
            [self.arrayBagTags addObject:bagjet.bagTag];
        }
        
//        if ([totalAmount.text floatValue] < [bagjet.totalAmountOfBag floatValue])
//            totalAmount.text = bagjet.totalAmountOfBag;
    }
    
    DLog(@"itemsArray - %ld orderObj - %ld",[itemsArray count], [orderObj.bagsDetails count]);
    
    [itemDetailsTableView reloadData];
}



#pragma mark UIControls Methods
-(void) viewTapped
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

-(void) directionBtnClicked
{
    [appDel.piingo_GoogleMap getDirectionRoutesFrom:[NSString stringWithFormat:@"%lf,%lf", [appDel.latitude doubleValue], [appDel.longitude doubleValue]] to:[NSString stringWithFormat:@"%lf,%lf", [[orderDetailDic objectForKey:@"clat"] doubleValue], [[orderDetailDic objectForKey:@"clon"] doubleValue]] withTravelMode:@"driving" andWithUsingWaypoints:nil];
}

-(void) callBtnClicked
{
    if (![[orderDetailDic objectForKey:@"customerPhone"] length])
    {
        [appDel showAlertWithMessage:@"Customer does not have mobile number." andTitle:@"" andBtnTitle:@"OK"];
    }
    else
    {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
        {
            NSString *strPhone = @"";
            
            strPhone = [orderDetailDic objectForKey:@"customerPhone"];
            
//            if ([[orderDetailDic objectForKey:@"customerPhone"] hasPrefix:@"+65"] || [[orderDetailDic objectForKey:@"customerPhone"] hasPrefix:@"65"])
//            {
//                strPhone = [orderDetailDic objectForKey:@"customerPhone"];
//            }
//            else
//            {
//                strPhone = [NSString stringWithFormat:@"+65%@", [orderDetailDic objectForKey:@"customerPhone"]];
//            }
            
            NSString *phoneNumber = [@"telprompt://" stringByAppendingString:strPhone];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
            
        } else {
            
            [appDel showAlertWithMessage:@"Your device doesn't support this feature." andTitle:@"" andBtnTitle:@"OK"];
        }
    }
}


-(void) addBtnClicked
{
    
    if (statusDisplayButton.enabled == NO)
    {
        
        AddItemsViewController_New *addItems_New = [[AddItemsViewController_New alloc] init];
        addItems_New.parentDel = self;
        addItems_New.orderDetailDic = [[NSDictionary alloc]initWithDictionary:orderDetailDic];
        
        [self presentViewController:addItems_New animated:YES completion:nil];
    }
    else
    {
        [appDel showAlertWithMessage:@"Please check that you are At The Door." andTitle:@"" andBtnTitle:@"OK"];
    }
}


-(void) handleSwipeUpFrom:(UISwipeGestureRecognizer *) gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp)
    {
        dismissViewBtn.selected = YES;
        [self dismisDetilViewBtnClicked:dismissViewBtn];
    }
    else if(gesture.direction == UISwipeGestureRecognizerDirectionDown)
    {
        dismissViewBtn.selected = NO;
        [self dismisDetilViewBtnClicked:dismissViewBtn];
    }
}
-(void) dismisDetilViewBtnClicked:(UIButton *) sender
{
    [UIView animateWithDuration:0.3 animations:^{
       
        if(sender.selected)
        {
            sender.selected = !sender.selected;
            fullJobDetailView.frame = CGRectMake(0, screen_height-114.0-160.0+5, screen_width, 160.0);
            appDel.piingo_GoogleMap.frame = CGRectMake(0, 0, screen_width, 5+screen_height-64-50-160.0);
            
            viewMap.frame = CGRectMake(0, 0, screen_width, 5+screen_height-64-50-160.0);
            
            //self.mapView.frame = CGRectMake(0, 0, screen_width, 5+screen_height-64-50-160.0);
            
        }
        else
        {
            sender.selected = !sender.selected;
            fullJobDetailView.frame = CGRectMake(0, screen_height-114.0-160.0+5+110, screen_width, 160.0);
            appDel.piingo_GoogleMap.frame = CGRectMake(0, 0, screen_width, 5+screen_height-64-50-160.0+110);
            
            viewMap.frame = CGRectMake(0, 0, screen_width, 5+screen_height-64-50-160.0+110);
            
            //self.mapView.frame = CGRectMake(0, 0, screen_width, 5+screen_height-64-50-160.0+110);
            
        }
        
        [appDel.piingo_GoogleMap changeFrame];
        
    }];
   
}


-(void) addItemDetails:(NSMutableDictionary *) dictAllTypes
{
    [itemDetailArray removeAllObjects];
    
    
    
    for (int i = 0; i < [dictAllTypes count]; i++)
    {
        NSArray *arrayServiceType = [dictAllTypes objectForKey:[[dictAllTypes allKeys] objectAtIndex:i]];
        
        NSMutableArray *itemDetailArray1 = [[NSMutableArray alloc] init];
        
        for (long int j = 0; j < [arrayServiceType count]; j++)
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in [arrayServiceType objectAtIndex:j])
            {
                [iTemDetialsMutdic setValue:[[arrayServiceType objectAtIndex:j] objectForKey:key] forKey:key];
            }
            
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
            
            [itemDetailArray1 addObject:iTemDetialsMutdic];
        }
        
//        NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
//        
//        [iTemDetialsMutdic setValue:[[arrayServiceType objectAtIndex:i] objectForKey:@"jd"] forKey:@"ic"];
//        
//        if ([[arrayServiceType objectAtIndex:i] objectForKey:@"quantity"])
//        {
//            [iTemDetialsMutdic setValue:[[arrayServiceType objectAtIndex:i] objectForKey:@"quantity"] forKey:@"quantity"];
//        }
//        
//        if ([[arrayServiceType objectAtIndex:i] objectForKey:@"weight"])
//        {
//            [iTemDetialsMutdic setValue:[[arrayServiceType objectAtIndex:i] objectForKey:@"weight"] forKey:@"weight"];
//        }
//        
//        [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
//        
//        [itemDetailArray1 addObject:iTemDetialsMutdic];
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray1 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"%@ String:%@", [[dictAllTypes allKeys] objectAtIndex:i], jsonString);
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:i]];
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"bagID" ascending:YES];
        
        NSArray *arrayData = [orderObj.bagsDetails sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
        
        NSString *strBagTag = [NSString stringWithFormat:@"%@-%ld-%@", orderObj.oid, [arrayData count]+1, [[itemDetailArray1 objectAtIndex:0] objectForKey:@"jd"]];
        
        if ([self.arrayBagTags containsObject:strBagTag])
        {
            strBagTag = [NSString stringWithFormat:@"%@-%ld-%@", orderObj.oid, [arrayData count]+2, [[itemDetailArray1 objectAtIndex:0] objectForKey:@"jd"]];
        }
        else
        {
            [self.arrayBagTags addObject:strBagTag];
        }
        
        [bagObj setBagTag:strBagTag];
        
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        
        [itemObj setITemType:[NSNumber numberWithInt:i]];
        [itemObj setITemCode:[[dictAllTypes allKeys] objectAtIndex:i]];
        
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    
    [self reloadTableView];
    
    return;
    
    
    
    
    NSMutableArray *arrayWAI, *arrayDC, *arrayDCG, *arrayIRN, *arrayWF, *arrayHL_DC, *arrayHL_DCG, *arrayHL_WI, *arrayLeather, *arrayCarpet, *arrayCurtains;
    
    arrayWAI = [[NSMutableArray alloc]init];
    arrayDC = [[NSMutableArray alloc]init];
    arrayDCG = [[NSMutableArray alloc]init];
    arrayIRN = [[NSMutableArray alloc]init];
    arrayWF = [[NSMutableArray alloc]init];
    arrayHL_DC = [[NSMutableArray alloc]init];
    arrayHL_DCG = [[NSMutableArray alloc]init];
    arrayHL_WI = [[NSMutableArray alloc]init];
    arrayLeather = [[NSMutableArray alloc]init];
    arrayCarpet = [[NSMutableArray alloc]init];
    arrayCurtains = [[NSMutableArray alloc]init];
    
    NSArray *arraykey = [dictAllTypes allKeys];
    
    for (int i=0; i<[dictAllTypes count]; i++)
    {
        NSString *strJobType = [arraykey objectAtIndex:i];
        
        NSArray *arra = [dictAllTypes objectForKey:strJobType];
        
        if ([strJobType caseInsensitiveCompare:@"Dry Cleaning"] == NSOrderedSame)
        {
            [arrayDC addObjectsFromArray:arra];
        }
        else if ([strJobType caseInsensitiveCompare:@"Green Dry Cleaning"] == NSOrderedSame)
        {
            [arrayDCG addObjectsFromArray:arra];
        }
        else if ([strJobType caseInsensitiveCompare:@"Wash & Iron"] == NSOrderedSame)
        {
            [arrayWAI addObjectsFromArray:arra];
        }
        else if ([strJobType caseInsensitiveCompare:@"Ironing"] == NSOrderedSame)
        {
            [arrayIRN addObjectsFromArray:arra];
        }
        else if ([strJobType caseInsensitiveCompare:@"Load Wash"] == NSOrderedSame)
        {
            [arrayWF addObjectsFromArray:arra];
        }
        else if ([strJobType caseInsensitiveCompare:@"Leather"] == NSOrderedSame)
        {
            [arrayLeather addObjectsFromArray:arra];
        }
        else if ([strJobType caseInsensitiveCompare:@"Carpet"] == NSOrderedSame)
        {
            [arrayCarpet addObjectsFromArray:arra];
        }
        else if ([strJobType caseInsensitiveCompare:@"Curtains"] == NSOrderedSame)
        {
            [arrayCurtains addObjectsFromArray:arra];
        }
    }
    
    if ([arrayWF count])
    {
        NSMutableArray *itemDetailArray1 = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
        
        [iTemDetialsMutdic setValue:@"WF" forKey:@"ic"];
        
        [iTemDetialsMutdic setValue:[[arrayWF objectAtIndex:0]objectForKey:@"quantity"] forKey:@"quantity"];
        [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
        
        if ([[arrayWF objectAtIndex:0]objectForKey:@"UOMId"])
        {
            [iTemDetialsMutdic setValue:[[arrayWF objectAtIndex:0]objectForKey:@"UOMId"] forKey:@"UOMId"];
        }
        else
        {
            [iTemDetialsMutdic setValue:@"2" forKey:@"UOMId"];
        }
        
        [iTemDetialsMutdic setValue:@"1" forKey:@"JTMId"];
        
        [itemDetailArray1 addObject:iTemDetialsMutdic];
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray1 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"WF String:%@", jsonString);
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:0]];
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:0]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    if ([arrayWAI count])
    {
        //Wash and Iron
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        NSMutableArray *itemDetailArray1 = [[NSMutableArray alloc] init];
        
        for (long int i = 0; i < [arrayWAI count]; i++)
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in [arrayWAI objectAtIndex:i])
            {
                [iTemDetialsMutdic setValue:[[arrayWAI objectAtIndex:i] objectForKey:key] forKey:key];
                //[iTemDetialsMutdic setValue:[countArray objectAtIndex:i] forKey:@"quantity"];
            }
            
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
            
            if ([[arrayWAI objectAtIndex:i]objectForKey:@"UOMId"])
            {
                [iTemDetialsMutdic setValue:[[arrayWAI objectAtIndex:i]objectForKey:@"UOMId"] forKey:@"UOMId"];
            }
            else
            {
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
            }
            
            [iTemDetialsMutdic setValue:@"3" forKey:@"JTMId"];
            
            [itemDetailArray1 addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray1 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"W&I String:%@", jsonString);
        
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
//        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
//        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
//        DLog(@"W&F String:%@", jsonString2);
//        
//        [bagObj setBagDetailDic:jsonString2];
//        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
//        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:1]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
        
    }
    
    if ([arrayDC count])
    {
        //Dry Cleaning
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
        
        for (long int i = 0; i < [arrayDC count]; i++)
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in [arrayDC objectAtIndex:i])
            {
                [iTemDetialsMutdic setValue:[[arrayDC objectAtIndex:i] objectForKey:key] forKey:key];
                //[iTemDetialsMutdic setValue:[countArray2 objectAtIndex:i] forKey:@"quantity"];
            }
            
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
            
            if ([[arrayDC objectAtIndex:i]objectForKey:@"UOMId"])
            {
                [iTemDetialsMutdic setValue:[[arrayDC objectAtIndex:i]objectForKey:@"UOMId"] forKey:@"UOMId"];
            }
            else
            {
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
            }
            
            [iTemDetialsMutdic setValue:@"2" forKey:@"JTMId"];
            
            [itemDetailArray2 addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"DC String:%@", jsonString);
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
        //        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        //        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        //        DLog(@"W&F String:%@", jsonString2);
        //
        //        [bagObj setBagDetailDic:jsonString2];
//        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
//        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:2]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    
    if ([arrayIRN count])
    {
        //Iron Cleaning
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
        
        for (long int i = 0; i < [arrayIRN count]; i++)
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in [arrayIRN objectAtIndex:i])
            {
                [iTemDetialsMutdic setValue:[[arrayIRN objectAtIndex:i] objectForKey:key] forKey:key];
                //[iTemDetialsMutdic setValue:[countArray3 objectAtIndex:i] forKey:@"quantity"];
            }
            
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
            
            if ([[arrayIRN objectAtIndex:i]objectForKey:@"UOMId"])
            {
                [iTemDetialsMutdic setValue:[[arrayIRN objectAtIndex:i]objectForKey:@"UOMId"] forKey:@"UOMId"];
            }
            else
            {
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
            }
            
            [iTemDetialsMutdic setValue:@"4" forKey:@"JTMId"];
            
            [itemDetailArray2 addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"Ironing String:%@", jsonString);
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
        //        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        //        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        //        DLog(@"W&F String:%@", jsonString2);
        //
        //        [bagObj setBagDetailDic:jsonString2];
//        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
//        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:3]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    
    if ([arrayLeather count])
    {
        //Leather
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
        
        for (long int i = 0; i < [arrayLeather count]; i++)
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in [arrayLeather objectAtIndex:i])
            {
                [iTemDetialsMutdic setValue:[[arrayLeather objectAtIndex:i] objectForKey:key] forKey:key];
                //[iTemDetialsMutdic setValue:[countArray3 objectAtIndex:i] forKey:@"quantity"];
            }
            
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
            
            if ([[arrayLeather objectAtIndex:i]objectForKey:@"UOMId"])
            {
                [iTemDetialsMutdic setValue:[[arrayLeather objectAtIndex:i]objectForKey:@"UOMId"] forKey:@"UOMId"];
            }
            else
            {
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
            }
            
            [iTemDetialsMutdic setValue:@"5" forKey:@"JTMId"];
            
            [itemDetailArray2 addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"Leather String:%@", jsonString);
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
        //        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        //        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        //        DLog(@"W&F String:%@", jsonString2);
        //
        //        [bagObj setBagDetailDic:jsonString2];
        //        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
        //        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:4]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    
    if ([arrayCarpet count])
    {
        //Carpet
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
        
        for (long int i = 0; i < [arrayCarpet count]; i++)
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in [arrayCarpet objectAtIndex:i])
            {
                [iTemDetialsMutdic setValue:[[arrayCarpet objectAtIndex:i] objectForKey:key] forKey:key];
                //[iTemDetialsMutdic setValue:[countArray3 objectAtIndex:i] forKey:@"quantity"];
            }
            
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
            
            if ([[arrayCarpet objectAtIndex:i]objectForKey:@"UOMId"])
            {
                [iTemDetialsMutdic setValue:[[arrayCarpet objectAtIndex:i]objectForKey:@"UOMId"] forKey:@"UOMId"];
            }
            else
            {
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
            }
            
            [iTemDetialsMutdic setValue:@"6" forKey:@"JTMId"];
            
            [itemDetailArray2 addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"Carpet String:%@", jsonString);
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
        //        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        //        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        //        DLog(@"W&F String:%@", jsonString2);
        //
        //        [bagObj setBagDetailDic:jsonString2];
        //        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
        //        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:5]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    
    if ([arrayCurtains count])
    {
        //Curtains
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
        
        for (long int i = 0; i < [arrayCurtains count]; i++)
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            for (NSString *key in [arrayCurtains objectAtIndex:i])
            {
                [iTemDetialsMutdic setValue:[[arrayCurtains objectAtIndex:i] objectForKey:key] forKey:key];
                //[iTemDetialsMutdic setValue:[countArray3 objectAtIndex:i] forKey:@"quantity"];
            }
            
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"oid"];
            
            if ([[arrayCurtains objectAtIndex:i]objectForKey:@"UOMId"])
            {
                [iTemDetialsMutdic setValue:[[arrayCurtains objectAtIndex:i]objectForKey:@"UOMId"] forKey:@"UOMId"];
            }
            else
            {
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
            }
            
            [iTemDetialsMutdic setValue:@"7" forKey:@"JTMId"];
            
            [itemDetailArray2 addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"Curtains String:%@", jsonString);
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
        //        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        //        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        //        DLog(@"W&F String:%@", jsonString2);
        //
        //        [bagObj setBagDetailDic:jsonString2];
        //        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
        //        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:6]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    
    [self reloadTableView];
    
}

-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2
{
    [itemDetailArray removeAllObjects];
    
    NSMutableArray *arrayWAI, *arrayDC, *arrayIRN;
    
    arrayWAI = [[NSMutableArray alloc]init];
    arrayDC = [[NSMutableArray alloc]init];
    arrayIRN = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[itemDetailsArray count]; i++)
    {
        NSDictionary *dic = [itemDetailsArray objectAtIndex:i];
        
        if (![[dic objectForKey:@"wip"] isEqualToString:@"0.0"])
        {
            [arrayWAI addObject:dic];
        }
        if (![[dic objectForKey:@"dcp"] isEqualToString:@"0.0"])
        {
            [arrayDC addObject:dic];
        }
        if (![[dic objectForKey:@"irp"] isEqualToString:@"0.0"])
        {
            [arrayIRN addObject:dic];
        }
    }
    
    NSPredicate *removeItemPredicate = [NSPredicate predicateWithFormat:@"SELF != %@ AND SELF != %@ AND SELF != %@ AND SELF.length>0",@"",@"0",nil];
    [countArray filteredArrayUsingPredicate:removeItemPredicate];
    [countArray2 filteredArrayUsingPredicate:removeItemPredicate];
    
    if (!([[countArray filteredArrayUsingPredicate:removeItemPredicate] count] > 0) && !([[countArray2 filteredArrayUsingPredicate:removeItemPredicate] count] > 0))
    {
        return;
    }
    
    if (type == 0)
    {
        //Wash and fold
        
        if ([[countArray objectAtIndex:0] isEqualToString:@""] || [[countArray objectAtIndex:0] isEqualToString:@"0"])
        {
            return;
        }
        else
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            
            [iTemDetialsMutdic setValue:@"WF" forKey:@"ic"];
            
            [iTemDetialsMutdic setValue:[countArray objectAtIndex:0] forKey:@"quantity"];
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"cobID"];
            [iTemDetialsMutdic setValue:@"2" forKey:@"UOMId"];
            [iTemDetialsMutdic setValue:@"1" forKey:@"JTMId"];
            
            [itemDetailArray addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"Wash & Fold String:%@", jsonString);
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:0]];
        
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        DLog(@"Wash & Fold String:%@", jsonString2);
        
        [bagObj setBagDetailDic:jsonString2];
//        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
//        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:0]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    else if (type == 1)
    {
        //Wash and Iron
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        for (long int i = 0; i < [arrayWAI count]; i++)
        {
            if ([[countArray objectAtIndex:i] isEqualToString:@""] || [[countArray objectAtIndex:i] isEqualToString:@"0"])
            {
                
            }
            else
            {
                NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
                
                for (NSString *key in [arrayWAI objectAtIndex:i])
                {
                    [iTemDetialsMutdic setValue:[[arrayWAI objectAtIndex:i] objectForKey:key] forKey:key];
                    [iTemDetialsMutdic setValue:[countArray objectAtIndex:i] forKey:@"quantity"];
                }
                
                [iTemDetialsMutdic setValue:orderObj.oid forKey:@"cobID"];
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
                [iTemDetialsMutdic setValue:@"3" forKey:@"JTMId"];
                
                [itemDetailArray addObject:iTemDetialsMutdic];
            }
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"W&I String:%@", jsonString);
        
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        DLog(@"W&I String:%@", jsonString2);
        
        [bagObj setBagDetailDic:jsonString2];
//        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
//        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:1]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
        //    }
        //    else if (type == 2)
        {
            //Dry Cleaning
            NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
            
            for (long int i = 0; i < [arrayDC count]; i++)
            {
                if ([[countArray2 objectAtIndex:i] isEqualToString:@""] || [[countArray2 objectAtIndex:i] isEqualToString:@"0"])
                {
                    
                }
                else
                {
                    NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
                    
                    for (NSString *key in [arrayDC objectAtIndex:i])
                    {
                        [iTemDetialsMutdic setValue:[[arrayDC objectAtIndex:i] objectForKey:key] forKey:key];
                        [iTemDetialsMutdic setValue:[countArray2 objectAtIndex:i] forKey:@"quantity"];
                    }
                    
                    [iTemDetialsMutdic setValue:orderObj.oid forKey:@"cobID"];
                    [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
                    [iTemDetialsMutdic setValue:@"2" forKey:@"JTMId"];
                    
                    [itemDetailArray2 addObject:iTemDetialsMutdic];
                }
            }
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DLog(@"DC String:%@", jsonString);
            
            //        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
            
            ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
            //        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
            //        [bagObj setBagTag:@""];
            //        [bagObj setBagType:[NSNumber numberWithInt:1]];
            
            NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray2 options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
            DLog(@"DC String:%@", jsonString2);
            
            //        [bagObj setBagDetailDic:jsonString2];
            //        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
            //        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
            //        [bagObj setStrachCount:@""];
            //        [bagObj setStrainCount:@""];
            //        [bagObj setNotes:@""];
            //        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
            //        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
            //        [bagObj setTotalAmountOfBag:@"0.0"];
            
            NSString *totalBagJsonDetailString = [NSString stringWithFormat:@"%@;%@",bagObj.bagDetailDic,jsonString2];
            [bagObj setBagDetailDic:totalBagJsonDetailString];
            
            [itemObj setITemDetailDic:jsonString];
            [itemObj setITemType:[NSNumber numberWithInt:2]];
            [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
            
            [bagObj addItemsObject:itemObj];
            
            NSError *error1;
            if (![[appDel managedObjectContext] save:&error1]) {
                NSLog(@"error %@",error);
            }
        }
    }
    
    [self reloadTableView];
    
}


-(void) addItemDetails:(NSInteger) type withDetails:(NSArray *) itemDetailsArray andCountDetails:(NSArray *) countArray anddetail2:(NSArray *) countArray2 andDetails3:(NSArray *) countArray3
{
    [itemDetailArray removeAllObjects];
    
    NSMutableArray *arrayWAI, *arrayDC, *arrayIRN;
    
    arrayWAI = [[NSMutableArray alloc]init];
    arrayDC = [[NSMutableArray alloc]init];
    arrayIRN = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[itemDetailsArray count]; i++)
    {
        NSDictionary *dic = [itemDetailsArray objectAtIndex:i];
        
        if (![[dic objectForKey:@"wip"] isEqualToString:@"0.0"])
        {
            [arrayWAI addObject:dic];
        }
        if (![[dic objectForKey:@"dcp"] isEqualToString:@"0.0"])
        {
            [arrayDC addObject:dic];
        }
        if (![[dic objectForKey:@"irp"] isEqualToString:@"0.0"])
        {
            [arrayIRN addObject:dic];
        }
    }
    
    
    NSPredicate *removeItemPredicate = [NSPredicate predicateWithFormat:@"SELF != %@ AND SELF != %@ AND SELF != %@ AND SELF.length>0",@"",@"0",nil];
    [countArray filteredArrayUsingPredicate:removeItemPredicate];
    [countArray2 filteredArrayUsingPredicate:removeItemPredicate];
    [countArray3 filteredArrayUsingPredicate:removeItemPredicate];
    
    if (!([[countArray filteredArrayUsingPredicate:removeItemPredicate] count] > 0) && !([[countArray2 filteredArrayUsingPredicate:removeItemPredicate] count] > 0) && !([[countArray3 filteredArrayUsingPredicate:removeItemPredicate] count] > 0))
    {
        return;
    }
    
    if (type == 0)
    {
        //Wash and fold
        
        if ([[countArray objectAtIndex:0] isEqualToString:@""] || [[countArray objectAtIndex:0] isEqualToString:@"0"])
        {
            return;
        }
        else
        {
            NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
            
            
            [iTemDetialsMutdic setValue:@"WF" forKey:@"ic"];
            
            [iTemDetialsMutdic setValue:[countArray objectAtIndex:0] forKey:@"quantity"];
            [iTemDetialsMutdic setValue:orderObj.oid forKey:@"cobID"];
            [iTemDetialsMutdic setValue:@"2" forKey:@"UOMId"];
            [iTemDetialsMutdic setValue:@"1" forKey:@"JTMId"];
            
            [itemDetailArray addObject:iTemDetialsMutdic];
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"DC String:%@", jsonString);
        
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:0]];
        
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        DLog(@"DC String:%@", jsonString2);
        
        [bagObj setBagDetailDic:jsonString2];
//        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
//        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:0]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
    }
    else if (type == 1)
    {
        //Wash and Iron
        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
        
        for (long int i = 0; i < [arrayWAI count]; i++)
        {
            if ([[countArray objectAtIndex:i] isEqualToString:@""] || [[countArray objectAtIndex:i] isEqualToString:@"0"])
            {
                
            }
            else
            {
                NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
                
                for (NSString *key in [arrayWAI objectAtIndex:i])
                {
                    [iTemDetialsMutdic setValue:[[arrayWAI objectAtIndex:i] objectForKey:key] forKey:key];
                    [iTemDetialsMutdic setValue:[countArray objectAtIndex:i] forKey:@"quantity"];
                }
                
                [iTemDetialsMutdic setValue:orderObj.oid forKey:@"cobID"];
                [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
                [iTemDetialsMutdic setValue:@"3" forKey:@"JTMId"];
                
                [itemDetailArray addObject:iTemDetialsMutdic];
            }
        }
        
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        DLog(@"W&F String:%@", jsonString);
        
        
        ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
        [bagObj setBagTag:@""];
        [bagObj setBagType:[NSNumber numberWithInt:1]];
        
        NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
        DLog(@"W&F String:%@", jsonString2);
        
        [bagObj setBagDetailDic:jsonString2];
//        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
//        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
        
        
        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
        [bagObj setTotalAmountOfBag:@"0.0"];
        
        [itemObj setITemDetailDic:jsonString];
        [itemObj setITemType:[NSNumber numberWithInt:1]];
        [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
        [orderObj addBagsDetailsObject:bagObj];
        
        [bagObj addItemsObject:itemObj];
        
        
        NSError *error1;
        if (![[appDel managedObjectContext] save:&error1]) {
            NSLog(@"error %@",error);
        }
        //    }
        //    else if (type == 2)
        {
            //Dry Cleaning
            NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
            
            for (long int i = 0; i < [arrayDC count]; i++)
            {
                if ([[countArray2 objectAtIndex:i] isEqualToString:@""] || [[countArray2 objectAtIndex:i] isEqualToString:@"0"])
                {
                    
                }
                else
                {
                    NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
                    
                    for (NSString *key in [arrayDC objectAtIndex:i])
                    {
                        [iTemDetialsMutdic setValue:[[arrayDC objectAtIndex:i] objectForKey:key] forKey:key];
                        [iTemDetialsMutdic setValue:[countArray2 objectAtIndex:i] forKey:@"quantity"];
                    }
                    
                    [iTemDetialsMutdic setValue:orderObj.oid forKey:@"cobID"];
                    [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
                    [iTemDetialsMutdic setValue:@"2" forKey:@"JTMId"];
                    
                    [itemDetailArray2 addObject:iTemDetialsMutdic];
                }
            }
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DLog(@"DC String:%@", jsonString);
            
            //        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
            
            ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
            //        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
            //        [bagObj setBagTag:@""];
            //        [bagObj setBagType:[NSNumber numberWithInt:1]];
            
            NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray2 options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
            DLog(@"DC String:%@", jsonString2);
            
            //        [bagObj setBagDetailDic:jsonString2];
            //        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
            //        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
            //        [bagObj setStrachCount:@""];
            //        [bagObj setStrainCount:@""];
            //        [bagObj setNotes:@""];
            //        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
            //        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
            //        [bagObj setTotalAmountOfBag:@"0.0"];
            
            NSString *totalBagJsonDetailString = [NSString stringWithFormat:@"%@;%@",bagObj.bagDetailDic,jsonString2];
            [bagObj setBagDetailDic:totalBagJsonDetailString];
            
            [itemObj setITemDetailDic:jsonString];
            [itemObj setITemType:[NSNumber numberWithInt:2]];
            [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
            
            [bagObj addItemsObject:itemObj];
            
            NSError *error1;
            if (![[appDel managedObjectContext] save:&error1]) {
                NSLog(@"error %@",error);
            }
        }
        //    else if (type == 3)
        {
            //Iron Cleaning
            NSMutableArray *itemDetailArray2 = [[NSMutableArray alloc] init];
            
            for (long int i = 0; i < [arrayIRN count]; i++)
            {
                if ([[countArray3 objectAtIndex:i] isEqualToString:@""] || [[countArray3 objectAtIndex:i] isEqualToString:@"0"])
                {
                    
                }
                else
                {
                    NSMutableDictionary *iTemDetialsMutdic = [[NSMutableDictionary alloc] init];
                    
                    for (NSString *key in [arrayIRN objectAtIndex:i])
                    {
                        [iTemDetialsMutdic setValue:[[arrayIRN objectAtIndex:i] objectForKey:key] forKey:key];
                        [iTemDetialsMutdic setValue:[countArray3 objectAtIndex:i] forKey:@"quantity"];
                    }
                    
                    [iTemDetialsMutdic setValue:orderObj.oid forKey:@"cobID"];
                    [iTemDetialsMutdic setValue:@"1" forKey:@"UOMId"];
                    [iTemDetialsMutdic setValue:@"4" forKey:@"JTMId"];
                    
                    [itemDetailArray2 addObject:iTemDetialsMutdic];
                }
            }
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:itemDetailArray2 options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            DLog(@"DC String:%@", jsonString);
            
            //        BagDetails *bagObj = [NSEntityDescription insertNewObjectForEntityForName:@"BagDetails" inManagedObjectContext:[appDel managedObjectContext]];
            
            ItemsDetails *itemObj = [NSEntityDescription insertNewObjectForEntityForName:@"ItemsDetails" inManagedObjectContext:[appDel managedObjectContext]];
            //        [bagObj setIsBagConfirmed:[NSNumber numberWithBool:NO]];
            //        [bagObj setBagTag:@""];
            //        [bagObj setBagType:[NSNumber numberWithInt:1]];
            
            NSData *jsonData2 = [NSJSONSerialization dataWithJSONObject:countArray3 options:NSJSONWritingPrettyPrinted error:&error];
            NSString *jsonString2 = [[NSString alloc] initWithData:jsonData2 encoding:NSUTF8StringEncoding];
            DLog(@"DC String:%@", jsonString2);
            
            //        [bagObj setBagDetailDic:jsonString2];
            //        [bagObj setIsStrach:[NSNumber numberWithBool:NO]];
            //        [bagObj setIsStrain:[NSNumber numberWithBool:NO]];
            //        [bagObj setStrachCount:@""];
            //        [bagObj setStrainCount:@""];
            //        [bagObj setNotes:@""];
            //        [bagObj setIsBagDeleted:[NSNumber numberWithBool:NO]];
            //        [bagObj setBagID:[[CoreDataMethods sharedInstance] getBagUniqueCode]];
            //        [bagObj setTotalAmountOfBag:@"0.0"];
            
            NSString *totalBagJsonDetailString = [NSString stringWithFormat:@"%@;%@",bagObj.bagDetailDic,jsonString2];
            [bagObj setBagDetailDic:totalBagJsonDetailString];
            
            [itemObj setITemDetailDic:jsonString];
            [itemObj setITemType:[NSNumber numberWithInt:3]];
            [itemObj setItemUniqueID:[NSNumber numberWithInt:-1]];
            
            [bagObj addItemsObject:itemObj];
            
            NSError *error1;
            if (![[appDel managedObjectContext] save:&error1]) {
                NSLog(@"error %@",error);
            }
        }
    }
    
    [self reloadTableView];
    
}


-(void) itemDetailsAreUploadedWithTag:(id) details
{
    //if (details)
        //totalAmount.text = [[[details objectForKey:@"r"] objectAtIndex:0] objectForKey:@"total"];
    
    [self reloadTableView];
}
#pragma mark --
-(void) start_OR_AtTheDoorClicked:(UIButton *) sender
{
    
    if (!enableAllAction) {
        return;
    }
    
    if ([[sender.titleLabel.text lowercaseString] isEqual:@"start"])
    {
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:@"Are you going to start this order?"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self startServiceCalled];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
    else
    {
        UIAlertController * alert = [UIAlertController
                                      alertControllerWithTitle:@""
                                      message:@"Are you At The Gate of Customer's Home?"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [self atTheDoorClicked];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

-(void) startServiceCalled
{
    
    if (appDel.latitude && appDel.socketIO)
    {
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", appDel.latitude, @"lat", appDel.longitude, @"lon", [orderDetailDic objectForKey:@"oid"], @"orderId", self.strTaskId, @"taskId", self.strDirection, @"direction", [orderDetailDic objectForKey:@"uid"], @"userId", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/start", BASE_URL];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
                
                [statusDisplayButton setTitle:@"AT THE DOOR" forState:UIControlStateNormal];
                
                UIImage *butImage1 = [UIImage imageNamed:@"door_locked.png"];
                [statusDisplayButton setImage:butImage1 forState:UIControlStateNormal];
                
                [statusDisplayButton centerImageAndTextWithSpacing:6.0];
            }
        }];
        
        
        
        
//        [appDel.socketIO emitWithAck:@"piingob startorder" with:@[dic]](0, ^(NSArray* data) {
//
//            if ([[[data objectAtIndex:0]objectForKey:@"s"]intValue] == 1)
//            {
//                [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
//
//                NSLog(@"piingob startorder : %@", data);
//
//                [statusDisplayButton setTitle:@"AT THE DOOR" forState:UIControlStateNormal];
//
//                UIImage *butImage1 = [UIImage imageNamed:@"door_locked.png"];
//                [statusDisplayButton setImage:butImage1 forState:UIControlStateNormal];
//
//                [statusDisplayButton centerImageAndTextWithSpacing:6.0];
//
//                if (automaticStartOrder)
//                {
//                    [self atTheDoorClicked];
//                }
//            }
//            else
//            {
//                [self startServiceCalled];
//            }
//        });
    }
}


-(void) atTheDoorClicked
{
    automaticStartOrder = NO;
    
    if (appDel.latitude && appDel.socketIO)
    {
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", appDel.latitude, @"lat", appDel.longitude, @"lon", [orderDetailDic objectForKey:@"oid"], @"orderId", self.strTaskId, @"taskId", self.strDirection, @"direction", [orderDetailDic objectForKey:@"uid"], @"userId", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/atthedoor", BASE_URL];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
                
                editbutton.hidden = NO;
                
                doorLockedBtn.enabled = YES;
                
                if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
                {
                    cancelOrderBtn.enabled = NO;
                }
                else
                {
                    cancelOrderBtn.enabled = YES;
                }
                
                statusDisplayButton.enabled = NO;
            }
        }];
//        [appDel.socketIO emitWithAck:@"piingob atthedoor" with:@[dic]](0, ^(NSArray* data) {
//
//            if ([[[data objectAtIndex:0]objectForKey:@"s"]intValue] == 1)
//            {
//                [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
//
//                NSLog(@"piingob atthedoor : %@", data);
//
//                editbutton.hidden = NO;
//
//                doorLockedBtn.enabled = YES;
//
//                if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
//                {
//                    cancelOrderBtn.enabled = NO;
//                }
//                else
//                {
//                    cancelOrderBtn.enabled = YES;
//                }
//
//                statusDisplayButton.enabled = NO;
//            }
//            else
//            {
//                [self atTheDoorClicked];
//            }
//
//        });
    }
}



-(void) unabletoserveClicked
{
    if (!enableAllAction) {
        return;
    }
    
    selectedIndex = -1;
    
    if ([arrayReason count])
    {
        mainView_Reasons.hidden = NO;
        
        return;
    }
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/servicefailure/reason/get", BASE_URL];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
            
            if ([[responseObj objectForKey:@"em"] count])
            {
                [arrayReason removeAllObjects];
                
                [arrayReason addObjectsFromArray:[responseObj objectForKey:@"em"]];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    
                    mainView_Reasons = [[UIView alloc]initWithFrame:self.view.bounds];
                    mainView_Reasons.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
                    [self.view addSubview:mainView_Reasons];
                    
                    
                    CGFloat height = 200*MULTIPLYHEIGHT;
                    CGFloat yView = screen_height/2-height/2;
                    
                    UIView *view_Reasons = [[UIView alloc]initWithFrame:CGRectMake(0, yView, screen_width, height)];
                    view_Reasons.backgroundColor = [UIColor whiteColor];
                    [mainView_Reasons addSubview:view_Reasons];
                    
                    CGFloat yPos = 0;
                    
                    UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(10*MULTIPLYHEIGHT, yPos, screen_width-(10*MULTIPLYHEIGHT), 44)];
                    lblTitle.text = @"Select Reason";
                    lblTitle.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
                    [view_Reasons addSubview:lblTitle];
                    
                    yPos += 44+5*MULTIPLYHEIGHT;
                    
                    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btnClose setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
                    btnClose.frame = CGRectMake(screen_width-55, 5, 44, 44);
                    [view_Reasons addSubview:btnClose];
                    [btnClose addTarget:self action:@selector(closeReasonView) forControlEvents:UIControlEventTouchUpInside];
                    
                    
                    tblResons = [[UITableView alloc]initWithFrame:CGRectMake(0, yPos, screen_width, view_Reasons.frame.size.height-yPos)];
                    tblResons.dataSource = self;
                    tblResons.delegate = self;
                    [view_Reasons addSubview:tblResons];
                    
                    yPos += tblResons.frame.size.height+5*MULTIPLYHEIGHT;
                    
                    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
                    [btnDone setTitle:@"SUBMIT" forState:UIControlStateNormal];
                    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
                    [view_Reasons addSubview:btnDone];
                    [btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [btnDone addTarget:self action:@selector(reasonSelected:) forControlEvents:UIControlEventTouchUpInside];
                    btnDone.backgroundColor = BLUE_COLOR;
                    
                    btnDone.frame = CGRectMake(screen_width/2-(80*MULTIPLYHEIGHT)/2, yPos, 80*MULTIPLYHEIGHT, 25*MULTIPLYHEIGHT);
                    
                    yPos += 25*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
                    
                    CGRect rect = view_Reasons.frame;
                    rect.size.height = yPos;
                    view_Reasons.frame = rect;
                    
                }];
            }
        }
        else {
            
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
}

-(void) closeReasonView
{
    
    mainView_Reasons.hidden = YES;
}

-(void) reasonSelected:(id)sender
{
    if (ReasonId == 0)
    {
        [appDel showAlertWithMessage:@"Please select reason" andTitle:@"" andBtnTitle:@"OK"];
    }
    else
    {
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Are you sure you want to update order to unable to serve?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                                 
                                 NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", self.strDirection, @"direction", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
                                 
                                 NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/servicefailure/save", BASE_URL];
                                 
                                 [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                                     
                                     [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                                     
                                     {
                                         if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                                         {
                                             doorLockedBtn.enabled = NO;
                                             statusDisplayButton.enabled = NO;
                                             
                                             [self closeReasonView];
                                             
                                             [self unabletoServeNodeJS];
                                             
                                             if (self.isFromCreateOrder)
                                             {
                                                 appDel.isPickupCompletedForCreatedOrder = YES;
                                                 [self.navigationController popToRootViewControllerAnimated:YES];
                                             }
                                             else
                                             {
                                                 [self gotoBack];
                                             }
                                         }
                                         else
                                         {
                                             [appDel displayErrorMessagErrorResponse:responseObj];
                                         }
                                     }
                                     
                                 }];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

-(void) cancelOrderClicked
{
    if (!enableAllAction) {
        return;
    }
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Are you sure you want to cancel the order?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                             
                             NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [orderDetailDic objectForKey:@"uid"], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
                             
                             NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/cancel", BASE_URL];
                             
                             [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                                 
                                 [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                                 
                                 if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                                 {
                                     doorLockedBtn.enabled = NO;
                                     cancelOrderBtn.enabled = NO;
                                     statusDisplayButton.enabled = NO;
                                     
                                     editbutton.hidden = YES;
                                     
//                                     UIAlertController * alert = [UIAlertController
//                                                                  alertControllerWithTitle:@""
//                                                                  message:@"Order canceled successfully"
//                                                                  preferredStyle:UIAlertControllerStyleAlert];
//                                     
//                                     UIAlertAction* ok = [UIAlertAction
//                                                          actionWithTitle:@"OK"
//                                                          style:UIAlertActionStyleDefault
//                                                          handler:^(UIAlertAction * action)
//                                                          {
//                                                              if (self.isFromCreateOrder)
//                                                              {
//                                                                  appDel.isPickupCompletedForCreatedOrder = YES;
//                                                                  [self.navigationController popToRootViewControllerAnimated:YES];
//                                                              }
//                                                              else
//                                                              {
//                                                                  [self finishOrderNodeJS];
//                                                                  
//                                                                  [self gotoBack];
//                                                              }
//                                                          }];
//                                     
//                                     [alert addAction:ok];
//                                     
//                                     [self presentViewController:alert animated:YES completion:nil];
                                 }
                                 else
                                 {
                                     [appDel displayErrorMessagErrorResponse:responseObj];
                                 }
                             }];
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) finishOrderNodeJS
{
    if (appDel.latitude && appDel.socketIO)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", appDel.latitude, @"lat", appDel.longitude, @"lon", [orderDetailDic objectForKey:@"oid"], @"orderId", self.strTaskId, @"taskId", self.strDirection, @"direction", [orderDetailDic objectForKey:@"uid"], @"userId", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/confirm", BASE_URL];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            
        }];
        
        
//        [appDel.socketIO emitWithAck:@"piingob finishorder" with:@[dic]](0, ^(NSArray* data) {
//
//            if ([[[data objectAtIndex:0]objectForKey:@"s"] intValue] == 1)
//            {
//                NSLog(@"piingob finishorder : %@", data);
//            }
//            else
//            {
//                [self finishOrderNodeJS];
//            }
//
//        });
    }
    else
    {
        [appDel showAlertWithMessage:@"piingob finishorder socket not called." andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) confirmOrderWithoutPayment
{
    if (!statusDisplayButton.enabled)
    {
        [self deliverOrderWitoutPayment];
        
        return;
        
        strOSType = @"D";
        
        [self createSignatureView];
    }
    else
    {
        [appDel showAlertWithMessage:@"Please check that you are at the Gate of Customer's Home?" andTitle:@"" andBtnTitle:@"OK"];
    }
}


-(void) confirmOrderWithoutBagsEntering
{
    if (!statusDisplayButton.enabled)
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"Are you sure you want to confirm this pickup order without entering bags?"
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                                 
                                 NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", @"1", @"deferred", nil];
                                 
                                 NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/save/pickup/confirm", BASE_URL];
                                 
                                 [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                                     
                                     if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                                     {
                                         
                                         if (appDel.latitude && appDel.socketIO)
                                         {
                                             NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", appDel.latitude, @"lat", appDel.longitude, @"lon", [orderDetailDic objectForKey:@"oid"], @"orderId", self.strTaskId, @"taskId", self.strDirection, @"direction", [orderDetailDic objectForKey:@"uid"], @"userId", nil];
                                             
                                             NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/deferred", BASE_URL];
                                             
                                             [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                                             
                                             [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                                                 
                                                 [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                                                 
                                                 if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
                                                     
                                                     [appDel showAlertWithMessage:@"Pickup order is confirmed. but Piingo should enter bag details later." andTitle:@"" andBtnTitle:@"OK"];
                                                     
                                                     [self gotoBack];
                                                 }
                                             }];
                                             
//                                             [appDel.socketIO emitWithAck:@"piingob deferred" with:@[dic]](0, ^(NSArray* data) {
//
//                                                 if ([[[data objectAtIndex:0]objectForKey:@"s"] intValue] == 1)
//                                                 {
//                                                     NSLog(@"piingob deferred : %@", data);
//
//                                                     [appDel showAlertWithMessage:@"Pickup order is confirmed. but Piingo should enter bag details later." andTitle:@"" andBtnTitle:@"OK"];
//
//                                                     [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
//
//                                                     [self gotoBack];
//                                                 }
//                                                 else
//                                                 {
//                                                     [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
//
//                                                     [appDel showAlertWithMessage:@"Error occured while confirming the pickup order." andTitle:@"" andBtnTitle:@"OK"];
//                                                 }
//                                             });
                                         }
                                     }
                                     else
                                     {
                                         [appDel displayErrorMessagErrorResponse:responseObj];
                                     }
                                 }];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [appDel showAlertWithMessage:@"Please check that you are at the Gate of Customer's Home?" andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) conformOrderBtnClicked
{
    [self.view endEditing:YES];
    
    if ([self.strDirection caseInsensitiveCompare:@"pickup"] == NSOrderedSame)
    {
        BOOL AllBagsConfirmed = NO;
        
        for (BagDetails *bagDetails in itemsArray)
        {
            if ([bagDetails.isBagConfirmed boolValue])
            {
                AllBagsConfirmed = YES;
            }
            else
            {
                AllBagsConfirmed = NO;
                break;
            }
        }
        
        NSMutableArray *arrayTypes = [[NSMutableArray alloc]init];
        
        for (BagDetails *bagDetails in itemsArray)
        {
            NSData *data;
            id json;
            
//            if ([bagDetails.bagType intValue] != 0)
//            {
//                
//                NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"iTemType" ascending:YES];
//                NSArray *itemsArray1 = [NSArray arrayWithArray:[[bagDetails.items allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]]];
//                
//                for (int i = 0; i< [itemsArray1 count]; i++)
//                {
//                    ItemsDetails *itremObj = (ItemsDetails *)[itemsArray1 objectAtIndex:i];
//                    
//                    data = [itremObj.iTemDetailDic dataUsingEncoding:NSUTF8StringEncoding];
//                    json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//                    
//                    if ([json count] > 0)
//                    {
//                        if (![arrayTypes containsObject:[NSString stringWithFormat:@"%ld", (long)[itremObj.iTemType integerValue]]])
//                        {
//                            [arrayTypes addObject:[NSString stringWithFormat:@"%ld", (long)[itremObj.iTemType integerValue]]];
//                        }
//                    }
//                }
//            }
//            else if ([bagDetails.bagType intValue] == 0)
//            {
//                if (![arrayTypes containsObject:@"0"])
//                {
//                    [arrayTypes addObject:@"0"];
//                }
//            }
            
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"iTemType" ascending:YES];
            NSArray *itemsArray1 = [NSArray arrayWithArray:[[bagDetails.items allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]]];
            
            for (int i = 0; i< [itemsArray1 count]; i++)
            {
                ItemsDetails *itremObj = (ItemsDetails *)[itemsArray1 objectAtIndex:i];
                
                data = [itremObj.iTemDetailDic dataUsingEncoding:NSUTF8StringEncoding];
                json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if ([json count] > 0)
                {
                    if (![arrayTypes containsObject:[NSString stringWithFormat:@"%@", itremObj.iTemCode]])
                    {
                        [arrayTypes addObject:[NSString stringWithFormat:@"%@", itremObj.iTemCode]];
                    }
                }
            }
        }
        
        NSMutableArray *arrayData = [NSMutableArray arrayWithArray:[self.orderInfo objectForKey:ORDER_JOB_TYPE]];
        
        NSMutableArray *arrayJobTypeOrg = [NSMutableArray array];
        
        for (int i = 0; i < [arrayData count]; i++)
        {
            NSString *str = [arrayData objectAtIndex:i];
            
            if ([str length])
            {
                [arrayJobTypeOrg addObject:str];
            }
        }
        
//        [self pickupOrder];
//        
//        return;
        
        if (AllBagsConfirmed && [arrayTypes count] == [arrayJobTypeOrg count])
        {
            [self pickupOrder];
        }
        else
        {
            [appDel showAlertWithMessage:@"Please Enter all wash types that customer has entered during order booking and Confirm if any pending bags" andTitle:@"" andBtnTitle:@"OK"];
        }
    }
    else
    {
        if (!statusDisplayButton.enabled)
        {
            NSString *strMessage = @"";
            
            if ([arrayUndeliveredItems count])
            {
                strMessage = @"Are you sure you want to confirm this partial delivery order? Before confirm, please make sure to do scan to check the bags are releated to this order.";
            }
            else if ([arrayRewashItems count])
            {
                strMessage = @"Are you sure you want to confirm this partial delivery order? Before confirm, please make sure to do scan to check the bags are releated to this order.";
            }
            else
            {
                strMessage = @"Are you sure you want to confirm this delivery order? Before confirm, please make sure to do scan to check the bags are releated to this order.";
            }
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@""
                                         message:strMessage
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* scan = [UIAlertAction
                                 actionWithTitle:@"Start Scan"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     
                                     [self startScanClicked];
                                     
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"Confirm Order"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     strOSType = @"D";
                                     
                                     [self createSignatureView];
                                     
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
            UIAlertAction* cancel = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         [alert dismissViewControllerAnimated:YES completion:nil];
                                         
                                     }];
            
            [alert addAction:scan];
            [alert addAction:ok];
            [alert addAction:cancel];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [appDel showAlertWithMessage:@"Please check that you are at the Gate of Customer's Home?" andTitle:@"" andBtnTitle:@"OK"];
        }
    }
   
}



#pragma tag child mrthod keyboard
-(void) startTagEnter:(NSString *) strRect
{
    CGRect rect = CGRectFromString(strRect);
    
    if (rect.origin.y >= screen_height)
    {
        rect.origin.y = screen_height;
        
        if (totalAmountView)
        {
            itemDetailsTableView.frame = CGRectMake(0, 50, screen_width, rect.origin.y-190);
        }
        else
        {
            itemDetailsTableView.frame = CGRectMake(0, 50, screen_width, rect.origin.y-120);
        }
    }
    else
    {
        itemDetailsTableView.frame = CGRectMake(0, 50, screen_width, screen_height-rect.size.height-100);
    }
}
-(void) tagEnterfinished
{
    itemDetailsTableView.frame = CGRectMake(0, 50, screen_width, screen_height-240.0);
}
#pragma mark CollectionViewmethods
-(void) showCollectionView
{
    
}

-(void) unabletoServeNodeJS
{
    if (appDel.latitude && appDel.socketIO)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", appDel.latitude, @"lat", appDel.longitude, @"lon", [orderDetailDic objectForKey:@"oid"], @"orderId", self.strTaskId, @"taskId", strReasonName, @"r", self.strDirection, @"direction", [orderDetailDic objectForKey:@"uid"], @"userId", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/unabletoserve", BASE_URL];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
                
                
            }
        }];
        
        
//        [appDel.socketIO emitWithAck:@"piingob unabletoserve" with:@[dic]](0, ^(NSArray* data) {
//
//            if ([[[data objectAtIndex:0]objectForKey:@"s"]intValue] == 1)
//            {
//                NSLog(@"piingob unabletoserve : %@", data);
//            }
//            else
//            {
//                [self unabletoServeNodeJS];
//            }
//
//        });
    }
}

#pragma mark UIActionView DelegateMethods
-(void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CANCEL_ORDER_BTN_TAG)
    {
        if (buttonIndex == 0)
        {
            strOSType = @"C";
            
            [self createSignatureView];
        }
    }
    
    else if (alertView.tag == AFTER_ORDER_CONFORMED)
    {
        if (self.isFromCreateOrder)
        {
            appDel.isPickupCompletedForCreatedOrder = YES;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            if ([arrayRewashItems count])
            {
                [self editOrder];
            }
            else
            {
                [self gotoBack];
            }
        }
    }
}

-(void) createSignatureView
{
    for (UIView *view in view_Custom.subviews)
    {
        [view removeFromSuperview];
    }
    
    view_Custom = [[UIView alloc]initWithFrame:appDel.window.bounds];
    view_Custom.backgroundColor = [UIColor whiteColor];
    [appDel.window addSubview:view_Custom];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"cancel_grey"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(btnCloseClicked) forControlEvents:UIControlEventTouchUpInside];
    [view_Custom addSubview:btnClose];
    
    btnClose.frame = CGRectMake(screen_width-50, 20, 44, 44);
    
    float yAxis = 20*MULTIPLYHEIGHT;
    
//    NSArray *arrTitle = @[@"Name:", @"Relationship with customer:"];
//    
//    NSArray *arrValues = @[self.strUserName, @"Customer"];
//    
//
//    for (int i=0; i<[arrTitle count]; i++)
//    {
//        UILabel *lblt = [[UILabel alloc]init];
//        lblt.text = [arrTitle objectAtIndex:i];
//        lblt.textColor = [UIColor grayColor];
//        lblt.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
//        [view_Custom addSubview:lblt];
//        
//        float lblX = 10*MULTIPLYHEIGHT;
//        float lblHeight = 20*MULTIPLYHEIGHT;
//        
//        lblt.frame = CGRectMake(lblX, yAxis, screen_width-(lblX*2), lblHeight);
//        
//        yAxis += lblHeight;
//        
//        UITextField *tf = [[UITextField alloc]init];
//        tf.delegate = self;
//        tf.text = [arrValues objectAtIndex:i];
//        tf.tag = i+1;
//        tf.borderStyle = UITextBorderStyleRoundedRect;
//        tf.textColor = [UIColor blackColor];
//        tf.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
//        [view_Custom addSubview:tf];
//        
//        tf.frame = CGRectMake(lblX, yAxis, screen_width-(lblX*2), lblHeight+5*MULTIPLYHEIGHT);
//        
//        if (i == 1)
//        {
//            tempTf = tf;
//            
//            float btnAWidth = 20*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
//            
//            UIButton *btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
//           // btnArrow.backgroundColor = [UIColor redColor];
//            btnArrow.frame = CGRectMake(view_Custom.frame.size.width-btnAWidth-7*MULTIPLYHEIGHT, yAxis, btnAWidth, btnAWidth);
//            [btnArrow addTarget:self action:@selector(openPopupForRelationName) forControlEvents:UIControlEventTouchUpInside];
//            [btnArrow setImage:[UIImage imageNamed:@"down_arrow_gray"] forState:UIControlStateNormal];
//            btnArrow.tag = 1238;
//            [view_Custom addSubview:btnArrow];
//        }
//        
//        
//        yAxis += tf.frame.size.height+10*MULTIPLYHEIGHT;
//    }
    
    UILabel *lblt = [[UILabel alloc]init];
    lblt.text = @"Signature:";
    lblt.textColor = [UIColor grayColor];
    lblt.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
    [view_Custom addSubview:lblt];
    
    float lblX = 10*MULTIPLYHEIGHT;
    float lblHeight = 20*MULTIPLYHEIGHT;
    
    lblt.frame = CGRectMake(lblX, yAxis, screen_width-(lblX*2), lblHeight);
    
    yAxis += lblHeight;
    
    float vx = 5*MULTIPLYHEIGHT;
    
    
    signatureView = nil;
    
    signatureView = [[PPSSignatureView alloc]initWithFrame:CGRectMake(vx, yAxis, screen_width-(vx*2), screen_height-(yAxis+5*MULTIPLYHEIGHT+40*MULTIPLYHEIGHT)) context:NULL];
    //signatureView.backgroundColor = [UIColor redColor];
    signatureView.hasSignature = YES;
    //signatureView.frame = CGRectMake(vx, yAxis, screen_width-(vx*2), screen_height-(yAxis+5*MULTIPLYHEIGHT));
    [view_Custom addSubview:signatureView];
    
    [signatureView erase];
    
    signatureView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    signatureView.layer.borderWidth = 1.0;
    
    yAxis += signatureView.frame.size.height+5*MULTIPLYHEIGHT;
    
    UIButton *btnSubmit = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnSubmit setTitle:@"SUBMIT" forState:UIControlStateNormal];
    [btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnSubmit.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
    btnSubmit.backgroundColor = BLUE_COLOR;
    [view_Custom addSubview:btnSubmit];
    [btnSubmit addTarget:self action:@selector(btnSignatureSubmitClicked) forControlEvents:UIControlEventTouchUpInside];
    
    float btnWidth = 110*MULTIPLYHEIGHT;
    float btnHeight = 29*MULTIPLYHEIGHT;
    
    
    float btnX = 20*MULTIPLYHEIGHT;
    
    btnSubmit.frame = CGRectMake(btnX, yAxis, btnWidth, btnHeight);
    
    btnX += btnWidth+10*MULTIPLYHEIGHT;
    
    UIButton *btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClear setTitle:@"CLEAR SIGNATURE" forState:UIControlStateNormal];
    [btnClear setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnClear.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1];
    //btnClear.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.6];
    [view_Custom addSubview:btnClear];
    [btnClear addTarget:self action:@selector(btnClearSignatureClicked) forControlEvents:UIControlEventTouchUpInside];
    
    float btnCWidth = 120*MULTIPLYHEIGHT;
    
    btnClear.frame = CGRectMake(btnX, yAxis, btnCWidth, btnHeight);
}

-(void) btnClearSignatureClicked
{
    [signatureView erase];
}

-(void) btnSignatureSubmitClicked
{
//    UITextField *nameTF = [view_Custom viewWithTag:1];
//    
//    UITextField *reTF = [view_Custom viewWithTag:2];
//    
//    if (![nameTF.text length])
//    {
//        [appDel showAlertWithMessage:@"Please enter name" andTitle:@"" andBtnTitle:@"OK"];
//        
//        return;
//    }
    
    UIImage *sigImage = signatureView.signatureImage;
    
    if (!sigImage)
    {
        [appDel showAlertWithMessage:@"Please sign in signature box" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    NSString *stringSignature = [self encodeToBase64String:signatureView.signatureImage];
    
    if (![stringSignature length])
    {
        [appDel showAlertWithMessage:@"Invalid Signature type" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    [self btnCloseClicked];
    
    if ([strOSType isEqualToString:@"C"])
    {
        [self cancelOrder];
    }
    else if ([strOSType isEqualToString:@"P"])
    {
        [self pickupOrder];
    }
    else if ([strOSType isEqualToString:@"D"])
    {
        if ([arrayUndeliveredItems count])
        {
            [self deliverOrderPartially];
        }
        else if ([arrayRewashItems count])
        {
            [self deliverOrderPartially];
        }
        else if ([[self.orderDetailDic objectForKey:@"partial"] intValue] == 1)
        {
            [self deliverOrderPartially];
        }
        else
        {
            [self deliverOrder];
        }
    }
    else if ([strOSType isEqualToString:@"D-W/O-P"])
    {
        [self deliverOrderWitoutPaymentServiceCalled];
    }
    else if ([strOSType isEqualToString:@"E"])
    {
        [self editOrder];
    }
}

-(void) startScanClicked
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
//    ScanController *scanner = [storyboard instantiateViewControllerWithIdentifier:@"ScanController"];
//    scanner.delegate = self;
//    scanner.strOid = [self.orderDetailDic objectForKey:@"oid"];
//    scanner.arrayTotalBags = [[NSMutableArray alloc]initWithArray:deliveryPartialArray];
//    scanner.view.backgroundColor = [UIColor whiteColor];
//    [self presentViewController:scanner animated:YES completion:nil];
    
    ScanViewController *scanner = [storyboard instantiateViewControllerWithIdentifier:@"ScanViewController"];
    scanner.delegate = self;
    scanner.strOid = [self.orderDetailDic objectForKey:@"oid"];
    scanner.arrayTotalBags = [[NSMutableArray alloc]initWithArray:deliveryPartialArray];
    scanner.view.backgroundColor = [UIColor whiteColor];
    [self presentViewController:scanner animated:YES completion:nil];
}

-(void) didScanCompleteWithBagNo:(NSString *)bagNo
{
    BOOL foundBagNo = NO;
    
    for (int i = 0; i < [deliveryPartialArray count]; i++)
    {
        NSDictionary *dictMain = [deliveryPartialArray objectAtIndex:i];
        
        NSDictionary *dict = [[dictMain objectForKey:@"Bag"] objectAtIndex:0];
        
        if ([[dict objectForKey:@"BagNo"] isEqualToString:bagNo])
        {
            foundBagNo = YES;
            
            break;
        }
    }
    
    if (foundBagNo)
    {
        //[appDel showAlertWithMessage:@"This bag is related to this order" andTitle:@"Success" andBtnTitle:@"OK"];
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@""
                                     message:@"This bag is related to this order. If scanning of bags completed, please click on 'Confirm order' or go to scan mode to scan the bags."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"Confirm order"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 if ([strOSType isEqualToString:@"D"])
                                 {
                                     if ([arrayUndeliveredItems count])
                                     {
                                         [self deliverOrderPartially];
                                     }
                                     else if ([arrayRewashItems count])
                                     {
                                         [self deliverOrderPartially];
                                     }
                                     else if ([[self.orderDetailDic objectForKey:@"partial"] intValue] == 1)
                                     {
                                         [self deliverOrderPartially];
                                     }
                                     else
                                     {
                                         [self deliverOrder];
                                     }
                                 }
                                 else if ([strOSType isEqualToString:@"D-W/O-P"])
                                 {
                                     [self deliverOrderWitoutPaymentServiceCalled];
                                 }
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:ok];
       
        UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Go to scan"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 //[self openScanMode];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        [appDel showAlertWithMessage:@"This bag is not related to this order!!" andTitle:@"Error" andBtnTitle:@"OK"];
    }
}


- (NSString *)encodeToBase64String:(UIImage *)image {
    
//    NSData *data = UIImagePNGRepresentation(image);
//    
//    NSString *str = [data base64EncodedString];
//    
//    return str;
    
    
    NSData *data = UIImagePNGRepresentation(image);
    
    return [data base64EncodedStringWithOptions:kNilOptions];
}

//- (NSString*)encodeStringTo64:(NSString*)fromString
//{
//    NSData *plainData = [fromString dataUsingEncoding:NSUTF8StringEncoding];
//    NSString *base64String;
//    base64String = [plainData base64EncodedStringWithOptions:kNilOptions];  // iOS 7+
//    
//    return base64String;
//}

- (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

-(void)btnCloseClicked
{
    [view_Custom removeFromSuperview];
    view_Custom = nil;
}

-(void) cancelOrder
{
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [orderDetailDic objectForKey:@"uid"], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/cancel", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        {
            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
            {
                doorLockedBtn.enabled = NO;
                cancelOrderBtn.enabled = NO;
                statusDisplayButton.enabled = NO;
                
                editbutton.hidden = YES;
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@""
                                             message:@"Order canceled successfully"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction
                                     actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         if (self.isFromCreateOrder)
                                         {
                                             appDel.isPickupCompletedForCreatedOrder = YES;
                                             [self.navigationController popToRootViewControllerAnimated:YES];
                                         }
                                         else
                                         {
                                             [self gotoBack];
                                         }
                                     }];
                
                [alert addAction:ok];
                
                [self presentViewController:alert animated:YES completion:nil];
            }
            else
            {
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
        }
    }];
}

-(void) pickupOrder
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Are you sure you want to confirm this pickup order?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
                             
                             NSString *stringSignature = [self encodeToBase64String:signatureView.signatureImage];
                             
                             NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", @"0", @"deferred", stringSignature, @"signature", nil];
                             
                             NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/save/pickup/confirm", BASE_URL];
                             
                             [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                                 
                                 [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                                 
                                 if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                                 {
                                     
                                     [self finishOrderNodeJS];
                                     
                                     UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Successfully Order Placed" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                                     transactionAlertView.tag = AFTER_ORDER_CONFORMED;
                                     [transactionAlertView show];
                                 }
                                 else
                                 {
                                     //[appDel displayErrorMessagErrorResponse:responseObj];
                                     UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Failure" message:@"Have some problem in conform the order please retry to conform." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                                     [transactionAlertView show];
                                 }
                             }];
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) deliverOrderWitoutPayment
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Are you sure you want to confirm this delivery order without payment?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [self enterNotesForDeliveryWithoutPayment];
                             
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) deliverOrderWitoutPaymentServiceCalled
{
    NSString *strPaid = totalAmount.text;
    
    NSString *stringSignature = [self encodeToBase64String:signatureView.signatureImage];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", strPaid, @"amountReceived", @"1", @"deliverdWithoutPayment", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", tvPaymentNotes.text, @"deliverdWithoutPaymentNote", stringSignature, @"signature", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/save/delivery/confirm", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Successfully Order Delivered without payment" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            transactionAlertView.tag = AFTER_ORDER_CONFORMED;
            [transactionAlertView show];
            
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:appDel.strCobId];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self finishOrderNodeJS];
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

-(void) enterNotesForDeliveryWithoutPayment
{
    view_Custom = [[UIView alloc]initWithFrame:appDel.window.bounds];
    view_Custom.backgroundColor = [UIColor whiteColor];
    [appDel.window addSubview:view_Custom];
    
    UIButton *btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnClose setImage:[UIImage imageNamed:@"cancel_grey"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(btnCloseClicked) forControlEvents:UIControlEventTouchUpInside];
    [view_Custom addSubview:btnClose];
    
    btnClose.frame = CGRectMake(screen_width-50, 20, 44, 44);
    
    float yAxis = 20*MULTIPLYHEIGHT;
    UILabel *lblt = [[UILabel alloc]init];
    lblt.text = @"Reason for no payment:";
    lblt.textColor = [UIColor grayColor];
    lblt.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
    [view_Custom addSubview:lblt];
    
    float lblX = 10*MULTIPLYHEIGHT;
    float lblHeight = 20*MULTIPLYHEIGHT;
    
    lblt.frame = CGRectMake(lblX, yAxis, screen_width-(lblX*2), lblHeight);
    
    yAxis += lblHeight+5*MULTIPLYHEIGHT;
    
    float tvX = 25*MULTIPLYHEIGHT;
    float tvW = 220*MULTIPLYHEIGHT;
    float tvH = 190*MULTIPLYHEIGHT;
    
    tvPaymentNotes = [[UITextView alloc]initWithFrame:CGRectMake(tvX, yAxis, tvW, tvH)];
    tvPaymentNotes.delegate = self;
    tvPaymentNotes.backgroundColor = RGBCOLORCODE(240, 240, 240, 1.0);
    tvPaymentNotes.textColor = [UIColor darkGrayColor];
    [view_Custom addSubview:tvPaymentNotes];
    
    tvPaymentNotes.textColor = [UIColor darkGrayColor];
    tvPaymentNotes.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
    
    UIToolbar* tvToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    tvToolbar.barTintColor = [UIColor whiteColor];
    tvToolbar.items = [NSArray arrayWithObjects:
                       [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                       [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)], nil];
    [tvToolbar sizeToFit];
    tvPaymentNotes.inputAccessoryView = tvToolbar;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [view_Custom addSubview:btnDone];
    [btnDone setImage:[UIImage imageNamed:@"save_pref"] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
    [btnDone addTarget:self action:@selector(saveDeliveryNotes) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"SAVE"];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:RGBCOLORCODE(170, 170, 170, 1.0)} range:NSMakeRange(0, [attr length])];
    float spacing = 1.0f;
    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
    [btnDone setAttributedTitle:attr forState:UIControlStateNormal];
    
    [btnDone centerImageAndTextWithSpacing:5*MULTIPLYHEIGHT];
    
    UIEdgeInsets titleInsets = btnDone.titleEdgeInsets;
    titleInsets.left -= 3*MULTIPLYHEIGHT;
    btnDone.titleEdgeInsets = titleInsets;
    
    float btnDW = 100*MULTIPLYHEIGHT;
    
    btnDone.frame = CGRectMake(screen_width/2-btnDW/2, screen_height-50*MULTIPLYHEIGHT, btnDW, 40*MULTIPLYHEIGHT);
    
    [tvPaymentNotes becomeFirstResponder];
}


-(void) saveDeliveryNotes
{
    if ([tvPaymentNotes.text length])
    {
        for (UIView *view in view_Custom.subviews)
        {
            [view removeFromSuperview];
        }
        
        [view_Custom removeFromSuperview];
        view_Custom = nil;
        
        strOSType = @"D-W/O-P";
        
        [self createSignatureView];
    }
    else
    {
        [appDel showAlertWithMessage:@"Please enter the reason for no payment." andTitle:@"" andBtnTitle:@"OK"];
    }
}


-(void) deliverOrder
{
    
    NSString *strPayment = @"";
    
    if ([[orderDetailDic objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] == NSOrderedSame)
    {
        strPayment = @"Cash";
    }
    else
    {
        strPayment = [selectedCardDict objectForKey:@"_id"];
    }
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSString *strAmount = [totalAmount.text stringByReplacingOccurrencesOfString:@"$" withString:@""];
    
    strAmount = [strAmount stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", strPayment, @"pType", strAmount, @"amountReceived", [orderDetailDic objectForKey:@"uid"], @"userId", [orderDetailDic objectForKey:@"oid"], @"oid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", strBilldId, @"billId", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/payment/finalnew", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && ([[responseObj objectForKey:@"s"] intValue] == 1 || [[responseObj objectForKey:@"s"] intValue] == 250))
        {
            NSString *strPaid = @"";
            
            if ([[responseObj objectForKey:@"s"] intValue] == 1)
            {
                strPaid = [NSString stringWithFormat:@"%.2f", [[[[[responseObj objectForKey:@"em"] objectAtIndex:0] objectForKey:@"totalSum"] objectForKey:@"amountPaid"]floatValue]];
            }
            else
            {
                strPaid = totalAmount.text;
            }
            
            NSString *stringSignature = [self encodeToBase64String:signatureView.signatureImage];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", strPaid, @"amountReceived", @"0", @"deliverdWithoutPayment", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", stringSignature, @"signature", nil];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/save/delivery/confirm", BASE_URL];
            
            [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                
                [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                
                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                {
                    if ([[orderDetailDic objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] != NSOrderedSame)
                    {
                        UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Successfully Order Delivered" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                        transactionAlertView.tag = AFTER_ORDER_CONFORMED;
                        [transactionAlertView show];
                    }
                    else
                    {
                        UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Successfully Order Delivered" message:@"Please don't forget to collect the money" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                        transactionAlertView.tag = AFTER_ORDER_CONFORMED;
                        [transactionAlertView show];
                    }
                    
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:appDel.strCobId];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [self finishOrderNodeJS];
                }
                else
                {
                    [appDel displayErrorMessagErrorResponse:responseObj];
                }
            }];
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

-(void) editOrder
{
    self.navigationController.navigationBarHidden = YES;
    
    ScheduleLaterViewController1 *scheduleVC = [[ScheduleLaterViewController1 alloc] init];
    
    if ([arrayRewashItems count])
    {
        scheduleVC.isRewashOrder = YES;
        scheduleVC.arrayRewashItems = [[NSMutableArray alloc]initWithArray:arrayRewashItems];
    }
    
    else if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame)
    {
        scheduleVC.isDeliveryOrder = YES;
    }
    
    scheduleVC.userAddresses = [[NSArray alloc]initWithArray:userAddresses];
    scheduleVC.userSavedCards = [[NSArray alloc]initWithArray:userSavedCards];
    scheduleVC.dictUpdateOrder = [[NSMutableDictionary alloc]initWithDictionary:orderDetailDic];
    scheduleVC.dictChangedValues = [[NSMutableDictionary alloc]initWithDictionary:orderDetailDic];
    scheduleVC.dictAllowFields = [[NSMutableDictionary alloc]initWithDictionary:self.dictUpdatable];
    scheduleVC.arrayJobTypeOrg = [[NSMutableArray alloc]initWithArray:[orderDetailDic objectForKey:ORDER_JOB_TYPE]];
    
    scheduleVC.view.frame = CGRectMake(0.0, screen_height, screen_width, screen_height);
    
    UINavigationController *navSL = [[UINavigationController alloc]initWithRootViewController:scheduleVC];
    navSL.navigationBarHidden = YES;
    
    navSL.view.frame = CGRectMake(0.0, screen_height-50, screen_width, screen_height);
    [self addChildViewController:navSL];
    [self.view addSubview:navSL.view];
    
    [UIView animateWithDuration:0.3 animations:^{
        navSL.view.frame = self.view.bounds;
    } completion:^(BOOL finished) {
        
    }];
}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 2)
    {
        tempTf = textField;
        
        if (![textField.text isEqualToString:@"Others"] && !isEditable)
        {
            [textField resignFirstResponder];
            
            [self openPopupForRelationName];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

-(void) openPopupForRelationName
{
    [tempTf resignFirstResponder];
    
    view_Popover = [[UIView alloc]initWithFrame:self.view.bounds];
    view_Popover.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    [appDel.window addSubview:view_Popover];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(closeCustomPopover)];
    tap.cancelsTouchesInView = NO;
    [view_Popover addGestureRecognizer:tap];
    
    NSArray *arrayTypes = [[NSArray alloc]initWithObjects:@"Customer", @"Spouse", @"Sibling", @"Family member", @"Helper", @"Others", nil];
    customPopOverView = [[CustomPopoverView alloc]initWithArray:arrayTypes];
    customPopOverView.delegate = self;
    [view_Popover addSubview:customPopOverView];
    customPopOverView.alpha = 1.0;
    customPopOverView.backgroundColor = [UIColor clearColor];
    
    CGRect tfRect = [tempTf.superview.superview convertRect:tempTf.frame toView:appDel.window];
    
    float lblX = 10*MULTIPLYHEIGHT;
    
    float yC = tfRect.origin.y+20*MULTIPLYHEIGHT+4*MULTIPLYHEIGHT;
    
    customPopOverView.frame = CGRectMake(lblX, yC, screen_width-(lblX*2), 0);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        
        customPopOverView.frame = CGRectMake(20, yC, screen_width-40, screen_height-(tfRect.origin.y+35));
        
        
    } completion:^(BOOL finished) {
        
        
    }];
}

-(void) closeCustomPopover
{
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        
        CGRect frame = customPopOverView.frame;
        frame.size.height = 0;
        customPopOverView.frame = frame;
        
        
    } completion:^(BOOL finished) {
        
        [view_Popover removeFromSuperview];
        view_Popover = nil;
        
        [customPopOverView removeFromSuperview];
        customPopOverView = nil;
        
    }];
}

-(void) didSelectFromList:(NSString *)string AtIndex:(NSInteger)row
{
    if (![string isEqualToString:@"Others"])
    {
        isEditable = NO;
        tempTf.text = string;
    }
    else
    {
        isEditable = YES;
        tempTf.text = @"";
        
        [tempTf becomeFirstResponder];
    }
    
    [self closeCustomPopover];
}

-(void) didConformPatyment
{
    [self gotoBack];
}


-(void) openCardDetailsVC
{
    UpdatePaymentOrderViewController *paymentUUpdateVC = [[UpdatePaymentOrderViewController alloc] initWithNibName:nil bundle:nil andIscurrentJobDetails:orderDetailDic];
    paymentUUpdateVC.delegate = self;
    paymentUUpdateVC.strTotalAmount = totalAmount.text;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:paymentUUpdateVC];
    
    [self.navigationController presentViewController:navVC animated:YES completion:^{
        
    }];
}

#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == tblResons)
    {
        NSDictionary *dict = [arrayReason objectAtIndex:indexPath.row];
        
        NSString *strReason = [dict objectForKey:@"reason"];
        
        CGFloat height = [AppDelegate getLabelHeightForRegularText:strReason WithWidth:screen_width-(10*MULTIPLYHEIGHT*2) FontSize:appDel.FONT_SIZE_CUSTOM-3];
        
        return height+22*MULTIPLYHEIGHT;
    }
    
    else if ([self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame)
    {
        
        NSDictionary *dictDetail = [arrayCustomizedData objectAtIndex:indexPath.row];
        
        NSArray *arrayDetail = [dictDetail objectForKey:@"STItems"];
        
        NSString *strWashType = [dictDetail objectForKey:@"serviceType"];
        
        float yAxis = 20*MULTIPLYHEIGHT;
        
        float imgWX = 11*MULTIPLYHEIGHT;
        float imgWWidth = 29*MULTIPLYHEIGHT;
        
        float lblWX = imgWX+imgWWidth+11*MULTIPLYHEIGHT;
        float minusWidth = 85*MULTIPLYHEIGHT;
        float lblWWidth = lblWX+minusWidth;
        float lblWHeight = 15*MULTIPLYHEIGHT;
        
        yAxis += lblWHeight+15*MULTIPLYHEIGHT;
        
        if ([strWashType caseInsensitiveCompare:SERVICETYPE_WF] == NSOrderedSame  || [strWashType isEqualToString:SERVICETYPE_CA])
        {
            yAxis += lblWHeight;
            
            yAxis += 20*MULTIPLYHEIGHT;
        }
        else
        {
            NSString *strType = @"";
            
            for (NSDictionary *dict1 in arrayDetail)
            {
                NSArray *arrayItemCode = [dict1 allKeys];
                
                for (NSString *strCode in arrayItemCode)
                {
                    NSArray *arrayItems = [dict1 objectForKey:strCode];
                    
                    NSDictionary *dict2 = [arrayItems objectAtIndex:0];
                    
                    if ([dict2 objectForKey:@"itemName"])
                    {
                        NSString *strI = [[[dict2 objectForKey:@"itemName"] componentsSeparatedByString:@"^^"] objectAtIndex:0];
                        
                        if ([[dict2 objectForKey:@"weight"] floatValue] == 0.0)
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%ld  ", strI, [arrayItems count]];
                        }
                        else
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%@ kgs  ", strI, [dict2 objectForKey:@"weight"]];
                        }
                    }
                    else
                    {
                        if ([[dict2 objectForKey:@"weight"] floatValue] == 0.0)
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%ld  ", [dict2 objectForKey:@"itemCode"], [arrayItems count]];
                        }
                        else
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%@ kgs  ", [dict2 objectForKey:@"itemCode"], [dict2 objectForKey:@"weight"]];
                        }
                    }
                }
            }
            
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:strType];
            
            NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
            paragrapStyle.alignment = NSTextAlignmentLeft;
            [paragrapStyle setLineSpacing:4.0f];
            [paragrapStyle setMaximumLineHeight:100.0f];
            
            [attr addAttributes:@{NSParagraphStyleAttributeName:paragrapStyle, NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-3]} range:NSMakeRange(0, attr.length)];
            
            CGSize frameSize = [AppDelegate getAttributedTextHeightForText:attr WithWidth:lblWWidth];
            
            if (frameSize.height <= 20)
            {
                frameSize.height = 20;
            }
            
            yAxis += frameSize.height+20*MULTIPLYHEIGHT;
            
        }
        
        return yAxis;
    }
    else if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame && [self.strTaskStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
    {
        
        if (indexPath.section == 0)
        {
            if ([[[deliveryPartialArray objectAtIndex:indexPath.row] objectForKey:@"serviceTypesId"] isEqualToString:@"WF"] || [[[deliveryPartialArray objectAtIndex:indexPath.row] objectForKey:@"serviceTypesId"] isEqualToString:@"CA"])
            {
                return 90;
            }
            
            NSInteger count = [[[[[[deliveryPartialArray objectAtIndex:indexPath.row] objectForKey:@"Bag"] objectAtIndex:0]objectForKey:@"itemsDetailsFull"] allKeys] count];
            
            return 50 + 50 * count;
        }
        else if (indexPath.section == 1)
        {
            NSInteger count = [[[[[[arrayUndeliveredItems objectAtIndex:indexPath.row] objectForKey:@"Bag"] objectAtIndex:0]objectForKey:@"itemsDetailsFull"] allKeys] count];
            
            return 50 + 50 * count;
        }
        else if (indexPath.section == 2)
        {
            NSInteger count = [[[[[[arrayRewashItems objectAtIndex:indexPath.row] objectForKey:@"Bag"] objectAtIndex:0]objectForKey:@"itemsDetailsFull"] allKeys] count];
            
            return 50 + 50 * count;
        }
    }
    else
    {
        
        if ([itemsArray count])
        {
            BagDetails *bagObj = [itemsArray objectAtIndex:indexPath.row];
            
//            if ([bagObj.bagType integerValue] == 0)
//            {
//                return 110+15;
//            }
            
            NSData *data;
            id json;
            
            float yAxis = 30;
            
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"iTemType" ascending:YES];
            NSArray *itemsArray1 = [NSArray arrayWithArray:[[bagObj.items allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]]];
            
            for (int i = 0; i< [itemsArray1 count]; i++)
            {
                yAxis += 20;
                
                ItemsDetails *itremObj = (ItemsDetails *)[itemsArray1 objectAtIndex:i];
                
                data = [itremObj.iTemDetailDic dataUsingEncoding:NSUTF8StringEncoding];
                json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                if ([json count] > 0)
                {
                    yAxis += 25;
                    
                    if ([json isKindOfClass:[NSArray class]])
                    {
                        for (int i = 0; i<[json count]; i++)
                        {
                            if ([[json objectAtIndex:i] objectForKey:@"quantity"])
                            {
                                yAxis += 25;
                            }
                            else if ([[json objectAtIndex:i] objectForKey:@"weight"])
                            {
                                yAxis += 25;
                            }
                        }
                    }
                }
            }
            
            return yAxis+55;
        }
    }
    return 110.0-25;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame && [self.strTaskStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
    {
        if (section == 0)
        {
            return 0;
        }
        else
        {
            if (section == 1)
            {
                if ([arrayUndeliveredItems count])
                {
                    return 25*MULTIPLYHEIGHT;
                }
                
                return 0;
            }
            else if (section == 2)
            {
                if ([arrayRewashItems count])
                {
                    return 25*MULTIPLYHEIGHT;
                }
                
                return 0;
            }
            else
            {
                return 0;
            }
        }
    }
    else
    {
        return 0;
    }
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame && [self.strTaskStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
    {
        
        if (section == 0)
        {
            return 0;
        }
        else if (section == 1)
        {
            if ([arrayUndeliveredItems count])
            {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, 25*MULTIPLYHEIGHT)];
                
                UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10*MULTIPLYHEIGHT, 0, screen_width, 25*MULTIPLYHEIGHT)];
                lbl.text = @"Undelivered Items";
                lbl.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM+2];
                lbl.textColor = BLUE_COLOR;
                [view addSubview:lbl];
                
                return view;
            }
            
            return 0;
        }
        else if (section == 2)
        {
            if ([arrayRewashItems count])
            {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, 25*MULTIPLYHEIGHT)];
                
                UILabel *lbl = [[UILabel alloc]initWithFrame:CGRectMake(10*MULTIPLYHEIGHT, 0, screen_width, 25*MULTIPLYHEIGHT)];
                lbl.text = @"Rewash Items";
                lbl.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM+2];
                lbl.textColor = BLUE_COLOR;
                [view addSubview:lbl];
                
                return view;
            }
            
            return 0;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return 0;
    }
}

-(CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (tableView == tblResons)
    {
        return 0;
    }
    
    return 15.0;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (tableView == tblResons)
    {
        return 0;
    }
    
    UIView *emptyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 15.0)];
    emptyView.backgroundColor = [UIColor clearColor];
    
    return emptyView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame && [self.strTaskStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
    {
        if (appDel.isPartialDelivery)
        {
            return 3;
        }
        else if (appDel.isRewash)
        {
            return 3;
        }
        else
        {
            return 1;
        }
    }
    else
    {
        return 1;
    }
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == tblResons)
    {
        return [arrayReason count];
    }
    
    else if ([self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame)
    {
        return [arrayPriceList count];
    }
    
    else if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame && [self.strTaskStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
    {
        if (section == 0)
        {
            return [deliveryPartialArray count];
        }
        else if (section == 1)
        {
            return [arrayUndeliveredItems count];
        }
        else if (section == 2)
        {
            return [arrayRewashItems count];
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return [itemsArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == tblResons)
    {
        static NSString *CellIdentifier;
        CellIdentifier = [NSString stringWithFormat:@"ReasonCell"];
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            cell.backgroundColor = [UIColor clearColor];
            
            CGFloat lblX = 10*MULTIPLYHEIGHT;
            
            UILabel *lblReason = [[UILabel alloc]initWithFrame:CGRectMake(lblX, 10*MULTIPLYHEIGHT, screen_width-(5*MULTIPLYHEIGHT*2), 30)];
            lblReason.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-3];
            lblReason.textColor = [UIColor grayColor];
            lblReason.tag = 1;
            [cell.contentView addSubview:lblReason];
        }
        
        UILabel *lblReadon = (UILabel *) [cell.contentView viewWithTag:1];
        
        NSDictionary *dict = [arrayReason objectAtIndex:indexPath.row];
        
        if(indexPath.row == selectedIndex)
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            lblReadon.textColor = BLUE_COLOR;
            
            ReasonId = [[dict objectForKey:@"rid"]intValue];
            
            strReasonName = [dict objectForKey:@"reason"];
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            lblReadon.textColor = [UIColor grayColor];
        }
        
        NSString *strReason = [dict objectForKey:@"reason"];
        
        CGFloat height = [AppDelegate getLabelHeightForRegularText:strReason WithWidth:lblReadon.frame.size.width FontSize:lblReadon.font.pointSize];
        CGRect rect = lblReadon.frame;
        rect.size.height = height;
        lblReadon.frame = rect;
        
        lblReadon.text = [dict objectForKey:@"reason"];
        
        return cell;
    }
    
    else if ([self.strTaskStatus caseInsensitiveCompare:@"D"] == NSOrderedSame)
    {
        static NSString *CellIdentifier;
        CellIdentifier = [NSString stringWithFormat:@"Cell"];
        
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UIView *viewBG = [[UIView alloc]initWithFrame:CGRectMake(0, 5, screen_width, 100)];
            viewBG.tag = 1;
            viewBG.backgroundColor = [UIColor clearColor];
            //viewBG.backgroundColor = [UIColor yellowColor];
            [cell.contentView addSubview:viewBG];
            
            
            float yAxis = 20*MULTIPLYHEIGHT;
            
            float imgWX = 11*MULTIPLYHEIGHT;
            float imgWWidth = 29*MULTIPLYHEIGHT;
            
            UIImageView *imgWashType = [[UIImageView alloc]initWithFrame:CGRectMake(imgWX, yAxis, imgWWidth, imgWWidth)];
            imgWashType.tag = 2;
            imgWashType.contentMode = UIViewContentModeScaleAspectFit;
            [viewBG addSubview:imgWashType];
            
            
            float lblWX = imgWX+imgWWidth+11*MULTIPLYHEIGHT;
            float minusWidth = 85*MULTIPLYHEIGHT;
            float lblWWidth = lblWX+minusWidth;
            float lblWHeight = 15*MULTIPLYHEIGHT;
            
            UILabel *lblWashType = [[UILabel alloc]initWithFrame:CGRectMake(lblWX, yAxis, lblWWidth+5*MULTIPLYHEIGHT, lblWHeight)];
            lblWashType.tag = 3;
            lblWashType.numberOfLines = 0;
            lblWashType.textColor = [UIColor grayColor];
            lblWashType.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2];
            [viewBG addSubview:lblWashType];
            
            float lblPWidth = 70*MULTIPLYHEIGHT;
            float lblPHeight = 15*MULTIPLYHEIGHT;
            float lblPX = 90*MULTIPLYHEIGHT;
            
            UILabel *lblPrice = [[UILabel alloc]initWithFrame:CGRectMake(screen_width-lblPX, yAxis, lblPWidth, lblPHeight)];
            lblPrice.tag = 5;
            lblPrice.textAlignment = NSTextAlignmentRight;
            lblPrice.textColor = [UIColor darkGrayColor];
            lblPrice.backgroundColor = [UIColor clearColor];
            lblPrice.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM+2];
            [viewBG addSubview:lblPrice];
            
            yAxis += lblWHeight+15*MULTIPLYHEIGHT;
            
            
            UILabel *lblDetail = [[UILabel alloc]initWithFrame:CGRectMake(lblWX, yAxis, lblWWidth, lblWHeight)];
            lblDetail.tag = 4;
            lblDetail.numberOfLines = 0;
            lblDetail.textColor = [UIColor grayColor];
            lblDetail.backgroundColor = [UIColor clearColor];
            lblDetail.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-3];
            [viewBG addSubview:lblDetail];
            
            
            UIImageView *imgArrow = [[UIImageView alloc]init];
            imgArrow.tag = 6;
            imgArrow.contentMode = UIViewContentModeScaleAspectFit;
            imgArrow.image = [UIImage imageNamed:@"right_arrow"];
            //[viewBG addSubview:imgArrow];
            
            CALayer *bottomLayerView = [[CALayer alloc]init];
            bottomLayerView.name = @"viewBG";
            CGFloat layerX = 40*MULTIPLYHEIGHT;
            bottomLayerView.frame = CGRectMake(layerX, viewBG.frame.size.height-1, viewBG.frame.size.width-(layerX*2), 1);
            bottomLayerView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.3].CGColor;
            [viewBG.layer addSublayer:bottomLayerView];
        }
        
        cell.backgroundColor = [UIColor clearColor];
        float yAxis = 0;
        
        UIView *viewBG = (UIView *) [cell.contentView viewWithTag:1];
        UIImageView *imgWashType = (UIImageView *) [cell.contentView viewWithTag:2];
        
        UILabel *lblWashType = (UILabel *) [cell.contentView viewWithTag:3];
        
        UILabel *lblDetail = (UILabel *) [cell.contentView viewWithTag:4];
        
        UILabel *lblPrice = (UILabel *) [cell.contentView viewWithTag:5];
        
        UIImageView *imgArrow = (UIImageView *) [cell.contentView viewWithTag:6];
        
        NSDictionary *dictDetail = [arrayCustomizedData objectAtIndex:indexPath.row];
        
        NSArray *arrayDetail = [dictDetail objectForKey:@"STItems"];
        
        NSString *strWashType = [dictDetail objectForKey:@"serviceType"];
        NSString *strServiceName = [dictDetail objectForKey:@"serviceTypeName"];
        
        NSString *strTi = @"";
        
        if ([strServiceName length])
        {
            strTi = [strServiceName uppercaseString];
        }
        else
        {
            strTi = [strWashType uppercaseString];
        }
        
        lblWashType.text = strTi;
        
        CGFloat lblWH = [AppDelegate getLabelHeightForMediumText:strTi WithWidth:lblWashType.frame.size.width FontSize:lblWashType.font.pointSize];
        
        CGRect frame = lblWashType.frame;
        frame.size.height = lblWH;
        lblWashType.frame = frame;
        
        if ([strWashType caseInsensitiveCompare:SERVICETYPE_WF] == NSOrderedSame)
        {
            if ([arrayDetail count])
            {
                NSDictionary *dictDetail = [arrayDetail objectAtIndex:0];
                
                lblDetail.text = [NSString stringWithFormat:@"Number of kgs - %.2f", [[dictDetail objectForKey:@"weight"] floatValue]];
                lblPrice.text = [NSString stringWithFormat:@"$ %.2f", [[dictDetail objectForKey:@"totalPrice"] floatValue]];
            }
            
            yAxis = lblWashType.frame.origin.y+lblWashType.frame.size.height;
            
            yAxis += 30*MULTIPLYHEIGHT;
            
            imgWashType.image = [UIImage imageNamed:@"loadwash_price"];
            
            imgArrow.hidden = YES;
        }
        else if ([strWashType caseInsensitiveCompare:SERVICETYPE_CA] == NSOrderedSame)
        {
            if ([arrayDetail count])
            {
                NSDictionary *dictDetail = [arrayDetail objectAtIndex:0];
                
                lblDetail.text = [NSString stringWithFormat:@"Number of sqfts - %.2f", [[dictDetail objectForKey:@"weight"] floatValue]];
                lblPrice.text = [NSString stringWithFormat:@"$ %.2f", [[dictDetail objectForKey:@"totalPrice"] floatValue]];
            }
            
            yAxis = lblWashType.frame.origin.y+lblWashType.frame.size.height;
            
            yAxis += 30*MULTIPLYHEIGHT;
            
            imgWashType.image = [UIImage imageNamed:@"carpet_price"];
            
            imgArrow.hidden = YES;
        }
        else
        {
            if ([strWashType caseInsensitiveCompare:SERVICETYPE_DC] == NSOrderedSame || [strWashType caseInsensitiveCompare:SERVICETYPE_DCG] == NSOrderedSame)
            {
                imgWashType.image = [UIImage imageNamed:@"dryclean_price"];
            }
            else if ([strWashType caseInsensitiveCompare:SERVICETYPE_WI] == NSOrderedSame)
            {
                imgWashType.image = [UIImage imageNamed:@"wash_iron_price"];
            }
            else if ([strWashType caseInsensitiveCompare:SERVICETYPE_IR] == NSOrderedSame)
            {
                imgWashType.image = [UIImage imageNamed:@"ironing_price"];
            }
            else if ([strWashType caseInsensitiveCompare:SERVICETYPE_LE] == NSOrderedSame)
            {
                imgWashType.image = [UIImage imageNamed:@"leather_price"];
            }
            else if ([strWashType containsString:SERVICETYPE_CC])
            {
                imgWashType.image = [UIImage imageNamed:@"curtains_price"];
            }
            else if ([strWashType containsString:SERVICETYPE_BAG])
            {
                imgWashType.image = [UIImage imageNamed:@"bag_price"];
            }
            else if ([strWashType containsString:SERVICETYPE_SHOE])
            {
                imgWashType.image = [UIImage imageNamed:@"shoe_price"];
            }
            
            NSString *strType = @"";
            float Price = 0;
            
            BOOL isColorCodeFound = NO;
            
            for (NSDictionary *dict1 in arrayDetail)
            {
                NSArray *arrayItemCode = [dict1 allKeys];
                
                for (NSString *strCode in arrayItemCode)
                {
                    NSArray *arrayItems = [dict1 objectForKey:strCode];
                    
                    NSDictionary *dict2 = [arrayItems objectAtIndex:0];
                    
                    if ([dict2 objectForKey:@"itemName"])
                    {
                        NSString *strI = [[[dict2 objectForKey:@"itemName"] componentsSeparatedByString:@"^^"] objectAtIndex:0];
                        
                        if ([[dict2 objectForKey:@"weight"] floatValue] == 0.0)
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%ld  ", strI, [arrayItems count]];
                        }
                        else
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%@ kgs  ", strI, [dict2 objectForKey:@"weight"]];
                        }
                    }
                    else
                    {
                        if ([[dict2 objectForKey:@"weight"] floatValue] == 0.0)
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%ld  ", [dict2 objectForKey:@"itemCode"], [arrayItems count]];
                        }
                        else
                        {
                            strType = [strType stringByAppendingFormat:@"%@-%@ kgs  ", [dict2 objectForKey:@"itemCode"], [dict2 objectForKey:@"weight"]];
                        }
                    }
                    
                    for (NSDictionary *dict3 in arrayItems)
                    {
                        Price += [[dict3 objectForKey:@"totalPrice"] floatValue];
                        
                        if ([[dict3 objectForKey:@"brand"] length])
                        {
                            isColorCodeFound = YES;
                        }
                    }
                }
            }
            
            if (isColorCodeFound && ![strWashType containsString:@"CC_"])
            {
                imgArrow.hidden = NO;
            }
            else
            {
                imgArrow.hidden = YES;
            }
            
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:strType];
            
            NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
            paragrapStyle.alignment = NSTextAlignmentLeft;
            [paragrapStyle setLineSpacing:4.0f];
            [paragrapStyle setMaximumLineHeight:100.0f];
            
            [attr addAttributes:@{NSParagraphStyleAttributeName:paragrapStyle, NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:lblDetail.font.pointSize]} range:NSMakeRange(0, attr.length)];
            
            CGSize frameSize = [AppDelegate getAttributedTextHeightForText:attr WithWidth:lblDetail.frame.size.width];
            
            if (frameSize.height <= 20)
            {
                frameSize.height = 20;
            }
            
            lblDetail.attributedText = attr;
            
            CGRect frame = lblDetail.frame;
            frame.size.height = frameSize.height;
            lblDetail.frame = frame;
            
            lblPrice.text = [NSString stringWithFormat:@"$ %.2f", Price];
            
            yAxis = lblDetail.frame.origin.y+lblDetail.frame.size.height;
        }
        
        float viewbgY = 0*MULTIPLYHEIGHT;
        
        yAxis += 20*MULTIPLYHEIGHT;
        
        viewBG.frame = CGRectMake(0, viewbgY, screen_width, yAxis);
        
        for (CALayer *layer in [viewBG.layer sublayers])
        {
            if ([[layer name] isEqualToString:@"viewBG"])
            {
                CGRect rectL = layer.frame;
                rectL.origin.y = viewBG.frame.size.height-1;
                layer.frame = rectL;
            }
        }
        
        //    CGRect rect = imgWashType.frame;
        //    rect.origin.y = (yAxis/2)-(imgWashType.frame.size.height/2);
        //    imgWashType.frame = rect;
        
        
        float imgAWidth = 8*MULTIPLYHEIGHT;
        float minusArrowY = 15*MULTIPLYHEIGHT;
        imgArrow.frame = CGRectMake(screen_width-minusArrowY, (yAxis/2)-(imgAWidth/2), imgAWidth, imgAWidth);
        
        CGRect rectPrice = lblPrice.frame;
        rectPrice.origin.y = yAxis/2-lblPrice.frame.size.height/2;
        lblPrice.frame = rectPrice;
        
        return cell;
    }
    
    else if ([self.strDirection caseInsensitiveCompare:@"Delivery"] == NSOrderedSame && [self.strTaskStatus caseInsensitiveCompare:@"D"] != NSOrderedSame)
    {
        if (([[[deliveryPartialArray objectAtIndex:indexPath.row] objectForKey:@"serviceTypesId"] isEqualToString:@"WF"] || [[[deliveryPartialArray objectAtIndex:indexPath.row] objectForKey:@"serviceTypesId"] isEqualToString:@"CA"])&& indexPath.section == 0)
        {
            
            static NSString *cellIdentifier;
            
            cellIdentifier = [NSString stringWithFormat:@"W&FBagCell%ld",(long)indexPath.row];
            
            WashAndFoldBagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                
                cell = [[WashAndFoldBagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andWithDelegate:self];
            }
            
            [cell setDetials:[deliveryPartialArray objectAtIndex:indexPath.row]];
            
            return cell;
        }
        else
        {
            static NSString *cellIdentifier;
            
            cellIdentifier = [NSString stringWithFormat:@"W&IBagCell%ld",(long)indexPath.row];
            
            WashAndIronBagTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
            
            if (cell == nil) {
                
                cell = [[WashAndIronBagTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andWithDelegate:self];
            }
            
            if (indexPath.section == 0)
            {
                cell.userInteractionEnabled = YES;
                
                [cell setDetials:[deliveryPartialArray objectAtIndex:indexPath.row]];
            }
            else if (indexPath.section == 1)
            {
                cell.userInteractionEnabled = NO;
                
                [cell setDetials:[arrayUndeliveredItems objectAtIndex:indexPath.row]];
            }
            else if (indexPath.section == 2)
            {
                cell.userInteractionEnabled = NO;
                
                [cell setDetials:[arrayRewashItems objectAtIndex:indexPath.row]];
            }
            
            return cell;
        }
    }
    else
    {
        static NSString *cellIdentifier;
        
        cellIdentifier = [NSString stringWithFormat:@"itemCell%ld",(long)indexPath.row];
        
        ItemsDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            
            cell = [[ItemsDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier andWithDelegate:self];
        }
        
        [cell setDetials:[itemsArray objectAtIndex:indexPath.row]];

        return cell;
    }
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == tblResons)
    {
//        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        
//        UILabel *lblReadon = (UILabel *) [cell.contentView viewWithTag:1];
//        
//        NSDictionary *dict = [arrayReason objectAtIndex:indexPath.row];
        
        selectedIndex = (int) indexPath.row;
        [tableView reloadData];
    }
}

-(void) btnOptionsClicked:(id)sender
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:@"Partial delivery or Rewash?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* partial = [UIAlertAction
                              actionWithTitle:@"Partial Delivery"
                              style:UIAlertActionStyleDefault
                              handler:^(UIAlertAction * action)
                              {
                                  
                                  appDel.isPartialDelivery = YES;
                                  appDel.isRewash = NO;
                                  
                                  [itemDetailsTableView reloadData];
                                  
                                  [alert dismissViewControllerAnimated:YES completion:nil];
                                  
                              }];
    UIAlertAction* rewash = [UIAlertAction
                             actionWithTitle:@"Rewash"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 appDel.isRewash = YES;
                                 appDel.isPartialDelivery = NO;
                                 
                                 [itemDetailsTableView reloadData];
                                 
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:partial];
    [alert addAction:rewash];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) getDeliveryDataToPartial
{
    for (int i = 0; i < [deliveryDetaildArray count]; i++)
    {
        NSDictionary *dictBag = [deliveryDetaildArray objectAtIndex:i];
        
        if ([[dictBag objectForKey:@"serviceTypesId"] isEqualToString:@"WF"] || [[dictBag objectForKey:@"serviceTypesId"] isEqualToString:@"CA"])
        {
            NSDictionary *dictItem = [[dictBag objectForKey:@"Bag"] objectAtIndex:0];
            
            if ([[dictItem objectForKey:@"status"] isEqualToString:@"DE"])
            {
                continue;
            }
            
            NSMutableArray *arrayBag = [[NSMutableArray alloc]initWithObjects:[[dictBag objectForKey:@"Bag"] objectAtIndex:0], nil];
            
            NSMutableDictionary *dictBagPar = [[NSMutableDictionary alloc]initWithObjectsAndKeys:arrayBag, @"Bag", nil];
            [dictBagPar setObject:[dictBag objectForKey:@"serviceTypesId"] forKey:@"serviceTypesId"];
            [dictBagPar setObject:[dictBag objectForKey:@"_id"] forKey:@"_id"];
            
            [deliveryPartialArray addObject:dictBagPar];
        }
        else
        {
            NSArray *arrayData = [dictBag objectForKey:@"Bag"];
            
            for (int p = 0; p < [arrayData count]; p++)
            {
                NSArray *arrayItems = [[arrayData objectAtIndex:p] objectForKey:@"itemsDetailsFull"];
                
                NSMutableDictionary *dictItemsFull = [[NSMutableDictionary alloc]init];
                
                NSMutableDictionary *dictItemType = [[NSMutableDictionary alloc]init];
                
                for (int j = 0; j < [arrayItems count]; j++)
                {
                    NSDictionary *dictItem = [arrayItems objectAtIndex:j];
                    
                    if ([[dictItem objectForKey:@"status"] isEqualToString:@"DE"])
                    {
                        continue;
                    }
                    
                    NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]initWithDictionary:dictItem];
                    [dict1 setObject:@"Y" forKey:@"selectedItem"];
                    [dict1 setObject:@"N" forKey:@"Partial"];
                    [dict1 setObject:@"N" forKey:@"Rewash"];
                    
                    NSString *strItemCode = [dictItem objectForKey:@"itemType"];
                    
                    if (![dictItemType objectForKey:strItemCode])
                    {
                        NSMutableArray *arrayItemCode = [[NSMutableArray alloc]initWithObjects:dict1, nil];
                        
                        [dictItemType setObject:arrayItemCode forKey:strItemCode];
                    }
                    else
                    {
                        NSMutableArray *arrayItemCode = [dictItemType objectForKey:strItemCode];
                        
                        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]initWithDictionary:dictItem];
                        [dict1 setObject:@"Y" forKey:@"selectedItem"];
                        [dict1 setObject:@"N" forKey:@"Partial"];
                        [dict1 setObject:@"N" forKey:@"Rewash"];
                        
                        [arrayItemCode addObject:dict1];
                    }
                }
                
                if ([dictItemType count])
                {
                    [dictItemsFull setObject:dictItemType forKey:@"itemsDetailsFull"];
                    
                    [dictItemsFull setObject:[[arrayData objectAtIndex:p] objectForKey:@"BagNo"] forKey:@"BagNo"];
                    [dictItemsFull setObject:[[arrayData objectAtIndex:p] objectForKey:@"Total"] forKey:@"Total"];
                    [dictItemsFull setObject:[[arrayData objectAtIndex:p] objectForKey:@"_id"] forKey:@"_id"];
                    
                    NSMutableArray *arrayBag = [[NSMutableArray alloc]initWithObjects:dictItemsFull, nil];
                    
                    NSMutableDictionary *dictBagPar = [[NSMutableDictionary alloc]initWithObjectsAndKeys:arrayBag, @"Bag", nil];
                    [dictBagPar setObject:[dictBag objectForKey:@"serviceTypesId"] forKey:@"serviceTypesId"];
                    [dictBagPar setObject:[dictBag objectForKey:@"_id"] forKey:@"_id"];
                    
                    [deliveryPartialArray addObject:dictBagPar];
                }
            }
        }
    }
}

-(void) didUpdateToPartialDelivery:(NSArray *) arrayItems
{
    BOOL isBreak = NO;
    
    for (int i = 0; i < [arrayItems count]; i++)
    {
        NSMutableDictionary *dictSelectedItem = [arrayItems objectAtIndex:i];
        
        NSString *strId = [dictSelectedItem objectForKey:@"_id"];
        
        NSString *strSelected = [dictSelectedItem objectForKey:@"selectedItem"];
        
        for (int j = 0; j < [deliveryPartialArray count]; j++)
        {
            NSMutableDictionary *dictBag = [deliveryPartialArray objectAtIndex:j];
            
            NSMutableDictionary *dictItems = [[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"itemsDetailsFull"];
            
            for (int k = 0; k < [dictItems count]; k++)
            {
                NSMutableArray *arrayOrgItems = [dictItems objectForKey:[[dictItems allKeys] objectAtIndex:k]];
                
                for (int p = 0; p < [arrayOrgItems count]; p++)
                {
                    NSMutableDictionary *dictItemSingle = [arrayOrgItems objectAtIndex:p];
                    
                    if ([strId isEqualToString:[dictItemSingle objectForKey:@"_id"]] && [strSelected isEqualToString:@"N"])
                    {
                        [dictItemSingle setObject:@"N" forKey:@"selectedItem"];
                        
                        if (appDel.isPartialDelivery)
                        {
                            if ([[dictItemSingle objectForKey:@"Rewash"] isEqualToString:@"N"])
                            {
                                [dictItemSingle setObject:@"Y" forKey:@"Partial"];
                            }
                        }
                        else if (appDel.isRewash)
                        {
                            if ([[dictItemSingle objectForKey:@"Partial"] isEqualToString:@"N"])
                            {
                                [dictItemSingle setObject:@"Y" forKey:@"Rewash"];
                            }
                        }
                        
                        isBreak = YES;
                        
                        break;
                    }
                }
                
                if (isBreak)
                {
                    break;
                }
            }
            
            if (isBreak)
            {
                break;
            }
        }
        
        if (isBreak)
        {
            isBreak = NO;
        }
    }
    
    if (appDel.isPartialDelivery)
    {
        [arrayUndeliveredItems removeAllObjects];
    }
    else if (appDel.isRewash)
    {
        [arrayRewashItems removeAllObjects];
    }
    
    for (int i = 0; i < [deliveryPartialArray count]; i++)
    {
        NSMutableDictionary *dictBag = [deliveryPartialArray objectAtIndex:i];
        
        NSMutableDictionary *dictItems = [[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"itemsDetailsFull"];
        
        NSMutableDictionary *dictItemsFull = [[NSMutableDictionary alloc]init];
        
        NSMutableDictionary *dictItemType = [[NSMutableDictionary alloc]init];
        
        for (int j = 0; j < [dictItems count]; j++)
        {
            NSMutableArray *arrayItems = [dictItems objectForKey:[[dictItems allKeys] objectAtIndex:j]];
            
            for (int k = 0; k < [arrayItems count]; k++)
            {
                NSMutableDictionary *dictItem = [arrayItems objectAtIndex:k];
                
                NSString *strSelected = [dictItem objectForKey:@"selectedItem"];
                
                NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]initWithDictionary:dictItem];
                
                NSString *strItemCode = [dictItem objectForKey:@"itemType"];
                
                if (![dictItemType objectForKey:strItemCode])
                {
                    if ([strSelected isEqualToString:@"N"])
                    {
                        [dict1 setObject:@"Y" forKey:@"selectedItem"];
                        
                        NSMutableArray *arrayItemCode = [[NSMutableArray alloc]initWithObjects:dict1, nil];
                        
                        if (appDel.isPartialDelivery && [[dictItem objectForKey:@"Partial"] isEqualToString:@"Y"])
                        {
                            [dictItemType setObject:arrayItemCode forKey:strItemCode];
                        }
                        else if (appDel.isRewash && [[dictItem objectForKey:@"Rewash"] isEqualToString:@"Y"])
                        {
                            [dictItemType setObject:arrayItemCode forKey:strItemCode];
                        }
                    }
                }
                else
                {
                    if ([strSelected isEqualToString:@"N"])
                    {
                        NSMutableArray *arrayItemCode = [dictItemType objectForKey:strItemCode];
                        
                        NSMutableDictionary *dict1 = [[NSMutableDictionary alloc]initWithDictionary:dictItem];
                        [dict1 setObject:@"Y" forKey:@"selectedItem"];
                        
                        if (appDel.isPartialDelivery && [[dictItem objectForKey:@"Partial"] isEqualToString:@"Y"])
                        {
                            [arrayItemCode addObject:dict1];
                        }
                        else if (appDel.isRewash && [[dictItem objectForKey:@"Rewash"] isEqualToString:@"Y"])
                        {
                            [arrayItemCode addObject:dict1];
                        }
                    }
                }
            }
        }
        
        if ([dictItemType count])
        {
            [dictItemsFull setObject:dictItemType forKey:@"itemsDetailsFull"];
            
            if (appDel.isRewash || appDel.isPartialDelivery)
            {
                [dictItemsFull setObject:[[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"BagNo"] forKey:@"BagNo"];
            }
            else
            {
                [dictItemsFull setObject:@"" forKey:@"BagNo"];
            }
            
            [dictItemsFull setObject:[[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"Total"] forKey:@"Total"];
            [dictItemsFull setObject:[[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"_id"] forKey:@"_id"];
            
            NSMutableArray *arrayBag = [[NSMutableArray alloc]initWithObjects:dictItemsFull, nil];
            
            NSMutableDictionary *dictBagPar = [[NSMutableDictionary alloc]initWithObjectsAndKeys:arrayBag, @"Bag", nil];
            [dictBagPar setObject:[dictBag objectForKey:@"serviceTypesId"] forKey:@"serviceTypesId"];
            [dictBagPar setObject:[dictBag objectForKey:@"_id"] forKey:@"_id"];
            
            if (appDel.isPartialDelivery)
            {
                [arrayUndeliveredItems addObject:dictBagPar];
            }
            else if (appDel.isRewash)
            {
                [arrayRewashItems addObject:dictBagPar];
            }
        }
    }
    
    [itemDetailsTableView reloadData];
}

-(void) deliverOrderPartially
{
    NSString *strPayment = @"";
    
    if ([[orderDetailDic objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] == NSOrderedSame)
    {
        strPayment = @"Cash";
    }
    else
    {
        strPayment = [selectedCardDict objectForKey:@"_id"];
    }
    
    
    ////
    
    NSMutableArray *arrayItemsPar = [[NSMutableArray alloc]init];
    
    NSMutableArray *arrayBagNo = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [deliveryPartialArray count]; i++)
    {
        NSDictionary *dictBag = [deliveryPartialArray objectAtIndex:i];
        
        NSMutableDictionary *dictItems = [[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"itemsDetailsFull"];
        
        if (![dictItems count])
        {
            [arrayBagNo addObject:[[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"BagNo"]];
        }
        
        for (int j = 0; j < [dictItems count]; j++)
        {
            NSMutableArray *arrayItems = [dictItems objectForKey:[[dictItems allKeys] objectAtIndex:j]];;
            
            for (int p = 0; p < [arrayItems count]; p++)
            {
                NSMutableDictionary *dictItem = [arrayItems objectAtIndex:p];
                
                if ([[dictItem objectForKey:@"selectedItem"] isEqualToString:@"Y"])
                {
                    [arrayItemsPar addObject:[dictItem objectForKey:@"itemId"]];
                }
            }
        }
    }
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", strPayment, @"pType", [orderDetailDic objectForKey:@"oid"], @"oid", arrayItemsPar, @"itemToDeliver", arrayBagNo, @"fullBagDelivery", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/createpartialbill", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            
            NSString *stringSignature = [self encodeToBase64String:signatureView.signatureImage];
            
            NSDictionary *dictRes = [[responseObj objectForKey:@"em"] objectAtIndex:0];
            
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [orderDetailDic objectForKey:@"oid"], @"oid", strPayment, @"pType", [[dictRes objectForKey:@"totalSum"] objectForKey:@"totalAmount"], @"amountReceived", [dictRes objectForKey:@"billId"], @"billId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", stringSignature, @"signature", nil];
            
            NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/makepartialpaymentanddelivery", BASE_URL];
            
            [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                
                [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                
                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                {
                    if ([[orderDetailDic objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] != NSOrderedSame)
                    {
                        if ([arrayRewashItems count])
                        {
                            UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Order Delivered Partially" message:@"Please confirm the rewash order" delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil, nil];
                            transactionAlertView.tag = AFTER_ORDER_CONFORMED;
                            [transactionAlertView show];
                        }
                        else
                        {
                            UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Order Delivered Partially" message:@"" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                            transactionAlertView.tag = AFTER_ORDER_CONFORMED;
                            [transactionAlertView show];
                        }
                    }
                    else
                    {
                        if ([arrayRewashItems count])
                        {
                            UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Order Delivered Partially, Please don't forget to collect the money." message:@"Please confirm the rewash order" delegate:self cancelButtonTitle:@"Next" otherButtonTitles:nil, nil];
                            transactionAlertView.tag = AFTER_ORDER_CONFORMED;
                            [transactionAlertView show];
                        }
                        else
                        {
                            UIAlertView *transactionAlertView = [[UIAlertView alloc] initWithTitle:@"Order Delivered Partially" message:@"Please don't forget to collect the money." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                            transactionAlertView.tag = AFTER_ORDER_CONFORMED;
                            [transactionAlertView show];
                        }
                    }
                    
                    [self finishOrderNodeJS];
                }
                else
                {
                    [appDel displayErrorMessagErrorResponse:responseObj];
                }
            }];
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) doorLockedResponse:(id) response
{
    
}


-(void) backToPreviousScreen
{
    backBtn.hidden = YES;
    
    CGRect rect = deliveryDetailsView.frame;
    rect.origin.x = screen_width;
    [UIView animateWithDuration:0.3 animations:^{
        
        deliveryDetailsView.frame = rect;
        
        progressView_Blue.frame = CGRectMake(0.0, 100.0, screen_width/2, 2.0);
        progressView_Grey.frame = CGRectMake(screen_width/2, 101.0, screen_width/2, 1.0);
        
        
    } completion:^(BOOL finished) {
        
    }];
}



@end





