//
//  ScheduleLaterViewController.m
//  Piing
//
//  Created by Piing on 10/23/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import "ScheduleLaterViewController1.h"
#import "DeliveryViewController1.h"
#import "ListViewController.h"
#import "UIButton+Position.h"
#import "CustomPopoverView.h"
#import "PiingApp-Swift.h"
#import "FXBlurView.h"
#import "PreferencesViewController.h"
#import "HMSegmentedControl.h"
#import "DateTimeViewController.h"



#define PLACE_HOLDER_COLOR_INSTEAD_IMAGE [UIColor clearColor]


#define SCHEDULE_SCREEN_TAG 50

@interface ScheduleLaterViewController1 () <CustomPopoverViewDelegate, PreferencesViewControllerDelegate, HMSegmentedControlDelegate, UIScrollViewDelegate, DateTimeViewControllerDelegate> {
    UIView *scheduleScreenView;
    UIButton *addressBtn;
    
    UILabel *pickUpDateLbl;
    UILabel *pickUpTimeLbl;
    
    ListViewController *listView;
    
    NSDictionary *selectedAddress;
    
    AppDelegate *appDel;
    
    CustomPopoverView *customPopOverView;
    
    UILabel *LblDaysToDeliver;
    
    float previousAddressYAxis;
    SevenSwitch *mySwitch2;
    
    FXBlurView *blurEffect;
    
    UIView *view_BG, *view_Popup;
    
    UILabel *lblInst;
    UIScrollView *scrollView;
    
    HMSegmentedControl *segmentCleaning;
    NSDictionary *dictJobTypes;
    
    CGFloat addOrMinusYPos;
    NSMutableArray *arraAlldata;
    
    NSMutableDictionary *dictPickupDatesAndTimes;
    
    NSMutableDictionary *dictServiceType;
    
    BOOL curtainSelected, dryCleaningSelected, shoeSelected;
    
    SevenSwitch *switchCurtain;
    
    UIView *viewSome;
    
    UIButton *btnCurtain, *btnDryCleaning, *btnShoe;
    
    UIImageView *imgEcoBG;
    
    BOOL knowMoreExpanded;
    
    NSInteger selected_DC_Tag;
    
    NSMutableArray *arraySelectedServiceTypes;
    
    NSString *selectedCurtainServiceType;
}

@property (nonatomic, strong) NSMutableArray *pickUpDates;

@property (nonatomic, strong) NSMutableDictionary *orderInfo;

@end


@implementation ScheduleLaterViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    self.orderInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    
    arraySelectedServiceTypes = [[NSMutableArray alloc]init];
    
    dictPickupDatesAndTimes = [[NSMutableDictionary alloc]init];
    
    self.pickUpDates = [[NSMutableArray alloc]init];
    arraAlldata = [[NSMutableArray alloc]init];
    
    if (self.isDeliveryOrder || self.isRewashOrder)
    {
        NSArray *sortedArray = [[NSMutableArray alloc]initWithArray:self.userAddresses];
        NSPredicate *getDefaultAddPredicate = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", [self.dictUpdateOrder objectForKey:ORDER_PICKUP_ADDRESS_ID]]];
        sortedArray = [sortedArray filteredArrayUsingPredicate:getDefaultAddPredicate];
        
        if ([sortedArray count] > 0)
        {
            selectedAddress = [sortedArray objectAtIndex:0];
        }
        
        [self orderInfoFromUpdateorder];
        
        [arraySelectedServiceTypes addObjectsFromArray:[self.orderInfo objectForKey:ORDER_JOB_TYPE]];
    }
    else if (!self.isFromCreateOrder)
    {
        NSArray *sortedArray = [[NSMutableArray alloc]initWithArray:self.userAddresses];
        NSPredicate *getDefaultAddPredicate = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", [self.dictUpdateOrder objectForKey:ORDER_PICKUP_ADDRESS_ID]]];
        sortedArray = [sortedArray filteredArrayUsingPredicate:getDefaultAddPredicate];
        
        if ([sortedArray count] > 0)
        {
            selectedAddress = [sortedArray objectAtIndex:0];
        }
        
        [self orderInfoFromUpdateorder];
        
        [arraySelectedServiceTypes addObjectsFromArray:[self.orderInfo objectForKey:ORDER_JOB_TYPE]];
    }
    else
    {
        NSArray *sortedArray = [[NSMutableArray alloc]initWithArray:self.userAddresses];
        NSPredicate *getDefaultAddPredicate = [NSPredicate predicateWithFormat:@"default == %d", 1];
        sortedArray = [sortedArray filteredArrayUsingPredicate:getDefaultAddPredicate];
        
        if ([sortedArray count] > 0)
        {
            selectedAddress = [sortedArray objectAtIndex:0];
        }
        else
        {
            selectedAddress = [self.userAddresses objectAtIndex:0];
        }
        
        [self.orderInfo setValue:ORDER_TYPE_REGULAR forKey:ORDER_TYPE];
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_USER_ID] forKey:ORDER_USER_ID];
        [self.orderInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN] forKey:@"t"];
        [self.orderInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"pid"];
        
        [self.orderInfo setObject:@"From IOS - Piingo App" forKey:ORDER_NOTES];
        [self.orderInfo setObject:@"" forKey:PROMO_CODE];
        
        NSMutableDictionary *dictMain  = [[NSMutableDictionary alloc]init];
        
        [dictMain setObject:@"Hanger" forKey:@"Shirts"];
        
        [dictMain setObject:@"Standard Hanger" forKey:@"TrousersHanged"];
        
        [dictMain setObject:@"Without Crease" forKey:@"TrousersCrease"];
        
        [dictMain setObject:@"No Starch" forKey:@"Starch"];
        
        [dictMain setObject:@"No" forKey:@"Stain"];
        
        [dictMain setObject:@"" forKey:@"Note"];
        
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
        
        [self.orderInfo setObject:strPref forKey:PREFERENCES_SELECTED];
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:@"pickupdate"] forKey:ORDER_PICKUP_DATE];
        
        [self.orderInfo setObject:@"B" forKey:ORDER_FROM];
    }
    
    [self createScheduleScreenView];
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isDeliveryOrder || self.isRewashOrder)
    {
        DeliveryViewController1 *vc = [[DeliveryViewController1 alloc] init];
        vc.orderInfo = [[NSMutableDictionary alloc]initWithDictionary:self.orderInfo];
        
        if (self.isRewashOrder)
        {
            vc.isRewashOrder = YES;
            vc.arrayRewashItems = [[NSMutableArray alloc]initWithArray:self.arrayRewashItems];
        }
        
        vc.dictAllowFields = [[NSMutableDictionary alloc]initWithDictionary:self.dictAllowFields];
        vc.userAddresses = [[NSMutableArray alloc]initWithArray:self.userAddresses];
        vc.userSavedCards = [[NSMutableArray alloc]initWithArray:self.userSavedCards];
        vc.orderInfo = [[NSMutableDictionary alloc]initWithDictionary:self.orderInfo];
        vc.dictChangedValues = [[NSMutableDictionary alloc]initWithDictionary:self.dictChangedValues];
        vc.isDeliveryOrder = self.isDeliveryOrder;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.navigationController.parentViewController.navigationController.navigationBarHidden = YES;
}

-(void) orderInfoFromUpdateorder
{
    if (self.isRewashOrder)
    {
        [self.orderInfo setObject:@"1" forKey:@"itsRewash"];
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:@"oid"] forKey:@"reWashMainOrderOid"];
        
        [self.orderInfo setObject:@"Rewash notes from IOS" forKey:@"reWashNote"];
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_JOB_TYPE] forKey:ORDER_JOB_TYPE];
        
        NSMutableArray *arrayItemsPar = [[NSMutableArray alloc]init];
        
        for (int i = 0; i < [self.arrayRewashItems count]; i++)
        {
            NSDictionary *dictBag = [self.arrayRewashItems objectAtIndex:i];
            
            NSMutableDictionary *dictItems = [[[dictBag objectForKey:@"Bag"] objectAtIndex:0] objectForKey:@"itemsDetailsFull"];
            
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
        
        [self.orderInfo setObject:arrayItemsPar forKey:@"reItems"];
        
        [self.orderInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"uid"];
    }
    
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:@"uid"] forKey:ORDER_USER_ID];
    [self.orderInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN] forKey:@"t"];
    [self.orderInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"pid"];
    
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_PICKUP_SLOT] forKey:ORDER_PICKUP_SLOT];
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_PICKUP_DATE] forKey:ORDER_PICKUP_DATE];
    
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_DELIVERY_ADDRESS_ID] forKey:ORDER_DELIVERY_ADDRESS_ID];
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_PICKUP_ADDRESS_ID] forKey:ORDER_PICKUP_ADDRESS_ID];
    
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_TYPE] forKey:ORDER_TYPE];
    
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_CARD_ID] forKey:ORDER_CARD_ID];
    
    if (!self.isRewashOrder)
    {
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:@"oid"] forKey:@"oid"];
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_JOB_TYPE] forKey:ORDER_JOB_TYPE];
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_DELIVERY_DATE] forKey:ORDER_DELIVERY_DATE];
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_DELIVERY_SLOT] forKey:ORDER_DELIVERY_SLOT];
    }
    
    if ([self.dictUpdateOrder objectForKey:PROMO_CODE])
    {
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:PROMO_CODE] forKey:PROMO_CODE];
    }
    else
    {
        [self.orderInfo setObject:@"" forKey:PROMO_CODE];
    }
    
    if ([self.dictUpdateOrder objectForKey:ORDER_NOTES])
    {
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_NOTES] forKey:ORDER_NOTES];
    }
    else
    {
        [self.orderInfo setObject:@"" forKey:ORDER_NOTES];
    }
    
    NSDictionary *dict1 = [self.dictUpdateOrder objectForKey:PREFERENCES_SELECTED];
    
    NSMutableDictionary *dictMain  = [[NSMutableDictionary alloc]init];
    
    if (![dict1 count])
    {
        [dictMain setObject:@"Hanger" forKey:@"Shirts"];
        
        [dictMain setObject:@"Standard Hanger" forKey:@"TrousersHanged"];
        
        [dictMain setObject:@"Without Crease" forKey:@"TrousersCrease"];
        
        [dictMain setObject:@"No Starch" forKey:@"Starch"];
        
        [dictMain setObject:@"No" forKey:@"Stain"];
        
        [dictMain setObject:@"" forKey:@"Note"];
        
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
        
        [self.orderInfo setObject:strPref forKey:PREFERENCES_SELECTED];
    }
    else
    {
        for (NSDictionary *dict2 in dict1)
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
        
        [self.orderInfo setObject:strPref forKey:PREFERENCES_SELECTED];
    }
    
    [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_FROM] forKey:ORDER_FROM];
    
    [self.dictChangedValues removeAllObjects];
    [self.dictChangedValues addEntriesFromDictionary:self.orderInfo];
}


