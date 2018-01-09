//
//  ItemsDetailTableViewCell.m
//  PiingApp
//
//  Created by SHASHANK on 16/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "ItemsDetailTableViewCell.h"
#import "SpacedSegmentController.h"
#import "PreferencesViewController.h"
#import "NSNull+JSON.h"
#import "JobdetailViewController.h"


#define BAG_DETAILS_VIEW_TAG 444

#define TEXT_LABEL_COLOR [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]

#define SPECIAL_REQ_NON_ACTIVE_COLOR [UIColor colorWithRed:173.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:1.0]
#define SPECIAL_REQ_SELECTED_COLOR [UIColor colorWithRed:210.0/255.0 green:187.0/255.0 blue:102.0/255.0 alpha:1.0]

@implementation ItemsDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) parentDelegate
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        parentDel = parentDelegate;
        //blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        
        blockedCharacters = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZ_"]invertedSet];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        self.backgroundColor = [UIColor clearColor];//[[UIColor blackColor] colorWithAlphaComponent:0.05];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UIImage *bgImg = [UIImage imageNamed:@"cell_bg_9p"];
        bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
        
        cellBGimage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, screen_width-20, 110.0)];
        cellBGimage.image = bgImg;
        cellBGimage.userInteractionEnabled = YES;
        [self addSubview:cellBGimage];
        
        itemTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+10, 10, screen_width-30, 20.0)];
        itemTypeLabel.backgroundColor = [UIColor clearColor];
        itemTypeLabel.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
        itemTypeLabel.textColor = APP_FONT_COLOR_GREY;
        [self addSubview:itemTypeLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25.0, CGRectGetMaxY(itemTypeLabel.frame)+2, CGRectGetWidth(cellBGimage.frame) - 120.0, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0];
        [self addSubview:lineView];
        
        titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, screen_width-30, 20.0)];
        titleLbl.backgroundColor = [UIColor clearColor];
        titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:14.0];
        [self addSubview:titleLbl];
        
        txtBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-155, 30.0+10, 135, 15)];
        txtBGImgView.userInteractionEnabled = YES;
        txtBGImgView.image = [UIImage imageNamed:@"text_field"];
        [self addSubview:txtBGImgView];
        
        
        txtManualTagBGImgView = [[UIImageView alloc] initWithFrame:CGRectMake(screen_width-150, 40.0+10, 140, 15)];
        txtManualTagBGImgView.userInteractionEnabled = YES;
        txtManualTagBGImgView.image = [UIImage imageNamed:@"text_field"];
        //[self addSubview:txtManualTagBGImgView];
        
        
        
        
        tagTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(screen_width-155, 30.0, 135, 30)];
        tagTextFeild.backgroundColor = [UIColor clearColor];
