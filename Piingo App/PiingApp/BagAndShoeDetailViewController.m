//
//  BagAndShoeDetailViewController.m
//  PiingApp
//
//  Created by Veedepu Srikanth on 21/06/17.
//  Copyright © 2017 shashank. All rights reserved.
//

#import "BagAndShoeDetailViewController.h"
#import "AppDelegate.h"
#import "UIButton+Position.h"
#import "CustomPopoverView.h"
#import <iOS-Color-Picker/FCColorPickerViewController.h>
#import "HMSegmentedControl.h"


#define SERVICETYPE_TAG 120
#define CATEGORY_TAG 100
#define ADDON_SIZE_TAG 80
#define BRAND_TAG 60
#define COLOR_TAG 40
#define ADDON_TYPE_TAG 20
#define INFO_TAG 200


@interface BagAndShoeDetailViewController () <UITextFieldDelegate, UITextViewDelegate, CustomPopoverViewDelegate, FCColorPickerViewControllerDelegate, UIScrollViewDelegate>
{
    UIScrollView *scrollItems;
    AppDelegate *appDel;
    
    UIView *bgView;
    
    CustomPopoverView *customPopOverView;
    
    UITextField *senderTF;
    UITextView *senderTV;
    
    NSMutableArray *arrayCategoryNames;
    
    NSInteger selectedCategoryIndex;
    
    NSMutableArray *arrayAddOnSize;
    
    NSMutableDictionary *dictSaveData;
    
    CGFloat orgContentHeight, orgOffsetY;
    
    BOOL fromTF, fromTV;
    
    UIButton *btnColorSender;
    
    NSMutableDictionary *dictCategories;
    
    HMSegmentedControl *segmentCategory;
    
    UIScrollView *scrollInnerView;
    
    NSMutableDictionary *dictServiceTypeIndexwise;
}

@property (nonatomic, copy) UIColor *color;

@end


