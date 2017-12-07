//
//  DeliveryViewController.m
//  Piing
//
//  Created by Piing on 10/24/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import "DeliveryViewController1.h"
#import "ListViewController.h"
#import "CustomPopoverView.h"
#import "ScheduleLaterViewController1.h"
#import "JobdetailViewController.h"
#import "DateTimeViewController.h"



#define PLACE_HOLDER_COLOR_INSTEAD_IMAGE [UIColor clearColor]

#define DELIVERY_VIEW_TAG 100

#define REDEEM_VIEW_TAG 200


@interface DeliveryViewController1 () <UITextFieldDelegate, CustomPopoverViewDelegate, DateTimeViewControllerDelegate>{
    ListViewController *listView;
    NSDictionary *selectedAddress;
    NSDictionary *selectedCard;
    
    int selectedTableIndex;
    
    AppDelegate *appDel;
    
    UIView *view_Popup;
    
    UILabel *lblPromocode;
    
    CustomPopoverView *customPopOverView;
    UIView *view_Tourist;
    float previousAddressYAxis;
    UIButton *backBtn;
    
    UIButton *promocodeBtn;
    
    NSMutableDictionary *dictDeliveryDatesAndTimes;
    NSMutableArray *arraAlldata;
    EGOImageView *cardIconView;

    int numberOfTimesTried;
    
    BOOL automaticDeliveryCalled;
    
}

@property (nonatomic, retain) NSMutableArray *deliveryDates;

@end