- (void)createScheduleScreenView {
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    float ratio = MULTIPLYHEIGHT;
    
    float yPos = 22*ratio;
    
    if(!scheduleScreenView) {
        scheduleScreenView = [[UIView alloc] initWithFrame:screenBounds];
        scheduleScreenView.backgroundColor = [UIColor clearColor];
        
        UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0, yPos, CGRectGetWidth(screenBounds), 40.0)];
        
        if (self.isFromCreateOrder)
        {
            titleLbl.text = @"CREATE ORDER";
        }
        else if (self.isRewashOrder)
        {
            titleLbl.text = @"CREATE ORDER";
        }
        else
        {
            titleLbl.text = @"UPDATE ORDER";
        }
        
        //[appDel spacingForTitle:titleLbl TitleString:string];
        titleLbl.textAlignment = NSTextAlignmentCenter;
        titleLbl.textColor = [UIColor grayColor];
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM+1];
        [scheduleScreenView addSubview:titleLbl];
        
        if (self.isFromCreateOrder)
        {
            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            closeBtn.frame = CGRectMake(10.0, yPos, 40, 40);
            [closeBtn setImage:[UIImage imageNamed:@"back_grey"] forState:UIControlStateNormal];
            [closeBtn addTarget:self action:@selector(closeScheduleScreen:) forControlEvents:UIControlEventTouchUpInside];
            closeBtn.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
            [scheduleScreenView addSubview:closeBtn];
            [closeBtn setShowsTouchWhenHighlighted:YES];
        }
        else
        {
            UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            closeBtn.frame = CGRectMake(CGRectGetWidth(screenBounds) - 50.0, yPos, 40, 40);
            [closeBtn setImage:[UIImage imageNamed:@"cancel_grey"] forState:UIControlStateNormal];
            [closeBtn addTarget:self action:@selector(closeScheduleScreen:) forControlEvents:UIControlEventTouchUpInside];
            closeBtn.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
            [scheduleScreenView addSubview:closeBtn];
            [closeBtn setShowsTouchWhenHighlighted:YES];
        }
        
        yPos += 40+25*MULTIPLYHEIGHT;
        
        // Custom Switch
        
        mySwitch2 = [[SevenSwitch alloc] initWithFrame:CGRectMake((screen_width/2)-(90/2),  yPos, 90, 25)];
        //mySwitch2.center = CGPointMake(self.view.bounds.size.width * 0.5, 30);
        //mySwitch2.inactiveColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        //mySwitch2.onTintColor = [UIColor colorWithRed:0.45f green:0.58f blue:0.67f alpha:1.00f];
        [mySwitch2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
        //    mySwitch2.offImage = [UIImage imageNamed:@"toggle_nonselected"];
        //    mySwitch2.onImage = [UIImage imageNamed:@"toggle_selected"];
        //mySwitch2.onTintColor = [UIColor colorWithHue:0.08f saturation:0.74f brightness:1.00f alpha:1.00f];
        mySwitch2.activeColor = [UIColor clearColor];
        mySwitch2.inactiveColor = [UIColor clearColor];
        mySwitch2.onTintColor = [UIColor clearColor];
        mySwitch2.onLabel.textColor = BLUE_COLOR;
        mySwitch2.offLabel.textColor = [UIColor grayColor];
        mySwitch2.isRounded = YES;
        mySwitch2.shadowColor = [UIColor clearColor];
        mySwitch2.activeBorderColor = BLUE_COLOR;
        mySwitch2.inactiveBorderColor = RGBCOLORCODE(200, 200, 200, 1.0);
        mySwitch2.onThumbImage = [UIImage imageNamed:@"thumb_selected"];
        mySwitch2.offThumbImage = [UIImage imageNamed:@"thumb_nonselected"];
        [mySwitch2 setOn:NO animated:YES];
        [scheduleScreenView addSubview:mySwitch2];
        
        
        
        if ([[self.orderInfo objectForKey:ORDER_TYPE] caseInsensitiveCompare:@"R"] == NSOrderedSame)
        {
            [mySwitch2 setOn:NO animated:YES];
        }
        else
        {
            [mySwitch2 setOn:YES animated:YES];
        }
        
        yPos += 30 + 20*MULTIPLYHEIGHT;
        
        float xPos = 14.4*MULTIPLYHEIGHT;;
        
        float height = 35.0*ratio;
        
        addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addressBtn.frame = CGRectMake(xPos, yPos, (CGRectGetWidth(screenBounds) - (xPos*2)), height);
        addressBtn.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        [addressBtn setTitle:@"SILOSO BEACH, SINGAPORE" forState:UIControlStateNormal];
        [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        addressBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        addressBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 35*MULTIPLYHEIGHT, 0.0, 26*MULTIPLYHEIGHT);
        [addressBtn addTarget:self action:@selector(selectPickUpAddress:) forControlEvents:UIControlEventTouchUpInside];
        [scheduleScreenView addSubview:addressBtn];
        [addressBtn setTitle:[self setTitleForAddress] forState:UIControlStateNormal];
        
        UIImageView *locImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0.0, 10*MULTIPLYHEIGHT, CGRectGetHeight(addressBtn.bounds))];
        locImgView.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
        locImgView.contentMode = UIViewContentModeScaleAspectFit;
        locImgView.image = [UIImage imageNamed:@"address_sl"];
        locImgView.userInteractionEnabled = NO;
        [addressBtn addSubview:locImgView];
        
        UIImageView *dropDownIconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(addressBtn.bounds) - (xPos*1.5)), 2.0, 15.0, CGRectGetHeight(addressBtn.bounds))];
        dropDownIconView.contentMode = UIViewContentModeScaleAspectFit;
        dropDownIconView.image = [UIImage imageNamed:@"down_arrow_gray"];
        dropDownIconView.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
        dropDownIconView.userInteractionEnabled = NO;
        [addressBtn addSubview:dropDownIconView];
        
        yPos += height+20*MULTIPLYHEIGHT;
        
        {
            
            UIView *washModeSelectionView = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos, (CGRectGetWidth(screenBounds) - (xPos*2)), 100.0*ratio)];
            washModeSelectionView.backgroundColor = LIGHT_GRAY_BACKGROUND_COLOR;
            
            scrollView = [[UIScrollView alloc]initWithFrame:washModeSelectionView.bounds];
            scrollView.delegate = self;
            [washModeSelectionView addSubview:scrollView];
            //scrollView.scrollEnabled = NO;
            scrollView.pagingEnabled = YES;
            
            
            //        CALayer *myLayer = [[CALayer alloc]init];
            //        myLayer.backgroundColor = [UIColor whiteColor].CGColor;
            //        myLayer.frame = CGRectMake(washModeSelectionView.frame.origin.x+2*MULTIPLYHEIGHT, washModeSelectionView.frame.origin.y + washModeSelectionView.frame.size.height-1, washModeSelectionView.frame.size.width-(2*MULTIPLYHEIGHT*2), 2);
            //        myLayer.shadowColor = [[UIColor grayColor] CGColor];
            //        myLayer.shadowOffset = CGSizeMake(0.0, 2.0);
            //        myLayer.shadowOpacity = 1.0;
            //        myLayer.shadowRadius = 2.0;
            //        [scheduleScreenView.layer addSublayer:myLayer];
            
            UIImageView *imgTopStrip = [[UIImageView alloc]initWithFrame:CGRectMake(xPos+2*MULTIPLYHEIGHT, washModeSelectionView.frame.origin.y+washModeSelectionView.frame.size.height-4.7*MULTIPLYHEIGHT, (CGRectGetWidth(screenBounds) - ((xPos+2*MULTIPLYHEIGHT)*2)), 5*MULTIPLYHEIGHT)];
            imgTopStrip.contentMode = UIViewContentModeScaleAspectFill;
            imgTopStrip.image = [UIImage imageNamed:@"mywallet_topstrip.png"];
            [scheduleScreenView addSubview:imgTopStrip];
            
            [scheduleScreenView addSubview:washModeSelectionView];
            
            
            NSArray *arrCleaning = @[CATEGORY_SERVICETYPE_GENERAL, CATEGORY_SERVICETYPE_HOME, CATEGORY_SERVICETYPE_SPECIALCARE];
            
            float segmentHeight = 22*MULTIPLYHEIGHT;
            
            segmentCleaning = [[HMSegmentedControl alloc]initWithSectionTitles:arrCleaning];
            segmentCleaning.delegate = self;
            segmentCleaning.frame = CGRectMake(0, 0, washModeSelectionView.frame.size.width, segmentHeight);
            
            float left = 20*MULTIPLYHEIGHT;
            float right = 20*MULTIPLYHEIGHT;
            
            segmentCleaning.type = HMSegmentedControlTypeText;
            segmentCleaning.segmentEdgeInset = UIEdgeInsetsMake(0, left, 0, right);
            segmentCleaning.backgroundColor = [UIColor clearColor];
            segmentCleaning.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
            segmentCleaning.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
            segmentCleaning.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(1)};
            segmentCleaning.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : BLUE_COLOR, NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(1)};
            [segmentCleaning addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
            [washModeSelectionView addSubview:segmentCleaning];
            segmentCleaning.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
            segmentCleaning.selectionIndicatorColor = [UIColor clearColor];
            segmentCleaning.selectionIndicatorBoxOpacity = 1.0f;
            segmentCleaning.selectedSegmentIndex = 0;
            segmentCleaning.verticalDividerEnabled = YES;
            segmentCleaning.verticalDividerColor = BLUE_COLOR;
            segmentCleaning.verticalDividerWidth = 1;
            segmentCleaning.selectionIndicatorHeight = 7*MULTIPLYHEIGHT;
            
            [segmentCleaning setIndexChangeBlock:^(NSInteger index) {
                
                //[self scrollAnimated];
                
            }];
            
            [self segmentedControlChangedValue:segmentCleaning];
            
            [self performSelector:@selector(offsetChange) withObject:nil afterDelay:0.5];
            
            
            float widthe = 28*MULTIPLYHEIGHT;
            segmentCleaning.scrollView.contentInset = UIEdgeInsetsMake(0, widthe, 0, widthe);
            
            
            NSArray *btnTitlesPersonal = @[@"LOAD WASH", @"DRY CLEANING", @"WASH & IRON", @"IRONING"];
            NSArray *btnIconsPersonal = @[@"load_wash", @"dry_cleaning", @"wash_and_iron", @"ironing"];
            NSArray *btnSelIconsPersonal = @[@"load_wash_selected", @"dry_cleaning_selected", @"wash_and_iron_selected", @"ironing_selected"];
            
            NSArray *btnTitlesHome = @[@"CURTAINS", @"CARPET"];
            NSArray *btnIconsHome = @[@"curtains", @"carpet"];
            NSArray *btnSelIconsHome = @[@"curtains_selected", @"carpet_selected"];
            
            NSArray *btnTitlesSpecial = @[@"BAGS", @"SHOES", @"LEATHER"];
            NSArray *btnIconsSpecial = @[ @"bags", @"shoes", @"leather"];
            NSArray *btnSelIconsSpecial = @[@"bags_selected", @"shoes_selected", @"leather_selected"];
            
            
            dictServiceType = [[NSMutableDictionary alloc]init];
            [dictServiceType setObject:SERVICETYPE_WF forKey:@"LOAD WASH"];
            [dictServiceType setObject:SERVICETYPE_DC forKey:@"DRY CLEANING"];
            [dictServiceType setObject:SERVICETYPE_WI forKey:@"WASH & IRON"];
            [dictServiceType setObject:SERVICETYPE_IR forKey:@"IRONING"];
            [dictServiceType setObject:SERVICETYPE_CA forKey:@"CARPET"];
            [dictServiceType setObject:SERVICETYPE_CC forKey:@"CURTAINS"];
            [dictServiceType setObject:SERVICETYPE_BAG forKey:@"BAGS"];
            [dictServiceType setObject:SERVICETYPE_SHOE forKey:@"SHOES"];
            [dictServiceType setObject:SERVICETYPE_LE forKey:@"LEATHER"];
            
            dictJobTypes = [[NSDictionary alloc]initWithObjectsAndKeys:btnTitlesPersonal, @"1", btnTitlesHome, @"2", btnTitlesSpecial, @"3", nil];
            
            NSDictionary *dictJobTypesIcons = [[NSDictionary alloc]initWithObjectsAndKeys:btnIconsPersonal, @"1", btnIconsHome, @"2", btnIconsSpecial, @"3", nil];
            
            NSDictionary *dictJobTypesSelIcons = [[NSDictionary alloc]initWithObjectsAndKeys:btnSelIconsPersonal, @"1", btnSelIconsHome, @"2", btnSelIconsSpecial, @"3", nil];
            
            float viewX = 0.0;
            int tagValue = 0;
            
            for (int k=0; k < [dictJobTypes count]; k++)
            {
                
                float btnWidth = 0.0;
                
                float minusWidth = 0.0;
                
                if (k == 0)
                {
                    minusWidth = 0.0;
                    
                    btnWidth = CGRectGetWidth(washModeSelectionView.bounds)/4;
                    viewX = k*washModeSelectionView.frame.size.width;
                }
                else if (k == 1)
                {
                    minusWidth = 40*MULTIPLYHEIGHT;
                    
                    btnWidth = CGRectGetWidth(washModeSelectionView.bounds)/2;
                    viewX = k*washModeSelectionView.frame.size.width;
                }
                else if (k == 2)
                {
                    minusWidth = 20*MULTIPLYHEIGHT;
                    
                    btnWidth = CGRectGetWidth(washModeSelectionView.bounds)/3;
                    viewX = k*washModeSelectionView.frame.size.width;
                }
                
                NSArray *arrTitles = [dictJobTypes objectForKey:[NSString stringWithFormat:@"%d", k+1]];
                NSArray *arrIcons = [dictJobTypesIcons objectForKey:[NSString stringWithFormat:@"%d", k+1]];
                NSArray *arrSelIcons = [dictJobTypesSelIcons objectForKey:[NSString stringWithFormat:@"%d", k+1]];
                
                UIView *viewType = [[UIView alloc]initWithFrame:CGRectMake(viewX+minusWidth, 25.0, scrollView.frame.size.width-(minusWidth*2), 100.0*ratio-20.0)];
                viewType.tag = k+1;
                viewType.backgroundColor = [UIColor clearColor];
                [scrollView addSubview:viewType];
                
                float Width = viewType.frame.size.width/[arrTitles count];
                
                for (int i=0; i<arrTitles.count; i++) {
                    
                    UIButton *washBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    washBtn.frame = CGRectMake(i*(Width), 0, Width, viewType.frame.size.height);
                    washBtn.tag = SCHEDULE_SCREEN_TAG + 7 + tagValue;
                    //washBtn.backgroundColor = [UIColor redColor];
                    washBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
                    [washBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    [washBtn setTitleColor:BLUE_COLOR forState:UIControlStateSelected];
                    [washBtn setTitle:[arrTitles objectAtIndex:i] forState:UIControlStateNormal];
                    [washBtn setImage:[UIImage imageNamed:[arrIcons objectAtIndex:i]] forState:UIControlStateNormal];
                    [washBtn setImage:[UIImage imageNamed:[arrSelIcons objectAtIndex:i]] forState:UIControlStateSelected];
                    [washBtn addTarget:self action:@selector(selectWashType:) forControlEvents:UIControlEventTouchUpInside];
                    [viewType addSubview:washBtn];
                    
                    if (!self.isFromCreateOrder)
                    {
                        if (k == 0)
                        {
                            if (i == 0 && [self.arrayJobTypeOrg containsObject:SERVICETYPE_WF])
                            {
                                washBtn.selected = YES;
                            }
                            else if (i == 1 && ([self.arrayJobTypeOrg containsObject:SERVICETYPE_DC] || [self.arrayJobTypeOrg containsObject:SERVICETYPE_DCG]))
                            {
                                washBtn.selected = YES;
                                
                                if ([self.arrayJobTypeOrg containsObject:SERVICETYPE_DCG] && [self.arrayJobTypeOrg containsObject:SERVICETYPE_DC])
                                {
                                    [washBtn setImage:[UIImage imageNamed:@"dc_dcg_selected"] forState:UIControlStateSelected];
                                    [washBtn setTitleColor:RGBCOLORCODE(105, 151, 20, 1.0) forState:UIControlStateSelected];
                                }
                                else if ([self.arrayJobTypeOrg containsObject:SERVICETYPE_DCG])
                                {
                                    [washBtn setImage:[UIImage imageNamed:@"dcg_selected"] forState:UIControlStateSelected];
                                    [washBtn setTitleColor:RGBCOLORCODE(105, 151, 20, 1.0) forState:UIControlStateSelected];
                                }
                            }
                            else if (i == 2 && [self.arrayJobTypeOrg containsObject:SERVICETYPE_WI])
                            {
                                washBtn.selected = YES;
                            }
                            else if (i == 3 && [self.arrayJobTypeOrg containsObject:SERVICETYPE_IR])
                            {
                                washBtn.selected = YES;
                            }
                        }
                        
                        else if (k == 1)
                        {
                            if (i == 0 && [self.arrayJobTypeOrg containsObject:SERVICETYPE_CA])
                            {
                                washBtn.selected = YES;
                            }
                            else if (i == 1 && ([self.arrayJobTypeOrg containsObject:SERVICETYPE_CC_DC] || [self.arrayJobTypeOrg containsObject:SERVICETYPE_CC_W_DC] || [self.arrayJobTypeOrg containsObject:SERVICETYPE_CC_WI] || [self.arrayJobTypeOrg containsObject:SERVICETYPE_CC_W_WI]))
                            {
                                washBtn.selected = YES;
                            }
                        }
                        
                        else if (k == 2)
                        {
                            if (i == 0 && [self.arrayJobTypeOrg containsObject:SERVICETYPE_BAG])
                            {
                                washBtn.selected = YES;
                            }
                            else if (i == 1 && ([self.arrayJobTypeOrg containsObject:SERVICETYPE_SHOE_POLISH] || [self.arrayJobTypeOrg containsObject:SERVICETYPE_SHOE_CLEAN]))
                            {
                                washBtn.selected = YES;
                            }
                            else if (i == 2 && [self.arrayJobTypeOrg containsObject:SERVICETYPE_LE])
                            {
                                washBtn.selected = YES;
                            }
                        }
                    }
                    
                    [washBtn centerImageAndTextWithSpacing:10*MULTIPLYHEIGHT];
                    
                    if (k == 0)
                    {
                        if (i != 3)
                        {
                            UIEdgeInsets titleEdgaeInsets = washBtn.titleEdgeInsets;
                            titleEdgaeInsets.right -= 10;
                            washBtn.titleEdgeInsets = titleEdgaeInsets;
                        }
                    }
                    
                    tagValue ++;
                    
                }
            }
            
            scrollView.contentSize = CGSizeMake(viewX+washModeSelectionView.frame.size.width, scrollView.frame.size.height);
            
            
            yPos += CGRectGetHeight(washModeSelectionView.frame);
            
            
            float btnCX = xPos+2*MULTIPLYHEIGHT;
            float btnCWidth = screen_width-btnCX*2;
            float btnCHeight = 20*MULTIPLYHEIGHT;
            
            addOrMinusYPos = yPos-btnCHeight;
            
            LblDaysToDeliver = [[UILabel alloc] init];
            LblDaysToDeliver.frame = CGRectMake(btnCX, addOrMinusYPos, btnCWidth, btnCHeight);
            LblDaysToDeliver.textAlignment = NSTextAlignmentCenter;
            LblDaysToDeliver.backgroundColor = [UIColor clearColor];
            LblDaysToDeliver.alpha = 0.0;
            
            LblDaysToDeliver.text = [@"Pick your order type" uppercaseString];
            
            if (!self.isFromCreateOrder)
            {
                [self showDaysToDeliver];
                
                [self GetDaysToDeliver];
            }
            
            LblDaysToDeliver.font = [UIFont fontWithName:APPFONT_LIGHT size:appDel.FONT_SIZE_CUSTOM-5];
            LblDaysToDeliver.textColor = [UIColor blackColor];
            [scheduleScreenView addSubview:LblDaysToDeliver];
            [scheduleScreenView insertSubview:LblDaysToDeliver belowSubview:imgTopStrip];
            LblDaysToDeliver.backgroundColor = RGBCOLORCODE(244, 245, 246, 1.0);
            
            LblDaysToDeliver.layer.borderColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2].CGColor;
            LblDaysToDeliver.layer.borderWidth = 1.0;
            
            yPos += btnCHeight+15*MULTIPLYHEIGHT;
            
        }
        
        if (!self.isFromCreateOrder)
        {
            UIButton *pickupDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            pickupDateBtn.frame = CGRectMake(xPos, yPos, (CGRectGetWidth(screenBounds) - (xPos*2)), height);
            pickupDateBtn.backgroundColor = LIGHT_GRAY_BACKGROUND_COLOR;
            [pickupDateBtn addTarget:self action:@selector(selectPickUpDate:) forControlEvents:UIControlEventTouchUpInside];
            [scheduleScreenView addSubview:pickupDateBtn];
            
            pickUpDateLbl = [[UILabel alloc] initWithFrame:CGRectMake(xPos+20*MULTIPLYHEIGHT, 0.0, (CGRectGetWidth(pickupDateBtn.bounds) - (xPos*2)), CGRectGetHeight(pickupDateBtn.bounds))];
            
            pickUpDateLbl.textColor = [UIColor grayColor];
            pickUpDateLbl.backgroundColor = [UIColor clearColor];
            pickUpDateLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
            
            pickUpDateLbl.attributedText = [self setPickupAttributedText];
            
            pickUpDateLbl.textAlignment = NSTextAlignmentLeft;
            pickUpDateLbl.userInteractionEnabled = NO;
            [pickupDateBtn addSubview:pickUpDateLbl];
            
            UIImageView *locImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0.0, 10*MULTIPLYHEIGHT, CGRectGetHeight(pickupDateBtn.bounds))];
            locImgView.contentMode = UIViewContentModeScaleAspectFit;
            locImgView.image = [UIImage imageNamed:@"pickup_date_time"];
            locImgView.userInteractionEnabled = NO;
            [pickupDateBtn addSubview:locImgView];
            
            UIImageView *dropDownIconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(pickupDateBtn.bounds) - (xPos*1.5)), 1.0, 15.0, CGRectGetHeight(pickupDateBtn.bounds))];
            dropDownIconView.contentMode = UIViewContentModeScaleAspectFit;
            dropDownIconView.image = [UIImage imageNamed:@"down_arrow_gray"];
            dropDownIconView.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
            dropDownIconView.userInteractionEnabled = NO;
            [pickupDateBtn addSubview:dropDownIconView];
            
            yPos += height+20*MULTIPLYHEIGHT;
            
        }
        
        {
            
            UIButton *instructionsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            instructionsBtn.frame = CGRectMake(xPos, yPos, 90*MULTIPLYHEIGHT, 40.0*ratio);
            instructionsBtn.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5*MULTIPLYHEIGHT, 0.0, 0.0);
            //instructionsBtn.backgroundColor = [UIColor redColor];
            [instructionsBtn setImage:[UIImage imageNamed:@"preferences_details_selected"] forState:UIControlStateNormal];
            instructionsBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
            [instructionsBtn setTitle:@"PREFERENCES" forState:UIControlStateNormal];
            [instructionsBtn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
            [instructionsBtn addTarget:self action:@selector(showPreferences) forControlEvents:UIControlEventTouchUpInside];
            instructionsBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [scheduleScreenView addSubview:instructionsBtn];
            [instructionsBtn setTitleColor:[BLUE_COLOR colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
            
            
            float nextWidth = 55*MULTIPLYHEIGHT;
            float minusX = 74*MULTIPLYHEIGHT;
            
            UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            nextBtn.frame = CGRectMake((screen_width - minusX), yPos, nextWidth, 40.0*ratio);
            [nextBtn setTitle:@"NEXT" forState:UIControlStateNormal];
            nextBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
            [nextBtn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
            [nextBtn addTarget:self action:@selector(nextBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
            [scheduleScreenView addSubview:nextBtn];
            [nextBtn setTitleColor:[BLUE_COLOR colorWithAlphaComponent:0.8] forState:UIControlStateHighlighted];
            
            UIImageView *nextIcon = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(nextBtn.bounds) - 10*MULTIPLYHEIGHT), 1.0, 12*MULTIPLYHEIGHT, CGRectGetHeight(nextBtn.bounds))];
            nextIcon.image = [UIImage imageNamed:@"next_arrow_blue"];
            nextIcon.userInteractionEnabled = NO;
            nextIcon.contentMode = UIViewContentModeScaleAspectFit;
            nextIcon.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
            [nextBtn addSubview:nextIcon];
            
        }
        
        yPos += height+20*MULTIPLYHEIGHT;
        
        if (!self.isFromCreateOrder)
        {
            CGFloat btnRX = 30*MULTIPLYHEIGHT;
            
            UIButton *btnRevertData = [UIButton buttonWithType:UIButtonTypeCustom];
            btnRevertData.frame = CGRectMake(btnRX, yPos, screen_width - (btnRX*2), height);
            btnRevertData.backgroundColor = [UIColor colorFromHexString:@"3277ba"];
            [btnRevertData setTitle:@"REVERT BACK" forState:UIControlStateNormal];
            btnRevertData.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM+1];
            [btnRevertData addTarget:self action:@selector(revertBackdata:) forControlEvents:UIControlEventTouchUpInside];
            //[scheduleScreenView addSubview:btnRevertData];
        }
        
    }
    
    [self.view addSubview:scheduleScreenView];
}