@implementation BagAndShoeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    self.color = [UIColor redColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillChangeNotif:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    dictSaveData = [[NSMutableDictionary alloc]init];
    dictCategories = [[NSMutableDictionary alloc]init];
    dictServiceTypeIndexwise = [[NSMutableDictionary alloc]init];
    
    NSMutableArray *arr1 = [[NSMutableArray alloc]initWithArray:self.arrayCategories];
    
    [dictCategories setObject:arr1 forKey:self.strServiceType];
    
    [dictServiceTypeIndexwise setObject:self.strServiceTypeName forKey:@"0"];
    
    CGFloat yAxis = 0;
    
    UIView *view_Top = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, 50*MULTIPLYHEIGHT)];
    view_Top.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
    [self.view addSubview:view_Top];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(5*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT, 40.0, 40.0);
    [closeBtn setImage:[UIImage imageNamed:@"cancel_grey"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(backToPreviousScreen) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.backgroundColor = [UIColor clearColor];
    [view_Top addSubview:closeBtn];
    
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(screen_width-60*MULTIPLYHEIGHT, 20*MULTIPLYHEIGHT, 60*MULTIPLYHEIGHT, 40.0);
    [addBtn setTitle:@"ADD" forState:UIControlStateNormal];
    [addBtn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
    addBtn.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
    [addBtn addTarget:self action:@selector(addBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    addBtn.backgroundColor = [UIColor clearColor];
    [view_Top addSubview:addBtn];
    
    yAxis += view_Top.frame.size.height+5*MULTIPLYHEIGHT;
    
    arrayCategoryNames = [[NSMutableArray alloc]init];
    arrayAddOnSize = [[NSMutableArray alloc]init];
    
    [self getCategoryNames];
    
    NSString *strSectionTitle;
    
    if ([self.strServiceType isEqualToString:SERVICETYPE_BAG])
    {
        strSectionTitle = self.strServiceTypeName;
    }
    else
    {
        strSectionTitle = @"SHOE";
    }
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < self.countOfItems; i++)
    {
        [arr addObject:[NSString stringWithFormat:@"%@ %d", strSectionTitle, i+1]];
    }
    
    float segmentCHeight = 30*MULTIPLYHEIGHT;
    
    segmentCategory = [[HMSegmentedControl alloc]initWithSectionTitles:arr];
    segmentCategory.frame = CGRectMake(0, yAxis, screen_width, segmentCHeight);
    float left = 15*MULTIPLYHEIGHT;
    float right = 15*MULTIPLYHEIGHT;
    segmentCategory.segmentEdgeInset = UIEdgeInsetsMake(0, left, 0, right);
    //segmentCategory.delegate = self;
    segmentCategory.borderType = HMSegmentedControlBorderTypeNone;
    segmentCategory.backgroundColor = [UIColor clearColor];
    segmentCategory.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    segmentCategory.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    segmentCategory.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor darkGrayColor], NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
    segmentCategory.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : BLUE_COLOR, NSFontAttributeName : [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-1]};
    [segmentCategory addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:segmentCategory];
    
    yAxis += segmentCHeight;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    scrollItems = [[UIScrollView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, screen_height-yAxis)];
    scrollItems.delegate = self;
    scrollItems.pagingEnabled = YES;
    [self.view addSubview:scrollItems];
    
    yAxis = 0;
    
    CGFloat xAxis = 0;
    
    for (int i = 0; i < self.countOfItems; i++)
    {
        yAxis = 10*MULTIPLYHEIGHT;
        
        CGFloat lblTH = 25*MULTIPLYHEIGHT;
        CGFloat lblTX = 10*MULTIPLYHEIGHT;
        CGFloat lblTW = screen_width-lblTX*2;
        
        UIScrollView *viewSe = [[UIScrollView alloc]initWithFrame:CGRectMake(xAxis, yAxis, screen_width, scrollItems.frame.size.height)];
        viewSe.delegate = self;
        viewSe.tag = i+1;
        viewSe.backgroundColor = [UIColor clearColor];
        [scrollItems addSubview:viewSe];
        
        if (i == 0)
        {
            scrollInnerView = viewSe;
        }
        
        yAxis = 0;
        
//        UILabel *lblTitle = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
//        lblTitle.text = [NSString stringWithFormat:@"%@ %d", strSectionTitle, i+1];
//        lblTitle.backgroundColor = BLUE_COLOR;
//        lblTitle.textAlignment = NSTextAlignmentCenter;
//        lblTitle.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM];
//        lblTitle.textColor = [UIColor whiteColor];
//        [viewSe addSubview:lblTitle];
//        
//        yAxis += lblTH;
        
        if (![self.strServiceType isEqualToString:SERVICETYPE_BAG])
        {
            UILabel *lblServiceType = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
            lblServiceType.text = @"Select the service type";
            lblServiceType.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
            lblServiceType.textColor = [UIColor grayColor];
            [viewSe addSubview:lblServiceType];
            
            yAxis += lblTH;
            
            UITextField *selectServiceTypeTF = [[UITextField alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
            selectServiceTypeTF.delegate = self;
            selectServiceTypeTF.tag = SERVICETYPE_TAG+i+1;
            selectServiceTypeTF.placeholder = @"Select service type";
            selectServiceTypeTF.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2];
            selectServiceTypeTF.textColor = [UIColor darkGrayColor];
            [viewSe addSubview:selectServiceTypeTF];
            selectServiceTypeTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
            selectServiceTypeTF.layer.borderWidth = 1.0;
            selectServiceTypeTF.layer.cornerRadius = 5.0;
            
            selectServiceTypeTF.rightViewMode = UITextFieldViewModeAlways;
            
            CGFloat smallW = 10*MULTIPLYHEIGHT;
            
            UIImageView *envelopeView = [[UIImageView alloc] initWithFrame:CGRectMake(selectServiceTypeTF.frame.size.width - smallW - 5*MULTIPLYHEIGHT, selectServiceTypeTF.frame.size.height/2 - smallW/2, smallW, smallW)];
            envelopeView.contentMode = UIViewContentModeScaleAspectFit;
            envelopeView.image = [UIImage imageNamed:@"down_arrow_gray"];
            [selectServiceTypeTF addSubview:envelopeView];
            
            selectServiceTypeTF.leftViewMode = UITextFieldViewModeAlways;
            selectServiceTypeTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 20)];
            
            if ([self.arrayShoeServicetype count] == 1)
            {
                selectServiceTypeTF.text = [self.arrayShoeServicetypeName objectAtIndex:0];
                selectServiceTypeTF.enabled = NO;
                selectServiceTypeTF.alpha = 0.4;
            }
            
            yAxis += lblTH+5*MULTIPLYHEIGHT;
        }
        
        UILabel *lblMaterial = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
        lblMaterial.text = @"Enter the material type";
        lblMaterial.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        lblMaterial.textColor = [UIColor grayColor];
        [viewSe addSubview:lblMaterial];
        
        yAxis += lblTH;
        
        UITextField *selectMaterialTF = [[UITextField alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
        selectMaterialTF.delegate = self;
        selectMaterialTF.tag = CATEGORY_TAG+i+1;
        selectMaterialTF.placeholder = @"Select Material type";
        selectMaterialTF.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2];
        selectMaterialTF.textColor = [UIColor darkGrayColor];
        [viewSe addSubview:selectMaterialTF];
        selectMaterialTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
        selectMaterialTF.layer.borderWidth = 1.0;
        selectMaterialTF.layer.cornerRadius = 5.0;
        
        selectMaterialTF.rightViewMode = UITextFieldViewModeAlways;
        
        CGFloat smallW = 10*MULTIPLYHEIGHT;
        
        UIImageView *envelopeView = [[UIImageView alloc] initWithFrame:CGRectMake(selectMaterialTF.frame.size.width - smallW - 5*MULTIPLYHEIGHT, selectMaterialTF.frame.size.height/2 - smallW/2, smallW, smallW)];
        envelopeView.contentMode = UIViewContentModeScaleAspectFit;
        envelopeView.image = [UIImage imageNamed:@"down_arrow_gray"];
        [selectMaterialTF addSubview:envelopeView];
        
        selectMaterialTF.leftViewMode = UITextFieldViewModeAlways;
        selectMaterialTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 20)];
        
        yAxis += lblTH;
        
        if ([self.strServiceType isEqualToString:SERVICETYPE_BAG])
        {
            UILabel *lblMaterialSize = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
            lblMaterialSize.text = @"Enter the material size";
            lblMaterialSize.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
            lblMaterialSize.textColor = [UIColor grayColor];
            [viewSe addSubview:lblMaterialSize];
            
            yAxis += lblTH;
            
            UITextField *selectMaterialSizeTF = [[UITextField alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
            selectMaterialSizeTF.delegate = self;
            selectMaterialSizeTF.tag = ADDON_SIZE_TAG+i+1;
            selectMaterialSizeTF.placeholder = @"Select Material size";
            selectMaterialSizeTF.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
            selectMaterialSizeTF.textColor = [UIColor darkGrayColor];
            [viewSe addSubview:selectMaterialSizeTF];
            selectMaterialSizeTF.layer.borderColor = [UIColor lightGrayColor].CGColor;
            selectMaterialSizeTF.layer.borderWidth = 1.0;
            selectMaterialSizeTF.layer.cornerRadius = 5.0;
            
            selectMaterialSizeTF.rightViewMode = UITextFieldViewModeAlways;
            
            UIImageView *sizeView = [[UIImageView alloc] initWithFrame:CGRectMake(selectMaterialTF.frame.size.width - smallW - 5*MULTIPLYHEIGHT, selectMaterialTF.frame.size.height/2 - smallW/2, smallW, smallW)];
            sizeView.contentMode = UIViewContentModeScaleAspectFit;
            sizeView.image = [UIImage imageNamed:@"down_arrow_gray"];
            [selectMaterialSizeTF addSubview:sizeView];
            
            selectMaterialSizeTF.leftViewMode = UITextFieldViewModeAlways;
            selectMaterialSizeTF.leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 15, 20)];
            
            yAxis += lblTH+5*MULTIPLYHEIGHT;
        }
        
        UILabel *lblBrand = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
        lblBrand.text = @"Enter the brand";
        lblBrand.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        lblBrand.textColor = [UIColor grayColor];
        [viewSe addSubview:lblBrand];
        
        yAxis += lblTH;
        
        UITextField *tfBrand = [[UITextField alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
        tfBrand.placeholder = @"Enter the brand";
        tfBrand.delegate = self;
        tfBrand.tag = BRAND_TAG+i+1;
        tfBrand.textColor = [UIColor darkGrayColor];
        tfBrand.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
        tfBrand.layer.borderColor = [UIColor lightGrayColor].CGColor;
        tfBrand.layer.borderWidth = 1.0;
        [viewSe addSubview:tfBrand];
        
        UILabel *leftViewBrand = [[UILabel alloc] initWithFrame:CGRectMake(0*MULTIPLYHEIGHT, 0, 10*MULTIPLYHEIGHT, lblTH)];
        leftViewBrand.backgroundColor = [UIColor clearColor];
        tfBrand.leftView = leftViewBrand;
        tfBrand.leftViewMode = UITextFieldViewModeAlways;
        
        yAxis += lblTH+5*MULTIPLYHEIGHT;
        
        UILabel *lblColor = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
        lblColor.text = @"Select the color";
        lblColor.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        lblColor.textColor = [UIColor grayColor];
        [viewSe addSubview:lblColor];
        
        yAxis += lblTH;
        
        CGFloat btnW = 30*MULTIPLYHEIGHT;
        
        UIButton *btnColor = [UIButton buttonWithType:UIButtonTypeCustom];
        btnColor.tag = COLOR_TAG+i+1;
        btnColor.backgroundColor = [UIColor whiteColor];
        btnColor.frame = CGRectMake(lblTX+20*MULTIPLYHEIGHT, yAxis, btnW, btnW);
        btnColor.layer.borderWidth = 1.0;
        btnColor.layer.borderColor = [UIColor grayColor].CGColor;
        btnColor.layer.cornerRadius = btnW/2;
        [btnColor addTarget:self action:@selector(btnColorClicked:) forControlEvents:UIControlEventTouchUpInside];
        [viewSe addSubview:btnColor];
        
        yAxis += btnW+6*MULTIPLYHEIGHT;
        
        UILabel *lblAddInfo = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
        lblAddInfo.text = @"Enter the additional information";
        lblAddInfo.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        lblAddInfo.textColor = [UIColor grayColor];
        [viewSe addSubview:lblAddInfo];
        
        yAxis += lblTH;
        
        UITextView *tvInfo = [[UITextView alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH+30*MULTIPLYHEIGHT)];
        tvInfo.tag = INFO_TAG+i+1;
        tvInfo.textColor = [UIColor darkGrayColor];
        tvInfo.delegate = self;
        tvInfo.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
        tvInfo.layer.borderColor = [UIColor lightGrayColor].CGColor;
        tvInfo.layer.borderWidth = 1.0;
        [viewSe addSubview:tvInfo];
        
        UIToolbar* tvToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        tvToolbar.barTintColor = [UIColor whiteColor];
        tvToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)], nil];
        [tvToolbar sizeToFit];
        tvInfo.inputAccessoryView = tvToolbar;
        
        yAxis += lblTH+30*MULTIPLYHEIGHT+5*MULTIPLYHEIGHT;
        