@implementation DeliveryViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    numberOfTimesTried = 0;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    dictDeliveryDatesAndTimes = [[NSMutableDictionary alloc]init];
    self.deliveryDates = [[NSMutableArray alloc]init];
    
    arraAlldata = [[NSMutableArray alloc]init];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    
    float yPos = 27*MULTIPLYHEIGHT;;
    
    float ratio = MULTIPLYHEIGHT;
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, CGRectGetWidth(screenBounds), 40.0)];
    
    if (self.isRewashOrder)
    {
        titleLbl.text = @"REWASH ORDER";
    }
    else
    {
        titleLbl.text = @"DELIVERY";
    }
    
    //[appDel spacingForTitle:titleLbl TitleString:string];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor grayColor];
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM];
    [self.view addSubview:titleLbl];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5.0, yPos, 40.0, 40.0);
    [backBtn setImage:[UIImage imageNamed:@"back_grey"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backToPreviousScreen) forControlEvents:UIControlEventTouchUpInside];
    backBtn.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
    [self.view addSubview:backBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(CGRectGetWidth(screenBounds) - 50.0, yPos, 40.0, 40.0);
    [closeBtn setImage:[UIImage imageNamed:@"cancel_grey"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeScheduleScreen:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
    [self.view addSubview:closeBtn];
    
    yPos = 90*ratio;
    
    float xPos = 14.4*MULTIPLYHEIGHT;;
    
    float height = 35*ratio;
    
    {
        UIButton *addressBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        addressBtn.tag = DELIVERY_VIEW_TAG + 2;
        addressBtn.frame = CGRectMake(xPos, yPos, (CGRectGetWidth(screenBounds) - (xPos*2)), height);
        addressBtn.backgroundColor = LIGHT_GRAY_BACKGROUND_COLOR;
        [addressBtn setTitle:@"SILOSO BEACH, SINGAPORE" forState:UIControlStateNormal];
        [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        addressBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        addressBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 35*MULTIPLYHEIGHT, 0.0, 26*MULTIPLYHEIGHT);
        [addressBtn addTarget:self action:@selector(selectDeliveryAddress:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addressBtn];
        [addressBtn setBackgroundImage:[AppDelegate imageWithColor:[[UIColor grayColor]colorWithAlphaComponent:0.2]] forState:UIControlStateHighlighted];
        addressBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        if (!self.isFromCreateOrder)
        {
            NSArray *sortedArray = [[NSMutableArray alloc]initWithArray:self.userAddresses];
            NSPredicate *getDefaultAddPredicate = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", [self.orderInfo objectForKey:ORDER_DELIVERY_ADDRESS_ID]]];
            sortedArray = [sortedArray filteredArrayUsingPredicate:getDefaultAddPredicate];
            
            if ([sortedArray count] > 0)
            {
                selectedAddress = [sortedArray objectAtIndex:0];
            }
            
            NSPredicate *getDefaultAddPredicate1 = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", [self.orderInfo objectForKey:ORDER_CARD_ID]]];
            NSArray *sortedArray1 = [self.userSavedCards filteredArrayUsingPredicate:getDefaultAddPredicate1];
            
            if(sortedArray1.count > 0)
            {
                selectedCard = [sortedArray1 objectAtIndex:0];
            }
        }
        else
        {
            NSArray *sortedArray = [[NSMutableArray alloc]initWithArray:self.userAddresses];
            NSPredicate *getDefaultAddPredicate = [NSPredicate predicateWithFormat:@"_id == %@", [NSString stringWithFormat:@"%@", [self.orderInfo objectForKey:ORDER_PICKUP_ADDRESS_ID]]];
            sortedArray = [sortedArray filteredArrayUsingPredicate:getDefaultAddPredicate];
            
            if ([sortedArray count] > 0)
            {
                selectedAddress = [sortedArray objectAtIndex:0];
            }
            
            NSPredicate *getDefaultAddPredicate1 = [NSPredicate predicateWithFormat:@"default == %d", 1];
            NSArray *sortedArray1 = [self.userSavedCards filteredArrayUsingPredicate:getDefaultAddPredicate1];
            
            if(sortedArray1.count > 0)
            {
                selectedCard = [sortedArray1 objectAtIndex:0];
            }
            else
            {
                selectedCard = [self.userSavedCards objectAtIndex:0];
            }
        }
        
        [addressBtn setTitle:[self setTitleForAddress] forState:UIControlStateNormal];
        
        [self.orderInfo setObject:[selectedCard objectForKey:@"_id"] forKey:ORDER_CARD_ID];
        
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
        
    }
    
    yPos += height+20*MULTIPLYHEIGHT;
    
    {
        UIButton *deliveryDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deliveryDateBtn.tag = DELIVERY_VIEW_TAG + 3;
        deliveryDateBtn.frame = CGRectMake(xPos, yPos, (CGRectGetWidth(screenBounds) - (xPos*2)), height);
        deliveryDateBtn.backgroundColor = LIGHT_GRAY_BACKGROUND_COLOR;
        [deliveryDateBtn addTarget:self action:@selector(selectDeliveryDate:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:deliveryDateBtn];
        [deliveryDateBtn setBackgroundImage:[AppDelegate imageWithColor:[[UIColor grayColor]colorWithAlphaComponent:0.2]] forState:UIControlStateHighlighted];
        
        UILabel *dateLbl = [[UILabel alloc] initWithFrame:CGRectMake(xPos+20*MULTIPLYHEIGHT, 0.0, CGRectGetWidth(deliveryDateBtn.bounds), CGRectGetHeight(deliveryDateBtn.bounds))];
        dateLbl.tag = DELIVERY_VIEW_TAG + 4;
        
        dateLbl.textAlignment = NSTextAlignmentLeft;
        dateLbl.textColor = [UIColor grayColor];
        dateLbl.backgroundColor = [UIColor clearColor];
        dateLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        dateLbl.userInteractionEnabled = NO;
        
        if (!self.isFromCreateOrder && !self.isRewashOrder)
        {
            if ([[self.dictChangedValues objectForKey:ORDER_PICKUP_DATE] isEqualToString:[self.orderInfo objectForKey:ORDER_PICKUP_DATE]] && [[self.dictChangedValues objectForKey:ORDER_TYPE] isEqualToString:[self.orderInfo objectForKey:ORDER_TYPE]] && [[self.dictChangedValues objectForKey:ORDER_JOB_TYPE] isEqualToArray:[self.orderInfo objectForKey:ORDER_JOB_TYPE]])
            {
                dateLbl.attributedText = [self setDeliveryAttributedText];
            }
            else
            {
                if ([self.dictAllowFields count] && [[self.dictAllowFields objectForKey:@"deliveryDate"] intValue] == 1)
                {
                    automaticDeliveryCalled = YES;
                    dateLbl.attributedText = [self setDeliveryAttributedText];
                    [self selectDeliveryDate:deliveryDateBtn];
                }
                
//                [self.orderInfo removeObjectForKey:ORDER_DELIVERY_DATE];
//                [self.orderInfo removeObjectForKey:ORDER_DELIVERY_SLOT];
//                
//                dateLbl.text = @"DELIVERY DATE : TIME";
            }
        }
        else
        {
            dateLbl.text = @"DELIVERY DATE : TIME";
            
            [self.orderInfo removeObjectForKey:ORDER_DELIVERY_DATE];
            [self.orderInfo removeObjectForKey:ORDER_DELIVERY_SLOT];
        }
        
        [deliveryDateBtn addSubview:dateLbl];
        
        UIImageView *locImgView = [[UIImageView alloc] initWithFrame:CGRectMake(xPos, 0.0, 10*MULTIPLYHEIGHT, CGRectGetHeight(deliveryDateBtn.bounds))];
        locImgView.contentMode = UIViewContentModeScaleAspectFit;
        locImgView.image = [UIImage imageNamed:@"pickup_date_time"];
        locImgView.userInteractionEnabled = NO;
        [deliveryDateBtn addSubview:locImgView];
        
        UIImageView *dropDownIconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(deliveryDateBtn.bounds) - (xPos*1.5)), 1.0, 15.0, CGRectGetHeight(deliveryDateBtn.bounds))];
        dropDownIconView.contentMode = UIViewContentModeScaleAspectFit;
        dropDownIconView.image = [UIImage imageNamed:@"down_arrow_gray"];
        dropDownIconView.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
        dropDownIconView.userInteractionEnabled = NO;
        [deliveryDateBtn addSubview:dropDownIconView];
    }
    
    yPos += height+25*MULTIPLYHEIGHT;
    
    {
        UIButton *cardBtnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cardBtnBtn.tag = DELIVERY_VIEW_TAG + 7;
        cardBtnBtn.frame = CGRectMake(xPos, yPos, (CGRectGetWidth(screenBounds) - (xPos*2)), height);
        cardBtnBtn.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        [cardBtnBtn addTarget:self action:@selector(selectDeliveryAddress:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:cardBtnBtn];
        [cardBtnBtn setBackgroundImage:[AppDelegate imageWithColor:[[UIColor grayColor]colorWithAlphaComponent:0.2]] forState:UIControlStateHighlighted];
        
        float ciWidth = 20*MULTIPLYHEIGHT;
        
        cardIconView = [[EGOImageView alloc] initWithFrame:CGRectMake(xPos, 0.0, ciWidth, CGRectGetHeight(cardBtnBtn.bounds))];
        cardIconView.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
        cardIconView.contentMode = UIViewContentModeScaleAspectFit;
        
        if([selectedCard objectForKey:@"cardTypeImage"])
        {
            cardIconView.imageURL = [NSURL URLWithString:[selectedCard objectForKey:@"cardTypeImage"]];
        }
        else
        {
            cardIconView.image = [UIImage imageNamed:@"cash_icon"];
        }
        
        cardIconView.userInteractionEnabled = NO;
        [cardBtnBtn addSubview:cardIconView];
        
        UILabel *lblCard = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetMaxX(cardIconView.frame) + 10.0), 0.0, CGRectGetWidth(cardBtnBtn.bounds), CGRectGetHeight(cardBtnBtn.bounds))];
        lblCard.tag = DELIVERY_VIEW_TAG + 8;
        lblCard.text = [selectedCard objectForKey:@"maskedCardNo"];
        lblCard.textAlignment = NSTextAlignmentLeft;
        lblCard.textColor = [UIColor grayColor];
        lblCard.backgroundColor = [UIColor clearColor];
        lblCard.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        lblCard.userInteractionEnabled = NO;
        [cardBtnBtn addSubview:lblCard];
        
        UIImageView *dropDownIconView = [[UIImageView alloc] initWithFrame:CGRectMake((CGRectGetWidth(cardBtnBtn.bounds) - (xPos*1.5)), 0.0, 10*MULTIPLYHEIGHT, CGRectGetHeight(cardBtnBtn.bounds))];
        dropDownIconView.contentMode = UIViewContentModeScaleAspectFit;
        dropDownIconView.image = [UIImage imageNamed:@"edit_icon"];
        dropDownIconView.backgroundColor = PLACE_HOLDER_COLOR_INSTEAD_IMAGE;
        dropDownIconView.userInteractionEnabled = NO;
        [cardBtnBtn addSubview:dropDownIconView];
    }
    
    yPos += height + 20*MULTIPLYHEIGHT;
    
    if (self.isFromCreateOrder)
    {
        promocodeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        promocodeBtn.frame = CGRectMake(xPos, yPos, (CGRectGetWidth(screenBounds) - (xPos*2)), height);
        promocodeBtn.backgroundColor = [UIColor clearColor];
        [promocodeBtn setBackgroundImage:[UIImage imageNamed:@"promocode_bg"] forState:UIControlStateNormal];
        [promocodeBtn addTarget:self action:@selector(selectPromocode:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:promocodeBtn];
        [promocodeBtn setImage:[UIImage imageNamed:@"promocode_icon"] forState:UIControlStateNormal];
        promocodeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        float leftEdge = 36*MULTIPLYHEIGHT;
        promocodeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, leftEdge, 0, 0);
        
        
        lblPromocode = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.0, CGRectGetWidth(promocodeBtn.bounds), CGRectGetHeight(promocodeBtn.bounds))];
        lblPromocode.text = @"ENTER PROMO CODE";
        lblPromocode.textAlignment = NSTextAlignmentCenter;
        lblPromocode.textColor = BLUE_COLOR;
        lblPromocode.backgroundColor = [UIColor clearColor];
        lblPromocode.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-3];
        lblPromocode.userInteractionEnabled = NO;
        [promocodeBtn addSubview:lblPromocode];
        
        yPos += height + 20*MULTIPLYHEIGHT;
    }
    
    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmBtn.frame = CGRectMake(xPos, yPos, screen_width - (xPos*2), height);
    confirmBtn.backgroundColor = APPLE_BLUE_COLOR;
    
    if (!self.isFromCreateOrder)
    {
        if (self.isRewashOrder)
        {
            [confirmBtn setAttributedTitle:[[WebserviceMethods sharedWebRequest] getAttributedStringWithSpacing:[@"CONFIRM REWASH" uppercaseString] andWithColor:[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:241.0/255.0 alpha:1.0] andFont:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE-2]] forState:UIControlStateNormal];
        }
        else
        {
            [confirmBtn setAttributedTitle:[[WebserviceMethods sharedWebRequest] getAttributedStringWithSpacing:[@"UPDATE ORDER" uppercaseString] andWithColor:[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:241.0/255.0 alpha:1.0] andFont:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE-2]] forState:UIControlStateNormal];
        }
    }
    else
    {
        [confirmBtn setAttributedTitle:[[WebserviceMethods sharedWebRequest] getAttributedStringWithSpacing:[@"PIING!" uppercaseString] andWithColor:[UIColor colorWithRed:240.0/255.0 green:242.0/255.0 blue:241.0/255.0 alpha:1.0] andFont:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE-2]] forState:UIControlStateNormal];
    }
    
    [confirmBtn addTarget:self action:@selector(confirmPiing:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    [confirmBtn setBackgroundImage:[AppDelegate imageWithColor:BLUE_COLOR_HIGHLITED] forState:UIControlStateHighlighted];
    
//    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, screen_width/2, 2.0)];
//    progressView.backgroundColor = APPLE_BLUE_COLOR;
//    [self.view addSubview:progressView];
//    
//    [UIView animateWithDuration:0.3 delay:0.2 options:0 animations:^{
//        
//        progressView.frame = CGRectMake(0, 0.0, screen_width, 2.0);
//        
//    } completion:^(BOOL finished) {
//        
//    }];

    listView = (ListViewController *)appDel.sideMenuViewController.rightMenuViewController;
    listView.delegate = self;
//    {
//        NSMutableArray *list = [NSMutableArray arrayWithCapacity:0];
//        for (int i=0; i<10; i++) {
//            
//            Item *obj = [[Item alloc] init];
//            obj.name = @"6:00 - 7:00 am";
//            obj.isSelected = NO;
//            [list addObject:obj];
//            
//        }
//        listView.itemList = nil;
//    }
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    self.navigationController.parentViewController.navigationController.navigationBarHidden = YES;
}

-(NSMutableAttributedString *) setDeliveryAttributedText
{
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"dd-MM-yyyy"];
    
    NSDate *date = [dtFormatter dateFromString:[self.orderInfo objectForKey:ORDER_DELIVERY_DATE]];
    
    [dtFormatter setDateFormat:@"dd MMM, EEE"];
    
    NSString *strDate = [dtFormatter stringFromDate:date];
    
    NSString *str1 = @"DELIVERY ";
    NSString *str2 = [[NSString stringWithFormat:@"%@ : %@", strDate, [self.orderInfo objectForKey:ORDER_DELIVERY_SLOT]]uppercaseString];
    
    NSString *strTotal = [NSString stringWithFormat:@"%@ %@", str1, str2];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:strTotal];
    
    [attrStr addAttributes:@{NSFontAttributeName : [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2], NSForegroundColorAttributeName : [UIColor grayColor]} range:NSMakeRange(0, str1.length)];
    
    [attrStr addAttributes:@{NSFontAttributeName : [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2], NSForegroundColorAttributeName : BLUE_COLOR} range:NSMakeRange(str1.length+1, str2.length)];
    
    float spacing = 0.5f;
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