-(NSMutableAttributedString *) setPickupAttributedText
{
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"dd-MM-yyyy"];
    
    NSDate *date = [dtFormatter dateFromString:[self.orderInfo objectForKey:ORDER_PICKUP_DATE]];
    
    [dtFormatter setDateFormat:@"dd MMM, EEE"];
    NSString *strDate = [dtFormatter stringFromDate:date];
    
    
    NSString *str1 = @"PICKUP ";
    NSString *str2 = [[NSString stringWithFormat:@"%@ : %@", strDate, [self.orderInfo objectForKey:ORDER_PICKUP_SLOT]]uppercaseString];
    
    NSString *strTotal = [NSString stringWithFormat:@"%@ %@", str1, str2];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:strTotal];
    
    [attrStr addAttributes:@{NSFontAttributeName : [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2], NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, str1.length)];
    
    [attrStr addAttributes:@{NSFontAttributeName : [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2], NSForegroundColorAttributeName : BLUE_COLOR} range:NSMakeRange(str1.length+1, str2.length)];
    
    float spacing = 0.6f;
    [attrStr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrStr length])];
    
    return attrStr;
}

-(NSString *) setTitleForAddress
{
    NSMutableString *str = [[NSMutableString alloc]init];
    
    if ([[selectedAddress objectForKey:@"name"]length])
    {
        [str appendString:[selectedAddress objectForKey:@"name"]];
    }
    
    if ([[selectedAddress  objectForKey:@"line1"]length] > 1)
    {
        [str appendString:[NSString stringWithFormat:@", %@", [selectedAddress  objectForKey:@"line1"]]];
    }
    else if ([[selectedAddress  objectForKey:@"line2"]length])
    {
        [str appendString:[NSString stringWithFormat:@", %@", [selectedAddress  objectForKey:@"line2"]]];
    }
    
    if ([[selectedAddress  objectForKey:@"zipcode"]length])
    {
        [str appendString:[NSString stringWithFormat:@", %@", [selectedAddress  objectForKey:@"zipcode"]]];
    }
    
    return str;
}


