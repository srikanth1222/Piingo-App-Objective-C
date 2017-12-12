//
//  LocationShareModel.h
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BackgroundTaskManager.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationShareModel : NSObject

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer * delay10Seconds;
@property (nonatomic, strong) BackgroundTaskManager * bgTask;
@property (nonatomic, strong) NSMutableArray *myLocationArray;

+(id)sharedModel;

@end
