//
//  SpacedSegmentController.m
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "SpacedSegmentController.h"


@implementation SpacedSegmentController
@synthesize btnDelegate;
@synthesize selectedIndex;
@synthesize selectedBtnImages, unselectedBtnImages, titlesNamesArray;

-(id)initWithFrame:(CGRect)frame titles:(NSArray *)titles unSelectedImages:(NSArray*)unSelectedImages selectedImages:(NSArray *)selectedImages seperatorSpacing:(NSNumber *)spacing andDelegate:(id)delegate 
{
    float labelY;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        labelY = 2;
    }
    else{
        labelY = 6;
    }

	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		self.btnDelegate = delegate;
		self.titlesNamesArray = [[NSMutableArray alloc] initWithArray:titles];
		self.selectedBtnImages = [[NSMutableArray alloc] initWithArray:selectedImages];
		self.unselectedBtnImages = [[NSMutableArray alloc] initWithArray:unSelectedImages];
		for(int i = 0; i<[titles count]; i++)
		{
//            NSLog(@"%d", i);
            
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			//[btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
//            if ([spacing floatValue] > 10)
//            {
//                [btn setBackgroundImage:[UIImage imageNamed:[unSelectedImages objectAtIndex:i]] forState:UIControlStateNormal];
//
//            }
//            else
//                [btn setBackgroundImage:[[UIImage imageNamed:[unSelectedImages objectAtIndex:i]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal];
            
            [btn setImage:[UIImage imageNamed:[unSelectedImages objectAtIndex:i]] forState:UIControlStateNormal];

			btn.tag = i+1;
			[btn setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
			btn.adjustsImageWhenHighlighted = NO;
			//btn.titleLabel.shadowOffset = CGSizeMake(1,1);
			btn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:13];
			btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            btn.titleLabel.textColor = [UIColor grayColor];
			[btn addTarget:self action:@selector(spaceSegmentClicked:) forControlEvents:UIControlEventTouchUpInside];
			btn.frame = CGRectMake((i*frame.size.width/[titles count]), 0, frame.size.width/[titles count], frame.size.height);
            btn.titleEdgeInsets=UIEdgeInsetsMake(labelY, 0, 0, 0);
			//NSLog(@"X-Position of %d iss %f",i+1,btn.frame.origin.x);
			[self addSubview:btn];
		}
    }
    
	return self;
	
}
-(id)initWithFrame:(CGRect)frame titles2:(NSArray *)titles unSelectedImages:(NSArray*)unSelectedImages selectedImages:(NSArray *)selectedImages seperatorSpacing:(NSNumber *)spacing andDelegate:(id)delegate
{
    float labelY;
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        labelY = 2;
    }
    else{
        labelY = 6;
    }
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.btnDelegate = delegate;
        self.titlesNamesArray = [[NSMutableArray alloc] initWithArray:titles];
        self.selectedBtnImages = [[NSMutableArray alloc] initWithArray:selectedImages];
        self.unselectedBtnImages = [[NSMutableArray alloc] initWithArray:unSelectedImages];
        for(int i = 0; i<[titles count]; i++)
        {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setImage:[UIImage imageNamed:[unSelectedImages objectAtIndex:i]] forState:UIControlStateNormal];
            btn.tag = i+1;
            [btn setTitle:@"" forState:UIControlStateNormal];
            btn.imageView.clipsToBounds = YES;
            btn.adjustsImageWhenHighlighted = NO;
            btn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:13];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(spaceSegmentClicked:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake((i*frame.size.width/[titles count]) +i*0+10, 0, frame.size.height-25, frame.size.height-25);
            btn.titleEdgeInsets=UIEdgeInsetsMake(labelY, 0, 0, 0);
            [self addSubview:btn];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(((i*frame.size.width/[titles count]) +i*0) - 10+10, CGRectGetMaxY(btn.frame)+3, CGRectGetWidth(btn.frame) + 20, 20)];
            titleLabel.text = [titles objectAtIndex:i];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:10.0];
            [self addSubview:titleLabel];
        }
    }
    
    return self;
    
}

