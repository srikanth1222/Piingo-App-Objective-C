/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import <UIKit/UIKit.h>

@class HSDNavigationManeuverView;
@protocol HSDNavigationManeuverViewDelegate <NSObject>
-(void)HSDNavigationManeuverViewDidTouched:(HSDNavigationManeuverView*)view;
@end

@interface HSDNavigationManeuverView : UIView
+(HSDNavigationManeuverView*)view;
@property(nonatomic, weak) id<HSDNavigationManeuverViewDelegate> delegate;
@property(nonatomic,weak) UILabel* distanceLbl; //distance to maneuver point
@property(nonatomic,weak) UILabel* instructionLbl; //maneuver instruction
@property(nonatomic,weak) UILabel* onRoadLbl; //name of current road
@end
