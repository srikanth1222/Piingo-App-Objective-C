//
//  JobOrderTableViewCell.m
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "JobOrderTableViewCell.h"
#import "NSNull+JSON.h"

@implementation JobOrderTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) delegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cellBg = [[UIImageView alloc] initWithFrame:CGRectMake(14.0, 0, screen_width-28, 165)];
        cellBg.layer.cornerRadius = 2.0;
        cellBg.clipsToBounds = YES;
        UIImage *bgImage = [UIImage imageNamed:@"cell_bg"];
        bgImage = [bgImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];

        cellBg.image = bgImage;
        cellBg.userInteractionEnabled = YES;
        
        UIImageView *slotCloctImgV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15.0, 15, 18)];
        slotCloctImgV.image = [UIImage imageNamed:@"time_icon"];
        [cellBg addSubview:slotCloctImgV];
        
        
        lblBookBow = [[UILabel alloc] initWithFrame:CGRectMake(cellBg.frame.size.width - 15-20, 16, 16.0, 16.0)];
        lblBookBow.layer.cornerRadius = 8.0;
        lblBookBow.text = @"B";
        lblBookBow.textAlignment = NSTextAlignmentCenter;
        lblBookBow.font = [UIFont fontWithName:APPFONT_MEDIUM size:12.0];
        lblBookBow.layer.borderWidth = 0.0;
        lblBookBow.layer.borderColor = [UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0].CGColor;
        lblBookBow.textColor = [UIColor blackColor];
        lblBookBow.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        lblBookBow.clipsToBounds = YES;
        [cellBg addSubview:lblBookBow];
        
        
        orderTypeLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellBg.frame.size.width - 15-20, 40, 16.0, 16.0)];
        orderTypeLbl.layer.cornerRadius = 8.0;
        orderTypeLbl.text = @"P";
        orderTypeLbl.textAlignment = NSTextAlignmentCenter;
        orderTypeLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:12.0];
        orderTypeLbl.layer.borderWidth = 0.0;
        orderTypeLbl.layer.borderColor = [UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0].CGColor;
        orderTypeLbl.textColor = [UIColor blackColor];
        orderTypeLbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        orderTypeLbl.clipsToBounds = YES;
        [cellBg addSubview:orderTypeLbl];
        
        orderReqTypeLbl = [[UILabel alloc] initWithFrame:CGRectMake(cellBg.frame.size.width - 15-20, CGRectGetMaxY(orderTypeLbl.frame)+7.5, 16.0, 16.0)];
        orderReqTypeLbl.layer.cornerRadius = 8.0;
        orderReqTypeLbl.text = @"R";
        orderReqTypeLbl.textAlignment = NSTextAlignmentCenter;
        orderReqTypeLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:12.0];
        orderReqTypeLbl.layer.borderWidth = 0.0;
        orderReqTypeLbl.layer.borderColor = [UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0].CGColor;
        orderReqTypeLbl.textColor = [UIColor blackColor];//[UIColor colorWithRed:65.0/255.0 green:235.0/255.0 blue:110.0/255.0 alpha:1.0];
        orderReqTypeLbl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.65];
        orderReqTypeLbl.clipsToBounds = YES;
        [cellBg addSubview:orderReqTypeLbl];
        
        
        lblDate = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(slotCloctImgV.frame)+5, 13.0, cellBg.frame.size.width - 15-28-10- CGRectGetMaxX(slotCloctImgV.frame), 20)];
        lblDate.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:15.0];
        lblDate.backgroundColor = [UIColor clearColor];
        lblDate.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
        [cellBg addSubview:lblDate];
        
        lblPaymentType = [[UILabel alloc] initWithFrame:CGRectMake(cellBg.frame.size.width-120, 13.0, 60, 20)];
        lblPaymentType.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:15.0];
        lblPaymentType.backgroundColor = [UIColor clearColor];
        lblPaymentType.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
        [cellBg addSubview:lblPaymentType];
        
        lblOrderId = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(slotCloctImgV.frame), CGRectGetMaxY(lblDate.frame)+5, cellBg.frame.size.width - 15-28-10- CGRectGetMaxX(slotCloctImgV.frame), 20)];
        lblOrderId.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:13.0];
        lblOrderId.backgroundColor = [UIColor clearColor];
        lblOrderId.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
        [cellBg addSubview:lblOrderId];
        
        orderPersonNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMinY(orderReqTypeLbl.frame)-2, cellBg.frame.size.width - 15-28-5-10-5, 20)];
        orderPersonNameLbl.text = @"Shahsank";
        orderPersonNameLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
        orderPersonNameLbl.backgroundColor = [UIColor clearColor];
        orderPersonNameLbl.textColor = [UIColor colorWithRed:81.0/255.0 green:81.0/255.0 blue:82.0/255.0 alpha:1.0];
        [cellBg addSubview:orderPersonNameLbl];
        
        
        orderAddressLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(orderPersonNameLbl.frame)+5, orderPersonNameLbl.frame.size.width, 50)];
        orderAddressLbl.text = @"Shahsank shdf wfoh fh8sho f89s fhsoiuf hfhwad fshf soahf ifhu";
        orderAddressLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
        orderAddressLbl.backgroundColor = [UIColor clearColor];
        orderAddressLbl.textColor = [UIColor blackColor];
        orderAddressLbl.numberOfLines = 0;
        [cellBg addSubview:orderAddressLbl];
        
        statusBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        statusBtn.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
        [statusBtn setTitle:@"Start" forState:UIControlStateNormal];
        [statusBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        statusBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:14.0];
        statusBtn.frame = CGRectMake(0, cellBg.frame.size.height - 34, cellBg.frame.size.width, 34);
        [cellBg addSubview:statusBtn];
        
        
        btnI = [UIButton buttonWithType:UIButtonTypeInfoDark];
        btnI.frame = CGRectMake(cellBg.frame.size.width-50, cellBg.frame.size.height-34, 35, 35);
        btnI.tintColor = [UIColor blackColor];
        [btnI addTarget:self action:@selector(btnIClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cellBg addSubview:btnI];
        
        
//        isNotesAvailbelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        isNotesAvailbelBtn.userInteractionEnabled = NO;
//        isNotesAvailbelBtn.frame = CGRectMake(cellBg.frame.size.width - 15-28, 15.0, 28, 28);
//        isNotesAvailbelBtn.backgroundColor = [UIColor clearColor];
//        [isNotesAvailbelBtn setBackgroundImage:[UIImage imageNamed:@"notes_btn"] forState:UIControlStateNormal];
//        [isNotesAvailbelBtn setBackgroundImage:[UIImage imageNamed:@"notes_btn"] forState:UIControlStateSelected];
//        [cellBg addSubview:isNotesAvailbelBtn];
//        
//        isNewUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        isNewUserBtn.frame = CGRectMake(cellBg.frame.size.width - 15-28, CGRectGetMaxY(isNotesAvailbelBtn.frame)+10, 28, 28);
//        isNewUserBtn.userInteractionEnabled = NO;
//        isNewUserBtn.backgroundColor = [UIColor clearColor];
//        [isNewUserBtn setBackgroundImage:[UIImage imageNamed:@"new_user_disable"] forState:UIControlStateNormal];
//        [isNewUserBtn setBackgroundImage:[UIImage imageNamed:@"new_user_active"] forState:UIControlStateSelected];
//        [cellBg addSubview:isNewUserBtn];
//        
//        isVipUserBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        isVipUserBtn.userInteractionEnabled = NO;
//        isVipUserBtn.frame = CGRectMake(cellBg.frame.size.width - 15-28, CGRectGetMaxY(isNewUserBtn.frame)+10, 28, 28);
//        isVipUserBtn.backgroundColor = [UIColor clearColor];
//        [isVipUserBtn setBackgroundImage:[UIImage imageNamed:@"vip_active"] forState:UIControlStateSelected];
//        [isVipUserBtn setBackgroundImage:[UIImage imageNamed:@"vip_disable"] forState:UIControlStateNormal];
//        [cellBg addSubview:isVipUserBtn];
        
        [self addSubview:cellBg];
        
        dictData = [[NSMutableDictionary alloc]init];
        
    }
    
    return self;
}