-(void) setDisableSegmentIndex:(int) index
{
    for(int i = 0; i<[self.titlesNamesArray count]; i++)
    {
        UIButton *btn = [self viewWithTag:i+1];
        
        if (btn.tag-1 == index)
        {
            btn.enabled = NO;
        }
    }
}

-(void)spaceSegmentClicked:(UIButton *)btn {

	[self setSelectedControlIndex:btn.tag-1];
	
	if(selector)
	{
		if([self.btnDelegate respondsToSelector:selector])
		{
		
			[self.btnDelegate performSelector:selector withObject:self];
					
		}
	}
}

//setting the image for the priority button when clicked
-(void) setSelectedControlIndex:(long int)index {
    
	for(int i = 0; i<[self.titlesNamesArray count]; i++)
	{
		UIButton *btn = (UIButton *)[self viewWithTag:i+1];
		
		if(i == index)
		{

          //  UIImage *img=[[UIImage imageNamed:[self.selectedBtnImages objectAtIndex:i]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 0)];
//			[btn setBackgroundImage:[[UIImage imageNamed:[self.selectedBtnImages objectAtIndex:i]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal];
//            btn.titleLabel.textColor=[UIColor whiteColor];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:[self.selectedBtnImages objectAtIndex:i]]  forState:UIControlStateNormal];

		}
		else
		{
          //  UIImage *img=[[UIImage imageNamed:[self.unselectedBtnImages objectAtIndex:i]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 0)];

//			[btn setBackgroundImage:[[UIImage imageNamed:[self.unselectedBtnImages objectAtIndex:i]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)] forState:UIControlStateNormal];
//            btn.titleLabel.textColor=[UIColor grayColor];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:[self.unselectedBtnImages objectAtIndex:i]]  forState:UIControlStateNormal];

		}
		
	}
	
	self.selectedIndex = index;

    
}

-(void) reloadImagesWithNormalArray:(NSArray *)nrmlArr selectedArray:(NSArray *)selArr andTitlesArray:(NSArray *)arr {
    
    
    if (self.titlesNamesArray) {
        self.titlesNamesArray = nil;
        [self.titlesNamesArray release];
    }
    
    if (self.selectedBtnImages) {
        self.selectedBtnImages = nil;
        [self.selectedBtnImages release];
    }
    if (self.unselectedBtnImages) {
        self.unselectedBtnImages = nil;
        [self.unselectedBtnImages release];
    }

    
    self.selectedBtnImages = [[NSMutableArray alloc] initWithArray:selArr];
    self.unselectedBtnImages = [[NSMutableArray alloc] initWithArray:nrmlArr];
    self.titlesNamesArray = [[NSMutableArray alloc] initWithArray:arr];

    
    for(int i = 0; i<[self.titlesNamesArray count]; i++)
    {
//        UIImage *img = [[UIImage imageNamed:[self.unselectedBtnImages objectAtIndex:i]] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];

        UIButton *btn = (UIButton *)[self viewWithTag:i+1];
//        btn.frame = CGRectMake(btn.frame.origin.x, btn.frame.origin.y, img.size.width, img.size.height);
//        [btn setBackgroundImage:img forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[self.unselectedBtnImages objectAtIndex:i]] forState:UIControlStateNormal];

    }
    
}

-(void)setTargetSelector:(SEL)selectorAction {
	selector = selectorAction;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code	
}

-(void) makeAllUnselected
{
    for(int i = 0; i<[self.titlesNamesArray count]; i++)
    {
        UIButton *btn = (UIButton *)[self viewWithTag:i+1];
        
        [btn setImage:[UIImage imageNamed:[self.unselectedBtnImages objectAtIndex:i]] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
-(void) dealloc {
    
    [self.titlesNamesArray release];
    [self.selectedBtnImages release];
    [self.unselectedBtnImages release];
    
    [super dealloc];
}

@end
