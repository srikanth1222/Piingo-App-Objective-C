//
//  PriceListViewController.m
//  Piing
//
//  Created by SHASHANK on 27/09/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import "PriceListViewController.h"
#import "UIButton+Position.h"
#import "CustomPopoverView.h"
#import "HMSegmentedControl.h"



@interface PriceListViewController () <CustomPopoverViewDelegate, HMSegmentedControlDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
    UITableView *tblPricing;
    
    UIButton *isExpressBtn;
    
    UIView *view_Express;
    
    NSString *strOrderType, *strJobType;
    
    HMSegmentedControl *segmentImages;
    
    AppDelegate *appDel;
    UIButton *btnArrow;
    
    UILabel *lblLoadWash;
    
    UILabel *lblOrderType;
    CGFloat previousSliderValue;
    
    CustomPopoverView *customPopOverView;
    
    UIButton *btnService;
    
    NSMutableArray *arrayCategory, *arraykey, *arrayRow;
    
    NSArray *arrayTypes;
    
    NSMutableArray *arrayImagePath;
    NSMutableArray *arrayImagePathSelected;
    
    int imagesDownloaded;
    
    NSMutableArray *arrayImagesDownloaded;
    NSMutableArray *arrayImageSelectedDownloaded;
    
    UIView *view_SegmentBG;
    
    UIView *viewArrow;
    
    NSInteger selectedCategoryIndex;
    
    UILabel *lblSwitch;
    
    NSTimer *timerSwitch;
    
    CGFloat yOffsetLW;
    CGFloat yOffsetOthers;
    
    UIView *viewLW;
    
    UIView *view_Bg;
    
    NSArray *arrayServiceTypes;
    
    UIImageView *imgLw;
    
    UILabel *lblL;
    
    NSInteger totalCategories;
    
    //SevenSwitch *mySwitch2;
    //UISegmentedControl *segmentSwitch;
    
    CALayer *topLayer, *bottomLayer;
    
    UIView *view_Bags, *view_Shoes;
    
    HMSegmentedControl *segmentCategory_Shoe, *segmentCategory_Bag;
    
    UISegmentedControl *segmentControlShoe, *segmentControlBag;
    
    NSInteger numberOfDays;
    
    NSInteger selectedAddOnIndex;
    
    NSMutableArray *arrayBagAddOn;
    
    UIView *view_Under_Bag, *viewImageBag;
    
    UILabel *lblBagSizePrice;
    
    UIView *view_Under_Shoes;
    
    UIView *viewImagesShoe;
    
    NSMutableArray *arrayAddOnTypeDesc;
    
    BOOL showAddOnDesc;
    
    UIButton *btnSwitch;
}

@end


