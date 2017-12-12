//
//  CustomSegmentControl.h
//  Vendle
//
//  Created by Hema on 25/08/14.
//  Copyright (c) 2014 Riktam Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSegmentControl : UIView {
    long int selIndex;
}
@property (nonatomic, retain) NSMutableArray *segmentTitles;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) NSString *callBackSel;
@property (nonatomic, readwrite) long int selectedIndex;

-(id) initWithFrame:(CGRect)frame andButtonTitles:(NSArray *)titles andWithSpacing:(NSNumber *)spacing andSelectionColor:(UIColor *)selColor andDelegate:(id)del andSelector:(NSString *)selctor;
-(id) initWithFrame:(CGRect)frame andButtonTitles2:(NSArray *)titles andWithSpacing:(NSNumber *)spacing andSelectionColor:(UIColor *)selColor andDelegate:(id)del andSelector:(NSString *)selctor;
-(void) resetAllSegments;

-(void) setDisableSegmentIndex:(NSString *) strIndex;

@end
