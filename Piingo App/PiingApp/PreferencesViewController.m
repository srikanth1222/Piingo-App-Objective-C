//
//  PreferencesViewController.m
//  Piing
//
//  Created by Veedepu Srikanth on 26/09/16.
//  Copyright © 2016 shashank. All rights reserved.
//

#import "PreferencesViewController.h"
#import "AppDelegate.h"
#import "PiingApp-Swift.h"
#import "UIButton+Position.h"


@interface PreferencesViewController () <UITextViewDelegate>
{
    AppDelegate *appDel;
    
    UIScrollView *scrollPre;
    
    CGPoint orgContentOffset;
    
    CGFloat orgContentHeight;
    
    NSArray *arraTit;
    
    NSString *strDefaultText;
    
    UIButton *btnDone;
    
    NSMutableDictionary *dictMain;
}

@end

@implementation PreferencesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    strDefaultText = @"   Do you have any special instructions for us?";
    
    dictMain  = [[NSMutableDictionary alloc]init];
    
    if ([self.strPrefs length])
    {
        self.strPrefs = [self.strPrefs stringByReplacingOccurrencesOfString:@"[" withString:@""];
        self.strPrefs = [self.strPrefs stringByReplacingOccurrencesOfString:@"]" withString:@""];
        self.strPrefs = [self.strPrefs stringByReplacingOccurrencesOfString:@"{" withString:@""];
        self.strPrefs = [self.strPrefs stringByReplacingOccurrencesOfString:@"}," withString:@"^"];
        self.strPrefs = [self.strPrefs stringByReplacingOccurrencesOfString:@"}" withString:@""];
        
        NSArray *arr = [self.strPrefs componentsSeparatedByString:@"^"];
        
        for (NSString *str in arr)
        {
            NSData *data = [[NSString stringWithFormat:@"{%@}", str] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict1 = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            [dictMain setObject:[dict1 objectForKey:@"value"] forKey:[dict1 objectForKey:@"name"]];
        }
    }
    //    else
    //    {
    //        dictMain  = [[NSMutableDictionary alloc]init];
    //
    //        [dictMain setObject:@"Hanger" forKey:@"Shirts"];
    //
    //        [dictMain setObject:@"Standard Hanger" forKey:@"TrousersHanged"];
    //
    //        [dictMain setObject:@"Without Crease" forKey:@"TrousersCrease"];
    //
    //        [dictMain setObject:@"No Starch" forKey:@"Starch"];
    //
    //        [dictMain setObject:@"No" forKey:@"Stain"];
    //
    //        [dictMain setObject:@"" forKey:@"Note"];
    //    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardwillShowNotif:) name:UIKeyboardWillShowNotification object:nil];
    
    float yPos = 25*MULTIPLYHEIGHT;
    
    float imgHeight = 130*MULTIPLYHEIGHT;
    
    UIImageView *imgView = [[UIImageView alloc]init];
    imgView.image = [UIImage imageNamed:@"preference_bg"];
    imgView.frame = CGRectMake(0, 0, screen_width, imgHeight);
    [self.view addSubview:imgView];
    
    UILabel *titleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, yPos, screen_width, 40.0)];
    NSString *string = @"PREFERENCES";
    [appDel spacingForTitle:titleLbl TitleString:string];
    titleLbl.textAlignment = NSTextAlignmentCenter;
    titleLbl.textColor = [UIColor whiteColor];
    titleLbl.backgroundColor = [UIColor clearColor];
    titleLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE-3];
    [self.view addSubview:titleLbl];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(screen_width - 50.0, yPos, 40.0, 40.0);
    [closeBtn setImage:[UIImage imageNamed:@"cancel_white"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closePreferences) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    
    float imgWidth = 40*MULTIPLYHEIGHT;
    UIImageView *imgTop = [[UIImageView alloc]init];
    imgTop.contentMode = UIViewContentModeScaleAspectFit;
    imgTop.frame = CGRectMake(screen_width/2-imgWidth/2, yPos+40+2*MULTIPLYHEIGHT, imgWidth, imgWidth);
    imgTop.image = [UIImage imageNamed:@"preference_icon"];
    [self.view addSubview:imgTop];
    
    
    yPos += imgHeight;
    
    scrollPre = [[UIScrollView alloc]init];
    //scrollPre.backgroundColor = [UIColor redColor];
    [scrollPre flashScrollIndicators];
    scrollPre.frame = CGRectMake(0, imgHeight, screen_width, screen_height-imgHeight-60*MULTIPLYHEIGHT);
    [self.view addSubview:scrollPre];
    
    
    float yAxis = 30*MULTIPLYHEIGHT;
    
    arraTit = [NSArray arrayWithObjects:@"SHIRTS", @"TROUSERS", @"STARCH", @"STAINS", @"NOTES", nil];
    
    for (int i=0; i<[arraTit count]; i++)
    {
        int xAxis = 25*MULTIPLYHEIGHT;
        
        UILabel *lblTit = [[UILabel alloc]initWithFrame:CGRectMake(xAxis, yAxis-1*MULTIPLYHEIGHT, screen_width-xAxis, 23*MULTIPLYHEIGHT)];
        NSString *string = [arraTit objectAtIndex:i];
        lblTit.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM+2];
        lblTit.textColor = [UIColor darkGrayColor];
        [scrollPre addSubview:lblTit];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
        
        float spacing = 1.5f;
        [attributedString addAttribute:NSKernAttributeName
                                 value:@(spacing)
                                 range:NSMakeRange(0, [string length])];
        
        lblTit.attributedText = attributedString;
        
        CALayer *layer = [[CALayer alloc]init];
        layer.frame = CGRectMake(0, lblTit.frame.size.height-1, 20*MULTIPLYHEIGHT, 1);
        layer.backgroundColor = RGBCOLORCODE(200, 200, 200, 1.0).CGColor;
        [lblTit.layer addSublayer:layer];
        
        
        yAxis += lblTit.frame.size.height+20*MULTIPLYHEIGHT;
        
        UIView *viewBg;
        
        if (i != 4)
        {
            float vHeight = 35*MULTIPLYHEIGHT;
            
            float imgX = 47*MULTIPLYHEIGHT;
            float imgWidth = 175*MULTIPLYHEIGHT;
            
            if (i == 1)
            {
                vHeight = 90*MULTIPLYHEIGHT;
                
                viewBg = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, vHeight)];
                
                yAxis += 60*MULTIPLYHEIGHT;
            }
            else if (i == 2)
            {
                imgX = 42*MULTIPLYHEIGHT;
                imgWidth = 185*MULTIPLYHEIGHT;
                
                viewBg = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, vHeight)];
            }
            else
            {
                viewBg = [[UIView alloc]initWithFrame:CGRectMake(0, yAxis, screen_width, vHeight)];
            }
            
            viewBg.tag = i+1;
            //viewBg.backgroundColor = [[UIColor redColor]colorWithAlphaComponent:0.3];
            [scrollPre addSubview:viewBg];
            
            yAxis += 43*MULTIPLYHEIGHT;
            
            UIImageView *imgLine = [[UIImageView alloc]initWithFrame:CGRectMake(imgX, yAxis, imgWidth, 1)];
            imgLine.backgroundColor = RGBCOLORCODE(235, 235, 235, 1.0);
            [scrollPre addSubview:imgLine];
        }
        
        
        if (i == 0 || i == 1 || i == 3)
        {
            float btnX = 25*MULTIPLYHEIGHT;
            
            for (int j=0; j<2; j++)
            {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = j+1;
                btn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
                [viewBg addSubview:btn];
                
                NSString *str1 = @"";
                NSString *str2 = @"";
                
                if (i == 0)
                {
                    str1 = @"FOLD";
                    str2 = @"HANGER";
                }
                else if (i == 1)
                {
                    str1 = @"CLIP HANGER";
                    str2 = @"STANDARD HANGER";
                }
                else if (i == 3)
                {
                    str1 = @"YES";
                    str2 = @"NO";
                }
                
                if (j == 0)
                {
                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str1];
                    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, [attr length])];
                    
                    float spacing = 1.0f;
                    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
                    
                    NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:str1];
                    [attrSel addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, [attrSel length])];
                    [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
                    
                    [btn setAttributedTitle:attr forState:UIControlStateNormal];
                    [btn setAttributedTitle:attrSel forState:UIControlStateSelected];
                    
                    btn.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                    btn.layer.borderWidth = 1.0f;
                    
                    if (i == 0)
                    {
                        if ([dictMain objectForKey:@"Shirts"] && [[dictMain objectForKey:@"Shirts"] caseInsensitiveCompare:str1] == NSOrderedSame)
                        {
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                    else if (i == 1)
                    {
                        if ([dictMain objectForKey:@"TrousersHanged"] && [[dictMain objectForKey:@"TrousersHanged"] caseInsensitiveCompare:str1] == NSOrderedSame)
                        {
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                    else if (i == 3)
                    {
                        if ([dictMain objectForKey:@"Stain"] && [[dictMain objectForKey:@"Stain"] caseInsensitiveCompare:str1] == NSOrderedSame)
                        {
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                }
                else
                {
                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str2];
                    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, [attr length])];
                    
                    float spacing = 1.0f;
                    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
                    
                    NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:str2];
                    [attrSel addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, [attrSel length])];
                    [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
                    
                    [btn setAttributedTitle:attr forState:UIControlStateNormal];
                    [btn setAttributedTitle:attrSel forState:UIControlStateSelected];
                    
                    btn.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                    btn.layer.borderWidth = 1.0f;
                    
                    [viewBg sendSubviewToBack:btn];
                    
                    if (i == 0)
                    {
                        if ([dictMain objectForKey:@"Shirts"] && [[dictMain objectForKey:@"Shirts"] caseInsensitiveCompare:str2] == NSOrderedSame)
                        {
                            [viewBg bringSubviewToFront:btn];
                            
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                    else if (i == 1)
                    {
                        if ([dictMain objectForKey:@"TrousersHanged"] && [[dictMain objectForKey:@"TrousersHanged"] caseInsensitiveCompare:str2] == NSOrderedSame)
                        {
                            [viewBg bringSubviewToFront:btn];
                            
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                    else if (i == 3)
                    {
                        if ([dictMain objectForKey:@"Stain"] && [[dictMain objectForKey:@"Stain"] caseInsensitiveCompare:str2] == NSOrderedSame)
                        {
                            [viewBg bringSubviewToFront:btn];
                            
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                }
                
                [btn addTarget:self action:@selector(btnOptionsSelected:) forControlEvents:UIControlEventTouchUpInside];
                
                float btnWidth = 110*MULTIPLYHEIGHT;
                float btnHeight = 23*MULTIPLYHEIGHT;
                
                btn.frame = CGRectMake(btnX, 0, btnWidth, btnHeight);
                
                
                if (i == 1)
                {
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                    btn.tag = j+3;
                    btn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
                    [viewBg addSubview:btn];
                    
                    NSString *str1 = @"";
                    NSString *str2 = @"";
                    
                    str1 = @"WITH CREASE";
                    str2 = @"WITHOUT CREASE";
                    
                    if (j == 0)
                    {
                        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str1];
                        [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, [attr length])];
                        
                        float spacing = 1.0f;
                        [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
                        
                        NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:str1];
                        [attrSel addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, [attrSel length])];
                        [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
                        
                        [btn setAttributedTitle:attr forState:UIControlStateNormal];
                        [btn setAttributedTitle:attrSel forState:UIControlStateSelected];
                        
                        btn.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                        btn.layer.borderWidth = 1.0f;
                        
                        if ([dictMain objectForKey:@"TrousersCrease"] && [[dictMain objectForKey:@"TrousersCrease"] caseInsensitiveCompare:str1] == NSOrderedSame)
                        {
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                    else
                    {
                        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str2];
                        [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, [attr length])];
                        
                        float spacing = 1.0f;
                        [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
                        
                        NSMutableAttributedString *attrSel = [[NSMutableAttributedString alloc] initWithString:str2];
                        [attrSel addAttributes:@{NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, [attrSel length])];
                        [attrSel addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attrSel length])];
                        
                        [btn setAttributedTitle:attr forState:UIControlStateNormal];
                        [btn setAttributedTitle:attrSel forState:UIControlStateSelected];
                        
                        btn.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                        btn.layer.borderWidth = 1.0f;
                        
                        [viewBg sendSubviewToBack:btn];
                        
                        if ([dictMain objectForKey:@"TrousersCrease"] && [[dictMain objectForKey:@"TrousersCrease"] caseInsensitiveCompare:str2] == NSOrderedSame)
                        {
                            [viewBg bringSubviewToFront:btn];
                            
                            btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                            btn.layer.borderWidth = 1.0f;
                            
                            btn.selected = YES;
                        }
                    }
                    
                    [btn addTarget:self action:@selector(btnCreaseSelected:) forControlEvents:UIControlEventTouchUpInside];
                    
                    btn.frame = CGRectMake(btnX, btnHeight+35*MULTIPLYHEIGHT, btnWidth, btnHeight);
                }
                
                
                btnX += btnWidth-1;
                
                if (i == 0 && j == 0)
                {
                    float lblPX = 0;
                    float lblPY = btnHeight;
                    float lblPW = screen_width;
                    float lblPH = 23*MULTIPLYHEIGHT;
                    
                    UILabel *lblPI = [[UILabel alloc]initWithFrame:CGRectMake(lblPX, lblPY, lblPW, lblPH)];
                    lblPI.textColor = RGBCOLORCODE(200, 200, 200, 1.0);
                    lblPI.textAlignment = NSTextAlignmentCenter;
                    lblPI.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
                    [viewBg addSubview:lblPI];
                    
                    NSString *strClipHanger_Extra = @"Additional $0.50 cents per fold";
                    
                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:strClipHanger_Extra];
                    
                    float spacing = 1.0f;
                    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
                    lblPI.attributedText = attr;
                    
                    if ([[dictMain objectForKey:@"Shirts"] caseInsensitiveCompare:str2] == NSOrderedSame)
                    {
                        lblPI.hidden = YES;
                    }
                }
                else if (i == 1 && j == 0)
                {
                    float lblPX = 0;
                    float lblPY = btnHeight;
                    float lblPW = screen_width;
                    float lblPH = 23*MULTIPLYHEIGHT;
                    
                    UILabel *lblPI = [[UILabel alloc]initWithFrame:CGRectMake(lblPX, lblPY, lblPW, lblPH)];
                    lblPI.textColor = RGBCOLORCODE(200, 200, 200, 1.0);
                    lblPI.textAlignment = NSTextAlignmentCenter;
                    lblPI.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
                    [viewBg addSubview:lblPI];
                    
                    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"Additional $0.50 cents per trouser"];
                    
                    float spacing = 1.0f;
                    [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
                    lblPI.attributedText = attr;
                    
                    if ([[dictMain objectForKey:@"TrousersHanged"] caseInsensitiveCompare:str2] == NSOrderedSame)
                    {
                        lblPI.hidden = YES;
                    }
                    
                }
            }
        }
        else if (i == 2)
        {
            float btnX = 25*MULTIPLYHEIGHT;
            
            NSArray *arr = [NSArray arrayWithObjects:@"LOW", @"MEDIUM", @"HIGH", nil];
            
            for (int j=0; j<[arr count]; j++)
            {
                NSString *str = [arr objectAtIndex:j];
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = j+1;
                btn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
                [viewBg addSubview:btn];
                
                NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
                [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, [attr length])];
                
                float spacing = 1.0f;
                [attr addAttribute:NSKernAttributeName value:@(spacing) range:NSMakeRange(0, [attr length])];
                
                [btn setAttributedTitle:attr forState:UIControlStateNormal];
                
                [btn addTarget:self action:@selector(btnStarchSelected:) forControlEvents:UIControlEventTouchUpInside];
                
                float btnWidth = 72*MULTIPLYHEIGHT;
                float btnHeight = 23*MULTIPLYHEIGHT;
                
                btn.frame = CGRectMake(btnX, 0, btnWidth, btnHeight);
                
                if (j == 0)
                {
                    btn.backgroundColor = [UIColor colorFromHexString:@"9bb3c9"];
                }
                else if (j == 1)
                {
                    btn.backgroundColor = [UIColor colorFromHexString:@"6ea3cf"];
                }
                else
                {
                    btn.backgroundColor = [UIColor colorFromHexString:@"488bcf"];
                }
                
                btn.alpha = 0.3;
                
                if ([dictMain objectForKey:@"Starch"] && [[dictMain objectForKey:@"Starch"] caseInsensitiveCompare:@"Low"] == NSOrderedSame && j == 0)
                {
                    btn.alpha = 1.0;
                }
                else if ([dictMain objectForKey:@"Starch"] && [[dictMain objectForKey:@"Starch"] caseInsensitiveCompare:@"Medium"] == NSOrderedSame && j == 1)
                {
                    btn.alpha = 1.0;
                }
                else if ([dictMain objectForKey:@"Starch"] && [[dictMain objectForKey:@"Starch"] caseInsensitiveCompare:@"High"] == NSOrderedSame && j == 2)
                {
                    btn.alpha = 1.0;
                }
                
                btnX += btnWidth+1;
            }
        }
        else if (i == 4)
        {
            float tvX = 25*MULTIPLYHEIGHT;
            float tvW = 220*MULTIPLYHEIGHT;
            float tvH = 70*MULTIPLYHEIGHT;
            
            UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(tvX, yAxis-10*MULTIPLYHEIGHT, tvW, tvH)];
            tv.delegate = self;
            tv.backgroundColor = RGBCOLORCODE(240, 240, 240, 1.0);
            tv.textColor = [UIColor darkGrayColor];
            [scrollPre addSubview:tv];
            
            tv.textColor = [UIColor lightGrayColor];
            tv.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
            tv.text = strDefaultText;
            
            if ([[dictMain objectForKey:@"Note"] length])
            {
                tv.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
                tv.textColor = [UIColor darkGrayColor];
                tv.text = [dictMain objectForKey:@"Note"];
            }
            
            UIToolbar* tvToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
            tvToolbar.barTintColor = [UIColor whiteColor];
            tvToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)], nil];
            [tvToolbar sizeToFit];
            tv.inputAccessoryView = tvToolbar;
            
            yAxis += tvH;
        }
        
        yAxis += 20*MULTIPLYHEIGHT;
    }
    
    orgContentHeight = yAxis+20*MULTIPLYHEIGHT;
    
    scrollPre.contentSize = CGSizeMake(scrollPre.frame.size.width, orgContentHeight);
    
    
    btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:btnDone];
    [btnDone setImage:[UIImage imageNamed:@"save_pref"] forState:UIControlStateNormal];
    btnDone.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.FONT_SIZE_CUSTOM-2];
    [btnDone addTarget:self action:@selector(savePreferences) forControlEvents:UIControlEventTouchUpInside];
    
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
    
}