//        tagTextFeild.layer.borderWidth = 1.0;
//        tagTextFeild.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
        tagTextFeild.placeholder = @"Enter Bag No.";
        tagTextFeild.delegate = self;
        tagTextFeild.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        tagTextFeild.tag = 100;
        tagTextFeild.textColor = [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:143.0/255.0 alpha:1.0];
        tagTextFeild.textAlignment = NSTextAlignmentCenter;
        tagTextFeild.font = [UIFont fontWithName:APPFONT_REGULAR size:12.0];
        [self addSubview:tagTextFeild];
        
        
        manualTagTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(screen_width-100, 40.0, 78, 30)];
        manualTagTextFeild.backgroundColor = [UIColor clearColor];
        manualTagTextFeild.placeholder = @"Manual tag No.";
        manualTagTextFeild.tag = 101;
        manualTagTextFeild.delegate = self;
        manualTagTextFeild.textColor = [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:143.0/255.0 alpha:1.0];
        manualTagTextFeild.textAlignment = NSTextAlignmentCenter;
        manualTagTextFeild.font = [UIFont fontWithName:APPFONT_REGULAR size:12.0];
        //[self addSubview:manualTagTextFeild];
        
        
        UIView *accesoryCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 50)];
        accesoryCustomView.backgroundColor = [UIColor clearColor];
        
        confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.backgroundColor = APP_GREEN_THEME_COLOR;
        confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
        confirmBtn.clipsToBounds = NO;
        confirmBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
        confirmBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [confirmBtn setTitle:@"Edit" forState:UIControlStateDisabled];
        [confirmBtn setTitle:@"Confirmed" forState:UIControlStateDisabled];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(conformBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [cellBGimage addSubview:confirmBtn];
        
        specialReqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        specialReqBtn.backgroundColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
        specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
        specialReqBtn.clipsToBounds = NO;
        specialReqBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
        specialReqBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [specialReqBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [specialReqBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        [specialReqBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [specialReqBtn setTitle:@"Spl.Request" forState:UIControlStateNormal];
        [specialReqBtn addTarget:self action:@selector(specialRequestClicked) forControlEvents:UIControlEventTouchUpInside];
        //[cellBGimage addSubview:specialReqBtn];
        
        {
            specilRequestView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
            specilRequestView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
            specilRequestView.clipsToBounds = NO;
            
            UIView *splView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, screen_width - 20, 250+25)];
            splView.layer.cornerRadius = 5.0;
            splView.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:172.0/255.0 blue:143.0/255.0 alpha:0.6];
            splView.center = CGPointMake(screen_width/2, screen_height/2-100);
            
            UILabel *spRLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(splView.frame)-20, 65.0)];
            spRLabel.numberOfLines = 0;
            spRLabel.textColor = [UIColor whiteColor];
            spRLabel.textAlignment = NSTextAlignmentCenter;
            spRLabel.backgroundColor = [UIColor clearColor];
            spRLabel.text = @"Special Request\nPlease mention the count of the Strain or Strach or both";
            spRLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:18.0];
            [splView addSubview:spRLabel];
            
            UILabel *strainTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(spRLabel.frame)+20, CGRectGetWidth(splView.frame)-130, 30.0)];
            strainTitleLabel.backgroundColor = [UIColor clearColor];
            strainTitleLabel.textColor = [UIColor whiteColor];
            strainTitleLabel.text = @"Strain Count";
            strainTitleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:18.0];
            [splView addSubview:strainTitleLabel];
            
            strainCountTxt = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(strainTitleLabel.frame)+10, CGRectGetMinY(strainTitleLabel.frame), 100.0, 30.0)];
            strainCountTxt.backgroundColor = [UIColor whiteColor];
            strainCountTxt.layer.borderWidth = 1.0;
            strainCountTxt.keyboardType = UIKeyboardTypeNumberPad;
            strainCountTxt.layer.cornerRadius = 5.0;
            strainCountTxt.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
            strainCountTxt.placeholder = @"0";
            strainCountTxt.textAlignment = NSTextAlignmentCenter;
            strainCountTxt.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
            [splView addSubview:strainCountTxt];
            
            
            UILabel *strachTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(strainTitleLabel.frame)+20, CGRectGetWidth(splView.frame)-130, 30.0)];
            strachTitleLabel.backgroundColor = [UIColor clearColor];
            strachTitleLabel.textColor = [UIColor whiteColor];
            strachTitleLabel.text = @"Strach Count";
            strachTitleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:18.0];
            [splView addSubview:strachTitleLabel];
            
            strachCountTxt = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(strachTitleLabel.frame)+10, CGRectGetMinY(strachTitleLabel.frame), 100.0, 30.0)];
            strachCountTxt.backgroundColor = [UIColor whiteColor];
            strachCountTxt.layer.borderWidth = 1.0;
            strachCountTxt.layer.cornerRadius = 5.0;
            strachCountTxt.keyboardType = UIKeyboardTypeNumberPad;
            strachCountTxt.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
            strachCountTxt.placeholder = @"0";
            strachCountTxt.textAlignment = NSTextAlignmentCenter;
            strachCountTxt.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
            [splView addSubview:strachCountTxt];
            
            SpacedSegmentController *selectBagTypeSegment = [[SpacedSegmentController alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(strachTitleLabel.frame) +5, 3*20+30, 20) titles:@[@"",@"",@""] unSelectedImages:@[@"low_inactive",@"medium_inactive",@"high_inactive"] selectedImages:@[@"low_active",@"medium_active",@"high_active"] seperatorSpacing:[NSNumber numberWithFloat:0.0] andDelegate:self];
            [selectBagTypeSegment setSelectedControlIndex:0];
            [splView addSubview:selectBagTypeSegment];
            
            UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            cancelBtn.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:171.0/255.0 blue:142.0/255.0 alpha:1.0];
            cancelBtn.clipsToBounds = NO;