@implementation PriceListViewController

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    
    [appDel.sideMenuViewController presentLeftMenuViewController];
    
    // [self setupMenuBarButtonItems];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *viewBG = [[UIView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:viewBG];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapped:)];
    tap.numberOfTouchesRequired = 1;
    tap.numberOfTapsRequired = 1;
    [viewBG addGestureRecognizer:tap];
    
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    arrayCategory = [[NSMutableArray alloc]init];
    arraykey = [[NSMutableArray alloc]init];
    arrayRow = [[NSMutableArray alloc]init];
    arrayImagePath = [[NSMutableArray alloc]init];
    arrayImagePathSelected = [[NSMutableArray alloc]init];
    
    arrayImagesDownloaded = [[NSMutableArray alloc]init];
    arrayImageSelectedDownloaded = [[NSMutableArray alloc]init];
    
    arrayBagAddOn = [[NSMutableArray alloc]init];
    arrayAddOnTypeDesc = [[NSMutableArray alloc]init];
    
    arrayTypes = [[NSArray alloc]initWithObjects:@"LOAD WASH", @"DRY CLEANING", @"GREEN DRY CLEANING", @"WASH & IRON", @"IRONING", @"LEATHER", @"CURTAINS", @"CARPET CLEANING", @"BAGS", @"SHOES", nil];
    
    arrayServiceTypes = [[NSArray alloc]initWithObjects:SERVICETYPE_WF, SERVICETYPE_DC, SERVICETYPE_DCG, SERVICETYPE_WI, SERVICETYPE_IR, SERVICETYPE_LE, SERVICETYPE_CC_DC, SERVICETYPE_CA, SERVICETYPE_BAG, SERVICETYPE_SHOE_CLEAN, nil];
    
    self.navigationController.navigationBarHidden = YES;
    
    float yAxis = 25*MULTIPLYHEIGHT;
    
    btnService = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnService setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    btnService.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
    [self.view addSubview:btnService];
    [btnService setImage:[UIImage imageNamed:@"down_arrow_gray"] forState:UIControlStateNormal];
    [btnService addTarget:self action:@selector(btnServiceTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
    btnService.frame = CGRectMake(0, yAxis, screen_width, 30*MULTIPLYHEIGHT);
    
    
    float btnWidth = 60;
    
    UIButton *btnPE = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPE.frame = CGRectMake(10, yAxis, btnWidth, 40);
    btnPE.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [btnPE setImage:[UIImage imageNamed:@"listButton"] forState:UIControlStateNormal];
    [btnPE addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnPE];
    
    yAxis += 30*MULTIPLYHEIGHT+30*MULTIPLYHEIGHT;
    
    [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes:@{NSForegroundColorAttributeName:[UIColor darkGrayColor], NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1]}];
    
    
    float viewSegmentHeight = 72*MULTIPLYHEIGHT+2;
    
    view_SegmentBG = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, viewSegmentHeight)];
    //view_SegmentBG.backgroundColor = [UIColor colorWithRed:245/255.0 green:245/255.0 blue:245/255.0 alpha:1.0];
    [self.view addSubview:view_SegmentBG];
    
    view_Bags = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, screen_height-yAxis)];
    [self.view addSubview:view_Bags];
    view_Bags.hidden = YES;
    
    view_Shoes = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, screen_height-yAxis)];
    [self.view addSubview:view_Shoes];
    view_Shoes.hidden = YES;
    
    topLayer = [[CALayer alloc]init];
    topLayer.frame = CGRectMake(10*MULTIPLYHEIGHT, 0, view_SegmentBG.frame.size.width-(10*MULTIPLYHEIGHT*2), 1);
    topLayer.backgroundColor = RGBCOLORCODE(240, 240, 240, 1.0).CGColor;
    [view_SegmentBG.layer addSublayer:topLayer];
    
    bottomLayer = [[CALayer alloc]init];
    bottomLayer.frame = CGRectMake(25*MULTIPLYHEIGHT, view_SegmentBG.frame.size.height-1, view_SegmentBG.frame.size.width-(25*MULTIPLYHEIGHT*2), 1);
    bottomLayer.backgroundColor = RGBCOLORCODE(240, 240, 240, 1.0).CGColor;
    [view_SegmentBG.layer addSublayer:bottomLayer];
    
    yAxis += viewSegmentHeight+20*MULTIPLYHEIGHT;
    
    
    viewLW = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis-20*MULTIPLYHEIGHT, screen_width, 100*MULTIPLYHEIGHT)];
    [self.view addSubview:viewLW];
    viewLW.hidden = YES;
    
    imgLw = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, viewLW.frame.size.width, 26*MULTIPLYHEIGHT)];
    imgLw.contentMode = UIViewContentModeScaleAspectFit;
    imgLw.image = [UIImage imageNamed:@"loadwash_price"];
    [viewLW addSubview:imgLw];
    
    lblL = [[UILabel alloc]initWithFrame:CGRectMake(0, imgLw.frame.size.height+5*MULTIPLYHEIGHT, viewLW.frame.size.width, 20*MULTIPLYHEIGHT)];
    lblL.textColor = [UIColor lightGrayColor];
    lblL.textAlignment = NSTextAlignmentCenter;
    lblL.text = [@"Load Wash only for personal wear" uppercaseString];
    lblL.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-6];
    [viewLW addSubview:lblL];
    
    
    
    yOffsetOthers = yAxis;
    float vH = 50*MULTIPLYHEIGHT;
    
    view_Express = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, vH)];
    view_Express.backgroundColor = [UIColor clearColor];
    [self.view addSubview:view_Express];
    
    CGFloat btnX = 0;
    
    float btnHeight = 20*MULTIPLYHEIGHT;
    CGFloat viewW = 150*MULTIPLYHEIGHT;
    
    UIView *viewType = [[UIView alloc]initWithFrame:CGRectMake(screen_width/2-viewW/2, 0, viewW, btnHeight)];
    viewType.layer.cornerRadius = 13.0;
    viewType.backgroundColor = [UIColor clearColor];
    viewType.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
    viewType.layer.borderWidth = 0.6f;
    viewType.layer.masksToBounds = YES;
    [view_Express addSubview:viewType];
    
    for (int i = 0; i < 2; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i+1;
        btn.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-3];
        [viewType addSubview:btn];
        btn.layer.cornerRadius = 13.0;
        
        NSString *str1 = @"REGULAR";
        NSString *str2 = @"EXPRESS";
        
        if (i == 0)
        {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str1];
            [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, [attr length])];
            
            float spacing = 0.5f;
            [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
            
            NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:str1];
            [attrSel addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, [attrSel length])];
            [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
            
            [btn setAttributedTitle:attr forState:UIControlStateNormal];
            [btn setAttributedTitle:attrSel forState:UIControlStateSelected];
            
            //btn.layer.borderColor = LIGHT_BLUE_COLOR.CGColor;
            btn.backgroundColor = BLUE_COLOR;
            btn.selected = YES;
            
            btnSwitch = btn;
        }
        else
        {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str2];
            [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, [attr length])];
            
            float spacing = 1.0f;
            [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
            
            NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:str2];
            [attrSel addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, [attrSel length])];
            [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
            
            [btn setAttributedTitle:attr forState:UIControlStateNormal];
            [btn setAttributedTitle:attrSel forState:UIControlStateSelected];
            
            //btn.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
            
            [viewType sendSubviewToBack:btn];
        }
        
        //btn.layer.borderWidth = 1.0f;
        
        [btn addTarget:self action:@selector(btnOptionsSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        float btnWidth = viewW/2;
        
        btn.frame = CGRectMake(btnX, 0, btnWidth, viewType.frame.size.height);
        
        btnX += btnWidth-1;
    }
    
    //    CGFloat sgX = 65 * MULTIPLYHEIGHT;
    //    CGFloat sgH = 18 * MULTIPLYHEIGHT;
    //
    //    segmentSwitch = [[UISegmentedControl alloc]initWithItems:@[@"REGULAR", @"EXPRESS"]];
    //    segmentSwitch.frame = CGRectMake(sgX, 0, screen_width-(sgX * 2), sgH);
    //    [segmentSwitch setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-3]} forState:UIControlStateSelected];
    //    [segmentSwitch setTitleTextAttributes:@{NSForegroundColorAttributeName : RGBCOLORCODE(64, 143, 210, 1.0), NSFontAttributeName: [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-3]} forState:UIControlStateNormal];
    //    [segmentSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    //    segmentSwitch.tintColor = RGBCOLORCODE(64, 143, 210, 1.0);
    //    segmentSwitch.selectedSegmentIndex = 0;
    //    [view_Express addSubview:segmentSwitch];
    
    //    mySwitch2 = [[SevenSwitch alloc] initWithFrame:CGRectMake((screen_width/2)-(90/2),  0, 90, 25)];
    //    //mySwitch2.center = CGPointMake(self.view.bounds.size.width * 0.5, 30);
    //    //mySwitch2.inactiveColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    //    //mySwitch2.onTintColor = [UIColor colorWithRed:0.45f green:0.58f blue:0.67f alpha:1.00f];
    //    [mySwitch2 addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    //    //    mySwitch2.offImage = [UIImage imageNamed:@"toggle_nonselected"];
    //    //    mySwitch2.onImage = [UIImage imageNamed:@"toggle_selected"];
    //    //mySwitch2.onTintColor = [UIColor colorWithHue:0.08f saturation:0.74f brightness:1.00f alpha:1.00f];
    //    mySwitch2.activeColor = [UIColor clearColor];
    //    mySwitch2.inactiveColor = [UIColor clearColor];
    //    mySwitch2.onTintColor = [UIColor clearColor];
    //    mySwitch2.onLabel.textColor = BLUE_COLOR;
    //    mySwitch2.offLabel.textColor = [UIColor grayColor];
    //    mySwitch2.isRounded = YES;
    //    mySwitch2.shadowColor = [UIColor clearColor];
    //    mySwitch2.activeBorderColor = BLUE_COLOR;
    //    mySwitch2.inactiveBorderColor = RGBCOLORCODE(200, 200, 200, 1.0);
    //    mySwitch2.onThumbImage = [UIImage imageNamed:@"thumb_selected"];
    //    mySwitch2.offThumbImage = [UIImage imageNamed:@"thumb_nonselected"];
    //    mySwitch2.thumbTintColor = [UIColor clearColor];
    //    [mySwitch2 setOn:NO animated:YES];
    //    [view_Express addSubview:mySwitch2];
    
    
    float lblSHeight = 16*MULTIPLYHEIGHT;
    float lY = viewType.frame.size.height+5*MULTIPLYHEIGHT;
    
    lblSwitch = [[UILabel alloc]initWithFrame:CGRectMake(0, lY, screen_width, lblSHeight)];
    lblSwitch.textAlignment = NSTextAlignmentCenter;
    lblSwitch.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-4];
    lblSwitch.textColor = RGBCOLORCODE(200, 200, 200, 1.0);
    [view_Express addSubview:lblSwitch];
    
    yAxis += vH + 3*MULTIPLYHEIGHT;
    
    float lblOX = 95*MULTIPLYHEIGHT;
    float lblOWidth = 45*MULTIPLYHEIGHT;
    
    lblOrderType = [[UILabel alloc]initWithFrame:CGRectMake(lblOX, 0, lblOWidth, vH)];
    lblOrderType.text = @"REGULAR";
    lblOrderType.textColor = RGBCOLORCODE(170, 170, 170, 1.0);
    lblOrderType.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
    //[view_Express addSubview:lblOrderType];
    
    UISlider *sliderPer = [[UISlider alloc]initWithFrame:CGRectMake(lblOX+lblOWidth,  0, 35*MULTIPLYHEIGHT, vH)];
    //sliderPer.thumbTintColor = RGBCOLORCODE(24, 157, 153, 1.0);
    sliderPer.tintColor = RGBCOLORCODE(24, 157, 153, 1.0);
    [sliderPer addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    //[view_Express addSubview:sliderPer];
    sliderPer.continuous = NO;
    [sliderPer setThumbImage:[UIImage imageNamed:@"unselected_thumb"] forState:UIControlStateNormal];
    [sliderPer setThumbImage:[UIImage imageNamed:@"unselected_thumb"] forState:UIControlStateHighlighted];
    
    
    yOffsetLW = yAxis+30*MULTIPLYHEIGHT;
    
    view_Bg = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, screen_height-yAxis)];
    [self.view addSubview:view_Bg];
    
    tblPricing = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screen_width, view_Bg.frame.size.height) style:UITableViewStylePlain];
    tblPricing.backgroundColor = [UIColor clearColor];
    tblPricing.delegate = self;
    tblPricing.dataSource = self;
    [view_Bg addSubview:tblPricing];
    tblPricing.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    float top = 10*MULTIPLYHEIGHT;
    float bottom = 20*MULTIPLYHEIGHT;
    
    tblPricing.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0);
    tblPricing.contentOffset = CGPointZero;
    
    float minusL = 46*MULTIPLYHEIGHT;
    
    lblLoadWash = [[UILabel alloc]initWithFrame:CGRectMake(0, minusL, view_Bg.frame.size.width, view_Bg.frame.size.height-minusL)];
    //lblLoadWash.backgroundColor = RGBCOLORCODE(240, 240, 240, 1.0);
    lblLoadWash.numberOfLines = 0;
    lblLoadWash.textAlignment = NSTextAlignmentCenter;
    [view_Bg addSubview:lblLoadWash];
    lblLoadWash.hidden = YES;
    
    [self.view bringSubviewToFront:view_Express];
    
    
    strOrderType = ORDER_TYPE_REGULAR;
    
    NSMutableAttributedString *attr;
    
    strJobType = SERVICETYPE_DC;
    
    attr = [[NSMutableAttributedString alloc] initWithString:@"DRY CLEANING"];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, [attr length])];
    
    float spacing = 1.0f;
    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
    [btnService setAttributedTitle:attr forState:UIControlStateNormal];
    
    [btnService buttonImageAndTextWithImagePosition:@"RIGHT" WithSpacing:10*MULTIPLYHEIGHT];
    
    UIEdgeInsets imageInsets = btnService.imageEdgeInsets;
    imageInsets.top += 2*MULTIPLYHEIGHT;
    btnService.imageEdgeInsets = imageInsets;
    
    [self getCategories];
}

-(void) btnOptionsSelected:(UIButton *) btn
{
    UIView *viewBg = btn.superview;
    
    for (id sender in viewBg.subviews)
    {
        if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *btn1 = (UIButton *) sender;
            
            if (btn1.tag == btn.tag)
            {
                btn.selected = YES;
                [viewBg bringSubviewToFront:btn];
                
                if (btn.tag == 1)
                {
                    //btn.layer.borderColor = LIGHT_BLUE_COLOR.CGColor;
                    btn.backgroundColor = BLUE_COLOR;
                    
                    strOrderType = ORDER_TYPE_REGULAR;
                }
                else if (btn.tag == 2)
                {
                    //btn.layer.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.7].CGColor;
                    btn.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
                    
                    strOrderType = ORDER_TYPE_EXPRESS;
                }
            }
            else
            {
                //btn1.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                btn1.backgroundColor = [UIColor clearColor];
                btn1.selected = NO;
            }
        }
    }
    
    if (btnSwitch != btn || !btnSwitch)
    {
        [self getCategories];
    }
    
    btnSwitch = btn;
}

-(void) hidelblSwitch
{
    lblSwitch.alpha = 1.0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        
        lblSwitch.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void) showlblSwitch
{
    lblSwitch.alpha = 0.0;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        
        lblSwitch.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
    }];
}



-(void) viewTapped:(UIGestureRecognizer *) tap
{
    [self.view endEditing:YES];
}

