//
//  ListView.m
//  Piing
//
//  Created by Piing on 10/25/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import "ListView.h"

#define CELL_HEIGHT 50*MULTIPLYHEIGHT

@implementation Item



@end


@interface ListView() <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *tblView;
    
    AppDelegate *appDel;
}

@end

@implementation ListView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame andDisplayList:(NSArray *)list{
    
    appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    self = [super initWithFrame:frame];
    self.items = list;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    //float height = MAX(list.count*CELL_HEIGHT, screen_height);
    
    
    self.clipsToBounds = YES;
    
    if (self) {
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.bounds), screen_height)];
        //bgView.backgroundColor = [UIColor colorFromHexString:@"edf1fa"];
        bgView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
        [self addSubview:bgView];
        
        tblView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 20.0, CGRectGetWidth(self.bounds), screen_height-20.0) style:UITableViewStylePlain];
        tblView.backgroundColor = [UIColor clearColor];
        tblView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tblView.delegate = self;
        tblView.dataSource = self;
        [self addSubview:tblView];
    }
    
    return self;
    
}

-(void)setItems:(NSArray *)items {
    
    _items = items;
    
    float customHeight = 0.0;
    
    for (int i = 0; i<[self.items count]; i++)
    {
        
//        if([[[self.items objectAtIndex:i] objectForKey:@"discountValue"]boolValue])
//        {
//            float height = 50*MULTIPLYHEIGHT;
//            
//            customHeight += height+6;
//        }
//        else
//        {
//            float height = 45*MULTIPLYHEIGHT;
//            
//            customHeight += height+6;
//        }
        
        float height = CELL_HEIGHT;
        customHeight += height;
    }
    
    float minusHeight = 30*MULTIPLYHEIGHT;
    
    float height = MIN(customHeight, (screen_height - (minusHeight*2)));
    tblView.frame = CGRectMake(0.0, minusHeight, CGRectGetWidth(self.bounds), height);
    tblView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    [tblView reloadData];
    
}