//            cancelBtn.layer.cornerRadius = 5.0;
            cancelBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:15.0];
            cancelBtn.frame = CGRectMake(CGRectGetMidX(splView.frame)/2 - 50, CGRectGetMaxY(strachCountTxt.frame)+45, 100, 30.0);
            [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
            [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cancelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [splView addSubview:cancelBtn];
            
            UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            addBtn.backgroundColor = [UIColor colorWithRed:42.0/255.0 green:171.0/255.0 blue:142.0/255.0 alpha:1.0];
            addBtn.clipsToBounds = NO;
//            addBtn.layer.cornerRadius = 5.0;
            addBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:15.0];
            addBtn.frame = CGRectMake(CGRectGetMidX(splView.frame)*4/3 - 50, CGRectGetMaxY(strachCountTxt.frame)+45, 100, 30.0);
            [addBtn setTitle:@"Add" forState:UIControlStateNormal];
            [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [splView addSubview:addBtn];
            
            [specilRequestView addSubview:splView];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
            [tapGesture setCancelsTouchesInView:NO];
            [specilRequestView addGestureRecognizer:tapGesture];
            
            //[appDel.window addSubview:specilRequestView];
            
            specilRequestView.hidden = YES;
            
            deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteBtn.frame = CGRectMake(self.frame.size.width-25,0, 24, 24);
            [deleteBtn setBackgroundImage:[UIImage imageNamed:@"deleteBagIcon"] forState:UIControlStateNormal];
            [deleteBtn addTarget:self action:@selector(deleteBagBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:deleteBtn];
            
            [self bringSubviewToFront:manualTagTextFeild];
        }
        
        //self.orderInfo = [[NSMutableDictionary alloc]init];
    }
    
    return self;
}

