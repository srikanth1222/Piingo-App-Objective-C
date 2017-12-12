//
//  CustomButton.m
//  Vendle
//
//  Created by Hema on 25/08/14.
//  Copyright (c) 2014 Riktam Technologies. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton


-(void) setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)controlState {
    
    if (controlState == UIControlStateNormal) {
        self.normalBgColor = backgroundColor;
    }
    else if(controlState == UIControlStateSelected) {
        self.selectedBgColor = backgroundColor;
    }
    
}

- (void) setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = self.selectedBgColor;
    }
    else {
        self.backgroundColor = self.normalBgColor;
    }
    
}

@end
