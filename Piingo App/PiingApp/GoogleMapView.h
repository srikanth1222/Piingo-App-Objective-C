//
//  GoogleMapView.h
//  GoogleMapsPOC
//
//  Created by Shashank on 17/05/15.
//  Copyright (c) 2015 Shashank. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomGMSMarker.h"
//#import "EventOrVenue.h"

@protocol GoogleMapViewDelegate<NSObject>
-(void) viewMiniDetailsButtonClicked:(UIButton *) sender;
-(void)googlemapViewTappedOnMarker:(CustomGMSMarker *)marker;
-(void) getCurrentCityWithLat:(double) lat andLong:(double) lng;
-(void) mapIsMovedAndRadius:(NSString *) radius;
@end

@interface GoogleMapView : UIView <GMSMapViewDelegate, CLLocationManagerDelegate>{
    GMSMapView *gMapView;
    UIView *markerView;
    
    NSMutableData *receivedData;
    NSString *currLocation;
    CLLocation *startLocation;
    int markerIndex;
    CustomLoaderView *loaderView;
    GMSMarker *droppedMarker;
    
    GMSMarker *clientMarker, *piingoMarker;
    
    BOOL isMapReoldedWithLatestData;
}

@property (nonatomic, readwrite, retain) id delegate;
@property (nonatomic, readwrite) CLLocationCoordinate2D mapLocation;
@property (nonatomic, readwrite) CLLocationCoordinate2D currentLocation;
@property (nonatomic, retain) CLLocationManager *locationManager;

@property (nonatomic, readwrite, retain) NSMutableArray *decodedPolylineArray;

@property (nonatomic, readwrite) BOOL isMapReoldedWithLatestData;

-(void)getDirectionRoutesFrom:(NSString *)saddr to:(NSString *)daddr withTravelMode:(NSString *)travelMode;
-(void)changeFrame;
-(void) clearAllMarkers;
-(void) reloadMapViewWithLatitude:(NSString *)lat andWithLogitude:(NSString *) lng;

-(void) reloadMapViewWithArrayOfLatLng:(NSMutableArray *) array;
//-(void)addMarker:(EventOrVenue *)obj withIndex:(int)index;
-(void) addMarker:(id) obj withIndex:(int) index;

-(void) selectedLocationPinWithLat:(double) lat andWithLogi:(double) lng;

-(void)getDirectionRoutesFrom:(NSString *)saddr to:(NSString *)daddr withTravelMode:(NSString *)travelMode andWithUsingWaypoints:(NSArray *) waypoints;
-(void) addClientMarker:(id) obj;
-(void) addPiingoMarkder:(id) obj;

@end
