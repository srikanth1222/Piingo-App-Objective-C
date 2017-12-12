//
//  CustomLabel.m
//  HCLERS
//
//  Created by Swathi on 4/12/13.
//  Copyright (c) 2013 Riktam Technologies. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)drawTextInRect:(CGRect)rect{
    CGRect frame = rect;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        frame.origin.y = 3;
    }
    rect = frame;
    [super drawTextInRect:rect];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