-(void) setDetials:(BagDetails *) bagObject
{
    for(UIView *v in [self subviews])
    {
        if (v.tag == BAG_DETAILS_VIEW_TAG)
            [v removeFromSuperview];
    }
    
    deleteBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-10, 0, 20, 20);
    
    confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
    specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
    
    {
        selectedItemObj = bagObject;
        
        if ([selectedItemObj.isBagConfirmed boolValue])
        {
            deleteBtn.hidden = YES;
            
            confirmBtn.enabled = NO;
            confirmBtn.backgroundColor = SPECIAL_REQ_NON_ACTIVE_COLOR;
            
            tagTextFeild.enabled = NO;
            manualTagTextFeild.enabled = NO;
            
            txtBGImgView.hidden = YES;
            txtManualTagBGImgView.hidden = YES;
            
            tagTextFeild.text = [NSString stringWithFormat:@"#%@",selectedItemObj.bagTag];
            manualTagTextFeild.text = [NSString stringWithFormat:@"#%@",selectedItemObj.manualBagTag];
        }
        else
        {
            deleteBtn.hidden = NO;
            
            txtBGImgView.hidden = NO;
            txtManualTagBGImgView.hidden = NO;
            
            confirmBtn.enabled = YES;
            confirmBtn.backgroundColor = APP_GREEN_THEME_COLOR;
            
            if ([selectedItemObj.bagTag length] > 0)
                tagTextFeild.text = selectedItemObj.bagTag;
            
            
            tagTextFeild.enabled = YES;
            
            if ([selectedItemObj.manualBagTag length] > 0)
                manualTagTextFeild.text = selectedItemObj.manualBagTag;
            
            
            manualTagTextFeild.enabled = YES;
        }
        
        NSData *data;
        id json;
        
//        if ([selectedItemObj.bagType integerValue] == 0)
//        {
//            cellBGimage.frame = CGRectMake(10, 5, screen_width-20, 110.0);
//            
//            confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-35.0, 95, 25.0);
//            specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-35.0, 95, 25.0);
//            
//            
//            ItemsDetails *itremObj = (ItemsDetails *)[[NSArray arrayWithArray:[selectedItemObj.items allObjects]] lastObject];
//            
//            data = [itremObj.iTemDetailDic dataUsingEncoding:NSUTF8StringEncoding];
//            json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            
//            itemTypeLabel.text = @"Load Wash";
//            
//            UIView *bagDetails = [[UIView alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(itemTypeLabel.frame)+5, cellBGimage.frame.size.width-110, 40)];
//            bagDetails.backgroundColor = [UIColor clearColor];
//            bagDetails.userInteractionEnabled = NO;
//            bagDetails.tag = BAG_DETAILS_VIEW_TAG;
//            
//            UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 120, 40.0)];
//            infoLabel.backgroundColor = [UIColor clearColor];
//            infoLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:14.0];
//            infoLabel.textColor = TEXT_LABEL_COLOR;
//            infoLabel.text = [NSString stringWithFormat:@"Number of kgs "];
//            [bagDetails addSubview:infoLabel];
//            
//            UILabel *infoValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(bagDetails.frame.size.width-50-25, 0, 50, 40.0)];
//            infoValueLabel.textAlignment = NSTextAlignmentCenter;
//            infoValueLabel.backgroundColor = [UIColor clearColor];
//            infoValueLabel.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
//            infoValueLabel.textColor = TEXT_LABEL_COLOR;
//            infoValueLabel.text = [NSString stringWithFormat:@"%@kg",[[json objectAtIndex:0] objectForKey:@"quantity"]];
//            [bagDetails addSubview:infoValueLabel];
//            
//            [self addSubview:bagDetails];
//        }
//        else if ([selectedItemObj.bagType integerValue] == 1)
        {
            cellBGimage.frame = CGRectMake(10, 5, screen_width-20, 110.0-15.0);
            
            UIView *bagDetails = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+40, cellBGimage.frame.size.width, cellBGimage.frame.size.height - CGRectGetMaxY(itemTypeLabel.frame)-35)];
            bagDetails.backgroundColor = [UIColor clearColor];
            bagDetails.tag = BAG_DETAILS_VIEW_TAG;
            [self addSubview:bagDetails];
            
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"iTemType" ascending:YES];
            NSArray *itemsArray = [NSArray arrayWithArray:[[selectedItemObj.items allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]]];
            
            NSMutableDictionary *dictWashCode = [[NSMutableDictionary alloc]init];
            
            [dictWashCode setObject:@"Load Wash" forKey:@"WF"];
            [dictWashCode setObject:@"Wash & Iron" forKey:@"WI"];
            [dictWashCode setObject:@"Dry Cleaning" forKey:@"DC"];
            [dictWashCode setObject:@"Green Dry Cleaning" forKey:@"DCG"];
            [dictWashCode setObject:@"Ironing" forKey:@"IR"];
            [dictWashCode setObject:@"Carpet Cleaning" forKey:@"CA"];
            [dictWashCode setObject:@"Lether Cleaning" forKey:@"LE"];
            [dictWashCode setObject:@"Curtain Without Installation - Dry Cleaning" forKey:@"CC_DC"];
            [dictWashCode setObject:@"Curtain Without Installation - Wash & Iron" forKey:@"CC_WI"];
            [dictWashCode setObject:@"Curtain With Installation - Dry Cleaning" forKey:@"CC_W_DC"];
            [dictWashCode setObject:@"Curtain With Installation - Wash & Iron" forKey:@"CC_W_WI"];
            [dictWashCode setObject:@"Bag Cleaning" forKey:SERVICETYPE_BAG];
            [dictWashCode setObject:@"Shoe Cleaning" forKey:SERVICETYPE_SHOE_CLEAN];
            [dictWashCode setObject:@"Shoe Polishing" forKey:SERVICETYPE_SHOE_POLISH];
            
            for (int i = 0; i< [itemsArray count]; i++)
            {
                ItemsDetails *itremObj = (ItemsDetails *)[itemsArray objectAtIndex:i];
                
                data = [itremObj.iTemDetailDic dataUsingEncoding:NSUTF8StringEncoding];
                json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                DLog(@"Json array %@",json);
                
                if ([json count] > 0)
                {
                    cellBGimage.frame = CGRectMake(10, 5, screen_width-20, cellBGimage.frame.size.height+25.0);
                    
                    if ([json isKindOfClass:[NSArray class]])
                    {
                        for (int i = 0; i<[json count]; i++)
                        {
                            DLog(@"%f",cellBGimage.frame.size.height);
                            
                            titleLbl.text = [[json objectAtIndex:i] objectForKey:@"jd"];
                            
                            itemTypeLabel.text = [dictWashCode objectForKey:[[json objectAtIndex:i] objectForKey:@"jd"]];
                            
                            cellBGimage.frame = CGRectMake(10, 5, screen_width-20, cellBGimage.frame.size.height+25.0);
                            bagDetails.frame = CGRectMake(10, bagDetails.frame.origin.x, cellBGimage.frame.size.width, bagDetails.frame.size.height+25.0);
                            
                            if ([[json objectAtIndex:i] objectForKey:@"quantity"] && [[json objectAtIndex:i] objectForKey:@"weight"])
                            {
                                UILabel *categoryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25*(i), 90, 20.0)];
                                categoryNameLabel.backgroundColor = [UIColor clearColor];
                                categoryNameLabel.adjustsFontSizeToFitWidth = YES;
                                categoryNameLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
                                categoryNameLabel.textColor = TEXT_LABEL_COLOR;
                                [bagDetails addSubview:categoryNameLabel];
                                
                                UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(categoryNameLabel.frame.size.width+10, 25*(i), 45.0, 20.0)];
                                infoLabel.backgroundColor = [UIColor clearColor];
                                infoLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
                                infoLabel.textColor = TEXT_LABEL_COLOR;
                                infoLabel.textAlignment = NSTextAlignmentRight;
                                [bagDetails addSubview:infoLabel];
                                
                                UILabel *categoryNameLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(infoLabel.frame.origin.x+ infoLabel.frame.size.width+10, 25*(i), 75, 20.0)];
                                categoryNameLabel1.backgroundColor = [UIColor clearColor];
                                categoryNameLabel1.adjustsFontSizeToFitWidth = YES;
                                categoryNameLabel1.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
                                categoryNameLabel1.textColor = TEXT_LABEL_COLOR;
                                [bagDetails addSubview:categoryNameLabel1];
                                
                                UILabel *infoLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(categoryNameLabel1.frame.origin.x+ categoryNameLabel1.frame.size.width+10, 25*(i), 45.0, 20.0)];
                                infoLabel1.backgroundColor = [UIColor clearColor];
                                infoLabel1.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
                                infoLabel1.textColor = TEXT_LABEL_COLOR;
                                infoLabel1.textAlignment = NSTextAlignmentRight;
                                [bagDetails addSubview:infoLabel1];
                                
                                categoryNameLabel.text = [[json objectAtIndex:i] objectForKey:@"n"];
                                infoLabel.text = [NSString stringWithFormat:@": %@",[[json objectAtIndex:i] objectForKey:@"quantity"]];
                                
                                categoryNameLabel1.text = @"Weight (KGs)";
                                infoLabel1.text = [NSString stringWithFormat:@": %@",[[json objectAtIndex:i] objectForKey:@"weight"]];
                            }
                            else if ([[json objectAtIndex:i] objectForKey:@"quantity"])
                            {
                                UILabel *categoryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25*(i), screen_width-15-100+10, 20.0)];
                                categoryNameLabel.backgroundColor = [UIColor clearColor];
                                categoryNameLabel.adjustsFontSizeToFitWidth = YES;
                                categoryNameLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
                                categoryNameLabel.textColor = TEXT_LABEL_COLOR;
                                [bagDetails addSubview:categoryNameLabel];
                                
                                UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(categoryNameLabel.frame.size.width+10, 25*(i), 45.0, 20.0)];
                                infoLabel.backgroundColor = [UIColor clearColor];
                                infoLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
                                infoLabel.textColor = TEXT_LABEL_COLOR;
                                infoLabel.textAlignment = NSTextAlignmentRight;
                                [bagDetails addSubview:infoLabel];
                                
                                categoryNameLabel.text = [[json objectAtIndex:i] objectForKey:@"n"];
                                infoLabel.text = [NSString stringWithFormat:@": %@",[[json objectAtIndex:i] objectForKey:@"quantity"]];
                                
                            }
                            else if ([[json objectAtIndex:i] objectForKey:@"weight"])
                            {
                                UILabel *categoryNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 25*(i), screen_width-15-100+10, 20.0)];
                                categoryNameLabel.backgroundColor = [UIColor clearColor];
                                categoryNameLabel.adjustsFontSizeToFitWidth = YES;
                                categoryNameLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
                                categoryNameLabel.textColor = TEXT_LABEL_COLOR;
                                [bagDetails addSubview:categoryNameLabel];
                                
                                UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(categoryNameLabel.frame.size.width+10, 25*(i), 45.0, 20.0)];
                                infoLabel.backgroundColor = [UIColor clearColor];
                                infoLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
                                infoLabel.textColor = TEXT_LABEL_COLOR;
                                infoLabel.textAlignment = NSTextAlignmentRight;
                                [bagDetails addSubview:infoLabel];
                                
                                if ([[[json objectAtIndex:i] objectForKey:@"jd"] isEqualToString:@"WF"])
                                {
                                    categoryNameLabel.text = @"Number of KGs";
                                }
                                else if ([[[json objectAtIndex:i] objectForKey:@"jd"] isEqualToString:@"CA"])
                                {
                                    categoryNameLabel.text = @"Number of sqfts";
                                }
                                
                                infoLabel.text = [NSString stringWithFormat:@": %@",[[json objectAtIndex:i] objectForKey:@"weight"]];
                            }
                        }
                    }
                    
                    bagDetails.frame = CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+40, cellBGimage.frame.size.width, cellBGimage.frame.size.height - CGRectGetMaxY(itemTypeLabel.frame)-35);
                }
                
            }
            
            bagDetails.frame = CGRectMake(10, CGRectGetMaxY(itemTypeLabel.frame)+40, cellBGimage.frame.size.width, cellBGimage.frame.size.height - CGRectGetMaxY(itemTypeLabel.frame)-75);
            
            
            confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-35.0, 95, 25.0);
            specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-35.0, 95, 25.0);
            
        }
        
    }
    
    [self bringSubviewToFront:confirmBtn];
    [self bringSubviewToFront:specilRequestView];
}

