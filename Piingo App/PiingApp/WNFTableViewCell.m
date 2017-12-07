//
//  WashAndFoldBagTableViewCell.m
//  PiingApp
//
//  Created by SHASHANK on 23/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "WNFTableViewCell.h"

#define TEXT_LABEL_COLOR [UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0]

#define SPECIAL_REQ_NON_ACTIVE_COLOR [UIColor colorWithRed:173.0/255.0 green:173.0/255.0 blue:173.0/255.0 alpha:1.0]
#define SPECIAL_REQ_SELECTED_COLOR [UIColor colorWithRed:210.0/255.0 green:187.0/255.0 blue:102.0/255.0 alpha:1.0]

@implementation WNFTableViewCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andWithDelegate:(id) parentDelegate{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        parentDel = parentDelegate;
        
        self.backgroundColor = [UIColor clearColor];//[[UIColor blackColor] colorWithAlphaComponent:0.05];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
//        UIImage *bgImg = [UIImage imageNamed:@"cell_bg_9p"];
        UIImage *bgImg = [UIImage imageNamed:@""];
        bgImg = [bgImg resizableImageWithCapInsets:UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5)];
        
        cellBGimage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, screen_width-20, 110.0)];
        cellBGimage.image = bgImg;
        cellBGimage.userInteractionEnabled = YES;
        [self addSubview:cellBGimage];
        
        itemTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10+10, 10, screen_width, 20.0)];
        itemTypeLabel.backgroundColor = [UIColor clearColor];
        itemTypeLabel.font = [UIFont fontWithName:APPFONT_BOLD size:16.0];
        itemTypeLabel.textColor = APP_FONT_COLOR_GREY;
        [self addSubview:itemTypeLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(25.0, CGRectGetMaxY(itemTypeLabel.frame)+2, CGRectGetWidth(cellBGimage.frame) - 50.0, 1)];
        lineView.backgroundColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0];
        [self addSubview:lineView];
        
        tagTextFeild = [[UITextField alloc] initWithFrame:CGRectMake(screen_width-100, 10.0, 78, 22.0)];
        tagTextFeild.backgroundColor = [UIColor clearColor];
        //        tagTextFeild.layer.borderWidth = 1.0;
        //        tagTextFeild.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.7].CGColor;