-(void) selectPromocode:(UIButton *) sender
{
    if (self.isDeliveryOrder)
    {
        [appDel showAlertWithMessage:@"Promocode is not editable by Piingo" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    view_Popup = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    //view_Popup.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    [self.view addSubview:view_Popup];
    view_Popup.alpha = 0.0;
    [appDel applyBlurEffectForView:view_Popup Style:BLUR_EFFECT_STYLE_DARK];
    
    
    float vtX = 12*MULTIPLYHEIGHT;
    
    view_Tourist = [[UIView alloc]initWithFrame:CGRectMake(vtX, 0, screen_width-(vtX*2), 190)];
    view_Tourist.backgroundColor = [UIColor clearColor];
    view_Tourist.center = CGPointMake(view_Popup.frame.size.width/2, view_Popup.frame.size.height/2);
    [view_Popup addSubview:view_Tourist];
    view_Tourist.tag = REDEEM_VIEW_TAG;
    
    
    UIView *view_Top = [[UIView alloc]initWithFrame:CGRectMake(vtX, vtX, view_Tourist.frame.size.width-(vtX*2), view_Tourist.frame.size.height-(vtX*2))];
    view_Top.backgroundColor = [UIColor clearColor];
    view_Top.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view_Tourist addSubview:view_Top];
    view_Top.layer.cornerRadius = 5.0;
    view_Top.layer.masksToBounds = YES;
    view_Top.center = CGPointMake(view_Tourist.frame.size.width/2, view_Tourist.frame.size.height/2);
    [appDel applyBlurEffectForView:view_Top Style:BLUR_EFFECT_STYLE_EXTRA_LIGHT];
    
    
    float viewWidth = view_Tourist.frame.size.width;
    
    
    float piingiconHeight = 45*MULTIPLYHEIGHT;
    
    UIImageView *imgPiing = [[UIImageView alloc]init];
    imgPiing.image = [UIImage imageNamed:@"Piing_icon_reg"];
    imgPiing.backgroundColor = [UIColor clearColor];
    [view_Tourist addSubview:imgPiing];
    imgPiing.contentMode = UIViewContentModeScaleAspectFit;
    imgPiing.frame = CGRectMake(0, 0, piingiconHeight, piingiconHeight);
    imgPiing.center = CGPointMake(view_Tourist.frame.size.width/2, vtX);
    
    float closeHeight = 33*MULTIPLYHEIGHT;
    
    UIButton *closePCBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closePCBtn.tag = REDEEM_VIEW_TAG + 1;
    closePCBtn.frame = CGRectMake(viewWidth-closeHeight, 0.0, closeHeight, closeHeight);
    closePCBtn.center = CGPointMake(vtX, vtX);
    [closePCBtn setImage:[UIImage imageNamed:@"cancel_popup"] forState:UIControlStateNormal];
    [closePCBtn addTarget:self action:@selector(closePopupScreen) forControlEvents:UIControlEventTouchUpInside];
    [view_Tourist addSubview:closePCBtn];
    
    
    float yAxis = piingiconHeight/2+(10*MULTIPLYHEIGHT);
    
    UILabel *LblTourist = [[UILabel alloc] initWithFrame:CGRectMake(0, yAxis, view_Tourist.frame.size.width, 40)];
    LblTourist.text = @"REDEEM CODE";
    LblTourist.tag = REDEEM_VIEW_TAG + 2;
    LblTourist.textAlignment = NSTextAlignmentCenter;
    LblTourist.textColor = [UIColor colorFromHexString:@"#585858"];
    LblTourist.backgroundColor = [UIColor clearColor];
    LblTourist.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE-2];
    [view_Tourist addSubview:LblTourist];
    
    CGSize lblSize = [AppDelegate getLabelSizeForBoldText:LblTourist.text WithWidth:viewWidth-40 FontSize:LblTourist.font.pointSize];
    
    CGRect frameLbl = LblTourist.frame;
    frameLbl.size.height = lblSize.height+(10*MULTIPLYHEIGHT);
    LblTourist.frame = frameLbl;
    
    yAxis += frameLbl.size.height;
    
    UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(((viewWidth)/2)-(lblSize.width/2), yAxis, lblSize.width, 1)];
    imgLine.tag = REDEEM_VIEW_TAG + 10;
    imgLine.backgroundColor = [UIColor lightGrayColor];
    [view_Tourist addSubview:imgLine];
    
    yAxis += 10*MULTIPLYHEIGHT;
    
    float imgX = 36*MULTIPLYHEIGHT;
    
    UILabel *lblError = [[UILabel alloc]initWithFrame:CGRectMake(imgX, yAxis-10, view_Tourist.frame.size.width-(imgX*2), 50)];
    lblError.tag = REDEEM_VIEW_TAG + 7;
    lblError.numberOfLines = 3;
    lblError.textAlignment = NSTextAlignmentCenter;
    lblError.textColor = [UIColor redColor];
    lblError.backgroundColor = [UIColor clearColor];
    lblError.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
    [view_Tourist addSubview:lblError];
    lblError.hidden = YES;
    
    
    UITextField *tfPC = [[UITextField alloc]initWithFrame:CGRectMake(imgX, yAxis, view_Tourist.frame.size.width-(imgX*2), 40)];
    UIColor *color = APPLE_BLUE_COLOR;
    tfPC.delegate = self;
    tfPC.tag = REDEEM_VIEW_TAG + 3;
    tfPC.textAlignment = NSTextAlignmentCenter;
    //tfPC.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    tfPC.textColor = APPLE_BLUE_COLOR;
    tfPC.backgroundColor = [UIColor clearColor];
    tfPC.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM+1];
    [view_Tourist addSubview:tfPC];
    tfPC.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter promo code" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4]}];
    [tfPC becomeFirstResponder];
    
    CALayer *bottomLayer = [[CALayer alloc]init];
    bottomLayer.backgroundColor = [UIColor lightGrayColor].CGColor;
    bottomLayer.frame = CGRectMake(imgX, tfPC.frame.size.height-1, tfPC.frame.size.width-imgX*2, 1);
    [tfPC.layer addSublayer:bottomLayer];
    
    float imgWidth = 40*MULTIPLYHEIGHT;
    
    UIImageView *imgPic = [[UIImageView alloc]initWithFrame:CGRectMake(view_Tourist.frame.size.width/2-(imgWidth/2), yAxis+5, imgWidth, imgWidth)];
    imgPic.backgroundColor = [UIColor clearColor];
    imgPic.contentMode = UIViewContentModeScaleAspectFit;
    imgPic.image = [UIImage imageNamed:@"gift_box"];
    //imgPic.image = [UIImage imageNamed:@"shirt_icon"];
    imgPic.tag = REDEEM_VIEW_TAG + 6;
    [view_Tourist addSubview:imgPic];
    imgPic.hidden = YES;
    
    
    yAxis += imgWidth+10;
    
    float lblDiscountHeight = 20*MULTIPLYHEIGHT;
    
    UILabel *LblDiscount = [[UILabel alloc] initWithFrame:CGRectMake(imgX, yAxis, view_Tourist.frame.size.width-(imgX*2), lblDiscountHeight)];
    LblDiscount.text = @"";
    LblDiscount.numberOfLines = 0;
    LblDiscount.tag = REDEEM_VIEW_TAG + 5;
    LblDiscount.textAlignment = NSTextAlignmentCenter;
    LblDiscount.textColor = [UIColor grayColor];
    LblDiscount.backgroundColor = [UIColor clearColor];
    LblDiscount.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
    [view_Tourist addSubview:LblDiscount];
    LblDiscount.hidden = YES;
    
    
    float btnHeight = 25*MULTIPLYHEIGHT;
    
    UIButton *btnYes = [UIButton buttonWithType:UIButtonTypeCustom];
    btnYes.frame = CGRectMake(imgX, yAxis-(10*MULTIPLYHEIGHT), view_Tourist.frame.size.width-(imgX*2), btnHeight);
    btnYes.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE-2];
    [btnYes setTitle:@"REDEEM" forState:UIControlStateNormal];
    btnYes.tag = REDEEM_VIEW_TAG + 4;
    [btnYes setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnYes.backgroundColor = APPLE_BLUE_COLOR;
    [btnYes addTarget:self action:@selector(btnSubmitClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view_Tourist addSubview:btnYes];
    [btnYes setBackgroundImage:[AppDelegate imageWithColor:BLUE_COLOR_HIGHLITED] forState:UIControlStateHighlighted];
    
    
    yAxis += btnHeight+5*MULTIPLYHEIGHT+vtX;
    
    CGRect frameView = view_Tourist.frame;
    frameView.size.height = yAxis;
    view_Tourist.frame = frameView;
    
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        
        view_Popup.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        
    }];
    
}
-(void) btnSubmitClicked:(UIButton *) sender
{
    [self.view endEditing:YES];
    
    UIView *view_UnderPopup = (UIView *) [view_Popup viewWithTag:REDEEM_VIEW_TAG];
    //UIButton *btnClose = (UIButton *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+1];
    UILabel *lblTitle = (UILabel *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+2];
    UITextField *tfPC = (UITextField *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+3];
    UILabel *lblError = (UILabel *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+7];
    UIButton *btnSubmit = (UIButton *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+4];
    UILabel *lblDiscount = (UILabel *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+5];
    UIImageView *imgPic = (UIImageView *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+6];
    UIImageView *imgLine = (UIImageView *) [view_UnderPopup viewWithTag:REDEEM_VIEW_TAG+10];
    
    if (![tfPC.text length])
    {
        [appDel showAlertWithMessage:@"Please enter promo code" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    NSMutableDictionary *detailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", [self.orderInfo objectForKey:ORDER_USER_ID], @"userId", tfPC.text, @"promoCode", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/promo/check", BASE_URL];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:detailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
            
            [self.orderInfo setObject:[responseObj objectForKey:@"code"] forKey:PROMO_CODE];
            
            lblError.hidden = YES;
            
            //btnClose.hidden = YES;
            btnSubmit.hidden = YES;
            tfPC.hidden = YES;
            lblTitle.text = @"CONGRATULATIONS!";
            lblDiscount.hidden = NO;
            imgPic.hidden = NO;
            
            CGSize lblSize = [AppDelegate getLabelSizeForBoldText:lblTitle.text WithWidth:lblTitle.frame.size.width FontSize:lblTitle.font.pointSize];
            
            imgLine.frame = CGRectMake(((view_UnderPopup.frame.size.width)/2)-(lblSize.width/2), imgLine.frame.origin.y, lblSize.width, 1);
            
            lblPromocode.text = [responseObj objectForKey:@"desc"];
            lblDiscount.text = [responseObj objectForKey:@"desc"];
            
            float leftEdge = 28*MULTIPLYHEIGHT;
            promocodeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, leftEdge, 0, 0);
            
            [UIView animateKeyframesWithDuration:0.3 delay:3.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^
             {
                 view_Popup.alpha = 0.0;
                 
             } completion:^(BOOL finished) {
                 
                 [view_Popup removeFromSuperview];
                 view_Popup = nil;
                 
             }];
        }
        else {
            
            lblPromocode.text = @"ENTER PROMO CODE";
            [self.orderInfo setObject:@"" forKey:PROMO_CODE];
            
            lblError.text = [responseObj objectForKey:@"error"];
            
            lblError.hidden = NO;
            
            tfPC.text = @"";
            UIColor *color = [UIColor redColor];
            tfPC.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-3]}];
        }
        
    }];
}