//        UILabel *lblAddOn = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, yAxis, lblTW, lblTH)];
//        lblAddOn.text = @"Add ons";
//        lblAddOn.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
//        lblAddOn.textColor = [UIColor grayColor];
//        [viewSe addSubview:lblAddOn];
//        
//        yAxis += lblTH;
//        
//        NSArray *arrayAddOn = @[@"Stain removal", @"Interior cleaning", @"Anti bacterial cleaning", @"Hydrophobic coating", @"Bags silk bandeau"];
//        
//        UIView *viewUnderAdd = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, 10)];
//        viewUnderAdd.tag = ADDON_TYPE_TAG+i+1;
//        [viewSe addSubview:viewUnderAdd];
//        
//        CGFloat btnAY = 0;
//        
//        for (int j = 0; j < [arrayAddOn count]; j++)
//        {
//            UIButton *btnAddOn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [btnAddOn setTitle:[arrayAddOn objectAtIndex:j] forState:UIControlStateNormal];
//            [btnAddOn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//            [btnAddOn setImage:[UIImage imageNamed:@"uncheckmark"] forState:UIControlStateNormal];
//            [btnAddOn setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateSelected];
//            btnAddOn.imageView.contentMode = UIViewContentModeScaleAspectFit;
//            btnAddOn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//            btnAddOn.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
//            [btnAddOn addTarget:self action:@selector(btnAddOnClicked:) forControlEvents:UIControlEventTouchUpInside];
//            [viewUnderAdd addSubview:btnAddOn];
//            
//            CGFloat inset = 3*MULTIPLYHEIGHT;
//            
//            btnAddOn.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
//            
//            btnAddOn.frame = CGRectMake(lblTX, btnAY, lblTW, lblTH);
//            
//            [btnAddOn buttonImageAndTextWithImagePosition:@"LEFT" WithSpacing:10];
//            
//            btnAY += lblTH+5*MULTIPLYHEIGHT;
//        }
//        
//        CGRect frame = viewUnderAdd.frame;
//        frame.size.height = btnAY;
//        viewUnderAdd.frame = frame;
//        
//        yAxis += btnAY;
//        
//        CGRect rect = viewSe.frame;
//        rect.size.height = yAxis;
//        viewSe.frame = rect;
        
        viewSe.contentSize = CGSizeMake(screen_width, yAxis);
        
        if (i == 0)
        {
            orgContentHeight = yAxis;
            orgOffsetY = viewSe.contentOffset.y;
        }
        
        xAxis += screen_width;
    }
    
    scrollItems.contentSize = CGSizeMake(xAxis, 0);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == scrollInnerView)
    {
        orgOffsetY = scrollInnerView.contentOffset.y;
    }
    else
    {
        [self doneClicked];
        
        CGFloat pageWidth = scrollItems.frame.size.width;
        float fractionalPage = scrollItems.contentOffset.x / pageWidth;
        NSInteger page = lround(fractionalPage);
        
        [segmentCategory setSelectedSegmentIndex:page animated:YES];
        
        scrollInnerView = (UIScrollView *) [scrollItems viewWithTag:segmentCategory.selectedSegmentIndex+1];
        orgContentHeight = scrollInnerView.contentSize.height;
        orgOffsetY = scrollInnerView.contentOffset.y;
    }
}