-(void) btnServiceTypeClicked:(UIButton *) sender
{
    [self viewTapped:nil];
    
    if (sender.selected)
    {
        [self closeCustomPopover];
    }
    else
    {
        sender.selected = YES;
        
        if (customPopOverView)
        {
            [customPopOverView removeFromSuperview];
            customPopOverView = nil;
        }
        
        customPopOverView = [[CustomPopoverView alloc]initWithArray:arrayTypes SelectedRow:[arrayServiceTypes indexOfObject:strJobType]];
        customPopOverView.delegate = self;
        [self.view addSubview:customPopOverView];
        customPopOverView.alpha = 1.0;
        customPopOverView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        customPopOverView.textColor = RGBCOLORCODE(170, 170, 170, 1.0);
        
        customPopOverView.tblPopover.contentInset = UIEdgeInsetsZero;
        
        CGRect btnRect = [sender.superview convertRect:sender.frame toView:self.view];
        
        customPopOverView.frame = CGRectMake(0, btnRect.origin.y+35, screen_width, 0);
        
        [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
            
            customPopOverView.frame = CGRectMake(0, btnRect.origin.y+35, screen_width, screen_height-(btnRect.origin.y+35));
            
        } completion:^(BOOL finished) {
            
            
        }];
    }
}


#pragma mark CUSTOMPopover Delegate Method

-(void) didSelectFromList:(NSString *) string AtIndex:(NSInteger)row
{
    //selectedCategoryIndex = 0;
    
    btnService.selected = NO;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        
        CGRect frame = customPopOverView.frame;
        frame.size.height = 0;
        customPopOverView.frame = frame;
        
        
    } completion:^(BOOL finished) {
        
        [customPopOverView removeFromSuperview];
        customPopOverView = nil;
        
    }];
    
    selectedAddOnIndex = 0;
    
    strJobType = [arrayServiceTypes objectAtIndex:row];
    
    strJobType = [arrayServiceTypes objectAtIndex:row];
    
    view_Express.hidden = NO;
    
    if (btnSwitch.tag == 2 && [strOrderType isEqualToString:ORDER_TYPE_REGULAR])
    {
        strOrderType = ORDER_TYPE_EXPRESS;
    }
    
    showAddOnDesc = NO;
    
    if ([strJobType isEqualToString:SERVICETYPE_WF] || [strJobType isEqualToString:SERVICETYPE_CA])
    {
        view_SegmentBG.hidden = YES;
        
        segmentImages.hidden = YES;
        lblLoadWash.hidden = NO;
        tblPricing.hidden = YES;
        
        view_Shoes.hidden = YES;
        view_Bags.hidden = YES;
    }
    else if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH])
    {
        strOrderType = ORDER_TYPE_REGULAR;
        //[mySwitch2 setOn:NO animated:YES];
        //segmentSwitch.selectedSegmentIndex = 0;
        
        selectedCategoryIndex = 0;
        
        view_Shoes.hidden = NO;
        view_Bags.hidden = YES;
        
        view_SegmentBG.hidden = YES;
        
        segmentImages.hidden = YES;
        lblLoadWash.hidden = YES;
        tblPricing.hidden = NO;
        
        view_Express.hidden = YES;
    }
    else if ([strJobType isEqualToString:SERVICETYPE_BAG])
    {
        strOrderType = ORDER_TYPE_REGULAR;
        //[mySwitch2 setOn:NO animated:YES];
        //segmentSwitch.selectedSegmentIndex = 0;
        
        selectedCategoryIndex = 0;
        
        view_Bags.hidden = NO;
        
        view_Shoes.hidden = YES;
        
        view_SegmentBG.hidden = YES;
        
        segmentImages.hidden = YES;
        lblLoadWash.hidden = YES;
        tblPricing.hidden = NO;
        
        view_Express.hidden = YES;
    }
    else
    {
        tblPricing.frame = CGRectMake(0, 0, screen_width, view_Bg.frame.size.height);
        
        view_SegmentBG.hidden = NO;
        
        view_Shoes.hidden = YES;
        view_Bags.hidden = YES;
        
        lblLoadWash.hidden = YES;
        tblPricing.hidden = NO;
    }
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:string];
    
    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, [attr length])];
    
    float spacing = 1.0f;
    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
    [btnService setAttributedTitle:attr forState:UIControlStateNormal];
    
    if ([strJobType isEqualToString:SERVICETYPE_WF] || [strJobType isEqualToString:SERVICETYPE_CA])
    {
        CGRect frame = view_Express.frame;
        frame.origin.y = yOffsetLW;
        view_Express.frame = frame;
        
        viewLW.hidden = NO;
        
        view_Bg.backgroundColor = RGBCOLORCODE(240, 240, 240, 1.0);
    }
    else
    {
        CGRect frame = view_Express.frame;
        frame.origin.y = yOffsetOthers;
        view_Express.frame = frame;
        
        viewLW.hidden = YES;
        
        view_Bg.backgroundColor = [UIColor clearColor];
    }
    
    [self getCategories];
}

-(void) closeCustomPopover
{
    btnService.selected = NO;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        
        CGRect frame = customPopOverView.frame;
        frame.size.height = 0;
        customPopOverView.frame = frame;
        
        
    } completion:^(BOOL finished) {
        
        [customPopOverView removeFromSuperview];
        customPopOverView = nil;
        
    }];
}

-(void) getCategories
{
    [self GetDaysToDeliver];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:strOrderType, @"orderType", strJobType, @"serviceType", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@pricing/get", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [arrayCategory removeAllObjects];
            
            [arrayCategory addObjectsFromArray:[responseObj objectForKey:@"prices"]];
            
            [arrayAddOnTypeDesc removeAllObjects];
            
            if ([responseObj objectForKey:@"addOn"])
            {
                [arrayAddOnTypeDesc addObjectsFromArray:[responseObj objectForKey:@"addOn"]];
            }
            
            if ([strJobType isEqualToString:SERVICETYPE_WF] || [strJobType isEqualToString:SERVICETYPE_CA])
            {
                [self setloadWashText:[responseObj objectForKey:@"prices"]];
            }
            else if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN] || [strJobType isEqualToString:SERVICETYPE_SHOE_POLISH])
            {
                [self showShoeServiceTypes];
            }
            else if ([strJobType isEqualToString:SERVICETYPE_BAG])
            {
                [self showBagCategories];
            }
            else
            {
                if ([arrayCategory count])
                {
                    [self createCategories];
                }
                else
                {
                    [appDel showAlertWithMessage:@"No data" andTitle:@"" andBtnTitle:@"OK"];
                }
            }
        }
        else
        {
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

-(void) showBagCategories
{
    for (__strong id view in view_Bags.subviews)
    {
        [view removeFromSuperview];
        view = nil;
    }
    
    [self shoeAndBagCleaningData];
    
    CGFloat xAxis = 10*MULTIPLYHEIGHT;
    
    CGFloat yAxis = 10*MULTIPLYHEIGHT;
    CGFloat btnH = 20*MULTIPLYHEIGHT;
    
    UIScrollView *scrollBagsCategory = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, btnH)];
    [view_Bags addSubview:scrollBagsCategory];
    scrollBagsCategory.showsHorizontalScrollIndicator = NO;
    
    for (int i = 0; i < [arraykey count]; i++)
    {
        UIButton *btnSer = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSer.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
        btnSer.tag = i+1;
        
        NSString *str = [arraykey objectAtIndex:i];
        
        NSMutableAttributedString *mainAttr = [[NSMutableAttributedString alloc]initWithString:str];
        [mainAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1], NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, str.length)];
        [mainAttr addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, mainAttr.length)];
        
        [btnSer setAttributedTitle:mainAttr forState:UIControlStateSelected];
        
        NSMutableAttributedString *mainAttr1 = [[NSMutableAttributedString alloc]initWithString:str];
        [mainAttr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1], NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, str.length)];
        [mainAttr1 addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, mainAttr1.length)];
        
        [btnSer setAttributedTitle:mainAttr1 forState:UIControlStateNormal];
        
        CGSize size = [AppDelegate getAttributedTextHeightForText:mainAttr WithWidth:screen_width];
        
        btnSer.frame = CGRectMake(xAxis, 0, size.width + 20*MULTIPLYHEIGHT, btnH);
        [btnSer addTarget:self action:@selector(btnBagCategoryClicked:) forControlEvents:UIControlEventTouchUpInside];
        [scrollBagsCategory addSubview:btnSer];
        
        xAxis += size.width + 20*MULTIPLYHEIGHT + 15*MULTIPLYHEIGHT;
        
        if (i == selectedCategoryIndex)
        {
            btnSer.selected = YES;
            
            btnSer.layer.borderColor = [UIColor grayColor].CGColor;
            btnSer.layer.borderWidth = 1.0;
            btnSer.layer.cornerRadius = 10*MULTIPLYHEIGHT;
        }
    }
    
    [scrollBagsCategory setContentSize:CGSizeMake(xAxis, 0)];
    
    yAxis += btnH + 10*MULTIPLYHEIGHT;
    
    [self addBagData:yAxis];
}