#pragma mark UIControl Actions
-(void) viewTapped
{
    [strainCountTxt resignFirstResponder];
    [strachCountTxt resignFirstResponder];
}


-(void) specialRequestClicked
{
    //specilRequestView.hidden = NO;
    
//    PreferencesViewController *objPre = [[PreferencesViewController alloc]init];
//    objPre.delegate = self;
//    objPre.orderUpdateInfo = [[NSMutableDictionary alloc]initWithDictionary:self.orderInfo];
//    
//    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
//    
//    while (topController.presentedViewController)
//    {
//        topController = topController.presentedViewController;
//    }
//    
//    [topController presentViewController:objPre animated:YES completion:nil];
}



-(void) cancelBtnClicked
{
    [strainCountTxt resignFirstResponder];
    [strachCountTxt resignFirstResponder];

    specilRequestView.hidden = YES;
}
-(void) addBtnClicked
{
    [strainCountTxt resignFirstResponder];
    [strachCountTxt resignFirstResponder];
    
    specilRequestView.hidden = YES;
    
//    if ([strainCountTxt.text integerValue] != 0 )
//    {
//        [selectedItemObj setStrainCount:strainCountTxt.text];
//        //[selectedItemObj setIsStrain:[NSNumber numberWithBool:YES]];
//    }
//    else
//    {
//        [selectedItemObj setStrainCount:@"0"];
//        //[selectedItemObj setIsStrain:[NSNumber numberWithBool:NO]];
//
//    }
//    if ([strachCountTxt.text integerValue] != 0 )
//    {
//        [selectedItemObj setStrachCount:strachCountTxt.text];
//        //[selectedItemObj setIsStrach:[NSNumber numberWithBool:YES]];
//    }
//    else
//    {
//        [selectedItemObj setStrachCount:@"0"];
//        //[selectedItemObj setIsStrach:[NSNumber numberWithBool:NO]];
//    }
    
    
    
//    [selectedItemObj setStarch:[self.orderInfo objectForKey:STARCH_SELECTED]];
//    [selectedItemObj setStain:[self.orderInfo objectForKey:STAIN_SELECTED]];
//    [selectedItemObj setStarchType:[self.orderInfo objectForKey:STARCH_TYPE]];
//    [selectedItemObj setFolded:[self.orderInfo objectForKey:FOLDED_SELECTED]];
//    [selectedItemObj setHanger:[self.orderInfo objectForKey:HANGER_SELECTED]];
//    [selectedItemObj setCliphanger:[self.orderInfo objectForKey:CLIPHANGER_SELECTED]];
//    [selectedItemObj setCrease:[self.orderInfo objectForKey:CREASE_SELECTED]];
//    [selectedItemObj setNotes:[self.orderInfo objectForKey:ORDER_NOTES]];
    
    
    if ([parentDel respondsToSelector:@selector(itemDetailsAreUploadedWithTag:)])
        [parentDel performSelector:@selector(itemDetailsAreUploadedWithTag:) withObject:nil];
    
    NSError *error;
    if (![[appDel managedObjectContext] save:&error]) {
        NSLog(@"error %@",error);
    }
}