-(void) segmentedControlChangedValue:(HMSegmentedControl *) segment
{
    [self doneClicked];
    
    scrollInnerView = (UIScrollView *) [scrollItems viewWithTag:segmentCategory.selectedSegmentIndex+1];
    orgContentHeight = scrollInnerView.contentSize.height;
    orgOffsetY = scrollInnerView.contentOffset.y;
    
    [scrollItems setContentOffset:CGPointMake(screen_width*segmentCategory.selectedSegmentIndex, 0) animated:YES];
}



-(void) getCategoryNames
{
    [arrayCategoryNames removeAllObjects];
    
    for (int i=0; i<[self.arrayCategories count]; i++)
    {
        NSArray *arr = [[self.arrayCategories objectAtIndex:i]allKeys];
        
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
                [arrayCategoryNames addObject:str];
            }
        }
    }
}


-(void) btnColorClicked:(UIButton *) btn
{
    btnColorSender = btn;
    
    self.color = btnColorSender.backgroundColor;
    
    NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableDictionary *dictItem;
    
    for (int i = 0; i < [arraItems count]; i++)
    {
        NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
        
        if ([[dict1 objectForKey:@"itemRow"] intValue] == btn.superview.tag)
        {
            dictItem = dict1;
            
            break;
        }
    }
    
    if (!dictItem)
    {
        [appDel showAlertWithMessage:@"Please select the material type first" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    FCColorPickerViewController *colorPicker = [FCColorPickerViewController colorPickerWithColor:self.color delegate:self];
    colorPicker.tintColor = [UIColor whiteColor];
    [colorPicker setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentViewController:colorPicker animated:YES completion:nil];
}


-(void) btnAddOnClicked:(UIButton *) btn
{
    if ([self.strServiceType isEqualToString:SERVICETYPE_SHOE_POLISH])
    {
        [appDel showAlertWithMessage:@"Addons not applicable for Shoe polishing" andTitle:@"" andBtnTitle:@"OK"];
        return;
    }
    
    NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableDictionary *dictItem;
    
    for (int i = 0; i < [arraItems count]; i++)
    {
        NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
        
        if ([[dict1 objectForKey:@"itemRow"] intValue] == btn.superview.superview.tag)
        {
            dictItem = dict1;
            
            break;
        }
    }
    
    if (!dictItem)
    {
        [appDel showAlertWithMessage:@"Please select the material type first" andTitle:@"" andBtnTitle:@"OK"];
        
        return;
    }
    
    NSMutableDictionary *dictAddOn = [dictItem objectForKey:@"addOn"];
    
    NSMutableDictionary *dictUnder = [dictAddOn objectForKey:btn.currentTitle];
    
    if (btn.selected)
    {
        [dictUnder setObject:@"0" forKey:@"value"];
    }
    else
    {
        [dictUnder setObject:@"1" forKey:@"value"];
    }
    
    btn.selected = !btn.selected;
}

-(void) addBtnClicked
{
    //NSArray *arr = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    
    if ([dictSaveData count] > 1)
    {
        for (NSString *key in dictSaveData)
        {
            [arr addObjectsFromArray:[dictSaveData objectForKey:key]];
        }
    }
    else
    {
        [arr addObjectsFromArray:[dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]]];
    }
    
    if (self.countOfItems == [arr count])
    {
        for (int i = 0; i < [arr count]; i++)
        {
            NSMutableDictionary *dictItem = [arr objectAtIndex:i];
            
            if (![dictItem objectForKey:@"n"] || ![dictItem objectForKey:@"ic"] || ![dictItem objectForKey:@"brand"] || ![dictItem objectForKey:@"colorCode"])
            {
                [appDel showAlertWithMessage:@"Please enter all the details" andTitle:@"" andBtnTitle:@"OK"];
                
                return;
            }
        }
        
        [dictSaveData setObject:[NSString stringWithFormat:@"%ld", self.countOfItems] forKey:@"totalCount"];
        
        if ([self.delegate respondsToSelector:@selector(didAddBagsAndShoes:)])
        {
            [self backToPreviousScreen];
            
            [self.delegate didAddBagsAndShoes:dictSaveData];
        }
    }
    else
    {
        [appDel showAlertWithMessage:@"Please enter all the details" andTitle:@"" andBtnTitle:@"OK"];
        return;
    }
}

-(void) backToPreviousScreen
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.view endEditing:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) doneClicked
{
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    senderTF = textField;
    
    if (textField.tag >= SERVICETYPE_TAG)
    {
        [self openPopoverWithData:self.arrayShoeServicetypeName];
        
        return NO;
    }
    else if (textField.tag >= CATEGORY_TAG)
    {
        UITextView *aboveTf = [textField.superview viewWithTag:textField.tag+20];
        
        if (aboveTf && ![aboveTf.text length])
        {
            [appDel showAlertWithMessage:@"Please select the service type first" andTitle:@"" andBtnTitle:@"OK"];
            
            return NO;
        }
        
        if (![dictCategories objectForKey:self.strServiceType])
        {
            [self getCategories];
        }
        else
        {
            [self openPopoverWithData:arrayCategoryNames];
        }
        
        return NO;
    }
    else if (textField.tag >= ADDON_SIZE_TAG)
    {
        UITextView *aboveTf = [textField.superview viewWithTag:textField.tag+20];
        
        if ([aboveTf.text length])
        {
            [self openPopoverWithData:arrayAddOnSize];
        }
        else
        {
            [appDel showAlertWithMessage:@"Please select the material type first" andTitle:@"" andBtnTitle:@"OK"];
        }
        
        return NO;
    }
    else if (textField.tag >= BRAND_TAG)
    {
        UITextView *aboveTf = [textField.superview viewWithTag:textField.tag+40];
        
        if (![aboveTf.text length])
        {
            [appDel showAlertWithMessage:@"Please select the material type first" andTitle:@"" andBtnTitle:@"OK"];
            
            return NO;
        }
    }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    fromTF = YES;
    
    NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableDictionary *dictItem;
    
    for (int i = 0; i < [arraItems count]; i++)
    {
        NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
        
        if ([[dict1 objectForKey:@"itemRow"] intValue] == senderTF.superview.tag)
        {
            dictItem = dict1;
            
            break;
        }
    }
    
    if (!dictItem)
    {
        [textField resignFirstResponder];
    }
    
    scrollInnerView.contentOffset = CGPointMake(0, scrollInnerView.contentOffset.y);
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    fromTF = NO;
    
    NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableDictionary *dictItem;
    
    for (int i = 0; i < [arraItems count]; i++)
    {
        NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
        
        if ([[dict1 objectForKey:@"itemRow"] intValue] == senderTF.superview.tag)
        {
            dictItem = dict1;
            
            break;
        }
    }
    
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (dictItem)
    {
        [dictItem removeObjectForKey:@"brand"];
        
        if ([textField.text length])
        {
            [dictItem setObject:textField.text forKey:@"brand"];
        }
    }
   
}