-(void) showDaysToDeliver
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = LblDaysToDeliver.frame;
        frame.origin.y = addOrMinusYPos+LblDaysToDeliver.frame.size.height;
        LblDaysToDeliver.frame = frame;
        
        LblDaysToDeliver.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void) hideDaysToDeliver
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect frame = LblDaysToDeliver.frame;
        frame.origin.y = addOrMinusYPos;
        LblDaysToDeliver.frame = frame;
        
        LblDaysToDeliver.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    
    CGFloat pageWidth = scrollView.frame.size.width;
    float fractionalPage = scrollView.contentOffset.x / pageWidth;
    NSInteger page = lround(fractionalPage);
    
    [segmentCleaning setSelectedSegmentIndex:page animated:YES];
    
    float offset = 0.0;
    
    if (page == 0)
    {
        offset = -60*MULTIPLYHEIGHT;
    }
    else if (page == 1)
    {
        offset = 45*MULTIPLYHEIGHT;
    }
    else if (page == 2)
    {
        offset = 155*MULTIPLYHEIGHT;
    }
    
    [segmentCleaning.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
}

-(void) offsetChange
{
    [segmentCleaning.scrollView setContentOffset:CGPointMake(-60*MULTIPLYHEIGHT, 0) animated:YES];
}

-(void) segmentedControlChangedValue:(HMSegmentedControl *)segment
{
    float offset = 0.0;
    
    if (segment.selectedSegmentIndex == 0)
    {
        offset = -60*MULTIPLYHEIGHT;
    }
    else if (segment.selectedSegmentIndex == 1)
    {
        offset = 45*MULTIPLYHEIGHT;
    }
    else if (segment.selectedSegmentIndex == 2)
    {
        offset = 155*MULTIPLYHEIGHT;
    }
    
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width*segment.selectedSegmentIndex, 0) animated:YES];
    
    [segmentCleaning.scrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
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

-(void) btnShoeSelected:(UIButton *)sender
{
    [self showShoePopup];
}


-(void) showShoePopup
{
    [appDel applyCustomBlurEffetForView:self.view WithBlurRadius:5];
    
    blurEffect = [self.view viewWithTag:98765];
    blurEffect.alpha = 0.0;
    //blurEffect.dynamic = YES;
    
    [FXBlurView setUpdatesDisabled];
    
    
    float yAxis = 0;
    
    float vX = 25*MULTIPLYHEIGHT;
    float vH = 300*MULTIPLYHEIGHT;
    
    view_BG = [[UIView alloc]initWithFrame:self.view.bounds];
    view_BG.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.view addSubview:view_BG];
    view_BG.alpha = 0.0;
    
    
    view_Popup = [[UIView alloc]initWithFrame:CGRectMake(vX, screen_height, screen_width-(vX*2), vH)];
    view_Popup.backgroundColor = [UIColor whiteColor];
    [view_BG addSubview:view_Popup];
    view_Popup.clipsToBounds = YES;
    
    imgEcoBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, yAxis, view_Popup.frame.size.width, view_Popup.frame.size.height)];
    imgEcoBG.image = [UIImage imageNamed:@"shoe_bg"];
    [view_Popup addSubview:imgEcoBG];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20*MULTIPLYHEIGHT, view_Popup.frame.size.width, 20*MULTIPLYHEIGHT)];
    NSString *string = @"SELECT THE TYPE OF SHOE CLEANING";
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor blackColor];
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-4];
    [view_Popup addSubview:titleLbl];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 1.0f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [string length])];
    
    titleLbl.attributedText = attributedString;
    
    
    yAxis += 20*MULTIPLYHEIGHT+30*MULTIPLYHEIGHT;
    
    CGFloat vsX = 30*MULTIPLYHEIGHT;
    
    viewSome = [[UIView alloc]initWithFrame:CGRectMake(vsX, yAxis, view_Popup.frame.size.width-vsX*2, 100*MULTIPLYHEIGHT)];
    viewSome.backgroundColor = [UIColor clearColor];
    [view_Popup addSubview:viewSome];
    
    NSArray *btnTitlesHome = @[@"SHOE\nPOLISH", @"SHOE\nCLEANING"];
    NSArray *btnIconsHome = @[@"shoe_polish", @"shoe_cleaning"];
    NSArray *btnSelIconsHome = @[@"shoe_polish_selected", @"shoe_cleaning_selected"];
    
    float Width = viewSome.frame.size.width/[btnTitlesHome count];
    
    for (int i=0; i<btnTitlesHome.count; i++) {
        
        UIButton *washBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        washBtn.frame = CGRectMake(i*(Width), 0, Width, viewSome.frame.size.height);
        washBtn.tag = SCHEDULE_SCREEN_TAG + i + 30;
        //washBtn.backgroundColor = [UIColor redColor];
        washBtn.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-4];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[btnTitlesHome objectAtIndex:i]];
        
        NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:[btnTitlesHome objectAtIndex:i]];
        
        if (i == 1)
        {
            [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, [attr length])];
            [attrSel addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, [attr length])];
        }
        else
        {
            [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, [attr length])];
            [attrSel addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, [attr length])];
        }
        
        [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
        [attr addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attr length])];
        
        [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
        [attrSel addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attrSel length])];
        
        [washBtn setAttributedTitle:attr forState:UIControlStateNormal];
        [washBtn setAttributedTitle:attrSel forState:UIControlStateSelected];
        
        [washBtn setImage:[UIImage imageNamed:[btnIconsHome objectAtIndex:i]] forState:UIControlStateNormal];
        [washBtn setImage:[UIImage imageNamed:[btnSelIconsHome objectAtIndex:i]] forState:UIControlStateSelected];
        [washBtn addTarget:self action:@selector(selectShoeServieType:) forControlEvents:UIControlEventTouchUpInside];
        [viewSome addSubview:washBtn];
        washBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        washBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if (i == 0 && ([arraySelectedServiceTypes containsObject:SERVICETYPE_SHOE_POLISH]))
        {
            washBtn.selected = YES;
        }
        else if (i == 1 && ([arraySelectedServiceTypes containsObject:SERVICETYPE_SHOE_CLEAN]))
        {
            washBtn.selected = YES;
        }
        else
        {
            washBtn.selected = NO;
        }
        
        [washBtn centerImageAndTextWithSpacing:10*MULTIPLYHEIGHT];
    }
    
    yAxis += viewSome.frame.size.height+20*MULTIPLYHEIGHT;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [view_Popup addSubview:btnDone];
    [btnDone setImage:[UIImage imageNamed:@"done_icon"] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-6];
    [btnDone addTarget:self action:@selector(saveServiceType) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"DONE"];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, [attr length])];
    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
    [attr addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attr length])];
    
    [btnDone setAttributedTitle:attr forState:UIControlStateNormal];
    
    [btnDone centerImageAndTextWithSpacing:5*MULTIPLYHEIGHT];
    
    float btnDW = 100*MULTIPLYHEIGHT;
    
    btnDone.frame = CGRectMake(view_Popup.frame.size.width/2-btnDW/2, yAxis, btnDW, 35*MULTIPLYHEIGHT);
    
    yAxis += 35*MULTIPLYHEIGHT+30*MULTIPLYHEIGHT;
    
    CGRect frame = view_Popup.frame;
    frame.size.height = yAxis;
    view_Popup.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = view_Popup.frame;
        rect.origin.y = screen_height/2-rect.size.height/2;
        view_Popup.frame = rect;
        
        blurEffect.alpha = 1.0;
        view_BG.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void) selectShoeServieType:(UIButton *) btn
{
    NSString *strTitle = [btn currentAttributedTitle].string;
    
    if (btn.selected)
    {
        btn.selected = NO;
        
        if ([strTitle caseInsensitiveCompare:@"SHOE\nPOLISH"] == NSOrderedSame)
        {
            [arraySelectedServiceTypes removeObject:SERVICETYPE_SHOE_POLISH];
        }
        else
        {
            [arraySelectedServiceTypes removeObject:SERVICETYPE_SHOE_CLEAN];
        }
    }
    else
    {
        btn.selected = YES;
        
        if ([strTitle caseInsensitiveCompare:@"SHOE\nPOLISH"] == NSOrderedSame)
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_SHOE_POLISH];
        }
        else
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_SHOE_CLEAN];
        }
    }
}


-(void) btnDryCleaningSelected:(UIButton *)sender
{
    [self showDryCleaningPopup];
}