-(void) btnBagCategoryClicked:(UIButton *) btn
{
    UIScrollView *scroll = (UIScrollView *) btn.superview;
    
    for (id view in scroll.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *bt = (UIButton *) view;
            bt.selected = NO;
            bt.layer.borderWidth = 0.0;
        }
    }
    
    btn.selected = YES;
    btn.layer.borderColor = [UIColor grayColor].CGColor;
    btn.layer.borderWidth = 1.0;
    btn.layer.cornerRadius = 10*MULTIPLYHEIGHT;
    
    UIButton *btnNext = [scroll viewWithTag:btn.tag + 1];
    
    if (!btnNext)
    {
        btnNext = btn;
    }
    
    if (btnNext.frame.origin.x + btnNext.frame.size.width > screen_width)
    {
        [scroll setContentOffset:CGPointMake((btnNext.frame.origin.x + btnNext.frame.size.width + 15*MULTIPLYHEIGHT) - screen_width, 0) animated:YES];
    }
    else
    {
        [scroll setContentOffset:CGPointZero animated:YES];
    }
    
    selectedCategoryIndex = btn.tag-1;
    
    [self addBagData:scroll.frame.origin.y+scroll.frame.size.height+10*MULTIPLYHEIGHT];
}

-(void) addBagData:(CGFloat) yAxis
{
    for (__strong id view in view_Bags.subviews)
    {
        if ([view isKindOfClass:[UIScrollView class]])
        {
            
        }
        else
        {
            [view removeFromSuperview];
            view = nil;
        }
    }
    
    tblPricing.hidden = YES;
    
    view_Under_Bag = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, view_Bags.frame.size.height-yAxis)];
    view_Under_Bag.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    [view_Bags addSubview:view_Under_Bag];
    
    [self shoeAndBagCleaningData];
    
    [arrayBagAddOn removeAllObjects];
    
    if ([arrayCategory count])
    {
        NSDictionary *dictRow = [arrayCategory objectAtIndex:selectedCategoryIndex];
        NSArray *arr = [NSArray arrayWithArray:[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]]];
        
        for (int i = 0; i < [arr count]; i++)
        {
            NSString *strC = [[[[arr objectAtIndex:i] objectForKey:@"n"] componentsSeparatedByString:@"^^"] objectAtIndex:1];
            
            [arrayBagAddOn addObject:strC];
        }
    }
    else
    {
        NSLog(@"No Bags Data");
        
        return;
    }
    
    yAxis = 0;
    
    float segmentCHeight = 30*MULTIPLYHEIGHT;
    
    segmentCategory_Bag = [[HMSegmentedControl alloc]initWithSectionTitles:arrayBagAddOn];
    float left = 15*MULTIPLYHEIGHT;
    float right = 15*MULTIPLYHEIGHT;
    segmentCategory_Bag.segmentEdgeInset = UIEdgeInsetsMake(0, left, 0, right);
    segmentCategory_Bag.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 11*MULTIPLYHEIGHT, 0, 18*MULTIPLYHEIGHT);
    segmentCategory_Bag.frame = CGRectMake(0, yAxis, screen_width, segmentCHeight);
    segmentCategory_Bag.borderType = HMSegmentedControlBorderTypeNone;
    segmentCategory_Bag.backgroundColor = [UIColor clearColor];
    segmentCategory_Bag.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    segmentCategory_Bag.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentCategory_Bag.selectionIndicatorColor = BLUE_COLOR;
    segmentCategory_Bag.selectionIndicatorHeight = 2.0;
    segmentCategory_Bag.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
    segmentCategory_Bag.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
    [segmentCategory_Bag addTarget:self action:@selector(segmentedControlBagChangedValue:) forControlEvents:UIControlEventValueChanged];
    [view_Under_Bag addSubview:segmentCategory_Bag];
    
    segmentCategory_Bag.selectedSegmentIndex = selectedAddOnIndex;
    
    yAxis += segmentCHeight + 30*MULTIPLYHEIGHT;
    
    CGFloat sgX = 60 * MULTIPLYHEIGHT;
    CGFloat sgH = 19 * MULTIPLYHEIGHT;
    
    segmentControlBag = [[UISegmentedControl alloc]initWithItems:@[@"CLEANING", @"ADD-ONS"]];
    segmentControlBag.frame = CGRectMake(sgX, yAxis, screen_width-(sgX * 2), sgH);
    [view_Under_Bag addSubview:segmentControlBag];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3], NSKernAttributeName : @(1.0)} forState:UIControlStateSelected];
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3], NSKernAttributeName : @(1.0)} forState:UIControlStateNormal];
    
    [segmentControlBag addTarget:self action:@selector(segmentChangeBag:) forControlEvents:UIControlEventValueChanged];
    segmentControlBag.tintColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
    segmentControlBag.selectedSegmentIndex = 0;
    
    segmentControlBag.layer.cornerRadius = 12.0;
    segmentControlBag.layer.borderColor = BLUE_COLOR.CGColor;
    segmentControlBag.layer.borderWidth = 0.6f;
    segmentControlBag.layer.masksToBounds = YES;
    
    yAxis += sgH + 35*MULTIPLYHEIGHT;
    
    
    viewImageBag = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, view_Under_Bag.frame.size.height-yAxis)];
    [view_Under_Bag addSubview:viewImageBag];
    
    CGFloat imgSW = 60*MULTIPLYHEIGHT;
    CGFloat imgX = screen_width/2-imgSW/2;
    
    CGFloat localYaxis = 0;
    
    UIImageView *imgBag = [[UIImageView alloc]initWithFrame:CGRectMake(imgX, localYaxis, imgSW, imgSW)];
    imgBag.image = [UIImage imageNamed:@"bags"];
    imgBag.contentMode = UIViewContentModeScaleAspectFit;
    [viewImageBag addSubview:imgBag];
    
    localYaxis += imgSW+20*MULTIPLYHEIGHT;
    
    NSString *strBagDesc = @"";
    
    strBagDesc = @" Your bag is handled with utmost care as we give it a thorough cleaning for a premium look, a luxurious feel and a long-lasting lustre.";
    
    CGFloat lblDX = 30*MULTIPLYHEIGHT;
    CGFloat lblDW = screen_width-lblDX*2;
    
    UILabel *lblDesc = [[UILabel alloc]initWithFrame:CGRectMake(lblDX, localYaxis, lblDW, 20)];
    lblDesc.numberOfLines = 0;
    lblDesc.textAlignment = NSTextAlignmentCenter;
    lblDesc.textColor = [UIColor grayColor];
    [viewImageBag addSubview:lblDesc];
    
    NSMutableAttributedString *lblAttr = [[NSMutableAttributedString alloc]initWithString:strBagDesc];
    
    [lblAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(0.5)} range:NSMakeRange(0, lblAttr.string.length)];
    
    lblDesc.attributedText = lblAttr;
    
    CGSize size = [AppDelegate getAttributedTextHeightForText:lblAttr WithWidth:lblDesc.frame.size.width];
    
    CGRect rect = lblDesc.frame;
    rect.size.height = size.height;
    lblDesc.frame = rect;
    
    localYaxis += lblDesc.frame.size.height + 25*MULTIPLYHEIGHT;
    
    lblBagSizePrice = [[UILabel alloc]initWithFrame:CGRectMake(0, localYaxis, screen_width, 20)];
    lblBagSizePrice.numberOfLines = 0;
    lblBagSizePrice.textAlignment = NSTextAlignmentCenter;
    lblBagSizePrice.textColor = [UIColor grayColor];
    [viewImageBag addSubview:lblBagSizePrice];
    
    NSString *strPairPrice = [NSString stringWithFormat:@"$ %.2f", [[[arrayRow objectAtIndex:0] objectForKey:@"ip"] floatValue]];
    
    NSMutableAttributedString *lblPairAttr = [[NSMutableAttributedString alloc]initWithString:strPairPrice];
    
    [lblPairAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE+2], NSKernAttributeName : @(1.0)} range:NSMakeRange(0, strPairPrice.length)];
    
    lblBagSizePrice.attributedText = lblPairAttr;
    
    size = [AppDelegate getAttributedTextHeightForText:lblPairAttr WithWidth:lblBagSizePrice.frame.size.width];
    
    rect = lblBagSizePrice.frame;
    rect.size.height = size.height;
    lblBagSizePrice.frame = rect;
}

-(void) segmentedControlBagChangedValue:(HMSegmentedControl *) segment
{
    selectedAddOnIndex = segment.selectedSegmentIndex;
    
    if (segmentControlBag.selectedSegmentIndex == 0)
    {
        [self shoeAndBagCleaningData];
    }
    else
    {
        [self bagAddonService];
    }
}

-(void) segmentChangeBag:(UISegmentedControl *) segment
{
    if (segment.selectedSegmentIndex == 0)
    {
        [self shoeAndBagCleaningData];
    }
    else
    {
        showAddOnDesc = YES;
        
        [self bagAddonService];
    }
}

-(void) bagAddonService
{
    tblPricing.frame = CGRectMake(0, 0, screen_width, view_Bg.frame.size.height);
    tblPricing.hidden = NO;
    
    viewImageBag.hidden = YES;
    
    NSDictionary *dictRow = [arrayCategory objectAtIndex:selectedCategoryIndex];
    NSDictionary *dict1 = [[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]] objectAtIndex:selectedAddOnIndex];
    
    [arrayRow removeAllObjects];
    
    [arrayRow addObjectsFromArray:[dict1 objectForKey:@"addOn"]];
    
    [tblPricing setContentOffset:CGPointZero];
    
    [tblPricing reloadData];
    
}