-(void) conformBtnClicked
{
    
    [tagTextFeild resignFirstResponder];
    [manualTagTextFeild resignFirstResponder];
    
    DLog(@"Conform Btn %@ and tag = %@ and manualTag = %@",selectedItemObj.bagTag,tagTextFeild.text, manualTagTextFeild.text);
    
//    if ([tagTextFeild.text length] && [manualTagTextFeild.text length])
    if ([tagTextFeild.text length])
    {
        if ([[CoreDataMethods sharedInstance] checkTagisAlreadyExits:selectedItemObj.order andTagString:tagTextFeild.text andManualTagString:manualTagTextFeild.text])
        {
            [AppDelegate showAlertWithMessage:@"Tag number should not be repeat." andTitle:@"Alert" andBtnTitle:@"OK"];
            
            return;
        }
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"iTemType" ascending:YES];
        NSArray *itemsArray = [NSArray arrayWithArray:[selectedItemObj.items sortedArrayUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]]];
        
        NSMutableDictionary *dictSend = [[NSMutableDictionary alloc]init];
        
        NSMutableString *strBag = [@"" mutableCopy];
        
        for (int i = 0; i< [itemsArray count]; i++)
        {
            ItemsDetails *itremObj = (ItemsDetails *)[itemsArray objectAtIndex:i];
            
//            Order *parentOrderObj = selectedItemObj.order;
//            
//            NSSet *setBag = parentOrderObj.bagsDetails;
            
            NSData *data = [itremObj.iTemDetailDic dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            [dictSend setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"pid"];
            [dictSend setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN] forKey:@"t"];
            
            if (i == [itemsArray count]-1)
            {
                
                if (![dictSend objectForKey:@"oid"])
                {
                    [dictSend setObject:[[json objectAtIndex:0] objectForKey:@"oid"] forKey:@"oid"];
                }
                
                if ([[[json objectAtIndex:0] objectForKey:@"ic"] isEqualToString:@"WF"] || [[[json objectAtIndex:0] objectForKey:@"ic"] isEqualToString:@"CA"])
                {
                    if (![dictSend objectForKey:@"serviceTypesId"])
                    {
                        [dictSend setObject:[[json objectAtIndex:0] objectForKey:@"ic"] forKey:@"serviceTypesId"];
                    }
                    
                    if ([strBag length] < 6)
                    {
                        [strBag appendFormat:@"%@", [NSString stringWithFormat:@"{\"BagNo\":\"%@\",\"RFId\":\"%@\",\"totalClothes\":\"%@\",\"weight\":\"%@\"", tagTextFeild.text, @"", @"0", [[json objectAtIndex:0] objectForKey:@"weight"]]];
                    }
                }
                else
                {
                    if (![dictSend objectForKey:@"serviceTypesId"])
                    {
                        [dictSend setObject:[[json objectAtIndex:0] objectForKey:@"jd"] forKey:@"serviceTypesId"];
                    }
                    
                    NSMutableString *strItemDetails = [@"" mutableCopy];
                    
                    [strItemDetails appendString:@"["];
                    
                    int totalCountOfClothes = 0;
                    
                    for (NSDictionary *dict in json)
                    {
                        NSString *strWei = @"";
                        
                        if ([dict objectForKey:@"weight"])
                        {
                            strWei = [dict objectForKey:@"weight"];
                        }
                        else
                        {
                            strWei = @"0";
                        }
                        
                        [strItemDetails appendFormat:@"%@", [NSString stringWithFormat:@"{\"iType\":\"%@\",\"qty\":\"%@\",\"weight\":\"%@\",", [dict objectForKey:@"ic"], [dict objectForKey:@"quantity"], strWei]];
                        
                        if ([dict objectForKey:@"brand"])
                        {
                            [strItemDetails appendFormat:@"%@", [NSString stringWithFormat:@"\"brand\":\"%@\",", [dict objectForKey:@"brand"]]];
                        }
                        
                        if ([dict objectForKey:@"colorCode"])
                        {
                            [strItemDetails appendFormat:@"%@", [NSString stringWithFormat:@"\"colorCode\":\"%@\",", [dict objectForKey:@"colorCode"]]];
                        }
                        
                        if ([dict objectForKey:@"addInfo"])
                        {
                            [strItemDetails appendFormat:@"%@", [NSString stringWithFormat:@"\"notes\":\"%@\",", [dict objectForKey:@"addInfo"]]];
                        }
                        
                        if ([dict objectForKey:@"addOn"])
                        {
                            [strItemDetails appendString:@"\"addOn\":{"];
                            
                            NSDictionary *dictAddOn = [dict objectForKey:@"addOn"];
                            
                            for (NSString *key in dictAddOn)
                            {
                                [strItemDetails appendFormat:@"%@", [NSString stringWithFormat:@"\"%@\":\"%@\",", [[dictAddOn objectForKey:key] objectForKey:@"code"], [[dictAddOn objectForKey:key] objectForKey:@"value"]]];
                            }
                            
                            if ([strItemDetails hasSuffix:@","])
                            {
                                strItemDetails = [[strItemDetails substringToIndex:[strItemDetails length]-1]mutableCopy];
                            }
                            
                            [strItemDetails appendString:@"}"];
                        }
                        
                        [strItemDetails appendString:@"},"];
                        
                        totalCountOfClothes += [[dict objectForKey:@"quantity"] intValue];
                    }
                    
                    if ([strBag length] < 6)
                    {
                        [strBag appendFormat:@"%@", [NSString stringWithFormat:@"{\"BagNo\":\"%@\",\"RFId\":\"%@\",\"totalClothes\":\"%d\",\"weight\":\"%@\",\"itemDetails\":", tagTextFeild.text, @"", totalCountOfClothes, @"0.0"]];
                    }
                    
                    if ([strItemDetails hasSuffix:@","])
                    {
                        strItemDetails = [[strItemDetails substringToIndex:[strItemDetails length]-1]mutableCopy];
                    }
                    
                    [strItemDetails appendString:@"]"];
                    
                    [strBag appendString:strItemDetails];
                }
                
                [strBag appendString:@"}"];
            }
        }
        
        NSData *data = [strBag dataUsingEncoding:NSUTF8StringEncoding];
        id jsonItem = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        [dictSend setObject:jsonItem forKey:@"bag"];
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/save/bag", BASE_URL];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dictSend andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
            {
                @synchronized(self)
                {
                    confirmBtn.enabled = NO;
                    confirmBtn.backgroundColor = SPECIAL_REQ_NON_ACTIVE_COLOR;
                    
                    [selectedItemObj setIsBagConfirmed:[NSNumber numberWithBool:YES]];
                    //[selectedItemObj setTotalAmountOfBag:[[[responseObj objectForKey:@"r"] objectAtIndex:0] objectForKey:@"total"]];
                    
                    NSError *error;
                    if (![[appDel managedObjectContext] save:&error]) {
                        NSLog(@"error %@",error);
                    }
                }
                if ([parentDel respondsToSelector:@selector(itemDetailsAreUploadedWithTag:)])
                    [parentDel performSelector:@selector(itemDetailsAreUploadedWithTag:) withObject:responseObj];
            }
            else
            {
                [appDel displayErrorMessagErrorResponse:responseObj];
            }
        }];
    }
    else
    {
        [AppDelegate showAlertWithMessage:@"Please attach the Bag number" andTitle:@"Alert" andBtnTitle:@"OK"];
        
    }
    

}
-(void) deleteBagBtnClicked
{
    
    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"" message:@"Are you sure do you want to delete the bag" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAc = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (selectedItemObj)
        {
           
            for(UIView *v in [self subviews])
            {
                if (v.tag == BAG_DETAILS_VIEW_TAG)
                    [v removeFromSuperview];
            }
            
            
            NSMutableSet *mutableSet = [NSMutableSet setWithSet:selectedItemObj.order.bagsDetails];
            [mutableSet removeObject:selectedItemObj];
            selectedItemObj.order.bagsDetails = mutableSet;
            
            [selectedItemObj removeItems:selectedItemObj.items];
        }
        NSError *error;
        if (![[appDel managedObjectContext] save:&error]) {
            NSLog(@"error %@",error);
        }
        
        if ([parentDel respondsToSelector:@selector(itemDetailsAreUploadedWithTag:)])
        {
            JobdetailViewController *obj = parentDel;
            
            [obj.arrayBagTags removeObject:selectedItemObj.bagTag];
            
            [parentDel performSelector:@selector(itemDetailsAreUploadedWithTag:) withObject:nil];
        }
    }];
    
     UIAlertAction *nokAc = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         
         [successAlert dismissViewControllerAnimated:YES completion:nil];
     }];
    
    [successAlert addAction:okAc];
    [successAlert addAction:nokAc];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:successAlert animated:YES completion:nil];
}


