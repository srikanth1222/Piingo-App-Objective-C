//
//  ItemCollectionViewCell.m
//  PiingApp
//
//  Created by SHASHANK on 23/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "ItemCollectionViewCell.h"
#import "NSNull+JSON.h"

@interface ItemCollectionViewCell ()
{
    UIButton *tickMarkSelection;
    UILabel *brandNameLbl;
}
@end

@implementation ItemCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
        
        tickMarkSelection = [UIButton buttonWithType:UIButtonTypeCustom];
        tickMarkSelection.frame = CGRectMake(frame.size.width/2 - (18/2), 0.0, 18, 18);
        //tickMarkSelection.center = CGPointMake(9, frame.size.height/2);
        [tickMarkSelection setImage:[UIImage imageNamed:@"tick_color"] forState:UIControlStateSelected];
        tickMarkSelection.layer.cornerRadius = tickMarkSelection.frame.size.width/2.0;
        tickMarkSelection.clipsToBounds = YES;
        [self addSubview:tickMarkSelection];
        tickMarkSelection.userInteractionEnabled = NO;
        tickMarkSelection.selected = YES;
        
        brandNameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 20.0, frame.size.width, 20.0)];
        brandNameLbl.backgroundColor = [UIColor clearColor];
        brandNameLbl.text = @"Brand name";
        brandNameLbl.textColor = [UIColor blackColor];
        brandNameLbl.numberOfLines = 2;
        brandNameLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:15.0];
        brandNameLbl.textAlignment = NSTextAlignmentCenter;
        [self addSubview:brandNameLbl];
    }
    
    return self;
}

-(void)setDetails:(id) details
{
    [tickMarkSelection setBackgroundColor:[UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1.0]];
    
    if ([details objectForKey:@"colorCode"] && ![[details objectForKey:@"colorCode"] isEqual:[NSNull null]])
    {
        [tickMarkSelection setBackgroundColor:[UIColor colorFromHexString:[details objectForKey:@"colorCode"]]];
    }
    
    if ([[details objectForKey:@"selectedItem"] isEqualToString:@"N"])
        tickMarkSelection.selected = NO;
    else
        tickMarkSelection.selected = YES;
    
    if ([details objectForKey:@"brand"] && ![[details objectForKey:@"brand"] isEqual:[NSNull null]])
    {
        brandNameLbl.text = [details objectForKey:@"brand"];
    }
    else
    {
        brandNameLbl.text = [details objectForKey:@"itemType"];
    }
}
-(void) clickBtn
{
    tickMarkSelection.selected = !tickMarkSelection.selected;

}
-(BOOL) getTickMarkStatus
{
    return tickMarkSelection.selected;
}
@end