-(void)textViewDidBeginEditing:(UITextView *)textView
{
    fromTV = YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    senderTV = textView;
    
    NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableDictionary *dictItem;
    
    for (int i = 0; i < [arraItems count]; i++)
    {
        NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
        
        if ([[dict1 objectForKey:@"itemRow"] intValue] == senderTV.superview.tag)
        {
            dictItem = dict1;
            
            break;
        }
    }
    
    if (!dictItem)
    {
        [appDel showAlertWithMessage:@"Please select the material type first" andTitle:@"" andBtnTitle:@"OK"];
        [self.view endEditing:YES];
        
        return NO;
    }
    
    return YES;
}


-(void)textViewDidEndEditing:(UITextView *)textView
{
    NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableDictionary *dictItem;
    
    for (int i = 0; i < [arraItems count]; i++)
    {
        NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
        
        if ([[dict1 objectForKey:@"itemRow"] intValue] == senderTV.superview.tag)
        {
            dictItem = dict1;
            
            break;
        }
    }
    
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (dictItem)
    {
        [dictItem removeObjectForKey:@"addInfo"];
        
        if ([textView.text length])
        {
            [dictItem setObject:textView.text forKey:@"addInfo"];
        }
    }
    
    fromTV = NO;
}

-(void) openPopoverWithData:(NSMutableArray *) arrayData
{
    [self.view endEditing:YES];
    
    bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.view addSubview:bgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(closePopoverView:)];
    tap.cancelsTouchesInView = NO;
    [bgView addGestureRecognizer:tap];
    
    customPopOverView = [[CustomPopoverView alloc]initWithArray:arrayData SelectedRow:-1];
    customPopOverView.delegate = self;
    [self.view addSubview:customPopOverView];
    customPopOverView.alpha = 0.0;
    customPopOverView.backgroundColor = [UIColor clearColor];
    
    CGPoint point = [senderTF.superview convertPoint:senderTF.frame.origin toView:nil];
    
    CGFloat yVal = point.y;
    
    if (yVal > screen_height/1.5)
    {
        yVal = yVal-(screen_height/2.5);
        
        if (yVal < 0)
        {
            yVal *= -1;
        }
        
        [scrollInnerView setContentOffset:CGPointMake(0, scrollInnerView.contentOffset.y+yVal) animated:YES];
        
        yVal = (screen_height/2.5);
    }
    
    __block CGRect customRect = senderTF.frame;
    
    customPopOverView.frame = CGRectMake(customRect.origin.x, yVal+customRect.size.height, customRect.size.width, screen_height-(yVal+customRect.size.height));
    
    [customPopOverView reloadPopOverViewWithTag:1];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
        
        customPopOverView.alpha = 1.0;
        
    } completion:^(BOOL finished) {
        
        
    }];
}