-(void) btnIClicked:(UIButton *) sender
{
    if ([[dictData objectForKey:@"jt"] isEqualToString:@"Pickup"])
    {
        [self showPopup];
    }
    else
    {
        AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
        
        NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[dictData objectForKey:@"cobid"],@"cobid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@viewitemizedbilldetails/services.do?", BASE_URL];
        
        for (NSString *key in [registrationDetailsDic allKeys])
        {
            NSString *value = [registrationDetailsDic objectForKey:key];
            
            urlStr = [urlStr stringByAppendingFormat:@"&%@=%@",key,value];
        }
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"GET" withDetailsDictionary:nil andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            {
                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] caseInsensitiveCompare:@"y"] == NSOrderedSame)
                {
                    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
                    
                    if ([[responseObj objectForKey:@"r"] count])
                    {
                        dictBill = [[NSDictionary alloc]initWithDictionary:[[responseObj objectForKey:@"totalsum"] objectAtIndex:0]];
                        
                        [self showPopup];
                    }
                }
                else
                {
                    [appDel displayErrorMessagErrorResponse:responseObj];
                }
            }
        }];
    }
}

-(void) showPopup
{
    
//    NSDate *currentTime = [NSDate date];
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYY-MM-dd hh a"];
//    
//    NSString *str = [NSString stringWithFormat:@"%@ %@", [dictData objectForKey:@"d"], [[[dictData objectForKey:@"ep"]componentsSeparatedByString:@"-"]objectAtIndex:0]];
//    
//    NSDate *date = [dateFormatter dateFromString:str];
//    
//    NSTimeInterval timeint = [date timeIntervalSinceDate:currentTime];
//    
//    CGFloat minutes = timeint/60;
    
    AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    viewBG = [[UIView alloc]initWithFrame:appDel.window.bounds];
    viewBG.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    [appDel.window addSubview:viewBG];
    
    float VX = 20*MULTIPLYHEIGHT;
    
    UIView *viewShow = [[UIView alloc]initWithFrame:CGRectMake(VX, 0, screen_width-(VX*2), 100)];
    viewShow.backgroundColor = [UIColor whiteColor];
    [viewBG addSubview:viewShow];
    
    float yAxis = 10*MULTIPLYHEIGHT;
    
    UILabel *lblOrder = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, viewShow.frame.size.width, 20*MULTIPLYHEIGHT)];
    lblOrder.textColor = [UIColor blackColor];
    lblOrder.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM];
    lblOrder.textAlignment = NSTextAlignmentCenter;
    lblOrder.text = [NSString stringWithFormat:@"ORDER ID # %@", [dictData objectForKey:@"o"]];
    [viewShow addSubview:lblOrder];
    
    yAxis += 20*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT;
    
    UILabel *lblPT = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, viewShow.frame.size.width, 16*MULTIPLYHEIGHT)];
    lblPT.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
    lblPT.textColor = [UIColor grayColor];
    lblPT.textAlignment = NSTextAlignmentCenter;
    
    if ([[dictData objectForKey:@"pm"] intValue] == 1)
    {
        lblPT.text = @"Payment Mode : CASH";
    }
    else if ([[dictData objectForKey:@"pm"] intValue] == 2)
    {
        lblPT.text = @"Payment Mode : CARD";
    }
    
    [viewShow addSubview:lblPT];
    
    yAxis += 16*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
    
    if (![[dictData objectForKey:@"jt"] isEqualToString:@"Pickup"])
    {
        UILabel *lblFA = [[UILabel alloc]initWithFrame:CGRectMake(0, yAxis, viewShow.frame.size.width, 16*MULTIPLYHEIGHT)];
        lblFA.font = lblPT.font;
        lblFA.textColor = lblPT.textColor;
        lblFA.textAlignment = NSTextAlignmentCenter;
        lblFA.text = [NSString stringWithFormat:@"Final Amount : $ %@", [dictBill objectForKey:@"balanceamount"]];
        [viewShow addSubview:lblFA];
        
        yAxis += 16*MULTIPLYHEIGHT+6*MULTIPLYHEIGHT;
    }
    
    