-(void) showDryCleaningPopup
{
    [appDel applyCustomBlurEffetForView:self.view WithBlurRadius:5];
    
    blurEffect = [self.view viewWithTag:98765];
    blurEffect.alpha = 0.0;
    //blurEffect.dynamic = YES;
    
    [FXBlurView setUpdatesDisabled];
    
    
    float yAxis = 0;
    
    float vX = 25*MULTIPLYHEIGHT;
    float vH = 220*MULTIPLYHEIGHT;
    
    view_BG = [[UIView alloc]initWithFrame:self.view.bounds];
    view_BG.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.view addSubview:view_BG];
    view_BG.alpha = 0.0;
    
    
    view_Popup = [[UIView alloc]initWithFrame:CGRectMake(vX, screen_height, screen_width-(vX*2), vH)];
    view_Popup.backgroundColor = [UIColor whiteColor];
    [view_BG addSubview:view_Popup];
    view_Popup.clipsToBounds = YES;
    
    imgEcoBG = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, view_Popup.frame.size.width, view_Popup.frame.size.height)];
    imgEcoBG.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    imgEcoBG.image = [UIImage imageNamed:@"dc_eco_bg"];
    [view_Popup addSubview:imgEcoBG];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 15*MULTIPLYHEIGHT, view_Popup.frame.size.width, 20*MULTIPLYHEIGHT)];
    NSString *string = @"SELECT THE TYPE OF DRY CLEANING";
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor blackColor];
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-4];
    [view_Popup addSubview:titleLbl];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 1.0f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [string length])];
    
    titleLbl.attributedText = attributedString;
    
    
    yAxis += 20*MULTIPLYHEIGHT+30*MULTIPLYHEIGHT;
    
    CGFloat vsX = 25*MULTIPLYHEIGHT;
    
    viewSome = [[UIView alloc]initWithFrame:CGRectMake(vsX, yAxis, view_Popup.frame.size.width-vsX*2, 80*MULTIPLYHEIGHT)];
    viewSome.backgroundColor = [UIColor clearColor];
    [view_Popup addSubview:viewSome];
    
    NSArray *btnTitlesHome = @[@"NORMAL\nDRY CLEANING", @"GREEN\nDRY CLEANING"];
    NSArray *btnIconsHome = @[@"dry_cleaning", @"dcg"];
    NSArray *btnSelIconsHome = @[@"dry_cleaning_selected", @"dcg_selected"];
    
    float Width = viewSome.frame.size.width/[btnTitlesHome count];
    
    for (int i=0; i<btnTitlesHome.count; i++) {
        
        UIButton *washBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        washBtn.frame = CGRectMake(i*(Width), 0, Width, viewSome.frame.size.height);
        //washBtn.backgroundColor = [UIColor redColor];
        washBtn.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-4];
        
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:[btnTitlesHome objectAtIndex:i]];
        
        NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:[btnTitlesHome objectAtIndex:i]];
        
        if (i == 1)
        {
            //[washBtn setTitleColor:RGBCOLORCODE(105, 151, 20, 1.0) forState:UIControlStateNormal];
            
            [attr addAttributes:@{NSForegroundColorAttributeName:RGBCOLORCODE(105, 151, 20, 1.0)} range:NSMakeRange(0, [attr length])];
            [attrSel addAttributes:@{NSForegroundColorAttributeName:RGBCOLORCODE(105, 151, 20, 1.0)} range:NSMakeRange(0, [attr length])];
        }
        else
        {
            //            [washBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [washBtn setTitleColor:BLUE_COLOR forState:UIControlStateSelected];
            
            [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, [attr length])];
            [attrSel addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, [attr length])];
        }
        
        [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
        [attr addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attr length])];
        
        [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
        [attrSel addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attrSel length])];
        
        [washBtn setAttributedTitle:attr forState:UIControlStateNormal];
        [washBtn setAttributedTitle:attrSel forState:UIControlStateSelected];
        
        //[washBtn setTitle:[btnTitlesHome objectAtIndex:i] forState:UIControlStateNormal];
        [washBtn setImage:[UIImage imageNamed:[btnIconsHome objectAtIndex:i]] forState:UIControlStateNormal];
        [washBtn setImage:[UIImage imageNamed:[btnSelIconsHome objectAtIndex:i]] forState:UIControlStateSelected];
        [washBtn addTarget:self action:@selector(selectDCServieType:) forControlEvents:UIControlEventTouchUpInside];
        [viewSome addSubview:washBtn];
        washBtn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        washBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        if (i == 0 && ([arraySelectedServiceTypes containsObject:SERVICETYPE_DC]))
        {
            washBtn.selected = YES;
        }
        if (i == 1 && ([arraySelectedServiceTypes containsObject:SERVICETYPE_DCG]))
        {
            washBtn.selected = YES;
        }
        else
        {
            washBtn.selected = NO;
        }
        
        [washBtn centerImageAndTextWithSpacing:10*MULTIPLYHEIGHT];
        
        UIEdgeInsets titleEdgaeInsets = washBtn.titleEdgeInsets;
        titleEdgaeInsets.left -= 7*MULTIPLYHEIGHT;
        washBtn.titleEdgeInsets = titleEdgaeInsets;
    }
    
    yAxis += viewSome.frame.size.height+20*MULTIPLYHEIGHT;
    
    CGFloat imgX = 20*MULTIPLYHEIGHT;
    
    UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(imgX, yAxis, view_Popup.frame.size.width-imgX*2, 1)];
    imgLine.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    [view_Popup addSubview:imgLine];
    
    yAxis += 15*MULTIPLYHEIGHT;
    
    
    //    UILabel *lblOff = [[UILabel alloc] initWithFrame:CGRectMake(0, yAxis, view_Popup.frame.size.width, 20*MULTIPLYHEIGHT)];
    //    lblOff.numberOfLines = 0;
    //    NSString *stringOff = @"GET 25% CASHBACK ON\n";
    //    NSString *str2 = @"YOUR FIRST ECO DRY CLEANING";
    //
    //    NSString *strApp = [NSString stringWithFormat:@"%@%@", stringOff, str2];
    //
    //    lblOff.textAlignment = NSTextAlignmentCenter;
    //    lblOff.backgroundColor = [UIColor clearColor];
    //    [view_Popup addSubview:lblOff];
    //
    //    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc] initWithString:strApp];
    //
    //    float spacing1 = 0.7f;
    //    [attributedString1 addAttribute:NSKernAttributeName value:@(spacing1) range:NSMakeRange(0, [stringOff length])];
    //
    //    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    //    [paragraphStyle setLineSpacing:4.0f];
    //    [paragraphStyle setMaximumLineHeight:100.0f];
    //    paragraphStyle.alignment = NSTextAlignmentCenter;
    //
    //    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, strApp.length)];
    //
    //    [attributedString1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_Heavy size:appDel.HEADER_LABEL_FONT_SIZE-6], NSForegroundColorAttributeName:RGBCOLORCODE(107, 147, 31, 1.0)} range:NSMakeRange(0, [stringOff length])];
    //
    //    [attributedString1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-5], NSForegroundColorAttributeName:RGBCOLORCODE(107, 147, 31, 1.0)} range:NSMakeRange([stringOff length], [str2 length])];
    //
    //    float spacing2 = 0.7f;
    //    [attributedString1 addAttribute:NSKernAttributeName value:@(spacing2) range:NSMakeRange([stringOff length], [str2 length])];
    //
    //    CGSize size = [AppDelegate getAttributedTextHeightForText:attributedString1 WithWidth:lblOff.frame.size.width];
    //
    //    CGRect rectOff = lblOff.frame;
    //    rectOff.size.height = size.height;
    //    lblOff.frame = rectOff;
    //
    //    lblOff.attributedText = attributedString1;
    //
    //    yAxis += lblOff.frame.size.height+20*MULTIPLYHEIGHT;
    
    
    
    CGFloat lblDX = 15*MULTIPLYHEIGHT;
    
    UILabel *lblDesc = [[UILabel alloc] initWithFrame:CGRectMake(lblDX, yAxis, view_Popup.frame.size.width-(lblDX*2), 0)];
    
    NSString *str1 = GDC_TITLE;
    NSString *str2 = GDC_TEXT;
    NSString *str3 = GDC_FINAL;
    
    NSString *strTo = [NSString stringWithFormat:@"%@%@%@", str1, str2, str3];
    
    lblDesc.textAlignment = NSTextAlignmentCenter;
    lblDesc.numberOfLines = 0;
    lblDesc.textColor = [UIColor lightGrayColor];
    //lblDesc.backgroundColor = [UIColor redColor];
    lblDesc.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-6];
    [view_Popup addSubview:lblDesc];
    
    NSMutableAttributedString *attrDesc = [[NSMutableAttributedString alloc] initWithString:strTo];
    
    NSMutableParagraphStyle *paragraphStyleDes = NSMutableParagraphStyle.new;
    [paragraphStyleDes setLineSpacing:3.0f];
    [paragraphStyleDes setMaximumLineHeight:100.0f];
    paragraphStyleDes.alignment = NSTextAlignmentCenter;
    
    [attrDesc addAttribute:NSParagraphStyleAttributeName value:paragraphStyleDes range:NSMakeRange(0, strTo.length)];
    
    spacing = 1.0f;
    [attrDesc addAttribute:NSKernAttributeName  value:@(spacing) range:NSMakeRange(0, [strTo length])];
    
    [attrDesc addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-4], NSForegroundColorAttributeName:RGBCOLORCODE(107, 147, 31, 1.0)} range:NSMakeRange(0, [str1 length])];
    
    [attrDesc addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-5], NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange([str1 length], [str2 length])];
    
    [attrDesc addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD_ITALIC size:appDel.FONT_SIZE_CUSTOM-4], NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange([str1 length]+[str2 length], [str3 length])];
    
    lblDesc.attributedText = attrDesc;
    
    CGSize sizeDesc = [AppDelegate getAttributedTextHeightForText:attrDesc WithWidth:lblDesc.frame.size.width];
    
    CGRect rectDesc = lblDesc.frame;
    rectDesc.size.height = sizeDesc.height;
    lblDesc.frame = rectDesc;
    
    
    yAxis += lblDesc.frame.size.height+10*MULTIPLYHEIGHT;
    
    UIButton *btnPL = [UIButton buttonWithType:UIButtonTypeCustom];
    [view_Popup addSubview:btnPL];
    //btnPL.backgroundColor = [UIColor redColor];
    btnPL.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-6];
    [btnPL addTarget:self action:@selector(btnPriceListClicked) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *attrPL = [[NSMutableAttributedString alloc] initWithString:@"SEE PRICE LIST"];
    
    [attrPL addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, [attrPL length])];
    [attrPL addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrPL length])];
    [attrPL addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attrPL length])];
    
    [attrPL addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:(NSRange){0,[attrPL length]}];
    
    [btnPL setAttributedTitle:attrPL forState:UIControlStateNormal];
    
    float btnPLW = 100*MULTIPLYHEIGHT;
    
    btnPL.frame = CGRectMake(view_Popup.frame.size.width/2-btnPLW/2, yAxis, btnPLW, 25*MULTIPLYHEIGHT);
    
    yAxis += 25*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT;
    
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [view_Popup addSubview:btnDone];
    //[btnDone setImage:[UIImage imageNamed:@"done_icon"] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-3];
    [btnDone addTarget:self action:@selector(saveServiceType) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"DONE"];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]} range:NSMakeRange(0, [attr length])];
    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
    [attr addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attr length])];
    
    [btnDone setAttributedTitle:attr forState:UIControlStateNormal];
    
    //[btnDone centerImageAndTitle:5*MULTIPLYHEIGHT];
    
    btnDone.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    
    btnDone.layer.cornerRadius = 5.0;
    
    CGFloat btnDX = 23*MULTIPLYHEIGHT;
    CGFloat btnDH = 25*MULTIPLYHEIGHT;
    
    btnDone.frame = CGRectMake(btnDX, yAxis, view_Popup.frame.size.width-btnDX*2, btnDH);
    
    yAxis += btnDH+60*MULTIPLYHEIGHT;
    
    
    //    UIButton *btnKM = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [view_Popup addSubview:btnKM];
    //    [btnKM setImage:[UIImage imageNamed:@"apple_arrow_down"] forState:UIControlStateNormal];
    //    btnKM.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-6];
    //    [btnKM addTarget:self action:@selector(btnKnowMoreClicked) forControlEvents:UIControlEventTouchUpInside];
    //
    //    NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc] initWithString:@"KNOW MORE"];
    //
    //    [attr1 addAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, [attr1 length])];
    //    [attr1 addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr1 length])];
    //    [attr1 addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, [attr1 length])];
    //
    //    [btnKM setAttributedTitle:attr1 forState:UIControlStateNormal];
    //
    //    [btnKM buttonImageAndTextWithImagePosition:@"BOTTOM" WithSpacing:5*MULTIPLYHEIGHT];
    //
    //    float btnKMW = 100*MULTIPLYHEIGHT;
    //
    //    btnKM.frame = CGRectMake(view_Popup.frame.size.width/2-btnKMW/2, yAxis, btnKMW, 35*MULTIPLYHEIGHT);
    //
    ////    UIEdgeInsets titleInsets = btnKM.titleEdgeInsets;
    ////    titleInsets.left -= 8*MULTIPLYHEIGHT;
    ////    btnKM.titleEdgeInsets = titleInsets;
    //
    //    UIEdgeInsets imgInsets = btnKM.imageEdgeInsets;
    //    imgInsets.left += 8*MULTIPLYHEIGHT;
    //    btnKM.imageEdgeInsets = imgInsets;
    //
    //    yAxis += 35*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT;
    
    
    CGRect frame = view_Popup.frame;
    frame.size.height = yAxis;
    view_Popup.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = view_Popup.frame;
        rect.origin.y = screen_height/2-rect.size.height/2;
        view_Popup.frame = rect;
        
        blurEffect.alpha = 1.0;
        view_BG.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}