-(void) closePopupScreen
{
    [self.view endEditing:YES];
    
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        
        view_Popup.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [view_Popup removeFromSuperview];
        view_Popup = nil;
    }];
}


-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        
        view_Tourist.center = CGPointMake(view_Popup.frame.size.width/2, view_Popup.frame.size.height/3);
        
    } completion:^(BOOL finished) {
        
    }];
    
    UILabel *lblError = (UILabel *) [view_Tourist viewWithTag:REDEEM_VIEW_TAG+7];
    lblError.hidden = YES;
    
    textField.text = @"";
    UIColor *color = APPLE_BLUE_COLOR;
    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Enter promo code" attributes:@{NSForegroundColorAttributeName: color, NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-3]}];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateKeyframesWithDuration:0.3 delay:0.0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        
        view_Tourist.center = CGPointMake(view_Popup.frame.size.width/2, view_Popup.frame.size.height/2);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - action event handlers

- (void)confirmPiing:(UIButton *)sender {
    
    
    [self.orderInfo setObject:[selectedAddress objectForKey:@"_id"] forKey:ORDER_DELIVERY_ADDRESS_ID];
    
    if([self.orderInfo objectForKey:ORDER_DELIVERY_DATE] && [self.orderInfo objectForKey:ORDER_DELIVERY_SLOT]){
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        if ([[self.orderInfo objectForKey:ORDER_JOB_TYPE] isKindOfClass:[NSArray class]])
        {
            NSArray *arrayServiceType = [self.orderInfo objectForKey:ORDER_JOB_TYPE];
            
            NSString *strJobType = @"";
            
            for (int i = 0; i < [arrayServiceType count]; i++)
            {
                strJobType = [strJobType stringByAppendingString:[NSString stringWithFormat:@"%@,", [arrayServiceType objectAtIndex:i]]];
            }
            
            if ([strJobType hasSuffix:@","])
            {
                strJobType = [strJobType substringToIndex:[strJobType length]-1];
            }
            
            [self.orderInfo setObject:strJobType forKey:ORDER_JOB_TYPE];
        }
        
        NSString *urlStr;
        
        if (self.isRewashOrder || self.isFromCreateOrder)
        {
            urlStr = [NSString stringWithFormat:@"%@piingoapp/order/book", BASE_URL];
        }
        else
        {
            urlStr = [NSString stringWithFormat:@"%@piingoapp/order/update", BASE_URL];
        }
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:self.orderInfo andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
            {
                
                if (self.isFromCreateOrder)
                {
                    [self.orderInfo setObject:[[responseObj objectForKey:@"em"] objectForKey:ORDER_PICKUP_SLOT] forKey:ORDER_PICKUP_SLOT];
                    
                    [self.orderInfo setObject:[[responseObj objectForKey:@"em"] objectForKey:@"oid"] forKey:@"oid"];
                    
                    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/update", BASE_URL];
                    
                    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:self.orderInfo andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
                        
                        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                        
                        if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
                        {
                            
                        }
                        else {
                            
                            if ([[responseObj objectForKey:@"s"] intValue] == 0)
                            {
                                [self updateOrderAgain];
                            }
                            else
                            {
                                [appDel displayErrorMessagErrorResponse:responseObj];
                            }
                        }
                    }];
                }
                
                else
                {
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    UIAlertController * alert=   [UIAlertController
                                                  alertControllerWithTitle:@""
                                                  message:@"Order Updated successfully"
                                                  preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction
                                         actionWithTitle:@"OK"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             NSArray *arrayVC = self.navigationController.viewControllers;
                                             
                                             for (id VC in arrayVC)
                                             {
                                                 if ([VC isKindOfClass:[ScheduleLaterViewController1 class]])
                                                 {
                                                     ScheduleLaterViewController1 *scheduleVC = (ScheduleLaterViewController1 *) VC;
                                                     
                                                     [UIView animateWithDuration:0.3 animations:^{
                                                         
                                                         scheduleVC.navigationController.view.frame = CGRectMake(0.0, screen_height, screen_width, screen_height);
                                                         
                                                     } completion:^(BOOL finished) {
                                                         
                                                         [scheduleVC.navigationController.parentViewController viewWillAppear:YES];
                                                         [scheduleVC.navigationController.view removeFromSuperview];
                                                         
                                                         JobdetailViewController *obj = (JobdetailViewController *) scheduleVC.navigationController.parentViewController;
                                                         
                                                         [obj updatedOrderAndRefresh];
                                                     }];
                                                 }
                                             }
                                         }];
                    
                    [alert addAction:ok];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            }
            else {
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
            
        }];
        
    }
    else {
        if (![self.orderInfo objectForKey:ORDER_DELIVERY_DATE]) {
            
            [appDel showAlertWithMessage:@"Please select Delivery Date" andTitle:@"Error" andBtnTitle:@"OK"];
            
        }
        else if (![self.orderInfo objectForKey:ORDER_DELIVERY_SLOT]) {
            
            [appDel showAlertWithMessage:@"Please select Delivery Timeslot" andTitle:@"Error" andBtnTitle:@"OK"];
            
        }
    }
}