-(void) showShoeServiceTypes
{
    for (__strong id view in view_Shoes.subviews)
    {
        [view removeFromSuperview];
        view = nil;
    }
    
    [self shoeAndBagCleaningData];
    
    NSArray *arraySer = @[@"CLEANING", @"POLISHING & WAXING"];
    
    CGFloat xAxis = 30*MULTIPLYHEIGHT;
    
    CGFloat yAxis = 10*MULTIPLYHEIGHT;
    CGFloat btnH = 20*MULTIPLYHEIGHT;
    
    for (int i = 0; i < [arraySer count]; i++)
    {
        UIButton *btnSer = [UIButton buttonWithType:UIButtonTypeCustom];
        btnSer.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
        btnSer.tag = i+1;
        
        NSString *str = [arraySer objectAtIndex:i];
        
        NSMutableAttributedString *mainAttr = [[NSMutableAttributedString alloc]initWithString:str];
        [mainAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3], NSForegroundColorAttributeName:[UIColor blackColor]} range:NSMakeRange(0, str.length)];
        [mainAttr addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, mainAttr.length)];
        
        [btnSer setAttributedTitle:mainAttr forState:UIControlStateSelected];
        
        NSMutableAttributedString *mainAttr1 = [[NSMutableAttributedString alloc]initWithString:str];
        [mainAttr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3], NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, str.length)];
        [mainAttr1 addAttribute:NSKernAttributeName value:@(1.0) range:NSMakeRange(0, mainAttr1.length)];
        
        [btnSer setAttributedTitle:mainAttr1 forState:UIControlStateNormal];
        
        CGSize size = [AppDelegate getAttributedTextHeightForText:mainAttr WithWidth:screen_width];
        
        btnSer.frame = CGRectMake(xAxis, yAxis, size.width + 15*MULTIPLYHEIGHT, btnH);
        [btnSer addTarget:self action:@selector(btnShoeServiceTypeClicked:) forControlEvents:UIControlEventTouchUpInside];
        [view_Shoes addSubview:btnSer];
        
        xAxis += size.width + 15*MULTIPLYHEIGHT + 30*MULTIPLYHEIGHT;
        
        if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN] && i == 0)
        {
            btnSer.selected = YES;
            
            btnSer.layer.borderColor = [UIColor grayColor].CGColor;
            btnSer.layer.borderWidth = 1.0;
            btnSer.layer.cornerRadius = 8*MULTIPLYHEIGHT;
        }
        else if ([strJobType isEqualToString:SERVICETYPE_SHOE_POLISH] && i == 1)
        {
            btnSer.selected = YES;
            
            btnSer.layer.borderColor = [UIColor grayColor].CGColor;
            btnSer.layer.borderWidth = 1.0;
            btnSer.layer.cornerRadius = 8*MULTIPLYHEIGHT;
        }
    }
    
    yAxis += btnH + 10*MULTIPLYHEIGHT;
    
    view_Under_Shoes = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, view_Shoes.frame.size.height-yAxis)];
    view_Under_Shoes.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.1];
    [view_Shoes addSubview:view_Under_Shoes];
    
    //if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
    {
        
        if (![arraykey count])
        {
            NSLog(@"No Shoe Data");
            
            return;
        }
        
        yAxis = 0;
        
        float segmentCHeight = 30*MULTIPLYHEIGHT;
        
        segmentCategory_Shoe = [[HMSegmentedControl alloc]initWithSectionTitles:arraykey];
        float left = 15*MULTIPLYHEIGHT;
        float right = 15*MULTIPLYHEIGHT;
        segmentCategory_Shoe.segmentEdgeInset = UIEdgeInsetsMake(0, left, 0, right);
        segmentCategory_Shoe.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, 11*MULTIPLYHEIGHT, 0, 18*MULTIPLYHEIGHT);
        segmentCategory_Shoe.frame = CGRectMake(0, yAxis, screen_width, segmentCHeight);
        segmentCategory_Shoe.borderType = HMSegmentedControlBorderTypeNone;
        segmentCategory_Shoe.backgroundColor = [UIColor clearColor];
        segmentCategory_Shoe.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
        segmentCategory_Shoe.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        segmentCategory_Shoe.selectionIndicatorColor = BLUE_COLOR;
        segmentCategory_Shoe.selectionIndicatorHeight = 2.0;
        segmentCategory_Shoe.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
        segmentCategory_Shoe.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
        [segmentCategory_Shoe addTarget:self action:@selector(segmentedControlShoeChangedValue:) forControlEvents:UIControlEventValueChanged];
        [view_Under_Shoes addSubview:segmentCategory_Shoe];
        
        yAxis += segmentCHeight + 30*MULTIPLYHEIGHT;
        
        if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
        {
            CGFloat sgX = 60 * MULTIPLYHEIGHT;
            CGFloat sgH = 19 * MULTIPLYHEIGHT;
            
            segmentControlShoe = [[UISegmentedControl alloc]initWithItems:@[@"CLEANING",@"ADD-ONS"]];
            segmentControlShoe.frame = CGRectMake(sgX, yAxis, screen_width-(sgX * 2), sgH);
            [view_Under_Shoes addSubview:segmentControlShoe];
            
            [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3], NSKernAttributeName : @(1.0)} forState:UIControlStateSelected];
            [[UISegmentedControl appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3], NSKernAttributeName : @(1.0)} forState:UIControlStateNormal];
            
            [segmentControlShoe addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
            segmentControlShoe.tintColor = [UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0];
            segmentControlShoe.selectedSegmentIndex = 0;
            
            segmentControlShoe.layer.cornerRadius = 12.0;
            segmentControlShoe.layer.borderColor = BLUE_COLOR.CGColor;
            segmentControlShoe.layer.borderWidth = 0.6f;
            segmentControlShoe.layer.masksToBounds = YES;
            
            yAxis += sgH + 35*MULTIPLYHEIGHT;
        }
    }
    //    else
    //    {
    //        yAxis = 60*MULTIPLYHEIGHT;
    //    }
    
    
    CGFloat imgSW = 60*MULTIPLYHEIGHT;
    CGFloat imgX = screen_width/2-imgSW/2;
    
    viewImagesShoe = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, view_Under_Shoes.frame.size.height-yAxis)];
    [view_Under_Shoes addSubview:viewImagesShoe];
    
    CGFloat localYaxis = 0;
    
    UIImageView *imgShoe = [[UIImageView alloc]initWithFrame:CGRectMake(imgX, localYaxis, imgSW, imgSW)];
    imgShoe.image = [UIImage imageNamed:@"shoes"];
    imgShoe.contentMode = UIViewContentModeScaleAspectFit;
    [viewImagesShoe addSubview:imgShoe];
    
    
    NSString *strShoeDesc;
    
    if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
    {
        strShoeDesc = @"A thorough cleaning inside out along with a special polish, waxing and conditioning session will make your shoes last long and look shiny as new";
    }
    else
    {
        strShoeDesc = @"Removal of dirt and a coat of shoe wax and leather balm will have your shoes looking shiny & stylish as ever";
    }
    
    localYaxis += imgSW+20*MULTIPLYHEIGHT;
    
    CGFloat lblDX = 23*MULTIPLYHEIGHT;
    CGFloat lblDW = screen_width-lblDX*2;
    
    UILabel *lblDesc = [[UILabel alloc]initWithFrame:CGRectMake(lblDX, localYaxis, lblDW, 20)];
    lblDesc.numberOfLines = 0;
    lblDesc.textAlignment = NSTextAlignmentCenter;
    lblDesc.textColor = [UIColor grayColor];
    [viewImagesShoe addSubview:lblDesc];
    
    NSMutableAttributedString *lblAttr = [[NSMutableAttributedString alloc]initWithString:strShoeDesc];
    
    [lblAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(0.5)} range:NSMakeRange(0, lblAttr.string.length)];
    
    lblDesc.attributedText = lblAttr;
    
    CGSize size = [AppDelegate getAttributedTextHeightForText:lblAttr WithWidth:lblDesc.frame.size.width];
    
    CGRect rect = lblDesc.frame;
    rect.size.height = size.height;
    lblDesc.frame = rect;
    
    localYaxis += lblDesc.frame.size.height + 15*MULTIPLYHEIGHT;
    
    if ([strJobType isEqualToString:SERVICETYPE_SHOE_CLEAN])
    {
        tblPricing.hidden = NO;
        tblPricing.frame = CGRectMake(0, 130*MULTIPLYHEIGHT, screen_width, view_Under_Shoes.frame.size.height-130*MULTIPLYHEIGHT);
    }
    else
    {
        localYaxis += 20*MULTIPLYHEIGHT;
        
        tblPricing.hidden = YES;
        
        UILabel *lblPair = [[UILabel alloc]initWithFrame:CGRectMake(0, localYaxis, screen_width, 20)];
        lblPair.numberOfLines = 0;
        lblPair.textAlignment = NSTextAlignmentCenter;
        lblPair.textColor = [UIColor grayColor];
        [viewImagesShoe addSubview:lblPair];
        
        NSString *strPer = @"PER PAIR";
        
        NSString *strPairPrice = [NSString stringWithFormat:@"$ %.2f", [[[arrayRow objectAtIndex:0] objectForKey:@"ip"] floatValue]];
        
        NSMutableAttributedString *lblPairAttr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ %@", strPairPrice, strPer]];
        
        [lblPairAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE+2], NSKernAttributeName : @(1.0)} range:NSMakeRange(0, strPairPrice.length)];
        
        [lblPairAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2], NSKernAttributeName : @(1.0)} range:NSMakeRange(strPairPrice.length+1, strPer.length)];
        
        lblPair.attributedText = lblPairAttr;
        
        CGSize size = [AppDelegate getAttributedTextHeightForText:lblPairAttr WithWidth:lblPair.frame.size.width];
        
        CGRect rect = lblPair.frame;
        rect.size.height = size.height;
        lblPair.frame = rect;
        
        localYaxis += lblPair.frame.size.height+5*MULTIPLYHEIGHT;
        
        UILabel *lblDays = [[UILabel alloc]initWithFrame:CGRectMake(0, localYaxis, screen_width, 20*MULTIPLYHEIGHT)];
        lblDays.textAlignment = NSTextAlignmentCenter;
        [viewImagesShoe addSubview:lblDays];
        
        NSString *strDays = [NSString stringWithFormat:@"DELIVERY IN %ld DAYS", (long)numberOfDays];
        
        NSMutableAttributedString *lblAttrDays = [[NSMutableAttributedString alloc]initWithString:strDays];
        
        [lblAttrDays addAttributes:@{NSForegroundColorAttributeName : [UIColor lightGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(0.6)} range:NSMakeRange(0, lblAttrDays.string.length)];
        
        lblDays.attributedText = lblAttrDays;
    }
}

