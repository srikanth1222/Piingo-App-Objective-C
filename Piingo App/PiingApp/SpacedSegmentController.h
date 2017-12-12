//
//  SpacedSegmentController.h
//  PiingApp
//
//  Created by SHASHANK on 03/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SpacedSegmentController : UIView {

	id btnDelegate;
	int selectedIndex;
	
	SEL selector;
	NSMutableArray *selectedBtnImages,*unselectedBtnImages,*titlesNamesArray;
}

@property (nonatomic, retain) id btnDelegate;
@property (nonatomic,readwrite) int selectedIndex;
@property (nonatomic,retain) NSMutableArray *selectedBtnImages;
@property (nonatomic,retain) NSMutableArray *unselectedBtnImages;
@property (nonatomic,retain) NSMutableArray *titlesNamesArray;

-(void) setSelectedControlIndex:(long int)index ;
-(void)setTargetSelector:(SEL)selectorAction;
-(id)initWithFrame:(CGRect)frame titles:(NSArray *)titles unSelectedImages:(NSArray*)unSelectedImages selectedImages:(NSArray *)selectedImages seperatorSpacing:(NSNumber *)spacing andDelegate:(id)delegate;

-(void) reloadImagesWithNormalArray:(NSArray *)nrmlArr selectedArray:(NSArray *)selArr andTitlesArray:(NSArray *)arr ;

-(id)initWithFrame:(CGRect)frame titles2:(NSArray *)titles unSelectedImages:(NSArray*)unSelectedImages selectedImages:(NSArray *)selectedImages seperatorSpacing:(NSNumber *)spacing andDelegate:(id)delegate;

-(void) makeAllUnselected;
-(void) setDisableSegmentIndex:(int) index;

@end