-(void) updateOrderAgain
{
    numberOfTimesTried ++;
    
    if (numberOfTimesTried <= 2)
    {
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/update", BASE_URL];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:self.orderInfo andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
            {
                
            }
            else {
                
                if ([[responseObj objectForKey:@"s"] intValue] == 0)
                {
                    [self updateOrderAgain];
                }
                else
                {
                    [appDel displayErrorMessagErrorResponse:responseObj];
                }
            }
        }];
    }
    else
    {
        [appDel showAlertWithMessage:@"Oops! Something tore. We are working on it right now. Please check back." andTitle:@"" andBtnTitle:@"OK"];
    }
}


- (void)selectDeliveryAddress:(UIButton *)sender {
    
    UIButton *addressBtn = (UIButton *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 2];
    
    UIButton *cardBtn = (UIButton *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 7];
    UILabel *lblCard = (UILabel *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 8];
    
    if (addressBtn == sender)
    {
        if (self.isDeliveryOrder)
        {
            [appDel showAlertWithMessage:@"Delivery address is not editable by Piingo" andTitle:@"" andBtnTitle:@"OK"];
            
            return;
        }
        
        if (!self.isFromCreateOrder)
        {
            if ([self.dictAllowFields count] && [[self.dictAllowFields objectForKey:@"deliveryAddress"] intValue] == 0)
            {
                [appDel showAlertWithMessage:@"You can't update delivery address now." andTitle:@"" andBtnTitle:@"OK"];
                return;
            }
        }
    }
    
    if (sender.selected)
    {
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
                
                backBtn.hidden = NO;
                
                [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                
            }];
        }
        else if ([cardBtn isSelected])
        {
            [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
                
                customPopOverView.alpha = 0.0;
                
                CGRect frame = cardBtn.frame;
                frame.origin.y = previousAddressYAxis;
                cardBtn.frame = frame;
                
                
            } completion:^(BOOL finished) {
                
                [customPopOverView removeFromSuperview];
                customPopOverView = nil;
                
                cardBtn.selected = NO;
                
                backBtn.hidden = NO;
                
                lblCard.textColor = [UIColor grayColor];
                
            }];
        }
        
        return;
    }
    
    sender.selected = YES;
    
    backBtn.hidden = YES;
    
    
    if (addressBtn == sender)
    {
        previousAddressYAxis = addressBtn.frame.origin.y;
        
        customPopOverView = [[CustomPopoverView alloc]initWithArray:self.userAddresses IsAddressType:YES];
    }
    else if (cardBtn == sender)
    {
        previousAddressYAxis = cardBtn.frame.origin.y;
        
        customPopOverView = [[CustomPopoverView alloc]initWithArray:self.userSavedCards IsPaymentType:YES];
    }
    
    customPopOverView.isFromTag = 1;
    customPopOverView.delegate = self;
    [self.view addSubview:customPopOverView];
    customPopOverView.alpha = 0.0;
    
    int yVal = 70*MULTIPLYHEIGHT;
    
    customPopOverView.frame = CGRectMake(0, yVal+addressBtn.frame.size.height, screen_width, screen_height-(yVal+addressBtn.frame.size.height));
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        
        customPopOverView.alpha = 1.0;
        
        if (addressBtn == sender)
        {
            CGRect frame = addressBtn.frame;
            frame.origin.y = yVal;
            addressBtn.frame = frame;
        }
        else if (cardBtn == sender)
        {
            CGRect frame = cardBtn.frame;
            frame.origin.y = yVal;
            cardBtn.frame = frame;
        }
        
        
        
    } completion:^(BOOL finished) {
        
        if (addressBtn == sender)
        {
            [addressBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        else if (cardBtn == sender)
        {
            lblCard.textColor = [UIColor darkGrayColor];
        }
        
    }];
    
}