//    if (minutes <= 30)
//    {
//        if ([[dictData objectForKey:@"p"] length])
//        {
//            UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
//            UIImage *butImage1 = [UIImage imageNamed:@"phone_icon_seleted_New.png"];
//            rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            [rightbutton setImage:butImage1 forState:UIControlStateNormal];
//            [rightbutton addTarget:self action:@selector(callBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//            [rightbutton setTitle:[dictData objectForKey:@"p"] forState:UIControlStateNormal];
//            [rightbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            rightbutton.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2.5];
//            rightbutton.backgroundColor = BLUE_COLOR;
//            [viewShow addSubview:rightbutton];
//            
//            float btnW = 100*MULTIPLYHEIGHT;
//            rightbutton.frame = CGRectMake(viewShow.frame.size.width/2-btnW/2, yAxis, btnW, 20*MULTIPLYHEIGHT);
//            
//            yAxis += 20*MULTIPLYHEIGHT;
//        }
//    }
    
    if ([[dictData objectForKey:@"p"] length])
    {
        UIButton *rightbutton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *butImage1 = [UIImage imageNamed:@"phone_icon_seleted_New.png"];
        rightbutton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [rightbutton setImage:butImage1 forState:UIControlStateNormal];
        [rightbutton addTarget:self action:@selector(callBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [rightbutton setTitle:[dictData objectForKey:@"p"] forState:UIControlStateNormal];
        [rightbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightbutton.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2.5];
        rightbutton.backgroundColor = BLUE_COLOR;
        [viewShow addSubview:rightbutton];
        
        float btnW = 100*MULTIPLYHEIGHT;
        rightbutton.frame = CGRectMake(viewShow.frame.size.width/2-btnW/2, yAxis, btnW, 20*MULTIPLYHEIGHT);
        
        yAxis += 20*MULTIPLYHEIGHT;
    }
    
    
    yAxis += 10*MULTIPLYHEIGHT;
    
    float btnDW = 80*MULTIPLYHEIGHT;
    
    UIButton *btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    btnDone.frame = CGRectMake(viewShow.frame.size.width/2-btnDW/2, yAxis, btnDW, 22*MULTIPLYHEIGHT);
    [btnDone setTitle:@"DONE" forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2];
    [btnDone setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btnDone addTarget:self action:@selector(btnDoneClicked) forControlEvents:UIControlEventTouchUpInside];
    [viewShow addSubview:btnDone];
    btnDone.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btnDone.layer.borderWidth = 1.0;
    
    
    yAxis += 22*MULTIPLYHEIGHT+10*MULTIPLYHEIGHT;
    
    CGRect rect = viewShow.frame;
    rect.origin.y = screen_height/2-yAxis/2;
    rect.size.height = yAxis;
    viewShow.frame = rect;
}

-(void) callBtnClicked
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
    {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:[dictData objectForKey:@"p"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
    } else {
        
        AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
        [appDel showAlertWithMessage:@"Your device doesn't support this feature." andTitle:@"" andBtnTitle:@"OK"];
    }
}

-(void) btnDoneClicked
{
    [viewBG removeFromSuperview];
    viewBG = nil;
}

-(void) setDetails:(id) details withCurrentIndex:(NSInteger) index;
{
    
    [dictData removeAllObjects];
    
    [dictData addEntriesFromDictionary:details];
    
    orderPersonNameLbl.text = [details objectForKey:@"userName"];
    
    lblOrderId.text = [NSString stringWithFormat:@"ORDER ID # %@", [details objectForKey:@"oid"]];
    
    NSMutableString *strAddr = [[NSMutableString alloc]initWithString:@""];
    
    NSDictionary *dict = [[dictData objectForKey:@"currentAddress"] objectAtIndex:0];
    
    if ([[dict objectForKey:@"line1"] length] > 1)
    {
        [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dict objectForKey:@"line1"]]];
    }
    
    NSString *strFno;
    
    if ([[dict objectForKey:@"floorNo"] isKindOfClass:[NSString class]])
    {
        strFno = [dict objectForKey:@"floorNo"];
    }
    else
    {
        strFno = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"floorNo"] intValue]];
    }
    
    if ([strFno length])
    {
        if ([strFno length] == 1)
        {
            [strAddr appendString:[NSString stringWithFormat:@"#0%@", strFno]];
        }
        else
        {
            [strAddr appendString:[NSString stringWithFormat:@"#%@", [dict objectForKey:@"floorNo"]]];
        }
    }
    
    NSString *strUno;
    
    if ([[dict objectForKey:@"unitNo"] isKindOfClass:[NSString class]])
    {
        strUno = [dict objectForKey:@"unitNo"];
    }
    else
    {
        strUno = [NSString stringWithFormat:@"%d", [[dict objectForKey:@"unitNo"] intValue]];
    }
    
    if ([strUno length])
    {
        [strAddr appendString:[NSString stringWithFormat:@"-%@, ", strUno]];
    }
    
    if ([[dict objectForKey:@"line2"] length])
    {
        [strAddr appendString:[NSString stringWithFormat:@"%@, ", [dict objectForKey:@"line2"]]];
    }
    if ([[dict objectForKey:@"zipcode"] length])
    {
        [strAddr appendString:[NSString stringWithFormat:@"%@", [dict objectForKey:@"zipcode"]]];
    }
    
    CGFloat height = [AppDelegate getLabelHeightForRegularText:strAddr WithWidth:orderAddressLbl.frame.size.width FontSize:13];
    
    CGRect frame = orderAddressLbl.frame;
    frame.size.height = height;
    orderAddressLbl.frame = frame;
    
    orderAddressLbl.text = strAddr;
    
    frame = statusBtn.frame;
    frame.origin.y = orderAddressLbl.frame.origin.y+orderAddressLbl.frame.size.height+5;
    statusBtn.frame = frame;
    
    frame = btnI.frame;
    frame.origin.y = statusBtn.frame.origin.y;
    btnI.frame = frame;
    
    
    frame = cellBg.frame;
    frame.size.height = statusBtn.frame.origin.y+statusBtn.frame.size.height;
    cellBg.frame = frame;
    
    if ([[details objectForKey:@"orderType"] isEqualToString:@"B"])
    {
        lblBookBow.hidden = NO;
    }
    else
    {
        lblBookBow.hidden = YES;
    }
    
    if ([[details objectForKey:@"orderSpeed"] isEqualToString:@"R"])
    {
        orderReqTypeLbl.text = @"R";
    }
    else
    {
        orderReqTypeLbl.text = @"E";
    }
    
    NSString *strDate;
    
    if ([[details objectForKey:@"direction"] isEqualToString:@"Pickup"])
    {
        orderTypeLbl.text = @"P";
        
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"dd-MM-yyyy"];
        NSDate *date = [df dateFromString:[details objectForKey:@"pickUpDate"]];
        
        strDate = [df stringFromDate:date];
        strDate = [strDate stringByAppendingString:[NSString stringWithFormat:@", %@", [details objectForKey:@"pickUpSlotId"]]];
    }
    else
    {
        orderTypeLbl.text = @"D";
        
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        [df setDateFormat:@"dd-MM-yyyy"];
        NSDate *date = [df dateFromString:[details objectForKey:@"deliveryDate"]];
        
        strDate = [df stringFromDate:date];
        strDate = [strDate stringByAppendingString:[NSString stringWithFormat:@", %@", [details objectForKey:@"deliverySlotId"]]];
    }
    
    lblDate.text = strDate;
    
    if ([[details objectForKey:ORDER_CARD_ID] caseInsensitiveCompare:@"Cash"] == NSOrderedSame)
    {
        lblPaymentType.text = @"CASH";
    }
    else
    {
        lblPaymentType.text = @"CARD";
    }
    
    [statusBtn setTitle:[details objectForKey:@"statusMsg"] forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