#pragma mark - TextFeild Delegate methods

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return NO;
}

-(void) textFieldDidBeginEditing:(UITextField *)textField
{
//    if ([parentDel respondsToSelector:@selector(startTagEnter)])
//        [parentDel performSelector:@selector(startTagEnter) withObject:nil];

}

- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    id view = [self superview];
    
    while (view && [view isKindOfClass:[UITableView class]] == NO) {
        view = [view superview];
    }
    
    UITableView *tableView = (UITableView *)view;
    
    CGRect keyboardFrameEnd = [tableView.superview convertRect:keyboardEndFrame toView:nil];
    
    if ([parentDel respondsToSelector:@selector(startTagEnter:)])
        [parentDel performSelector:@selector(startTagEnter:) withObject:NSStringFromCGRect(keyboardFrameEnd)];
    
    [UIView commitAnimations];
    
}


-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField.text length] <= 3 && ![string isEqualToString:@""])
    {
        if (([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound))
        {
            NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
            
            if (textField == tagTextFeild)
            {
                [selectedItemObj setBagTag:str];
            }
            else if (textField == manualTagTextFeild)
            {
                [selectedItemObj setManualBagTag:str];
            }
            
            NSError *error;
            if (![[appDel managedObjectContext] save:&error]) {
                NSLog(@"error %@",error);
            }
            
            return YES;
        }
    }
    else if ([string isEqualToString:@""])
    {
        return YES;
    }
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    if ([parentDel respondsToSelector:@selector(tagEnterfinished)])
//        [parentDel performSelector:@selector(tagEnterfinished) withObject:nil];

    if (textField == tagTextFeild)
    {
        [selectedItemObj setBagTag:textField.text];
    }
    else if (textField == manualTagTextFeild)
    {
        [selectedItemObj setManualBagTag:textField.text];
    }

    NSError *error;
    if (![[appDel managedObjectContext] save:&error]) {
        NSLog(@"error %@",error);
    }

}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