#pragma mark FPPopover Delegate Method
-(void) didSelectFromList:(NSString *) string AtIndex:(NSInteger)row
{
    UIButton *addressBtn = (UIButton *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 2];
    
    UIButton *cardBtn = (UIButton *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 7];
    UILabel *lblCard = (UILabel *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 8];
    
    [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
        
        customPopOverView.alpha = 0.0;
        
        if (addressBtn.selected)
        {
            CGRect frame = addressBtn.frame;
            frame.origin.y = previousAddressYAxis;
            addressBtn.frame = frame;
        }
        else if (cardBtn.selected)
        {
            CGRect frame = cardBtn.frame;
            frame.origin.y = previousAddressYAxis;
            cardBtn.frame = frame;
        }
        
        
    } completion:^(BOOL finished) {
        
        [customPopOverView removeFromSuperview];
        customPopOverView = nil;
        
    }];
    
    
    if (addressBtn.selected)
    {
        selectedAddress = [self.userAddresses objectAtIndex:row];
        
        if (![[addressBtn titleForState:UIControlStateNormal] isEqualToString:string])
        {
            UILabel *deliveryDateLbl = (UILabel *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 4];
            
            [self.orderInfo removeObjectForKey:ORDER_DELIVERY_DATE];
            [self.orderInfo removeObjectForKey:ORDER_DELIVERY_SLOT];
            
            deliveryDateLbl.text = @"DELIVERY DATE : TIME";
        }
        
        [addressBtn setTitle:string forState:UIControlStateNormal];
        [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        addressBtn.selected = NO;
        backBtn.hidden = NO;
    }
    
    else if (cardBtn.selected)
    {
        cardBtn.selected = NO;
        backBtn.hidden = NO;
        
        selectedCard = [self.userSavedCards objectAtIndex:row];
        
        if([selectedCard objectForKey:@"cardTypeImage"])
        {
            cardIconView.imageURL = [NSURL URLWithString:[selectedCard objectForKey:@"cardTypeImage"]];
        }
        else
        {
            cardIconView.image = [UIImage imageNamed:@"cash_icon"];
        }
        
        lblCard.text = [selectedCard objectForKey:@"maskedCardNo"];
        lblCard.textColor = [UIColor grayColor];
        
        [self.orderInfo setObject:[selectedCard objectForKey:@"_id"] forKey:ORDER_CARD_ID];
    }
}