-(void) shoeAndBagCleaningData
{
    [arraykey removeAllObjects];
    
    for (int i=0; i<[arrayCategory count]; i++)
    {
        NSArray *arr = [[arrayCategory objectAtIndex:i]allKeys];
        
        for (NSString *str in arr)
        {
            if ([str isEqualToString:@"imgpath"])
            {
            }
            else if ([str isEqualToString:@"imgpathblue"])
            {
            }
            else
            {
                [arraykey addObject:str];
            }
        }
    }
    
    [arrayRow removeAllObjects];
    
    if ([arrayCategory count])
    {
        NSDictionary *dictRow = [arrayCategory objectAtIndex:selectedCategoryIndex];
        
        if ([strJobType isEqualToString:SERVICETYPE_BAG])
        {
            [arrayRow addObject:[[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]] objectAtIndex:selectedAddOnIndex]];
            
            if (viewImageBag)
            {
                viewImageBag.hidden = NO;
                
                tblPricing.hidden = YES;
                
                NSString *strPairPrice = [NSString stringWithFormat:@"$ %.2f", [[[arrayRow objectAtIndex:0] objectForKey:@"ip"] floatValue]];
                
                NSMutableAttributedString *lblPairAttr = [[NSMutableAttributedString alloc]initWithString:strPairPrice];
                
                [lblPairAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE+2], NSKernAttributeName : @(1.0)} range:NSMakeRange(0, strPairPrice.length)];
                
                lblBagSizePrice.attributedText = lblPairAttr;
                
                CGSize size = [AppDelegate getAttributedTextHeightForText:lblPairAttr WithWidth:lblBagSizePrice.frame.size.width];
                
                CGRect rect = lblBagSizePrice.frame;
                rect.size.height = size.height;
                lblBagSizePrice.frame = rect;
            }
        }
        else
        {
            [arrayRow addObjectsFromArray:[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]]];
            
            viewImagesShoe.hidden = NO;
            
            tblPricing.frame = CGRectMake(0, 130*MULTIPLYHEIGHT, screen_width, viewImagesShoe.frame.size.height-130*MULTIPLYHEIGHT);
        }
    }
    
    [tblPricing reloadData];
}

-(void) btnShoeServiceTypeClicked:(UIButton *) sender
{
    UIButton *btn1 = [view_Shoes viewWithTag:1];
    UIButton *btn2 = [view_Shoes viewWithTag:2];
    
    btn1.selected = NO;
    btn2.selected = NO;
    
    btn1.layer.borderWidth = 0.0;
    btn2.layer.borderWidth = 0.0;
    
    selectedCategoryIndex = 0;
    
    if (btn1 == sender)
    {
        strJobType = SERVICETYPE_SHOE_CLEAN;
        
        strJobType = SERVICETYPE_SHOE_CLEAN;
        
        btn1.selected = YES;
        
        btn1.layer.borderColor = [UIColor grayColor].CGColor;
        btn1.layer.borderWidth = 1.0;
        btn1.layer.cornerRadius = 8*MULTIPLYHEIGHT;
        
        [self getCategories];
    }
    else
    {
        strJobType = SERVICETYPE_SHOE_POLISH;
        
        strJobType = SERVICETYPE_SHOE_POLISH;
        
        btn2.selected = YES;
        
        btn2.layer.borderColor = [UIColor grayColor].CGColor;
        btn2.layer.borderWidth = 1.0;
        btn2.layer.cornerRadius = 8*MULTIPLYHEIGHT;
        
        [self getCategories];
    }
}

-(void) segmentedControlShoeChangedValue:(HMSegmentedControl *) segment
{
    selectedCategoryIndex = segment.selectedSegmentIndex;
    
    if (segmentControlShoe.selectedSegmentIndex == 0)
    {
        [arrayRow removeAllObjects];
        
        NSDictionary *dictRow = [arrayCategory objectAtIndex:selectedCategoryIndex];
        [arrayRow addObjectsFromArray:[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]]];
        
        [tblPricing reloadData];
    }
    else
    {
        [self shoeAddonService];
    }
}

-(void) segmentChange:(UISegmentedControl *) segment
{
    if (segment.selectedSegmentIndex == 0)
    {
        showAddOnDesc = NO;
        
        [self shoeAndBagCleaningData];
    }
    else
    {
        showAddOnDesc = YES;
        
        [self shoeAddonService];
    }
}

-(void) shoeAddonService
{
    viewImagesShoe.hidden = YES;
    
    tblPricing.frame = CGRectMake(0, 0, screen_width, view_Bg.frame.size.height);
    
    NSDictionary *dictRow = [arrayCategory objectAtIndex:selectedCategoryIndex];
    NSDictionary *dict1 = [[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]] objectAtIndex:0];
    
    [arrayRow removeAllObjects];
    
    [arrayRow addObjectsFromArray:[dict1 objectForKey:@"addOn"]];
    
    [tblPricing setContentOffset:CGPointZero];
    
    [tblPricing reloadData];
    
}

-(void) createCategories
{
    [arraykey removeAllObjects];
    [arrayImagePath removeAllObjects];
    [arrayImagePathSelected removeAllObjects];
    
    for (int i=0; i<[arrayCategory count]; i++)
    {
        NSArray *arr = [[arrayCategory objectAtIndex:i]allKeys];
        
        for (NSString *str in arr)
        {
            if ([str isEqualToString:@"imgpath"])
            {
                [arrayImagePath addObject:[[arrayCategory objectAtIndex:i] objectForKey:str]];
            }
            else if ([str isEqualToString:@"imgpathblue"])
            {
                [arrayImagePathSelected addObject:[[arrayCategory objectAtIndex:i] objectForKey:str]];
            }
            else
            {
                [arraykey addObject:str];
            }
        }
    }
    
    if (totalCategories == [arraykey count])
    {
        
    }
    else
    {
        selectedCategoryIndex = 0;
        totalCategories = [arraykey count];
    }
    
    [arrayRow removeAllObjects];
    
    NSDictionary *dictRow = [arrayCategory objectAtIndex:selectedCategoryIndex];
    [arrayRow addObjectsFromArray:[dictRow objectForKey:[arraykey objectAtIndex:selectedCategoryIndex]]];
    
    [tblPricing reloadData];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    imagesDownloaded = 0;
    
    [arrayImagesDownloaded removeAllObjects];
    [arrayImageSelectedDownloaded removeAllObjects];
    
    [self downloadImagePath];
    
}

-(void) downloadImagePath
{
    
    if ([appDel.dictPriceImages objectForKey:[arrayImagePath objectAtIndex:imagesDownloaded]])
    {
        UIImage *image = [appDel.dictPriceImages objectForKey:[arrayImagePath objectAtIndex:imagesDownloaded]];
        
        [arrayImagesDownloaded addObject:image];
        
        imagesDownloaded++;
        
        if ([arrayImagePath count]-1 >= imagesDownloaded)
        {
            [self downloadImagePath];
        }
        else
        {
            imagesDownloaded = 0;
            [self downloadImagePathSelected];
        }
    }
    else
    {
        if ([[arrayImagePath objectAtIndex:imagesDownloaded] length])
        {
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[arrayImagePath objectAtIndex:imagesDownloaded]]] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                
                if (!connectionError && data)
                {
                    UIImage *image = [UIImage imageWithData:data];
                    
                    [arrayImagesDownloaded addObject:image];
                    
                    [appDel.dictPriceImages setObject:image forKey:[arrayImagePath objectAtIndex:imagesDownloaded]];
                    
                    imagesDownloaded++;
                    
                    if ([arrayImagePath count]-1 >= imagesDownloaded)
                    {
                        [self downloadImagePath];
                    }
                    else
                    {
                        imagesDownloaded = 0;
                        [self downloadImagePathSelected];
                    }
                }
            }];
        }
        else
        {
            UIImage *image = [UIImage imageNamed:@"promotions_loading"];
            
            [arrayImagesDownloaded addObject:image];
            
            [appDel.dictPriceImages setObject:image forKey:[arrayImagePath objectAtIndex:imagesDownloaded]];
            
            imagesDownloaded++;
            
            if ([arrayImagePath count]-1 >= imagesDownloaded)
            {
                [self downloadImagePath];
            }
            else
            {
                imagesDownloaded = 0;
                [self downloadImagePathSelected];
            }
        }
    }
    
}