-(void)closeCustomPopover
{
    [self closePopoverView:nil];
}

-(void) closePopoverView:(UITapGestureRecognizer *) tap
{
    [customPopOverView reloadPopOverViewWithTag:2];
    
    [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
        
        customPopOverView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        [customPopOverView removeFromSuperview];
        customPopOverView = nil;
        
        [bgView removeFromSuperview];
        bgView = nil;
    }];
}

-(void)didSelectFromList:(NSString *)string AtIndex:(NSInteger)row
{
    senderTF.text = string;
    
    if (senderTF.tag >= SERVICETYPE_TAG)
    {
        if ([self.strServiceType isEqualToString:[self.arrayShoeServicetype objectAtIndex:row]])
        {
            [dictServiceTypeIndexwise setObject:self.strServiceTypeName forKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]];
        }
        else
        {
            NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
            
            if (arraItems)
            {
                
            }
            else
            {
                arraItems = [[NSMutableArray alloc]init];
            }
            
            NSMutableDictionary *dictItem;
            
            for (int i = 0; i < [arraItems count]; i++)
            {
                NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
                
                if ([[dict1 objectForKey:@"itemRow"] intValue] == senderTF.superview.tag)
                {
                    dictItem = dict1;
                    
                    break;
                }
            }
            
            if (dictItem)
            {
                [dictItem removeObjectForKey:@"n"];
                [dictItem removeObjectForKey:@"ic"];
                [dictItem removeObjectForKey:@"addOn"];
            }
            
            self.strServiceType = [self.arrayShoeServicetype objectAtIndex:row];
            self.strServiceTypeName = [self.arrayShoeServicetypeName objectAtIndex:row];
            
            [dictServiceTypeIndexwise setObject:self.strServiceTypeName forKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]];
            
            UITextField *tf1 = (UITextField *) [senderTF.superview viewWithTag:senderTF.tag-20];
            tf1.text = @"";
            
            [self createAddOnTypes:nil DictAddOn:nil];
            
//            UIView *viewAddOn = (UIView *) [senderTF.superview viewWithTag:senderTF.tag-CATEGORY_TAG];
//            
//            for (id view in viewAddOn.subviews)
//            {
//                if ([view isKindOfClass:[UIButton class]])
//                {
//                    UIButton *btn = (UIButton *) view;
//                    
//                    btn.selected = NO;
//                }
//            }
        }
        
        [self.arrayCategories removeAllObjects];
        
        [self.arrayCategories addObjectsFromArray:[dictCategories objectForKey:self.strServiceType]];
        [self getCategoryNames];
    }
    
    else if (senderTF.tag >= CATEGORY_TAG)
    {
        if (![dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]])
        {
            [dictServiceTypeIndexwise setObject:self.strServiceTypeName forKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]];
        }
        
        NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
        
        if (arraItems)
        {
            
        }
        else
        {
            arraItems = [[NSMutableArray alloc]init];
        }
        
        NSMutableDictionary *dictItem;
        
        for (int i = 0; i < [arraItems count]; i++)
        {
            NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
            
            if ([[dict1 objectForKey:@"itemRow"] intValue] == senderTF.superview.tag)
            {
                dictItem = dict1;
                
                break;
            }
        }
        
        if (!dictItem)
        {
            dictItem = [[NSMutableDictionary alloc]init];
            
            [arraItems addObject:dictItem];
            
            [dictSaveData setObject:arraItems forKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
        }
        
        [dictItem setObject:string forKey:@"n"];
        
        [dictItem setObject:[NSString stringWithFormat:@"%ld", row] forKey:@"categoryRow"];
        [dictItem setObject:[NSString stringWithFormat:@"%ld", senderTF.superview.tag] forKey:@"itemRow"];
        [dictItem setObject:self.strServiceType forKey:@"jd"];
        [dictItem setObject:@"1" forKey:@"quantity"];
        
        if (![dictItem objectForKey:@"colorCode"])
        {
            [dictItem setObject:@"#FFFFFF" forKey:@"colorCode"];
        }
        
        if (![self.strServiceType isEqualToString:SERVICETYPE_BAG])
        {
            NSArray *arra = [[self.arrayCategories objectAtIndex:[[dictItem objectForKey:@"categoryRow"] intValue]] objectForKey:[dictItem objectForKey:@"n"]];
            
            if ([arra count])
            {
                if ([[[arra objectAtIndex:0] objectForKey:@"ic"] isEqualToString:[dictItem objectForKey:@"ic"]])
                {
                    
                }
                else
                {
                    [dictItem setObject:[[arra objectAtIndex:0] objectForKey:@"ic"] forKey:@"ic"];
                    
                    [self createAddOnTypes:[[arra objectAtIndex:0] objectForKey:@"addOn"] DictAddOn:dictItem];
                }
            }
        }
        
        selectedCategoryIndex = row;
        
        [arrayAddOnSize removeAllObjects];
        
        NSArray *arra = [[self.arrayCategories objectAtIndex:selectedCategoryIndex] objectForKey:string];
        
        for (int i = 0; i < [arra count]; i++)
        {
            NSDictionary *dict = [arra objectAtIndex:i];
            
            NSArray *arr1 = [[dict objectForKey:@"n"] componentsSeparatedByString:@"^^"];
            
            NSString *strA = @"";
            
            if (arr1.count > 1)
            {
                strA = [arr1 objectAtIndex:1];
            }
            else
            {
                strA = [arr1 objectAtIndex:0];
            }
            
            [arrayAddOnSize addObject:strA];
        }
    }
    else if (senderTF.tag >= ADDON_SIZE_TAG)
    {
        NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
        
        NSMutableDictionary *dictItem;
        
        for (int i = 0; i < [arraItems count]; i++)
        {
            NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
            
            if ([[dict1 objectForKey:@"itemRow"] intValue] == senderTF.superview.tag)
            {
                dictItem = dict1;
                break;
            }
        }
        
        NSArray *arra = [[self.arrayCategories objectAtIndex:[[dictItem objectForKey:@"categoryRow"] intValue]] objectForKey:[dictItem objectForKey:@"n"]];
        
        for (int i = 0; i < [arra count]; i++)
        {
            NSDictionary *dict = [arra objectAtIndex:i];
            
            if ([[dict objectForKey:@"n"] containsString:string])
            {
                if ([[dict objectForKey:@"ic"] isEqualToString:[dictItem objectForKey:@"ic"]])
                {
                    
                }
                else
                {
                    [dictItem setObject:[dict objectForKey:@"ic"] forKey:@"ic"];
                    
                    [self createAddOnTypes:[dict objectForKey:@"addOn"] DictAddOn:dictItem];
                }
                
                break;
            }
        }
    }
    
    [self closePopoverView:nil];
}