- (void)backToPreviousScreen
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)closeScheduleScreen:(UIButton *)sender {
    
    UIButton *addressBtn = (UIButton *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 2];
    
    UIButton *cardBtn = (UIButton *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 7];
    UILabel *lblCard = (UILabel *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 8];
    
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
            
            backBtn.hidden = NO;
            
            [addressBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            
        }];
    }
    else if ([cardBtn isSelected])
    {
        [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
            
            customPopOverView.alpha = 0.0;
            
            CGRect frame = cardBtn.frame;
            frame.origin.y = previousAddressYAxis;
            cardBtn.frame = frame;
            
            
        } completion:^(BOOL finished) {
            
            [customPopOverView removeFromSuperview];
            customPopOverView = nil;
            
            cardBtn.selected = NO;
            
            backBtn.hidden = NO;
            
            lblCard.textColor = [UIColor grayColor];
            
        }];
    }
    else
    {
        if (self.isFromCreateOrder)
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            NSArray *arrayVC = self.navigationController.viewControllers;
            
            for (id VC in arrayVC)
            {
                if ([VC isKindOfClass:[ScheduleLaterViewController1 class]])
                {
                    ScheduleLaterViewController1 *scheduleVC = (ScheduleLaterViewController1 *) VC;
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        
                        scheduleVC.navigationController.view.frame = CGRectMake(0.0, screen_height, screen_width, screen_height);
                        
                    } completion:^(BOOL finished) {
                        
                        [scheduleVC.navigationController.parentViewController viewWillAppear:YES];
                        [scheduleVC.navigationController.view removeFromSuperview];
                        
                    }];
                }
            }
        }
    }
    
}