-(void) downloadImagePathSelected
{
    if ([appDel.dictPriceSelectedImages objectForKey:[arrayImagePathSelected objectAtIndex:imagesDownloaded]])
    {
        UIImage *image = [appDel.dictPriceSelectedImages objectForKey:[arrayImagePathSelected objectAtIndex:imagesDownloaded]];
        
        [arrayImageSelectedDownloaded addObject:image];
        
        imagesDownloaded++;
        
        if ([arrayImagePathSelected count]-1 >= imagesDownloaded)
        {
            [self downloadImagePathSelected];
        }
        else
        {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                [self createSegmentcategory];
                
            }];
        }
    }
    else
    {
        if ([[arrayImagePathSelected objectAtIndex:imagesDownloaded] length])
        {
            [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[arrayImagePathSelected objectAtIndex:imagesDownloaded]]] queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                
                if (!connectionError && data)
                {
                    UIImage *image = [UIImage imageWithData:data];
                    
                    [arrayImageSelectedDownloaded addObject:image];
                    
                    [appDel.dictPriceSelectedImages setObject:image forKey:[arrayImagePathSelected objectAtIndex:imagesDownloaded]];
                    
                    imagesDownloaded++;
                    
                    if ([arrayImagePathSelected count]-1 >= imagesDownloaded)
                    {
                        [self downloadImagePathSelected];
                    }
                    else
                    {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            
                            [self createSegmentcategory];
                            
                        }];
                    }
                }
            }];
        }
        else
        {
            UIImage *image = [UIImage imageNamed:@"promotions_loading"];
            
            [arrayImageSelectedDownloaded addObject:image];
            
            [appDel.dictPriceSelectedImages setObject:image forKey:[arrayImagePathSelected objectAtIndex:imagesDownloaded]];
            
            imagesDownloaded++;
            
            if ([arrayImagePathSelected count]-1 >= imagesDownloaded)
            {
                [self downloadImagePathSelected];
            }
            else
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self createSegmentcategory];
                    
                }];
            }
        }
    }
}

-(void) createSegmentcategory
{
    for (__strong id view in view_SegmentBG.subviews)
    {
        [view removeFromSuperview];
        view = nil;
    }
    
    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
    
    float segmentHeight = 72*MULTIPLYHEIGHT;
    
    segmentImages = [[HMSegmentedControl alloc]initWithSectionImages:arrayImagesDownloaded sectionSelectedImages:arrayImageSelectedDownloaded titlesForSections:arraykey];
    segmentImages.delegate = self;
    segmentImages.frame = CGRectMake(0, 1, screen_width, segmentHeight);
    
    float left = 15*MULTIPLYHEIGHT;
    float right = 15*MULTIPLYHEIGHT;
    
    segmentImages.segmentEdgeInset = UIEdgeInsetsMake(0, left, 0, right);
    segmentImages.backgroundColor = RGBCOLORCODE(252, 252, 252, 1.0);
    segmentImages.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleFixed;
    segmentImages.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    segmentImages.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1]};
    segmentImages.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : BLUE_COLOR, NSFontAttributeName : [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1]};
    [segmentImages addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [view_SegmentBG addSubview:segmentImages];
    segmentImages.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    segmentImages.selectionIndicatorColor = [UIColor clearColor];
    segmentImages.selectionIndicatorBoxOpacity = 1.0f;
    segmentImages.verticalDividerEnabled = NO;
    segmentImages.verticalDividerColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
    segmentImages.verticalDividerWidth = 1;
    
    __weak typeof(self) weakSelf = self;
    
    [segmentImages setIndexChangeBlock:^(NSInteger index) {
        
        [weakSelf performSelector:@selector(scrollAnimated) withObject:nil afterDelay:0.4];
    }];
    
    //[self segmentedControlChangedValue:segmentImages];
    
    segmentImages.selectedSegmentIndex = selectedCategoryIndex;
    
    float btnHeight = 16*MULTIPLYHEIGHT;
    
    viewArrow = [[UIView alloc]initWithFrame:CGRectMake(screen_width-btnHeight, 0, btnHeight, view_SegmentBG.frame.size.height)];
    viewArrow.backgroundColor = RGBCOLORCODE(252, 252, 252, 1.0);
    [view_SegmentBG addSubview:viewArrow];
    
    btnArrow = [UIButton buttonWithType:UIButtonTypeCustom];
    btnArrow.frame = CGRectMake(0, view_SegmentBG.frame.size.height/2 - btnHeight/2, btnHeight, btnHeight);
    [btnArrow setImage:[UIImage imageNamed:@"right_arrow1"] forState:UIControlStateNormal];
    [viewArrow addSubview:btnArrow];
    btnArrow.backgroundColor = [UIColor clearColor];
    
    if (segmentImages.frame.size.width > segmentImages.scrollView.contentSize.width)
    {
        viewArrow.hidden = YES;
    }
}

-(void) didStartScroll:(HMSegmentedControl *)segmentControl Scroller:(UIScrollView *)scrollView
{
    float scrollViewWidth = scrollView.frame.size.width;
    float scrollContentSizeWidth = scrollView.contentSize.width;
    float scrollOffset = scrollView.contentOffset.x;
    
    //    if (scrollOffset == 0)
    //    {
    //        // then we are at the top
    //    }
    if (scrollOffset + scrollViewWidth + 10 < scrollContentSizeWidth)
    {
        viewArrow.hidden = NO;
    }
    else if (scrollOffset + scrollViewWidth >= scrollContentSizeWidth)
    {
        viewArrow.hidden = YES;
    }
}

-(void) scrollAnimated
{
    float scrollViewWidth = segmentImages.scrollView.frame.size.width;
    float scrollContentSizeWidth = segmentImages.scrollView.contentSize.width;
    float scrollOffset = segmentImages.scrollView.contentOffset.x;
    
    //    if (scrollOffset == 0)
    //    {
    //        // then we are at the top
    //    }
    if (scrollOffset + scrollViewWidth < scrollContentSizeWidth)
    {
        viewArrow.hidden = NO;
    }
    else if (scrollOffset + scrollViewWidth >= scrollContentSizeWidth)
    {
        viewArrow.hidden = YES;
    }
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    btnService.selected = NO;
//    
//    [self btnServiceTypeClicked:btnService];
}


-(void) isExpressionBtnClicked:(UIButton *) sender
{
    sender.selected = !sender.selected;
    
    if (sender.selected)
    {
        strOrderType = ORDER_TYPE_EXPRESS;
    }
    else
    {
        strOrderType = ORDER_TYPE_REGULAR;
    }
    
    [self getCategories];
}

-(void) sliderChanged:(UISlider *)slider
{
    
    if (slider.value > previousSliderValue || previousSliderValue == 0)
    {
        lblOrderType.text = @"EXPRESS";
        strOrderType = ORDER_TYPE_EXPRESS;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [slider setValue:1.0 animated:YES];
            
        } completion:^(BOOL finished) {
            
        }];
        
        [slider setThumbImage:[UIImage imageNamed:@"selected_thumb"] forState:UIControlStateNormal];
        [slider setThumbImage:[UIImage imageNamed:@"selected_thumb"] forState:UIControlStateHighlighted];
    }
    else
    {
        lblOrderType.text = @"REGULAR";
        strOrderType = ORDER_TYPE_REGULAR;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [slider setValue:0 animated:YES];
            
        } completion:^(BOOL finished) {
            
        }];
        
        [slider setThumbImage:[UIImage imageNamed:@"unselected_thumb"] forState:UIControlStateNormal];
        [slider setThumbImage:[UIImage imageNamed:@"unselected_thumb"] forState:UIControlStateHighlighted];
    }
    
    previousSliderValue = slider.value;
    
    [self getCategories];
}

//-(void) switchChanged:(SevenSwitch *)switch1
//{
//    [self viewTapped:nil];
//
//    if(switch1.on) {
//        strOrderType = @"E";
//    }
//    else {
//        strOrderType = @"R";
//    }
//
//    [self getCategories];
//}

-(void) switchChanged:(UISegmentedControl *)switch1
{
    [self viewTapped:nil];
    
    if(switch1.selectedSegmentIndex == 1) {
        strOrderType = ORDER_TYPE_EXPRESS;
    }
    else {
        strOrderType = ORDER_TYPE_REGULAR;
    }
    
    [self getCategories];
}


-(void)GetDaysToDeliver
{
    NSMutableDictionary *detailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", @"B", @"orderType", strJobType, @"serviceTypes", strOrderType, @"orderSpeed", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/order/estimatedays", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:detailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1){
            
            [self showlblSwitch];
            
            numberOfDays = [[responseObj objectForKey:@"days"] intValue];
            
            if ([[responseObj objectForKey:@"days"] intValue] == 1)
            {
                lblSwitch.text = [NSString stringWithFormat:@"NEXT DAY DELIVERY"];
            }
            else
            {
                lblSwitch.text = [NSString stringWithFormat:@"%d DAY DELIVERY", [[responseObj objectForKey:@"days"] intValue]];
            }
        }
        else {
            
            if ([[responseObj objectForKey:@"s"] intValue] != 100)
            {
                //[mySwitch2 setOn:NO animated:YES];
                //segmentSwitch.selectedSegmentIndex = 0;
                
                UIView *viewBg = btnSwitch.superview;
                
                for (id sender in viewBg.subviews)
                {
                    if ([sender isKindOfClass:[UIButton class]])
                    {
                        UIButton *btn = (UIButton *) sender;
                        
                        if (btn.tag == 1)
                        {
                            btn.layer.borderColor = LIGHT_BLUE_COLOR.CGColor;
                            btn.backgroundColor = BLUE_COLOR;
                            
                            btnSwitch = btn;
                        }
                        else if (btn.tag == 2)
                        {
                            btn.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                            btn.backgroundColor = [UIColor clearColor];
                            btn.selected = NO;
                        }
                    }
                }
                
                [self btnOptionsSelected:btnSwitch];
                
                [self getCategories];
            }
            
            [appDel displayErrorMessagErrorResponse:responseObj];
        }
    }];
}