-(void) createAddOnTypes:(NSArray *) arrAddOn DictAddOn:(NSMutableDictionary *) dictItem
{
    
    UIScrollView *viewSe = [scrollItems viewWithTag:segmentCategory.selectedSegmentIndex+1];
    
    CGFloat yAxis = viewSe.contentSize.height;
    
    UIView *viewUnderAdd = [viewSe viewWithTag:ADDON_TYPE_TAG+segmentCategory.selectedSegmentIndex+1];
    
    if (viewUnderAdd)
    {
        for (__strong id view in viewUnderAdd.subviews)
        {
            [view removeFromSuperview];
            view = nil;
        }
        
        orgContentHeight = orgContentHeight-(viewUnderAdd.frame.size.height+20*MULTIPLYHEIGHT);
        
        yAxis = orgContentHeight;
        
        [viewUnderAdd removeFromSuperview];
        viewUnderAdd = nil;
    }
    
    if (![arrAddOn count])
    {
        viewSe.contentSize = CGSizeMake(screen_width, yAxis);
        
        return;
    }
    
    viewUnderAdd = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, 10)];
    viewUnderAdd.tag = ADDON_TYPE_TAG+segmentCategory.selectedSegmentIndex+1;
    [viewSe addSubview:viewUnderAdd];
    
    CGFloat lblTH = 25*MULTIPLYHEIGHT;
    CGFloat lblTX = 10*MULTIPLYHEIGHT;
    CGFloat lblTW = screen_width-lblTX*2;
    
    UILabel *lblAddOn = [[UILabel alloc]initWithFrame:CGRectMake(lblTX, 0, lblTW, lblTH)];
    lblAddOn.text = @"Add ons";
    lblAddOn.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
    lblAddOn.textColor = [UIColor grayColor];
    [viewUnderAdd addSubview:lblAddOn];
    
    [dictItem removeObjectForKey:@"addOn"];
    
    NSMutableDictionary *dictAddON = [[NSMutableDictionary alloc]init];
    
    CGFloat btnAY = lblTH;
    
    for (int j = 0; j < [arrAddOn count]; j++)
    {
        NSDictionary *dictAddOn = [arrAddOn objectAtIndex:j];
        
        UIButton *btnAddOn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnAddOn setTitle:[dictAddOn objectForKey:@"name"] forState:UIControlStateNormal];
        [btnAddOn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [btnAddOn setImage:[UIImage imageNamed:@"uncheckmark"] forState:UIControlStateNormal];
        [btnAddOn setImage:[UIImage imageNamed:@"checkmark"] forState:UIControlStateSelected];
        btnAddOn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnAddOn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        btnAddOn.titleLabel.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1];
        [btnAddOn addTarget:self action:@selector(btnAddOnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [viewUnderAdd addSubview:btnAddOn];
        
        NSMutableDictionary *dictUnder = [[NSMutableDictionary alloc]initWithDictionary:dictAddOn];
        [dictUnder setObject:@"0" forKey:@"value"];
        
        [dictAddON setObject:dictUnder forKey:[dictAddOn objectForKey:@"name"]];
        
        CGFloat inset = 3*MULTIPLYHEIGHT;
        
        btnAddOn.imageEdgeInsets = UIEdgeInsetsMake(inset, inset, inset, inset);
        
        btnAddOn.frame = CGRectMake(lblTX, btnAY, lblTW, lblTH);
        
        [btnAddOn buttonImageAndTextWithImagePosition:@"LEFT" WithSpacing:10];
        
        btnAY += lblTH+5*MULTIPLYHEIGHT;
    }
    
    [dictItem setObject:dictAddON forKey:@"addOn"];
    
    CGRect frame = viewUnderAdd.frame;
    frame.size.height = btnAY;
    viewUnderAdd.frame = frame;
    
    yAxis += btnAY;
    
    yAxis += 20*MULTIPLYHEIGHT;
    
    viewSe.contentSize = CGSizeMake(screen_width, yAxis);
    
    orgContentHeight = yAxis;
}