-(void)setSelectedItem:(NSString *)selectedItem {
    _selectedItem = selectedItem;
    [tblView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if([[[self.items objectAtIndex:indexPath.row] objectForKey:@"discountValue"]boolValue])
//    {
//        float height = 45*MULTIPLYHEIGHT;
//        return height+6;
//    }
//    else
//    {
//        float height = 45*MULTIPLYHEIGHT;
//        return height+6;
//    }
    
    float height = CELL_HEIGHT;
    return height;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        UILabel *valueLbl  = [[UILabel alloc] init];
        valueLbl.tag = 1;
        valueLbl.numberOfLines = 0;
        valueLbl.textAlignment = NSTextAlignmentCenter;
        valueLbl.textColor = [UIColor grayColor];
        valueLbl.backgroundColor = [UIColor clearColor];
        valueLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE];
        [cell.contentView addSubview:valueLbl];
        
        
        UIImageView *discountBorderImgView = [[UIImageView alloc] init];
        discountBorderImgView.tag = 2;
        discountBorderImgView.image = [UIImage imageNamed:@"discount_bg.png"];
        discountBorderImgView.contentMode = UIViewContentModeScaleAspectFit;
        //[cell.contentView addSubview:discountBorderImgView];
        
        UILabel *discountLbl = [[UILabel alloc] init];
        discountLbl.tag = 3;
        discountLbl.numberOfLines = 0;
        discountLbl.textAlignment = NSTextAlignmentCenter;
        discountLbl.textColor = [UIColor darkGrayColor];
        discountLbl.backgroundColor = [UIColor clearColor];
        discountLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-5];
        [cell.contentView addSubview:discountLbl];
        
        UIImageView *selectionImgView = [[UIImageView alloc] init];
        selectionImgView.tag = 4;
        selectionImgView.contentMode = UIViewContentModeScaleAspectFit;
        selectionImgView.image = [UIImage imageNamed:@"blue_tick"];
        [cell.contentView addSubview:selectionImgView];
        
    }
    
    UILabel *valueLbl = (UILabel *)[cell.contentView viewWithTag:1];
    valueLbl.backgroundColor = [UIColor clearColor];
    valueLbl.textAlignment = NSTextAlignmentLeft;
    
    UIImageView *selectionImgView = (UIImageView *)[cell.contentView viewWithTag:4];
    selectionImgView.hidden = ![[[self.items objectAtIndex:indexPath.row] objectForKey:@"actValue"] isEqualToString:self.selectedItem];
    valueLbl.textColor = [selectionImgView isHidden] ? [UIColor grayColor] : APPLE_BLUE_COLOR;
    
    NSString *strText = [[self.items objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    if ([strText containsString:@", "])
    {
        NSArray *array = [strText componentsSeparatedByString:@", "];
        
        NSString *str1 = [NSString stringWithFormat:@"%@, ", [array objectAtIndex:0]];
        NSString *str2 = [array objectAtIndex:1];
        
        if ([selectionImgView isHidden])
        {
            NSMutableAttributedString *attrMain = [[NSMutableAttributedString alloc]initWithString:str1];
            [attrMain addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE], NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, str1.length)];
            
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:str2];
            [attr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE-2], NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, str2.length)];
            
            [attrMain appendAttributedString:attr1];
            
            valueLbl.attributedText = attrMain;
        }
        else
        {
            NSMutableAttributedString *attrMain = [[NSMutableAttributedString alloc]initWithString:str1];
            [attrMain addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str1.length)];
            
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:str2];
            [attr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE-2], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str2.length)];
            
            [attrMain appendAttributedString:attr1];
            
            valueLbl.attributedText = attrMain;
        }
    }
    else
    {
        if ([selectionImgView isHidden])
        {
            valueLbl.font = [UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE];
        }
        else
        {
            valueLbl.font = [UIFont fontWithName:APPFONT_BOLD size:appDel.HEADER_LABEL_FONT_SIZE];
        }
        
        if (![self.isFrom containsString:@"DATE"])
        {
            if ([self.isFrom containsString:@"Recurring"])
            {
                
                if ([selectionImgView isHidden])
                {
                    NSString *str1 = [[self.items objectAtIndex:indexPath.row] objectForKey:@"title"];
                    NSString *str2 = [NSString stringWithFormat:@"\n%@", [[self.items objectAtIndex:indexPath.row] objectForKey:@"actValue"]];
                    
                    NSMutableAttributedString *attrMain = [[NSMutableAttributedString alloc]initWithString:str1];
                    [attrMain addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE], NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, str1.length)];
                    
                    NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:str2];
                    [attr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2], NSForegroundColorAttributeName:[UIColor grayColor]} range:NSMakeRange(0, str2.length)];
                    
                    [attrMain appendAttributedString:attr1];
                    
                    valueLbl.attributedText = attrMain;
                }
                else
                {
                    NSString *str1 = [[self.items objectAtIndex:indexPath.row] objectForKey:@"title"];
                    NSString *str2 = [NSString stringWithFormat:@"\n%@", [[self.items objectAtIndex:indexPath.row] objectForKey:@"actValue"]];
                    
                    NSMutableAttributedString *attrMain = [[NSMutableAttributedString alloc]initWithString:str1];
                    [attrMain addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.HEADER_LABEL_FONT_SIZE], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str1.length)];
                    
                    NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:str2];
                    [attr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str2.length)];
                    
                    [attrMain appendAttributedString:attr1];
                    
                    valueLbl.attributedText = attrMain;
                }
            }
            else
            {
                valueLbl.text = [[[self.items objectAtIndex:indexPath.row] objectForKey:@"title"] lowercaseString];
            }
        }
        else
        {
            valueLbl.text = [[self.items objectAtIndex:indexPath.row] objectForKey:@"title"];
        }
    }
    
    float lblX = 45*MULTIPLYHEIGHT;
    
    float lblHeight = CELL_HEIGHT;
    
    valueLbl.frame = CGRectMake(lblX, 0, self.frame.size.width-lblX, lblHeight);
    
    float siWidth = 15*MULTIPLYHEIGHT;
    
    selectionImgView.frame = CGRectMake(20*MULTIPLYHEIGHT, 3.0, siWidth, CGRectGetHeight(valueLbl.bounds));
    
    UIImageView *discountBorderImgView = (UIImageView *)[cell.contentView viewWithTag:2];
    discountBorderImgView.backgroundColor = [UIColor clearColor];
    
    UILabel *discountLbl = (UILabel *)[cell.contentView viewWithTag:3];
    
    //if(indexPath.row == 3)
    if([[self.items objectAtIndex:indexPath.row] objectForKey:@"discountValue"])
    {
        
        discountBorderImgView.hidden = NO;
        
        float discountWidth = 50*MULTIPLYHEIGHT;
        
        discountBorderImgView.frame = CGRectMake(self.frame.size.width-discountWidth-(7*MULTIPLYHEIGHT), 0.0, discountWidth, CGRectGetHeight(valueLbl.bounds));
        
        float discountLblHeight = 30*MULTIPLYHEIGHT;
        
        if ([self.isFrom containsString:@"DATE"])
        {
            //NSString *str1 = @"$";
            
            NSString *str1 = @"%";
            NSString *str2 = @"\nOFF";
            
            NSMutableAttributedString *attrMain = [[NSMutableAttributedString alloc]initWithString:str1];
            [attrMain addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-1], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str1.length)];
            
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:str2];
            [attr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-5], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str2.length)];
            
            [attrMain appendAttributedString:attr1];
            
            discountLbl.attributedText = attrMain;
            
            discountLbl.frame = CGRectMake(self.frame.size.width-discountLblHeight-(15*MULTIPLYHEIGHT), lblHeight/2-(discountLblHeight/2), discountLblHeight, discountLblHeight);
        }
        else
        {
            NSString *str1 = [NSString stringWithFormat:@"%d%%", [[[self.items objectAtIndex:indexPath.row] objectForKey:@"discountValue"]intValue]];
            
            NSString *str2 = @"\nOFF";
            
            NSMutableAttributedString *attrMain = [[NSMutableAttributedString alloc]initWithString:str1];
            [attrMain addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-2], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str1.length)];
            
            NSMutableAttributedString *attr1 = [[NSMutableAttributedString alloc]initWithString:str2];
            [attr1 addAttributes:@{NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:appDel.FONT_SIZE_CUSTOM-5], NSForegroundColorAttributeName:BLUE_COLOR} range:NSMakeRange(0, str2.length)];
            
            [attrMain appendAttributedString:attr1];
            
            discountLbl.attributedText = attrMain;
            
            discountLbl.frame = CGRectMake(self.frame.size.width-discountLblHeight-(17*MULTIPLYHEIGHT), lblHeight/2-(discountLblHeight/2), discountLblHeight, discountLblHeight);
            
            //discountLbl.text = [[[[self.items objectAtIndex:indexPath.row] objectForKey:@"discountValue"] stringByAppendingFormat:@"%%\nOFF"] uppercaseString];
        }
        
        discountLbl.textColor = valueLbl.textColor;
        
        discountLbl.hidden = NO;
        
        discountLbl.backgroundColor = [UIColor colorFromHexString:@"dce6ed"];
        discountLbl.layer.cornerRadius = discountLblHeight/2;
//        discountLbl.layer.borderColor = [UIColor grayColor].CGColor;
//        discountLbl.layer.borderWidth = 0.6;
        discountLbl.layer.masksToBounds = YES;
        
        discountLbl.hidden = ![[[self.items objectAtIndex:indexPath.row] objectForKey:@"discountValue"] intValue];
        
        discountBorderImgView.hidden = YES;
        
    }
    else {
        discountBorderImgView.hidden = YES;
        discountLbl.hidden = YES;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectedItem = [[self.items objectAtIndex:indexPath.row] objectForKey:@"actValue"];
    [tableView reloadData];
    
    [self.delegate performSelector:@selector(selectedValueFromListView:) withObject:[self.items objectAtIndex:indexPath.row]];
    
}

@end
