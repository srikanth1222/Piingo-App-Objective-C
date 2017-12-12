//
//  PreferencesViewController.h
//  Piing
//
//  Created by Veedepu Srikanth on 26/09/16.
//  Copyright © 2016 shashank. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PreferencesViewControllerDelegate <NSObject>

-(void) didAddPreferences:(NSString *) strPref;

@end


@interface PreferencesViewController : UIViewController

@property (nonatomic, strong) id <PreferencesViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *strPrefs;


@end