//        tagTextFeild.placeholder = @"Enter tag No.";
        tagTextFeild.enabled = NO;
        tagTextFeild.textColor = [UIColor colorWithRed:42.0/255.0 green:172.0/255.0 blue:143.0/255.0 alpha:1.0];
        tagTextFeild.textAlignment = NSTextAlignmentCenter;
        tagTextFeild.font = [UIFont fontWithName:APPFONT_REGULAR size:14.0];
        tagTextFeild.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self addSubview:tagTextFeild];
        
        confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        confirmBtn.backgroundColor = APP_GREEN_THEME_COLOR;
        confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
        //        confirmBtn.layer.cornerRadius = 5.0;
        confirmBtn.clipsToBounds = NO;
        //        confirmBtn.layer.borderColor = APPLE_BLUE_COLOR.CGColor;
        //        confirmBtn.layer.borderWidth = 0.5;
        confirmBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
        confirmBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [confirmBtn setTitle:@"Edit" forState:UIControlStateDisabled];
        [confirmBtn setTitle:@"Confirm" forState:UIControlStateNormal];
        [confirmBtn addTarget:self action:@selector(conformBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [cellBGimage addSubview:confirmBtn];
        
        specialReqBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        specialReqBtn.backgroundColor = SPECIAL_REQ_NON_ACTIVE_COLOR;
        specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
        //        specialReqBtn.layer.cornerRadius = 5.0;
        specialReqBtn.clipsToBounds = NO;
        //        specialReqBtn.layer.borderColor = APPLE_BLUE_COLOR.CGColor;
        //        specialReqBtn.layer.borderWidth = 0.5;
        specialReqBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:13.0];
        specialReqBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [specialReqBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [specialReqBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7] forState:UIControlStateHighlighted];
        [specialReqBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
        [specialReqBtn setTitle:@"Spl.Request" forState:UIControlStateNormal];
        [specialReqBtn addTarget:self action:@selector(specialRequestClicked) forControlEvents:UIControlEventTouchUpInside];
        [cellBGimage addSubview:specialReqBtn];
        
        specialReqBtn.hidden = YES;
        confirmBtn.hidden = YES;
    }
    return self;
}
-(void) setDetials:(id) itemDetailObj
{
    confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
    specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0+5, 95, 25.0);
    
    {
        
        NSData *data = [@"{\"bag\":\"bag1\",\"bagTag\":\"123460\",\"bagType\":\"1(optinal:Load Wash)\",\"no.ofkgs\":\"1.0\",\"W&F details\":{\"WF\":{\"items\":[{\"cobid\":\"293\",\"odid\":\"9\",\"ic\":\"WF\",\"in\":\"Load Wash\",\"clr\":\"#CC66FF\",\"ip\":\"10.5\",\"ctmid\":\"1\",\"codimid\":\"5\",\"ct\":\"Cotton\",\"btmid\":\"1\",\"bn\":\"Dolce & Gabbana\",\"spc\":\"0\",\"aer\":\"No\",\"tagno\":\"7867861\",\"ds\":\"Y\",\"remarks\":\"dfg\"}]}}}" dataUsingEncoding:NSUTF8StringEncoding];
        id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if (itemDetailObj) {
            json =itemDetailObj;
        }
        
        if ([[[[[[[json objectForKey:@"Load Wash"] objectForKey:@"WF"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"aer"] capitalizedString] isEqualToString:@"YES"])
        {
            confirmBtn.enabled = NO;
            specialReqBtn.backgroundColor = SPECIAL_REQ_SELECTED_COLOR;
        }
        else
        {
            confirmBtn.enabled = YES;
            specialReqBtn.backgroundColor = SPECIAL_REQ_NON_ACTIVE_COLOR;
        }
        
        tagTextFeild.text = [NSString stringWithFormat:@"#%@", [json objectForKey:@"bagtag"]];
        
        if (0 == 0)
        {
            itemTypeLabel.text = @"Load Wash";
            
            UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(itemTypeLabel.frame)+10, CGRectGetWidth(cellBGimage.frame)-50, 20.0)];
            infoLabel.backgroundColor = [UIColor clearColor];
            infoLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:14.0];
            infoLabel.textColor = TEXT_LABEL_COLOR;
            infoLabel.text = [NSString stringWithFormat:@"Number of kg (%@)",[json objectForKey:@"no.ofkgs"]];
            [self addSubview:infoLabel];
            
            UILabel *bagPriceValue = [[UILabel alloc] initWithFrame:CGRectMake(screen_width-50-25, CGRectGetMaxY(itemTypeLabel.frame)+10, 50, 20.0)];
            bagPriceValue.textAlignment = NSTextAlignmentCenter;
            bagPriceValue.backgroundColor = [UIColor clearColor];
            bagPriceValue.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
            bagPriceValue.textColor = TEXT_LABEL_COLOR;
            bagPriceValue.text = [NSString stringWithFormat:@"$%@",[[[[[json objectForKey:@"Load Wash"] objectForKey:@"WF"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"ip"]];
            [self addSubview:bagPriceValue];
            
            UILabel *pricePerkgLbl = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(infoLabel.frame), CGRectGetWidth(cellBGimage.frame)-50, 15.0)];
            pricePerkgLbl.textAlignment = NSTextAlignmentLeft;
            pricePerkgLbl.backgroundColor = [UIColor clearColor];
            pricePerkgLbl.font = [UIFont fontWithName:APPFONT_LIGHT size:12.0];
            pricePerkgLbl.textColor = [UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0];
            pricePerkgLbl.text = [NSString stringWithFormat:@"$3.99 per kg"];
            [self addSubview:pricePerkgLbl];
            
            return;
        }
        
        
        cellBGimage.frame = CGRectMake(10, 5, screen_width-20, 110.0-15.0);
        
        
        confirmBtn.frame = CGRectMake(CGRectGetWidth(cellBGimage.frame)-105.0, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
        specialReqBtn.frame = CGRectMake(10, CGRectGetHeight(cellBGimage.frame)-40.0, 95, 25.0);
        
    }
}
-(void) specialRequestClicked
{
    
}
-(void) conformBtnClicked
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