-(void) btnKnowMoreClicked
{
    if (knowMoreExpanded)
    {
        knowMoreExpanded = NO;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect frame = view_Popup.frame;
            frame.size.height -= 100*MULTIPLYHEIGHT;
            view_Popup.frame = frame;
            
        } completion:^(BOOL finished) {
            
        }];
    }
    else
    {
        knowMoreExpanded = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            CGRect frame = view_Popup.frame;
            frame.size.height += 100*MULTIPLYHEIGHT;
            view_Popup.frame = frame;
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = view_Popup.frame;
        rect.origin.y = screen_height/2-rect.size.height/2;
        view_Popup.frame = rect;
        
        blurEffect.alpha = 1.0;
        view_BG.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void) selectDCServieType:(UIButton *) btn
{
    NSString *strTitle = [btn currentAttributedTitle].string;
    
    if (btn.selected)
    {
        btn.selected = NO;
        
        if ([strTitle caseInsensitiveCompare:@"Normal\nDry cleaning"] == NSOrderedSame)
        {
            [arraySelectedServiceTypes removeObject:SERVICETYPE_DC];
        }
        else
        {
            [arraySelectedServiceTypes removeObject:SERVICETYPE_DCG];
        }
    }
    else
    {
        btn.selected = YES;
        
        if ([strTitle caseInsensitiveCompare:@"Normal\nDry cleaning"] == NSOrderedSame)
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_DC];
        }
        else
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_DCG];
        }
    }
    
    if ([arraySelectedServiceTypes containsObject:SERVICETYPE_DC] || [arraySelectedServiceTypes containsObject:SERVICETYPE_DCG])
    {
        btnDryCleaning.selected = YES;
    }
    else
    {
        btnDryCleaning.selected = NO;
    }
}

-(void) btnCurtainsSelected:(UIButton *)sender
{
    [self showCurtainsPopup];
}

-(void) showCurtainsPopup
{
    selectedCurtainServiceType = SERVICETYPE_CC_DC;
    
    [appDel applyCustomBlurEffetForView:self.view WithBlurRadius:5];
    
    blurEffect = [self.view viewWithTag:98765];
    blurEffect.alpha = 0.0;
    //blurEffect.dynamic = YES;
    
    [FXBlurView setUpdatesDisabled];
    
    
    float yAxis = 0;
    
    float vX = 25*MULTIPLYHEIGHT;
    float vH = 220*MULTIPLYHEIGHT;
    
    view_BG = [[UIView alloc]initWithFrame:self.view.bounds];
    view_BG.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [self.view addSubview:view_BG];
    view_BG.alpha = 0.0;
    
    
    view_Popup = [[UIView alloc]initWithFrame:CGRectMake(vX, screen_height, screen_width-(vX*2), vH)];
    view_Popup.backgroundColor = [UIColor whiteColor];
    [view_BG addSubview:view_Popup];
    
    float imgBH = 80*MULTIPLYHEIGHT;
    
    UIImageView *imgBg = [[UIImageView alloc]initWithFrame:CGRectMake(0, yAxis, view_Popup.frame.size.width, imgBH)];
    imgBg.image = [UIImage imageNamed:@"preference_bg"];
    [view_Popup addSubview:imgBg];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 15*MULTIPLYHEIGHT, view_Popup.frame.size.width, 20*MULTIPLYHEIGHT)];
    NSString *string = @"CURTAINS";
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
    [view_Popup addSubview:titleLbl];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    
    float spacing = 1.0f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [string length])];
    
    titleLbl.attributedText = attributedString;
    
    
    float imgWidth = 30*MULTIPLYHEIGHT;
    
    UIImageView *imgTop = [[UIImageView alloc]init];
    imgTop.contentMode = UIViewContentModeScaleAspectFit;
    imgTop.frame = CGRectMake(view_Popup.frame.size.width/2-imgWidth/2, 15*MULTIPLYHEIGHT+titleLbl.frame.size.height+5*MULTIPLYHEIGHT, imgWidth, imgWidth);
    imgTop.image = [UIImage imageNamed:@"curtains_icon"];
    [view_Popup addSubview:imgTop];
    
    
    yAxis += imgBH+20*MULTIPLYHEIGHT;
    
    //    UILabel *lblType = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, view_Popup.frame.size.width, 20*MULTIPLYHEIGHT)];
    //    lblType.text = @"SELECT YOUR SERVICE TYPE";
    //    lblType.textAlignment = NSTextAlignmentCenter;
    //    lblType.textColor = [UIColor lightGrayColor];
    //    lblType.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
    //    [view_Popup addSubview:lblType];
    //
    //    yAxis += 20*MULTIPLYHEIGHT+20*MULTIPLYHEIGHT;
    //
    //
    //    CGFloat vsX = 30*MULTIPLYHEIGHT;
    //
    //    viewSome = [[UIView alloc]initWithFrame:CGRectMake(vsX, yAxis, view_Popup.frame.size.width-vsX*2, 50*MULTIPLYHEIGHT)];
    //    viewSome.backgroundColor = [UIColor clearColor];
    //    [view_Popup addSubview:viewSome];
    //
    //    NSArray *btnTitlesHome = @[@"DRY CLEANING", @"WASH & IRON"];
    //    NSArray *btnIconsHome = @[@"dry_cleaning", @"wash_and_iron"];
    //    NSArray *btnSelIconsHome = @[@"dry_cleaning_selected", @"wash_and_iron_selected"];
    //
    //    float Width = viewSome.frame.size.width/[btnTitlesHome count];
    //
    //    for (int i=0; i<btnTitlesHome.count; i++) {
    //
    //        UIButton *washBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //        washBtn.frame = CGRectMake(i*(Width), 0, Width, viewSome.frame.size.height);
    //        //washBtn.backgroundColor = [UIColor redColor];
    //        washBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
    //        [washBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    //        [washBtn setTitleColor:BLUE_COLOR forState:UIControlStateSelected];
    //        [washBtn setTitle:[btnTitlesHome objectAtIndex:i] forState:UIControlStateNormal];
    //        [washBtn setImage:[UIImage imageNamed:[btnIconsHome objectAtIndex:i]] forState:UIControlStateNormal];
    //        [washBtn setImage:[UIImage imageNamed:[btnSelIconsHome objectAtIndex:i]] forState:UIControlStateSelected];
    //        [washBtn addTarget:self action:@selector(selectCurtainServieType:) forControlEvents:UIControlEventTouchUpInside];
    //        [viewSome addSubview:washBtn];
    //
    //
    //        // CC_WI, CC_DC, CC_W_WI, CC_W_DC
    //
    //        if (i == 0 && ([selectedCurtainServiceType isEqualToString:SERVICETYPE_CC_DC] || [selectedCurtainServiceType isEqualToString:SERVICETYPE_CC_W_DC]))
    //        {
    //            washBtn.selected = YES;
    //        }
    //        else if (i == 1 && ([selectedCurtainServiceType isEqualToString:SERVICETYPE_CC_WI] || [selectedCurtainServiceType isEqualToString:SERVICETYPE_CC_W_WI]))
    //        {
    //            washBtn.selected = YES;
    //        }
    //        else
    //        {
    //            washBtn.selected = NO;
    //        }
    //
    //        [washBtn centerImageAndTitle:10*MULTIPLYHEIGHT];
    //    }
    //
    //    yAxis += viewSome.frame.size.height+35*MULTIPLYHEIGHT;
    //
    //    CGFloat imgX = 20*MULTIPLYHEIGHT;
    //
    //    UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(imgX, yAxis, view_Popup.frame.size.width-imgX*2, 1)];
    //    imgLine.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.2];
    //    [view_Popup addSubview:imgLine];
    //
    //    yAxis += 12*MULTIPLYHEIGHT;
    
    CGFloat lblIX = 20*MULTIPLYHEIGHT;
    CGFloat lblIH = 30*MULTIPLYHEIGHT;
    
    lblInst = [[UILabel alloc]initWithFrame:CGRectMake(lblIX, yAxis, view_Popup.frame.size.width-lblIX*2, lblIH)];
    lblInst.textColor = [UIColor darkGrayColor];
    lblInst.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2];
    lblInst.numberOfLines = 0;
    lblInst.textAlignment = NSTextAlignmentCenter;
    lblInst.text = @"With Removal & Installation";
    [view_Popup addSubview:lblInst];
    
    yAxis += lblIH+5*MULTIPLYHEIGHT;
    
    // Custom Switch
    
    CGFloat sgX = 50 * MULTIPLYHEIGHT;
    CGFloat sgH = 17 * MULTIPLYHEIGHT;
    
    UISegmentedControl *segmentCurtain = [[UISegmentedControl alloc]initWithItems:@[@"YES", @"NO"]];
    segmentCurtain.frame = CGRectMake(sgX, yAxis, view_Popup.frame.size.width-(sgX * 2), sgH);
    [segmentCurtain setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-4]} forState:UIControlStateSelected];
    [segmentCurtain setTitleTextAttributes:@{NSForegroundColorAttributeName : RGBCOLORCODE(64, 143, 210, 1.0), NSFontAttributeName: [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-4]} forState:UIControlStateNormal];
    [segmentCurtain addTarget:self action:@selector(curtainPreference:) forControlEvents:UIControlEventValueChanged];
    segmentCurtain.tintColor = RGBCOLORCODE(64, 143, 210, 1.0);
    segmentCurtain.selectedSegmentIndex = 1;
    [view_Popup addSubview:segmentCurtain];
    
    
    //    switchCurtain = [[SevenSwitch alloc] initWithFrame:CGRectMake(30*MULTIPLYHEIGHT+100*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT,  yAxis+15*MULTIPLYHEIGHT, 35*MULTIPLYHEIGHT, 14*MULTIPLYHEIGHT)];
    //    switchCurtain.onLabel.text = @"";
    //    switchCurtain.offLabel.text = @"";
    //    //switchCurtain.center = CGPointMake(self.view.bounds.size.width * 0.5, 30);
    //    switchCurtain.inactiveColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    //    //switchCurtain.onTintColor = [UIColor colorWithRed:0.45f green:0.58f blue:0.67f alpha:1.00f];
    //    [switchCurtain addTarget:self action:@selector(curtainPreference:) forControlEvents:UIControlEventValueChanged];
    //    //switchCurtain.thumbImage = [UIImage imageNamed:@"round_image"];
    //    //        switchCurtain.offImage = [UIImage imageNamed:@"cross.png"];
    //    //        switchCurtain.onImage = [UIImage imageNamed:@"check.png"];
    //    //switchCurtain.onTintColor = [UIColor colorWithHue:0.08f saturation:0.74f brightness:1.00f alpha:1.00f];
    //    switchCurtain.onLabel.textColor = [UIColor whiteColor];
    //    switchCurtain.isRounded = YES;
    //    [view_Popup addSubview:switchCurtain];
    //
    //    [switchCurtain setOn:NO animated:YES];
    
    
    yAxis += sgH+25*MULTIPLYHEIGHT;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [view_Popup addSubview:btnDone];
    //[btnDone setImage:[UIImage imageNamed:@"done_icon"] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
    [btnDone addTarget:self action:@selector(saveServiceType) forControlEvents:UIControlEventTouchUpInside];
    btnDone.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    
    btnDone.layer.cornerRadius = 5.0;
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"DONE"];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor]} range:NSMakeRange(0, [attr length])];
    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
    [btnDone setAttributedTitle:attr forState:UIControlStateNormal];
    
    //    [btnDone centerImageAndTitle:3*MULTIPLYHEIGHT];
    //
    //    UIEdgeInsets titleInsets = btnDone.titleEdgeInsets;
    //    titleInsets.left -= 3*MULTIPLYHEIGHT;
    //    btnDone.titleEdgeInsets = titleInsets;
    
    
    CGFloat btnDX = 23*MULTIPLYHEIGHT;
    CGFloat btnDH = 25*MULTIPLYHEIGHT;
    
    btnDone.frame = CGRectMake(btnDX, yAxis, view_Popup.frame.size.width-btnDX*2, btnDH);
    
    yAxis += btnDH+20*MULTIPLYHEIGHT;
    
    NSString *strCurtainDesc = @"";
    
    strCurtainDesc = @"A thorough dry cleaning of curtains & drapes to give your living spaces a clean & vibrant look, with features like Removal & Installation offering great convenience.";
    
    CGFloat lblDX = 20*MULTIPLYHEIGHT;
    CGFloat lblDW = view_Popup.frame.size.width-lblDX*2;
    
    UILabel *lblDesc = [[UILabel alloc]initWithFrame:CGRectMake(lblDX, yAxis, lblDW, 20)];
    lblDesc.numberOfLines = 0;
    lblDesc.textAlignment = NSTextAlignmentCenter;
    lblDesc.textColor = [UIColor grayColor];
    [view_Popup addSubview:lblDesc];
    
    NSMutableAttributedString *lblAttr = [[NSMutableAttributedString alloc]initWithString:strCurtainDesc];
    
    [lblAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-5], NSKernAttributeName : @(0.7)} range:NSMakeRange(0, lblAttr.string.length)];
    
    lblDesc.attributedText = lblAttr;
    
    CGSize size = [AppDelegate getAttributedTextHeightForText:lblAttr WithWidth:lblDesc.frame.size.width];
    
    CGRect rect = lblDesc.frame;
    rect.size.height = size.height;
    lblDesc.frame = rect;
    
    yAxis += size.height+30*MULTIPLYHEIGHT;
    
    CGRect frame = view_Popup.frame;
    frame.size.height = yAxis;
    view_Popup.frame = frame;
    
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = view_Popup.frame;
        rect.origin.y = screen_height/2-rect.size.height/2;
        view_Popup.frame = rect;
        
        blurEffect.alpha = 1.0;
        view_BG.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}


