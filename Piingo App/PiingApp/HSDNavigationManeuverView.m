/*
 * Copyright © 2011-2016 HERE Global B.V. and its affiliate(s).
 * All rights reserved.
 * The use of this software is conditional upon having a separate agreement
 * with a HERE company for the use or utilization of this software. In the
 * absence of such agreement, the use of the software is not allowed.
 */

#import "HSDNavigationManeuverView.h"

@interface HSDNavigationManeuverView()
@property(nonatomic,weak) UITapGestureRecognizer* tapGesture;
@end

@implementation HSDNavigationManeuverView

#pragma mark - UI Action

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if(self.delegate)
        [self.delegate HSDNavigationManeuverViewDidTouched:self];
}

#pragma mark - Life Cycle

+(HSDNavigationManeuverView*)view
{
    HSDNavigationManeuverView* view = [[HSDNavigationManeuverView alloc] initWithFrame:CGRectZero];
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        
        UILabel* distanceLbl = [UILabel new];
        [self addSubview:distanceLbl];
        distanceLbl.font = [UIFont boldSystemFontOfSize:25.0f];
        self.distanceLbl = distanceLbl;
        distanceLbl.textColor = self.tintColor;
        distanceLbl.translatesAutoresizingMaskIntoConstraints = NO;
        distanceLbl.textAlignment = NSTextAlignmentCenter;
        
        UILabel* instructionLbl = [UILabel new];
        [self addSubview:instructionLbl];
        instructionLbl.font = [UIFont systemFontOfSize:18.0f];
        self.instructionLbl = instructionLbl;
        instructionLbl.translatesAutoresizingMaskIntoConstraints = NO;
        instructionLbl.textAlignment = NSTextAlignmentCenter;
        instructionLbl.adjustsFontSizeToFitWidth = YES;
        
        UILabel* onRoadLbl = [UILabel new];
        [self addSubview:onRoadLbl];
        onRoadLbl.font = [UIFont systemFontOfSize:14.0f];
        self.onRoadLbl = onRoadLbl;
        onRoadLbl.textColor = [UIColor lightGrayColor];
        onRoadLbl.translatesAutoresizingMaskIntoConstraints = NO;
        onRoadLbl.textAlignment = NSTextAlignmentCenter;
        onRoadLbl.adjustsFontSizeToFitWidth = YES;
        
        //autlayout
        NSDictionary* metrics = @{};
        NSDictionary* bindinds = @{@"distanceLbl" : self.distanceLbl, @"instructionLbl" : self.instructionLbl, @"onRoadLbl" : self.onRoadLbl};
        
        //horizontally strech full width
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[distanceLbl]-|" options:0 metrics:metrics views:bindinds]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[instructionLbl]-|" options:0 metrics:metrics views:bindinds]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[onRoadLbl]-|" options:0 metrics:metrics views:bindinds]];
        
        //vericall ordered
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(28)-[instructionLbl]-[distanceLbl]-[onRoadLbl]-(5)-|" options:0 metrics:metrics views:bindinds]];
    }
    return self;
}

-(void)didMoveToSuperview
{
    if(self.superview){
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        tapRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tapRecognizer];
        self.tapGesture = tapRecognizer;
    }
    else{
        [self removeGestureRecognizer:self.tapGesture];
    }
}


@end