-(void) keyboardwillChangeNotif:(NSNotification *) notification
{
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    CGPoint point;
    
    if (fromTF)
    {
        point = [senderTF.superview convertPoint:senderTF.frame.origin toView:nil];
    }
    else
    {
        point = [senderTV.superview convertPoint:senderTV.frame.origin toView:nil];
        point.y = point.y + senderTV.frame.size.height;
    }
    
    CGRect keyboardFrameEnd = [self.view convertRect:keyboardEndFrame toView:nil];
    
    if (point.y > keyboardFrameEnd.origin.y)
    {
        scrollInnerView.contentSize = CGSizeMake(screen_width, orgContentHeight + keyboardFrameEnd.origin.y);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        
        //CGRect keyboardFrameBegin = [self.view convertRect:keyboardBeginFrame toView:nil];
        
        scrollInnerView.contentOffset = CGPointMake(0, orgOffsetY + (point.y - keyboardFrameEnd.origin.y));
        
        [UIView commitAnimations];
    }
    else
    {
        scrollInnerView.contentSize = CGSizeMake(screen_width, orgContentHeight);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:animationDuration];
        [UIView setAnimationCurve:animationCurve];
        
        //CGRect keyboardFrameBegin = [self.view convertRect:keyboardBeginFrame toView:nil];
        
        if (scrollInnerView.frame.size.height > orgContentHeight)
        {
            scrollInnerView.contentOffset = CGPointZero;
            orgOffsetY = 0;
        }
        else
        {
            scrollInnerView.contentOffset = CGPointMake(0, orgOffsetY);
        }
        
        [UIView commitAnimations];
    }
}

- (void)colorPickerViewController:(FCColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color
{
    NSString *strHex = [self hexStringFromColor:color];
    NSLog(@"color : %@", strHex);
    btnColorSender.backgroundColor = color;
    
    NSMutableArray *arraItems = [dictSaveData objectForKey:[dictServiceTypeIndexwise objectForKey:[NSString stringWithFormat:@"%ld", segmentCategory.selectedSegmentIndex]]];
    
    NSMutableDictionary *dictItem;
    
    for (int i = 0; i < [arraItems count]; i++)
    {
        NSMutableDictionary *dict1 = [arraItems objectAtIndex:i];
        
        if ([[dict1 objectForKey:@"itemRow"] intValue] == btnColorSender.superview.tag)
        {
            dictItem = dict1;
            
            break;
        }
    }
    
    if (dictItem)
    {
        [dictItem setObject:strHex forKey:@"colorCode"];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSString *)hexStringFromColor:(UIColor *)color {
    const CGFloat *components = CGColorGetComponents(color.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

- (void)colorPickerViewControllerDidCancel:(FCColorPickerViewController *)colorPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) getCategories
{
    [self.view endEditing:YES];
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSMutableDictionary *registrationDetailsDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.strOrderType, @"orderType", self.strServiceType, @"serviceType", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@pricing/get", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:registrationDetailsDic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [self.arrayCategories removeAllObjects];
            [self.arrayCategories addObjectsFromArray:[responseObj objectForKey:@"prices"]];
            
            [dictCategories setObject:[responseObj objectForKey:@"prices"] forKey:self.strServiceType];
            
            [self getCategoryNames];
            
            [self openPopoverWithData:arrayCategoryNames];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