-(void) showAlert
{
    [AppDelegate showAlertWithMessage:@"You can't change preferences." andTitle:@"" andBtnTitle:@"OK"];
}

-(void) switchChanged:(SevenSwitch *)switch1
{
    UIView *viewBg = switch1.superview;
    
    if (viewBg.tag == 2)
    {
        if (switch1.isOn)
        {
            [dictMain setObject:@"With Crease" forKey:@"TrousersCrease"];
        }
        else
        {
            [dictMain setObject:@"Without Crease" forKey:@"TrousersCrease"];
        }
    }
    else if (viewBg.tag == 4)
    {
        if (switch1.isOn)
        {
            [dictMain setObject:@"Yes" forKey:@"Stain"];
        }
        else
        {
            [dictMain setObject:@"No" forKey:@"Stain"];
        }
    }
}

-(void) doneClicked
{
    [self.view endEditing:YES];
}

-(void) btnOptionsSelected:(UIButton *)btn
{
    UIView *viewBg = btn.superview;
    
    BOOL lblTrouHidden = YES;
    BOOL lblFoldHidden = YES;
    
    for (id sender in viewBg.subviews)
    {
        if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *btn1 = (UIButton *) sender;
            
            if (btn1.frame.origin.y == btn.frame.origin.y)
            {
                btn1.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                btn1.layer.borderWidth = 1.0f;
                btn1.selected = NO;
                
                if (btn1.tag == btn.tag)
                {
                    btn.selected = YES;
                    [viewBg bringSubviewToFront:btn];
                    
                    btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                    btn.layer.borderWidth = 1.0f;
                    
                    if (viewBg.tag == 2 && btn.tag == 1)
                    {
                        lblTrouHidden = NO;
                    }
                    else if (viewBg.tag == 1 && btn.tag == 1)
                    {
                        lblFoldHidden = NO;
                    }
                }
            }
        }
        
        for (id sender1 in viewBg.subviews)
        {
            if ([sender1 isKindOfClass:[UILabel class]])
            {
                UILabel *lbl = (UILabel *) sender1;
                
                if (viewBg.tag == 1)
                {
                    lbl.hidden = lblFoldHidden;
                }
                else if (viewBg.tag == 2)
                {
                    lbl.hidden = lblTrouHidden;
                }
                
                break;
            }
        }
    }
    
    if (viewBg.tag == 1)
    {
        if (btn.tag == 1)
        {
            [dictMain setObject:@"Fold" forKey:@"Shirts"];
        }
        else
        {
            [dictMain setObject:@"Hanger" forKey:@"Shirts"];
        }
    }
    else if (viewBg.tag == 2)
    {
        if (btn.tag == 1)
        {
            [dictMain setObject:@"Clip Hanger" forKey:@"TrousersHanged"];
        }
        else
        {
            [dictMain setObject:@"Standard Hanger" forKey:@"TrousersHanged"];
        }
    }
    else if (viewBg.tag == 4)
    {
        if (btn.tag == 1)
        {
            [dictMain setObject:@"Yes" forKey:@"Stain"];
        }
        else
        {
            [dictMain setObject:@"No" forKey:@"Stain"];
        }
    }
}