-(void) selectCurtainServieType:(UIButton *) btn
{
    for (UIButton *btn1 in viewSome.subviews)
    {
        btn1.selected = NO;
    }
    
    [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_DC];
    [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_W_DC];
    [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_WI];
    [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_W_WI];
    
    btn.selected = YES;
    
    NSString *strTitle = [btn currentTitle];
    
    if ([strTitle caseInsensitiveCompare:@"Dry cleaning"] == NSOrderedSame)
    {
        if ([switchCurtain isOn])
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_CC_W_DC];
        }
        else
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_CC_DC];
        }
    }
    else
    {
        if ([switchCurtain isOn])
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_CC_W_WI];
        }
        else
        {
            [arraySelectedServiceTypes addObject:SERVICETYPE_CC_WI];
        }
    }
}

-(void) curtainPreference:(UISegmentedControl *)switch1
{
    if (switch1.selectedSegmentIndex == 0)
    {
        selectedCurtainServiceType = SERVICETYPE_CC_W_DC;
    }
    else
    {
        selectedCurtainServiceType = SERVICETYPE_CC_DC;
    }
}

-(void) saveServiceType
{
    [UIView animateWithDuration:0.3 animations:^{
        
        CGRect rect = view_Popup.frame;
        rect.origin.y = screen_height;
        view_Popup.frame = rect;
        
        blurEffect.alpha = 0.0;
        view_BG.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [viewSome removeFromSuperview];
        viewSome = nil;
        
        [view_Popup removeFromSuperview];
        view_Popup = nil;
        
        [view_BG removeFromSuperview];
        view_BG = nil;
        
        [blurEffect removeFromSuperview];
        blurEffect = nil;
        
    }];
    
    if ([selectedCurtainServiceType length])
    {
        btnCurtain.selected = YES;
        
        if (![arraySelectedServiceTypes containsObject:selectedCurtainServiceType])
        {
            [arraySelectedServiceTypes addObject:selectedCurtainServiceType];
        }
    }
    else
    {
        //        btnCurtain.selected = NO;
        //        btnDryCleaning.selected = NO;
        //        btnShoe.selected = NO;
    }
    
    if (btnCurtain.selected || btnDryCleaning.selected || btnShoe.selected)
    {
        if (btnDryCleaning.selected)
        {
            if ([arraySelectedServiceTypes containsObject:SERVICETYPE_DC] && [arraySelectedServiceTypes containsObject:SERVICETYPE_DCG])
            {
                [btnDryCleaning setImage:[UIImage imageNamed:@"dc_dcg_selected"] forState:UIControlStateSelected];
                [btnDryCleaning setTitleColor:BLUE_COLOR forState:UIControlStateSelected];
            }
            else if ([arraySelectedServiceTypes containsObject:SERVICETYPE_DC])
            {
                [btnDryCleaning setImage:[UIImage imageNamed:@"dry_cleaning_selected"] forState:UIControlStateSelected];
                [btnDryCleaning setTitleColor:BLUE_COLOR forState:UIControlStateSelected];
            }
            else
            {
                [btnDryCleaning setImage:[UIImage imageNamed:@"dcg_selected"] forState:UIControlStateSelected];
                [btnDryCleaning setTitleColor:RGBCOLORCODE(105, 151, 20, 1.0) forState:UIControlStateSelected];
            }
            
            [btnDryCleaning centerImageAndTextWithSpacing:10*MULTIPLYHEIGHT];
        }
        
        [self showDaysToDeliver];
        
        [self GetDaysToDeliver];
    }
    
    selectedCurtainServiceType = @"";
}


-(void) showPreferences
{
    PreferencesViewController *objPre = [[PreferencesViewController alloc]init];
    objPre.delegate = self;
    objPre.strPrefs = [self.orderInfo objectForKey:PREFERENCES_SELECTED];
    [self presentViewController:objPre animated:YES completion:nil];
}

-(void) didAddPreferences:(NSString *) strPrefs
{
    if (self.isDeliveryOrder)
    {
        [AppDelegate showAlertWithMessage:@"Preferences are not editable by Piingo." andTitle:@"" andBtnTitle:@"OK"];
    }
    else
    {
        [self.orderInfo setObject:strPrefs forKey:PREFERENCES_SELECTED];
    }
}

-(void) revertBackdata:(id)sender
{
    return;
    
    [self orderInfoFromUpdateorder];
    
    [scheduleScreenView removeFromSuperview];
    scheduleScreenView = nil;
    [self createScheduleScreenView];
    
    //return;
    
    for (int i=0; i<4; i++) {
        
        UIButton *washBtn = [scheduleScreenView viewWithTag:SCHEDULE_SCREEN_TAG + 7 + i];
        washBtn.selected = NO;
        
        if ([[self.dictUpdateOrder objectForKey:@"jtmid"] containsString:@"1"])
        {
            if (i == 0)
            {
                washBtn.selected = YES;
            }
        }
        if ([[self.dictUpdateOrder objectForKey:@"jtmid"] containsString:@"2"])
        {
            if (i == 1)
            {
                washBtn.selected = YES;
            }
        }
        if ([[self.dictUpdateOrder objectForKey:@"jtmid"] containsString:@"3"])
        {
            if (i == 2)
            {
                washBtn.selected = YES;
            }
        }
        if ([[self.dictUpdateOrder objectForKey:@"jtmid"] containsString:@"4"])
        {
            if (i == 3)
            {
                washBtn.selected = YES;
            }
        }
    }
    
    pickUpDateLbl.text = [NSString stringWithFormat:@"PICKUP DATE: %@", [self.dictUpdateOrder objectForKey:ORDER_PICKUP_DATE]];
    pickUpTimeLbl.text = [NSString stringWithFormat:@"PICKUP TIME: %@", [self.dictUpdateOrder objectForKey:ORDER_PICKUP_SLOT]];
    
    
    if ([[self.dictUpdateOrder objectForKey:ORDER_TYPE] caseInsensitiveCompare:@"Regular"] == NSOrderedSame)
    {
        [mySwitch2 setOn:NO animated:YES];
    }
    else
    {
        [mySwitch2 setOn:YES animated:YES];
    }
    
    listView.selectedItem = [self.dictUpdateOrder objectForKey:ORDER_PICKUP_DATE];
    
    {
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_PICKUP_DATE] forKey:ORDER_PICKUP_DATE];
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:ORDER_PICKUP_SLOT] forKey:ORDER_PICKUP_SLOT];
        
        [self.orderInfo setObject:[self.dictUpdateOrder objectForKey:@"jtmid"] forKey:ORDER_JOB_TYPE];
        
        [self.dictChangedValues setObject:[self.dictUpdateOrder objectForKey:@"jtmid"] forKey:ORDER_JOB_TYPE];
        
        if ([[self.dictUpdateOrder objectForKey:ORDER_TYPE] caseInsensitiveCompare:@"Regular"] == NSOrderedSame)
        {
            [self.dictChangedValues setObject:@"R" forKey:ORDER_TYPE];
            
            [self.orderInfo setObject:@"R" forKey:ORDER_TYPE];
        }
        else
        {
            [self.dictChangedValues setObject:@"E" forKey:ORDER_TYPE];
            
            [self.orderInfo setObject:@"E" forKey:ORDER_TYPE];
        }
        
    }
    
}

-(void) switchChanged:(SevenSwitch *)switch1
{
    if (([self.dictAllowFields count] && [[self.dictAllowFields objectForKey:@"orderSpeed"] intValue] == 0) || self.isRewashOrder)
    {
        [AppDelegate showAlertWithMessage:@"You can't update order type." andTitle:@"" andBtnTitle:@"OK"];
        
        if ([[self.orderInfo objectForKey:ORDER_TYPE] caseInsensitiveCompare:@"R"] == NSOrderedSame)
        {
            [switch1 setOn:NO animated:YES];
        }
        else
        {
            [switch1 setOn:YES animated:YES];
        }
        
        return;
    }
    
    if(switch1.on)
    {
        [self.orderInfo setObject:ORDER_TYPE_EXPRESS forKey:ORDER_TYPE];
    }
    else
    {
        [self.orderInfo setObject:ORDER_TYPE_REGULAR forKey:ORDER_TYPE];
    }
    
    [self GetDaysToDeliver];
}


#pragma mark - Action Event Handler
- (void) handleExpressSwitch:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    if(sender.selected) {
        [self.orderInfo setObject:ORDER_TYPE_EXPRESS forKey:ORDER_TYPE];
    }
    else {
        [self.orderInfo setObject:ORDER_TYPE_REGULAR forKey:ORDER_TYPE];
    }
    
    [self GetDaysToDeliver];
    
}

- (void)selectPickUpAddress:(UIButton *)sender {
    
    //    [AppDelegate showAlertWithMessage:@"Pickup address is not editable by Piingo" andTitle:@"" andBtnTitle:@"OK"];
    //
    //    return;
    
    if ([addressBtn isSelected])
    {
        [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
            
            customPopOverView.alpha = 0.0;
            
            CGRect frame = addressBtn.frame;
            frame.origin.y = previousAddressYAxis;
            addressBtn.frame = frame;
            
            
        } completion:^(BOOL finished) {
            
            [customPopOverView removeFromSuperview];
            customPopOverView = nil;
            
            addressBtn.selected = NO;
            
            [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
        }];
        
        return;
    }
    
    previousAddressYAxis = addressBtn.frame.origin.y;
    
    addressBtn.selected = YES;
    
    customPopOverView = [[CustomPopoverView alloc]initWithArray:self.userAddresses IsAddressType:YES];
    customPopOverView.delegate = self;
    customPopOverView.isFromTag = 2;
    [scheduleScreenView addSubview:customPopOverView];
    customPopOverView.alpha = 0.0;
    
    int yVal = 70*MULTIPLYHEIGHT;
    
    customPopOverView.frame = CGRectMake(0, yVal+addressBtn.frame.size.height, screen_width, screen_height-(yVal+addressBtn.frame.size.height));
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        
        customPopOverView.alpha = 1.0;
        
        CGRect frame = addressBtn.frame;
        frame.origin.y = yVal;
        addressBtn.frame = frame;
        
        
    } completion:^(BOOL finished) {
        
        [addressBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        
    }];
}


