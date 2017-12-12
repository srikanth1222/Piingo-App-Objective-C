//
//  CustomGMSMarker.h
//  HCLERS
//
//  Created by Srikanth on 18/11/13.
//  Copyright (c) 2013 Riktam Technologies. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface CustomGMSMarker : GMSMarker{
    
}
@property (nonatomic, readwrite) int markerindex;
@property (nonatomic, retain) NSString *place;
@property (nonatomic, retain)  NSString *time;
@property (nonatomic, readwrite) BOOL isEvent;
@property (nonatomic, retain) NSString *imageTypeName;
@end