-(void) btnCreaseSelected:(UIButton *)btn
{
    UIView *viewBg = btn.superview;
    
    for (id sender in viewBg.subviews)
    {
        if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *btn1 = (UIButton *) sender;
            
            if (btn1.frame.origin.y == btn.frame.origin.y)
            {
                btn1.layer.borderColor = RGBCOLORCODE(220, 220, 220, 1.0).CGColor;
                btn1.layer.borderWidth = 1.0f;
                btn1.selected = NO;
                
                if (btn1.tag == btn.tag)
                {
                    btn.selected = YES;
                    [viewBg bringSubviewToFront:btn];
                    
                    btn.layer.borderColor = [BLUE_COLOR colorWithAlphaComponent:0.5].CGColor;
                    btn.layer.borderWidth = 1.0f;
                }
            }
        }
    }
    
    if (btn.tag == 3)
    {
        [dictMain setObject:@"With Crease" forKey:@"TrousersCrease"];
    }
    else
    {
        [dictMain setObject:@"Without Crease" forKey:@"TrousersCrease"];
    }
}

-(void) btnStarchSelected:(UIButton *) btn
{
    UIView *viewBg = btn.superview;
    
    for (id sender in viewBg.subviews)
    {
        if ([sender isKindOfClass:[UIButton class]])
        {
            UIButton *btn1 = (UIButton *) sender;
            
            if (btn1.tag == btn.tag)
            {
                btn1.alpha = 1.0;
            }
            else
            {
                btn1.alpha = 0.3;
            }
        }
    }
    
    if (viewBg.tag == 3)
    {
        if (btn.tag == 1)
        {
            [dictMain setObject:@"Low" forKey:@"Starch"];
        }
        else if (btn.tag == 2)
        {
            [dictMain setObject:@"Medium" forKey:@"Starch"];
        }
        else if (btn.tag == 3)
        {
            [dictMain setObject:@"High" forKey:@"Starch"];
        }
    }
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:strDefaultText])
    {
        textView.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-2];
        textView.textColor = [UIColor darkGrayColor];
        //textView.text = [self.orderUpdateInfo objectForKey:PNOTES];
        
        textView.text = @"";
    }
    
    CGPoint pointInTable = [textView.superview convertPoint:textView.frame.origin toView:scrollPre];
    CGPoint contentOffset = scrollPre.contentOffset;
    orgContentOffset = scrollPre.contentOffset;
    
    contentOffset.y = (pointInTable.y - textView.inputAccessoryView.frame.size.height);
    
    //NSLog(@"contentOffset is: %@", NSStringFromCGPoint(contentOffset));
    
    [scrollPre setContentOffset:contentOffset animated:YES];
    //[scrollPre setContentSize:CGSizeMake(scrollPre.frame.size.width, size.height+contentOffset.y)];
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.4f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    [scrollPre setContentSize:CGSizeMake(scrollPre.frame.size.width, orgContentHeight)];
    
    [scrollPre setContentOffset:orgContentOffset animated:NO];
    
    [UIView commitAnimations];
    
    textView.text = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([textView.text length] > 0 && ![textView.text isEqualToString:strDefaultText])
    {
        [dictMain setObject:textView.text forKey:@"Note"];
    }
    else
    {
        [dictMain setObject:@"" forKey:@"Note"];
        
        textView.textColor = [UIColor lightGrayColor];
        textView.font = [UIFont fontWithName:APPFONT_REGULAR size:appDel.FONT_SIZE_CUSTOM-4];
        textView.text = strDefaultText;
    }
    
    return YES;
}


-(void) keyboardwillShowNotif:(NSNotification *) notif
{
    //    NSTimeInterval obj = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //
    //    UIViewAnimationCurve curve = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey]integerValue];
    
    CGRect keyboardEndFrame = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    keyboardEndFrame = [self.view convertRect:keyboardEndFrame fromView:nil];
    
    //    [UIView beginAnimations:nil context:NULL];
    //    [UIView setAnimationDuration:0.3f];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    
    scrollPre.contentSize = CGSizeMake(scrollPre.frame.size.width, orgContentHeight+keyboardEndFrame.origin.y);
    
}

-(void) savePreferences
{
    
    //    NSError *error;
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictMain
    //                                                       options:0
    //                                                         error:&error];
    //
    //    if (! jsonData) {
    //        NSLog(@"Got an error: %@", error);
    //    } else {
    //        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //
    //        NSLog(@"%@", jsonString);
    //    }
    
    
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
    
    if ([self.delegate respondsToSelector:@selector(didAddPreferences:)])
    {
        [self closePreferences];
        
        [self.delegate didAddPreferences:strPref];
    }
}

-(void) closePreferences
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