#pragma mark FPPopover Delegate Method
-(void) didSelectFromList:(NSString *) string AtIndex:(NSInteger)row
{
    
    [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
        
        customPopOverView.alpha = 0.0;
        
        CGRect frame = addressBtn.frame;
        frame.origin.y = previousAddressYAxis;
        addressBtn.frame = frame;
        
        
    } completion:^(BOOL finished) {
        
        [customPopOverView removeFromSuperview];
        customPopOverView = nil;
        
        addressBtn.selected = NO;
        
        [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
    }];
    
    selectedAddress = [self.userAddresses objectAtIndex:row];
    
    [addressBtn setTitle:string forState:UIControlStateNormal];
    addressBtn.selected = NO;
}


- (void)selectPickUpDate:(UIButton *)sender
{
    [AppDelegate showAlertWithMessage:@"Pickup date is not editable by Piingo" andTitle:@"" andBtnTitle:@"OK"];
}

-(void) clickedOnPickupdate
{
    NSMutableArray *list = nil;
    
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"dd-MM-yyyy"];
    
    NSDateFormatter *toDtFormatter = [[NSDateFormatter alloc] init];
    [toDtFormatter setDateFormat:@"dd MMM, EEE"];
    
    list = [NSMutableArray arrayWithCapacity:0];
    NSArray *givenList = arraAlldata;
    for (NSDictionary *dict in givenList) {
        NSMutableDictionary *dtInfo = [NSMutableDictionary dictionaryWithCapacity:0];
        [dtInfo setObject:[dict objectForKey:@"date"] forKey:@"actValue"];
        [dtInfo setObject:[dict objectForKey:@"dis"] forKey:@"discountValue"];
        
        [dtInfo setObject:[toDtFormatter stringFromDate:[dtFormatter dateFromString:[dict objectForKey:@"date"]]] forKey:@"title"];
        
        CGRect frame = [[dtInfo objectForKey:@"title"] boundingRectWithSize:CGSizeMake(170, 44)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.FONT_SIZE_CUSTOM-1] }
                                                                    context:nil];
        
        [dtInfo setObject:[NSString stringWithFormat:@"%f", frame.size.width] forKey:@"TextWidth"];
        
        [list addObject:dtInfo];
    }
    
    if (![self.pickUpDates count])
    {
        [AppDelegate showAlertWithMessage:@"Pickup dates are not available at this time." andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    DateTimeViewController *objDt = [[DateTimeViewController alloc]init];
    objDt.delegate = self;
    objDt.dictAllowFields = [[NSMutableDictionary alloc]initWithDictionary:self.dictAllowFields];
    //objDt.isFromUpdateOrder = self.isFromUpdateOrder;
    objDt.arrayDates = [[NSMutableArray alloc]initWithArray:list];
    objDt.selectedAddress = [[NSMutableDictionary alloc]initWithDictionary:selectedAddress];
    objDt.orderInfo = [[NSMutableDictionary alloc]initWithDictionary:self.orderInfo];
    
    objDt.dictDatesAndTimes = [[NSMutableDictionary alloc]initWithDictionary:dictPickupDatesAndTimes];
    
    objDt.selectedDate = [self.orderInfo objectForKey:ORDER_PICKUP_DATE];
    objDt.strSelectedTimeSlot = [self.orderInfo objectForKey:ORDER_PICKUP_SLOT];
    
    [self presentViewController:objDt animated:YES completion:nil];
}

//- (void) handlePickUpDateScreenWithStatus:(BOOL)isHidden withList:(NSArray *)list {
//
//    [UIView animateWithDuration:0.3 animations:^{
//
//        [listView setItems:list];
//        listView.frame = CGRectMake(isHidden ? screen_width : screen_width - 220.0, 0.0, 220.0, CGRectGetHeight(self.view.bounds));
//
//    } completion:^(BOOL finished) {
//
//
//    }];
//
//}

-(void) didSelectDateAndTime:(NSArray *)array
{
    [self.orderInfo setObject:[array objectAtIndex:0] forKey:ORDER_PICKUP_DATE];
    [self.orderInfo setObject:[array objectAtIndex:1] forKey:ORDER_PICKUP_SLOT];
    
    pickUpDateLbl.attributedText = [self setPickupAttributedText];
}

- (void)selectWashType:(UIButton *)sender {
    
    if (self.isDeliveryOrder || self.isRewashOrder)
    {
        [AppDelegate showAlertWithMessage:@"Service types are not editable by Piingo." andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    /// Shoes Code
    
    shoeSelected  = NO;
    
    if([[sender.currentTitle lowercaseString] containsString:@"shoes"])
    {
        if (!sender.selected)
        {
            shoeSelected = YES;
            [self btnShoeSelected:sender];
        }
        else
        {
            shoeSelected = NO;
            
            [arraySelectedServiceTypes removeObject:SERVICETYPE_SHOE_POLISH];
            [arraySelectedServiceTypes removeObject:SERVICETYPE_SHOE_CLEAN];
        }
        
        btnShoe = sender;
    }
    
    
    /// Curtains Code
    
    curtainSelected  = NO;
    
    if([sender.currentTitle caseInsensitiveCompare:@"Curtains"] == NSOrderedSame)
    {
        if (!sender.selected)
        {
            curtainSelected = YES;
            [self btnCurtainsSelected:sender];
        }
        else
        {
            curtainSelected = NO;
            
            if ([arraySelectedServiceTypes containsObject:SERVICETYPE_CC_WI])
            {
                [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_WI];
            }
            else if ([arraySelectedServiceTypes containsObject:SERVICETYPE_CC_W_WI])
            {
                [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_W_WI];
            }
            else if ([arraySelectedServiceTypes containsObject:SERVICETYPE_CC_DC])
            {
                [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_DC];
            }
            else if ([arraySelectedServiceTypes containsObject:SERVICETYPE_CC_W_DC])
            {
                [arraySelectedServiceTypes removeObject:SERVICETYPE_CC_W_DC];
            }
        }
        
        btnCurtain = sender;
    }
    
    
    /// Dry Cleaning Code
    
    dryCleaningSelected = NO;
    
    if([sender.currentTitle caseInsensitiveCompare:@"Dry Cleaning"] == NSOrderedSame)
    {
        selected_DC_Tag = sender.tag;
        
        if (!sender.selected)
        {
            dryCleaningSelected = YES;
            [self btnDryCleaningSelected:sender];
        }
        else
        {
            dryCleaningSelected = NO;
            
            if ([arraySelectedServiceTypes containsObject:@"DC"])
            {
                [arraySelectedServiceTypes removeObject:@"DC"];
            }
            if ([arraySelectedServiceTypes containsObject:@"DCG"])
            {
                [arraySelectedServiceTypes removeObject:@"DCG"];
            }
        }
        
        btnDryCleaning = sender;
        
        [btnDryCleaning centerImageAndTextWithSpacing:10*MULTIPLYHEIGHT];
    }
    
    
    if (sender.selected)
    {
        sender.selected = NO;
        
        [arraySelectedServiceTypes removeObject:[dictServiceType objectForKey:sender.currentTitle]];
    }
    else
    {
        
        if([sender.currentTitle caseInsensitiveCompare:@"Dry Cleaning"] != NSOrderedSame && [sender.currentTitle caseInsensitiveCompare:@"Curtains"] != NSOrderedSame && ![[sender.currentTitle lowercaseString] containsString:@"shoes"])
        {
            sender.selected = YES;
            
            [arraySelectedServiceTypes addObject:[dictServiceType objectForKey:sender.currentTitle]];
        }
    }
    
    if([arraySelectedServiceTypes count])
    {
        [self showDaysToDeliver];
    }
    else
    {
        [self hideDaysToDeliver];
    }
    
    if (!curtainSelected && !dryCleaningSelected && !shoeSelected)
    {
        [self GetDaysToDeliver];
    }
}

-(void)GetDaysToDeliver
{
    if ([arraySelectedServiceTypes count])
    {
        NSMutableDictionary *detailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self.orderInfo objectForKey:@"userId"], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", [self.orderInfo objectForKey:ORDER_FROM], @"orderType", arraySelectedServiceTypes, @"serviceTypes", [self.orderInfo objectForKey:ORDER_TYPE], @"orderSpeed", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/estimatedays", BASE_URL];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:detailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
                
                if ([[responseObj objectForKey:@"days"] intValue] == 1)
                {
                    LblDaysToDeliver.text = [NSString stringWithFormat:@"%d DAY TO DELIVER", [[responseObj objectForKey:@"days"]intValue]];
                }
                else
                {
                    LblDaysToDeliver.text = [NSString stringWithFormat:@"%d DAYS TO DELIVER", [[responseObj objectForKey:@"days"]intValue]];
                }
            }
            else {
                
                if ([[responseObj objectForKey:@"s"] intValue] != 100)
                {
                    [mySwitch2 setOn:NO animated:YES];
                    
                    [self.orderInfo setObject:ORDER_TYPE_REGULAR forKey:ORDER_TYPE];
                    
                    [self GetDaysToDeliver];
                }
                
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
        }];
        
    }
    else
    {
        LblDaysToDeliver.text = [@"Pick your order type" uppercaseString];
    }
}


- (void)showInstructions:(UIButton *)sender {
    
    
}



- (void) nextBtnTapped:(UIButton *)sender {
    
    [self.orderInfo setObject:[selectedAddress objectForKey:@"_id"] forKey:ORDER_PICKUP_ADDRESS_ID];
    
    if ([arraySelectedServiceTypes count])
    {
        [self.orderInfo setObject:arraySelectedServiceTypes forKey:ORDER_JOB_TYPE];
    }
    
    if ([arraySelectedServiceTypes count])
    {
        DeliveryViewController1 *vc = [[DeliveryViewController1 alloc] init];
        
        if (self.isFromCreateOrder)
        {
            vc.isFromCreateOrder = YES;
        }
        
        if (self.isRewashOrder)
        {
            vc.isRewashOrder = YES;
            vc.arrayRewashItems = [[NSMutableArray alloc]initWithArray:self.arrayRewashItems];
        }
        
        vc.dictAllowFields = [[NSMutableDictionary alloc]initWithDictionary:self.dictAllowFields];
        vc.userAddresses = [[NSMutableArray alloc]initWithArray:self.userAddresses];
        vc.userSavedCards = [[NSMutableArray alloc]initWithArray:self.userSavedCards];
        vc.orderInfo = [[NSMutableDictionary alloc]initWithDictionary:self.orderInfo];
        vc.dictChangedValues = [[NSMutableDictionary alloc]initWithDictionary:self.dictChangedValues];
        vc.isDeliveryOrder = self.isDeliveryOrder;
        vc.arrayAllOrderDetails = [[NSMutableDictionary alloc]initWithDictionary:self.dictUpdateOrder];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else {
        
        if (![self.orderInfo objectForKey:ORDER_PICKUP_DATE]) {
            
            [AppDelegate showAlertWithMessage:@"Please select Pickup Date" andTitle:@"Error" andBtnTitle:@"OK"];
            
        }
        else if (![self.orderInfo objectForKey:ORDER_PICKUP_SLOT]) {
            
            [AppDelegate showAlertWithMessage:@"Please select Pickup Timeslot" andTitle:@"Error" andBtnTitle:@"OK"];
            
        }
        else if (![arraySelectedServiceTypes count]) {
            
            [AppDelegate showAlertWithMessage:@"Please select service type" andTitle:@"Error" andBtnTitle:@"OK"];
            
        }
    }
}

- (void)closeScheduleScreen:(UIButton *)sender {
    
    
    if (addressBtn && ![addressBtn isUserInteractionEnabled])
    {
        [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
            
            customPopOverView.alpha = 0.0;
            
            CGRect frame = addressBtn.frame;
            frame.origin.y = previousAddressYAxis;
            addressBtn.frame = frame;
            
            
        } completion:^(BOOL finished) {
            
            [customPopOverView removeFromSuperview];
            customPopOverView = nil;
            
            addressBtn.userInteractionEnabled = YES;
            
            [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
        }];
    }
    else
    {
        if (self.isFromCreateOrder)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                self.navigationController.view.frame = CGRectMake(0.0, screen_height, screen_width, screen_height);
                
            } completion:^(BOOL finished) {
                
                [self.navigationController.parentViewController viewWillAppear:YES];
                [self.navigationController.view removeFromSuperview];
            }];
        }
    }
}

@end