-(void) menuButtonClicked:(id)sender
{
    [self.sideMenuViewController presentLeftMenuViewController];
}


-(void)setloadWashText:(NSArray *) arr
{
    NSDictionary *dict = [arr objectAtIndex:0];
    
    NSString *str1 = @"";
    NSString *str2 = @"";
    
    if ([strJobType isEqualToString:SERVICETYPE_WF])
    {
        imgLw.image = [UIImage imageNamed:@"loadwash_price"];
        lblL.text = [@"Load Wash only for personal wear" uppercaseString];
        
        imgLw.frame = CGRectMake(0, 0, viewLW.frame.size.width, 26*MULTIPLYHEIGHT);
        
        str1 = [NSString stringWithFormat:@"$%.2f PER KG\n", [[dict objectForKey:@"ip"] floatValue]];
        
        str2 = [NSString stringWithFormat:@"(MINIMUM %@ KGS)\n", [dict objectForKey:@"twt"]];
    }
    else if ([strJobType isEqualToString:SERVICETYPE_CA])
    {
        imgLw.frame = CGRectMake(0, 0, viewLW.frame.size.width, 50*MULTIPLYHEIGHT);
        
        imgLw.image = [UIImage imageNamed:@"carpet_price"];
        lblL.text = @"";
        
        str1 = [NSString stringWithFormat:@"$%.2f PER SQFT\n", [[dict objectForKey:@"ip"] floatValue]];
    }
    
    NSMutableAttributedString *mainAttr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@%@", str1, str2]];
    
    [mainAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_SEMI_BOLD size:appDel.HEADER_LABEL_FONT_SIZE], NSForegroundColorAttributeName:[UIColor darkGrayColor]} range:NSMakeRange(0, str1.length)];
    
    [mainAttr addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-3], NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(str1.length, str2.length)];
    
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentCenter;
    [paragrapStyle setLineSpacing:8.0f];
    [paragrapStyle setMaximumLineHeight:100.0f];
    
    [mainAttr addAttribute:NSParagraphStyleAttributeName value:paragrapStyle range:NSMakeRange(0, mainAttr.length)];
    
    [mainAttr addAttribute:NSKernAttributeName
                     value:@(1.0)
                     range:NSMakeRange(0, mainAttr.length)];
    
    lblLoadWash.attributedText = mainAttr;
}

-(void) segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl
{
    [self viewTapped:nil];
    
    [arrayRow removeAllObjects];
    
    NSDictionary *dictRow = [arrayCategory objectAtIndex:segmentedControl.selectedSegmentIndex];
    
    [arrayRow addObjectsFromArray:[dictRow objectForKey:[arraykey objectAtIndex:segmentedControl.selectedSegmentIndex]]];
    
    selectedCategoryIndex = segmentedControl.selectedSegmentIndex;
    
    [tblPricing reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (showAddOnDesc)
    {
        CGFloat yAxis = 30*MULTIPLYHEIGHT;
        
        NSDictionary *dict = (NSDictionary *) [arrayRow objectAtIndex:indexPath.row];
        
        for (NSDictionary *dictAddOn in arrayAddOnTypeDesc)
        {
            if ([[dictAddOn objectForKey:@"name"] isEqualToString:[dict objectForKey:@"name"]])
            {
                NSMutableAttributedString *lblAttr = [[NSMutableAttributedString alloc]initWithString:[dictAddOn objectForKey:@"desc"]];
                
                [lblAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(0.5)} range:NSMakeRange(0, lblAttr.string.length)];
                
                CGFloat lblWX = 20*MULTIPLYHEIGHT;
                
                CGFloat lblW = screen_width-lblWX*4;
                
                CGSize size = [AppDelegate getAttributedTextHeightForText:lblAttr WithWidth:lblW];
                
                yAxis += size.height + 10*MULTIPLYHEIGHT;
                
                break;
            }
        }
        
        return yAxis;
    }
    else
    {
        return 30*MULTIPLYHEIGHT;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([strJobType isEqualToString:SERVICETYPE_WF] || [strJobType isEqualToString:SERVICETYPE_CA])
    {
        return 0;
    }
    else
    {
        return [arrayRow count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblWash = [[UILabel alloc]init];
        lblWash.tag = 10;
        lblWash.textColor = [UIColor grayColor];
        lblWash.numberOfLines = 0;
        lblWash.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-1];
        [cell.contentView addSubview:lblWash];
        
        UILabel *lblPrice = [[UILabel alloc]init];
        lblPrice.tag = 11;
        lblPrice.textColor = [UIColor blackColor];
        lblPrice.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
        [cell.contentView addSubview:lblPrice];
        
        UILabel *lblAddOnDesc = [[UILabel alloc]init];
        lblAddOnDesc.tag = 12;
        lblAddOnDesc.numberOfLines = 0;
        [cell.contentView addSubview:lblAddOnDesc];
        
        CALayer *bottomLayerView = [[CALayer alloc]init];
        bottomLayerView.name = @"viewBG";
        CGFloat layerX = 5*MULTIPLYHEIGHT;
        bottomLayerView.frame = CGRectMake(layerX, cell.contentView.frame.size.height-1, screen_width-(layerX*2), 1);
        bottomLayerView.backgroundColor = [[UIColor lightGrayColor]colorWithAlphaComponent:0.3].CGColor;
        [cell.contentView.layer addSublayer:bottomLayerView];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    NSDictionary *dict = (NSDictionary *) [arrayRow objectAtIndex:indexPath.row];
    
    UILabel *lblWash = (UILabel *) [cell.contentView viewWithTag:10];
    
    UILabel *lblPrice = (UILabel *) [cell.contentView viewWithTag:11];
    
    UILabel *lblAddOnDesc = (UILabel *) [cell.contentView viewWithTag:12];
    lblAddOnDesc.text = @"";
    
    float height = 30*MULTIPLYHEIGHT;
    
    float lblWX = 20*MULTIPLYHEIGHT;
    float lblWMinus = 77*MULTIPLYHEIGHT;
    float lblWWidth = screen_width-(lblWX+lblWMinus);
    
    lblWash.frame = CGRectMake(lblWX, 0, lblWWidth, height);
    
    float lblPWidth = 72*MULTIPLYHEIGHT;
    float lblPMinus = lblWMinus+15*MULTIPLYHEIGHT;
    
    lblPrice.frame = CGRectMake(screen_width-lblPMinus, 0, lblPWidth, height);
    
    lblPrice.textAlignment = NSTextAlignmentRight;
    
    if ([dict objectForKey:@"ip"])
    {
        lblPrice.text = [NSString stringWithFormat:@"$%.2f", [[dict objectForKey:@"ip"] floatValue]];
    }
    else
    {
        lblPrice.text = [NSString stringWithFormat:@"$%.2f", [[dict objectForKey:@"price"] floatValue]];
    }
    
    if ([dict objectForKey:@"n"])
    {
        NSString *strC = @"";
        
        NSArray *arr1 = [[dict objectForKey:@"n"] componentsSeparatedByString:@"^^"];
        
        if ([arr1 count] > 1)
        {
            strC = [[[dict objectForKey:@"n"] componentsSeparatedByString:@"^^"] objectAtIndex:1];
        }
        else
        {
            strC = [dict objectForKey:@"n"];
        }
        
        lblWash.text = strC;
    }
    else
    {
        lblWash.text = [dict objectForKey:@"name"];
        
        for (NSDictionary *dictAddOn in arrayAddOnTypeDesc)
        {
            if ([[dictAddOn objectForKey:@"name"] isEqualToString:[dict objectForKey:@"name"]])
            {
                NSMutableAttributedString *lblAttr = [[NSMutableAttributedString alloc]initWithString:[dictAddOn objectForKey:@"desc"]];
                
                [lblAttr addAttributes:@{NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4], NSKernAttributeName : @(0.5)} range:NSMakeRange(0, lblAttr.string.length)];
                
                lblAddOnDesc.attributedText = lblAttr;
                
                lblAddOnDesc.frame = CGRectMake(lblWX, height, screen_width-lblWX*4, 10);
                
                CGSize size = [AppDelegate getAttributedTextHeightForText:lblAttr WithWidth:lblAddOnDesc.frame.size.width];
                
                CGRect rect = lblAddOnDesc.frame;
                rect.size.height = size.height;
                lblAddOnDesc.frame = rect;
                
                height += rect.size.height+10*MULTIPLYHEIGHT;
                
                break;
            }
        }
    }
    
    for (CALayer *layer in [cell.contentView.layer sublayers])
    {
        if ([[layer name] isEqualToString:@"viewBG"])
        {
            CGRect rectL = layer.frame;
            rectL.origin.y = height-1;
            layer.frame = rectL;
        }
    }
    
    return cell;
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