-(void) clickedOnDeliverydate
{
    if (![self.deliveryDates count])
    {
        [appDel showAlertWithMessage:@"No delivery dates available for selected pickup date." andTitle:@"" andBtnTitle:@"OK"];
        return;
    }
    
    NSMutableArray *list = nil;
    
    NSDateFormatter *dtFormatter = [[NSDateFormatter alloc] init];
    [dtFormatter setDateFormat:@"dd-MM-yyyy"];
    
    list = [NSMutableArray arrayWithCapacity:0];
    NSArray *givenList = arraAlldata;
    
    NSDateFormatter *toDtFormatter = [[NSDateFormatter alloc] init];
    [toDtFormatter setDateFormat:@"dd MMM, EEE"];
    
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
    
    if (![self.deliveryDates count])
    {
        [appDel showAlertWithMessage:@"Delivery dates are not available at this time." andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    DateTimeViewController *objDt = [[DateTimeViewController alloc]init];
    
    objDt.isFromDelivery = YES;
    
    objDt.delegate = self;
    objDt.dictAllowFields = [[NSMutableDictionary alloc]initWithDictionary:self.dictAllowFields];
    objDt.arrayDates = [[NSMutableArray alloc]initWithArray:list];
    objDt.selectedAddress = [[NSMutableDictionary alloc]initWithDictionary:selectedAddress];
    objDt.orderInfo = [[NSMutableDictionary alloc]initWithDictionary:self.orderInfo];
    
    objDt.dictDatesAndTimes = [[NSMutableDictionary alloc]initWithDictionary:dictDeliveryDatesAndTimes];
    
    objDt.selectedDate = [self.orderInfo objectForKey:ORDER_DELIVERY_DATE];
    objDt.strSelectedTimeSlot = [self.orderInfo objectForKey:ORDER_DELIVERY_SLOT];
    
    [self presentViewController:objDt animated:YES completion:nil];
}

- (void)selectDeliveryDate:(UIButton *)sender
{
    if (self.isDeliveryOrder)
    {
        [appDel showAlertWithMessage:@"Delivery date is not editable by Piingo" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    if (!self.isFromCreateOrder)
    {
        if ([self.dictAllowFields count] && [[self.dictAllowFields objectForKey:@"deliveryDate"] intValue] == 0)
        {
            [appDel showAlertWithMessage:@"You can't update delivery date now." andTitle:@"" andBtnTitle:@"OK"];
            return;
        }
    }
    
    [self fetchDeliveryDates];
}

-(void) didSelectDateAndTime:(NSArray *)array
{
    [self.orderInfo setObject:[array objectAtIndex:0] forKey:ORDER_DELIVERY_DATE];
    [self.orderInfo setObject:[array objectAtIndex:1] forKey:ORDER_DELIVERY_SLOT];
    
    UILabel *deliveryDateLbl = (UILabel *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 4];
    
    deliveryDateLbl.attributedText = [self setDeliveryAttributedText];
}


- (void)fetchDeliveryDates
{
    NSMutableDictionary *detailsDic;
    
    if (self.isFromCreateOrder)
    {
        NSString *pickUDate = [self.orderInfo objectForKey:ORDER_PICKUP_DATE];
        
        detailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self.orderInfo objectForKey:ORDER_USER_ID], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", [selectedAddress objectForKey:@"_id"], @"deliveryAddressId", [self.orderInfo objectForKey:ORDER_JOB_TYPE], @"serviceTypes", pickUDate, @"pickUpDate", [self.orderInfo objectForKey:ORDER_TYPE], @"orderSpeed", [self.orderInfo objectForKey:ORDER_FROM], @"orderType", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", nil];
    }
    else
    {
        NSString *pickUDate = [self.orderInfo objectForKey:ORDER_PICKUP_DATE];
        NSString *pickUSlot = [self.orderInfo objectForKey:ORDER_PICKUP_SLOT];
        
        detailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[self.orderInfo objectForKey:ORDER_USER_ID], @"userId", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", [selectedAddress objectForKey:@"_id"], @"deliveryAddressId", [self.orderInfo objectForKey:ORDER_JOB_TYPE], @"serviceTypes", pickUDate, @"pickUpDate", pickUSlot, @"pickUpSlotId", [self.orderInfo objectForKey:ORDER_TYPE], @"orderSpeed", [self.orderInfo objectForKey:ORDER_FROM], @"orderType", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [self.orderInfo objectForKey:@"oid"], @"oid", [self.arrayAllOrderDetails objectForKey:@"dpid"], @"dpid", nil];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/deliverydates", BASE_URL];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:detailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
            
            [arraAlldata removeAllObjects];
            [self.deliveryDates removeAllObjects];
            [dictDeliveryDatesAndTimes removeAllObjects];
            
            [arraAlldata addObjectsFromArray:[responseObj objectForKey:@"dates"]];
            
            BOOL deliveryDateFound = NO;
            
            for (int i = 0; i < [arraAlldata count]; i++)
            {
                [self.deliveryDates addObject:[[arraAlldata objectAtIndex:i]objectForKey:@"date"]];
                
                [dictDeliveryDatesAndTimes setObject:[[arraAlldata objectAtIndex:i]objectForKey:@"slots"] forKey:[[arraAlldata objectAtIndex:i]objectForKey:@"date"]];
                
                if ([[[arraAlldata objectAtIndex:i]objectForKey:@"date"] isEqualToString:[self.orderInfo objectForKey:ORDER_DELIVERY_DATE]])
                {
                    deliveryDateFound = YES;
                }
            }
            
            if (automaticDeliveryCalled)
            {
                automaticDeliveryCalled = NO;
                
                if (!deliveryDateFound)
                {
                    [self.orderInfo removeObjectForKey:ORDER_DELIVERY_DATE];
                    [self.orderInfo removeObjectForKey:ORDER_DELIVERY_SLOT];
                    
                    UILabel *deliveryDateLbl = (UILabel *)[self.view viewWithTag:DELIVERY_VIEW_TAG + 4];
                    deliveryDateLbl.text = @"DELIVERY DATE : TIME";
                }
                
                return;
            }
            
            [self clickedOnDeliverydate];
        }
        else {
            
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
