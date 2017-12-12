//
//  ItemCollectionViewCell.h
//  PiingApp
//
//  Created by SHASHANK on 23/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCollectionViewCell : UICollectionViewCell

-(void)setDetails:(id) details;
-(void) clickBtn;
-(BOOL) getTickMarkStatus;

@end
