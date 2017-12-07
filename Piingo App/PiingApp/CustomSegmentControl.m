//
//  CustomSegmentControl.m
//  Vendle
//
//  Created by Hema on 25/08/14.
//  Copyright (c) 2014 Riktam Technologies. All rights reserved.
//

#import "CustomSegmentControl.h"
#import "CustomButton.h"

//#define GRAY_BACKGROUND_COLOR [[UIColor grayColor] colorWithAlphaComponent:0.6]
#define GRAY_BACKGROUND_COLOR [UIColor colorWithRed:217.0/255.0 green:217.0/255.0 blue:217.0/255.0 alpha:1.0]

@implementation CustomSegmentControl

@synthesize segmentTitles = _segmentTitles;

-(id) initWithFrame:(CGRect)frame andButtonTitles:(NSArray *)titles andWithSpacing:(NSNumber *)spacing andSelectionColor:(UIColor *)selColor andDelegate:(id)del andSelector:(NSString *)selctor {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.segmentTitles = [NSMutableArray arrayWithArray:titles];
        self.backgroundColor = GRAY_BACKGROUND_COLOR;
        
        self.callBackSel = selctor;
        self.delegate = del;
        
        for(int i = 0; i<[titles count]; i++)
		{
            
			CustomButton *btn = [CustomButton buttonWithType:UIButtonTypeCustom];
			btn.tag = i+1;
            btn.frame = CGRectMake((i*frame.size.width/[titles count]) , 0, frame.size.width/[titles count], frame.size.height);
			[btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
			btn.adjustsImageWhenHighlighted = NO;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
			btn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:18.0];
			btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:GRAY_BACKGROUND_COLOR forState:UIControlStateNormal];
            [btn setBackgroundColor:selColor forState:UIControlStateSelected];
            btn.layer.borderWidth = [spacing floatValue];
            btn.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.7] CGColor];
            btn.layer.cornerRadius = 3.0f;
            
            btn.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            btn.layer.shadowColor = [[UIColor blackColor] CGColor];
            
            btn.clipsToBounds = YES;
            [btn addTarget:self action:@selector(customSegmentClicked:) forControlEvents:UIControlEventTouchUpInside];
			[self addSubview:btn];
            
		}
        
        [self customSegmentClicked:(CustomButton *)[self viewWithTag:1]];
    }
    
    return self;
}

-(id) initWithFrame:(CGRect)frame andButtonTitles2:(NSArray *)titles andWithSpacing:(NSNumber *)spacing andSelectionColor:(UIColor *)selColor andDelegate:(id)del andSelector:(NSString *)selctor {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        self.segmentTitles = [NSMutableArray arrayWithArray:titles];
        self.backgroundColor = GRAY_BACKGROUND_COLOR;
        
        self.callBackSel = selctor;
        self.delegate = del;
        
        for(int i = 0; i<[titles count]; i++)
        {
            
            CustomButton *btn = [CustomButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i+1;
            btn.frame = CGRectMake((i*frame.size.width/[titles count]) , 0, frame.size.width/[titles count], frame.size.height);
            [btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
            btn.adjustsImageWhenHighlighted = NO;
            btn.titleLabel.adjustsFontSizeToFitWidth = YES;
            btn.titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:14.0];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
            [btn setTitleColor:[UIColor colorWithRed:64.0/255.0 green:143.0/255.0 blue:210.0/255.0 alpha:1.0] forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:selColor forState:UIControlStateSelected];
            btn.layer.borderWidth = [spacing floatValue];
//            btn.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.7] CGColor];
            btn.layer.cornerRadius = 2.5f;
            
            btn.layer.shadowOffset = CGSizeMake(1.0, 1.0);
            btn.layer.shadowColor = [[UIColor blackColor] CGColor];
            
            btn.clipsToBounds = YES;
            [btn addTarget:self action:@selector(customSegmentClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            
        }
        
        [self customSegmentClicked:(CustomButton *)[self viewWithTag:1]];
    }
    
    return self;
}

-(void) customSegmentClicked:(CustomButton *)button {
    [self resetAllSegments];
    button.selected = YES;
    SEL callBack = NSSelectorFromString(self.callBackSel);
    
    selIndex = button.tag - 1;
    if(self.delegate)
    [self.delegate performSelector:callBack withObject:self];
    
}

-(void) setDisableSegmentIndex:(NSString *) strIndex
{
    
    for(int i = 0; i<[self.segmentTitles count]; i++)
    {
        CustomButton *btn = (CustomButton *)[self viewWithTag:i+1];
        
        if (![strIndex containsString:[NSString stringWithFormat:@"%ld", (long)btn.tag+1]])
        {
            btn.enabled = NO;
        }
    }

}


-(void) resetAllSegments {
    
    for(int i = 0; i<[self.segmentTitles count]; i++)
    {
        CustomButton *btn = (CustomButton *)[self viewWithTag:i+1];
//        btn.layer.cornerRadius = 0.0;
        [btn setTitle:[self.segmentTitles objectAtIndex:i] forState:UIControlStateNormal];
        btn.selected = NO;
    }
    
}

- (void) setSelectedIndex:(long int)selectedIndex {
    
    selIndex = selectedIndex;
    [self customSegmentClicked:(CustomButton *)[self viewWithTag:selIndex+1]];
    
}

-(long int) selectedIndex {
    return selIndex;
}

-(void) setSegmentTitles:(NSMutableArray *)segmentTitles {
    _segmentTitles = segmentTitles;
    
    //    for(int i = 0; i<[self.segmentTitles count]; i++)
    //    {
    //        CustomButton *btn = (CustomButton *)[self viewWithTag:i+1];
    //        [btn setTitle:[self.segmentTitles objectAtIndex:i] forState:UIControlStateNormal];
    //    }
    
    [self resetAllSegments];
    CustomButton *btn = (CustomButton *)[self viewWithTag:selIndex+1];
    btn.selected = YES;
    
}

-(NSMutableArray *)segmentTitles {
    return _segmentTitles;
}
@end
