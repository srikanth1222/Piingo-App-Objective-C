//
//  GoogleMapView.m
//  GoogleMapsPOC
//
//  Created by Shashank on 17/05/15.
//  Copyright (c) 2015 Shashank. All rights reserved.
//

#import "GoogleMapView.h"
#import "AppDelegate.h"

#define ZOOM_LEVEL2   11
@interface GoogleMapView ()

@end

CustomGMSMarker *selectedMarker1;
//AutomaticScrollView *titleLabel;
UILabel *titleLabel1;

@implementation GoogleMapView
@synthesize delegate, mapLocation,currentLocation, decodedPolylineArray, isMapReoldedWithLatestData;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        selectedMarker1 = [[CustomGMSMarker alloc] init];
        
        clientMarker = [[GMSMarker alloc] init];
        piingoMarker = [[GMSMarker alloc] init];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        if(IS_OS_8_OR_LATER) {
            [self.locationManager requestWhenInUseAuthorization];  // For foreground access
            //            [self.locationManager requestAlwaysAuthorization]; // For background access
            // [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
        
        startLocation = self.locationManager.location;
        currLocation = [NSString stringWithFormat:@"%f,%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:ZOOM_LEVEL2];
        
        gMapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) camera:nil];
        gMapView.settings.rotateGestures = NO;
        gMapView.settings.tiltGestures = NO;
        gMapView.camera = camera;
        gMapView.delegate = self;
        gMapView.myLocationEnabled = YES;
        //   gMapView.settings.myLocationButton =YES;
        [self addSubview:gMapView];
        
        
        //In ViewDidLoad
        
        
        
        titleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 40-2, 185, 15.0+2)];
        //        [titleLabel setLabelFont:[UIFont fontWithName:APPFONT_SEMIBOLD size:12.0]];
        //        [titleLabel setLabelTextAlignment:NSTextAlignmentCenter];
        //        [titleLabel setLabelTextColor:[UIColor colorWithRed:114.0/255.0	green:131.0/255.0 blue:139.0/255.0 alpha:1.0]];
        titleLabel1.textColor = [UIColor colorWithRed:114.0/255.0	green:131.0/255.0 blue:139.0/255.0 alpha:1.0];
        titleLabel1.adjustsFontSizeToFitWidth = YES;
        titleLabel1.textAlignment = NSTextAlignmentCenter;
        titleLabel1.backgroundColor = [UIColor clearColor];
        titleLabel1.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:12.0];
        
    }
    
    return self;
}
-(void) addClientMarker:(id) obj
{
    DLog(@"addClientMarker Lat %lf long %f %@ %@", piingoMarker.position.latitude, piingoMarker.position.longitude,[obj objectForKey:@"clat"],[obj objectForKey:@"clon"]);
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[obj objectForKey:@"clat"] doubleValue];
    coordinates.longitude = [[obj objectForKey:@"clon"] doubleValue];
    
    clientMarker.position = coordinates;
    clientMarker.icon = [UIImage imageNamed:@"location_user"];
    clientMarker.map = gMapView;
    
}
-(void) addPiingoMarkder:(id) obj
{
    DLog(@"addPiingoMarkder Lat %lf long %lf %@ %@", piingoMarker.position.latitude, piingoMarker.position.longitude,[obj objectForKey:@"lat"],[obj objectForKey:@"long"]);
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[obj objectForKey:@"lat"] doubleValue];
    coordinates.longitude = [[obj objectForKey:@"long"] doubleValue];
    
    piingoMarker.position = coordinates;
    piingoMarker.icon = [UIImage imageNamed:@"location_piingo"];
    piingoMarker.map = gMapView;
}
-(void) addMarker:(id) obj withIndex:(int) index
{
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[obj objectForKey:@"lat"] doubleValue];
    coordinates.longitude = [[obj objectForKey:@"lon"] doubleValue];
    
    CustomGMSMarker *marker = [[CustomGMSMarker alloc] init];
    marker.position = coordinates;
    marker.icon = [UIImage imageNamed:@"location_piingo"];
    marker.infoWindowAnchor = CGPointMake(0.38, 0.0);
    marker.map = gMapView;
    //    marker.title = obj.name;
    //    marker.markerindex = index;
    //    marker.isEvent = obj.isEvent;
    //    marker.imageTypeName = obj.type;
    //
    //    marker.place = obj.eventVenue;
    //    marker.time = [AppDelegate peopleFollowingText:obj.peopleFollowing];
    
}

//-(void)addMarker:(EventOrVenue *)obj withIndex:(int)index{
//
//    NSString *typeIcon;
//    if(obj.isEvent){
//
//    typeIcon = [NSString stringWithFormat:@"%@_event_type_0",obj.type];
//
//    if ([obj.type rangeOfString:@"Musician"].location != NSNotFound)
//        typeIcon = @"Musician_event_type_0.png";
//
//        if(!obj.type.length)
//            typeIcon = @"Other_event_type_0.png";
//
//    }else{
//       typeIcon = [NSString stringWithFormat:@"%@_venue_type_0",obj.type];
//
//        if ([obj.type rangeOfString:@"Theatre"].location != NSNotFound) {
//            typeIcon = @"Theatre_venue_type_0.png";
//        }
//        else if ([obj.type rangeOfString:@"Bar"].location != NSNotFound) {
//            typeIcon = @"Bar_venue_type_0.png";
//        }
//        else if([obj.type rangeOfString:@"Recreational"].location != NSNotFound) {
//            typeIcon = @"Recreational_venue_type_0.png";
//        }
//        else if([obj.type rangeOfString:@"Caf"].location != NSNotFound) {
//            typeIcon = @"Cafe_venue_type_0.png";
//        }
//        if(!obj.type.length)
//            typeIcon = @"Other_venue_type_0.png";
//
//    }
//
//    CLLocationCoordinate2D coordinates;
//    coordinates.latitude = [obj.lat doubleValue];
//    coordinates.longitude = [obj.lon doubleValue];
//
//    CustomGMSMarker *marker = [[CustomGMSMarker alloc] init];
//    marker.position = coordinates;
//    marker.icon = [UIImage imageNamed:typeIcon];
//    marker.infoWindowAnchor = CGPointMake(0.38, 0.0);
//    marker.map = gMapView;
//    marker.title = obj.name;
//    marker.markerindex = index;
//    marker.isEvent = obj.isEvent;
//    marker.imageTypeName = obj.type;
//
//    if(obj.isEvent){
//        marker.place = obj.eventVenue;
////        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
////        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
////        NSDate *date = [dateFormatter dateFromString:obj.time];
////        [dateFormatter setDateFormat:@"dd'th' MMMM YYYY"];
////        marker.time = [dateFormatter stringFromDate:date] ;
//        marker.time = [AppDelegate changeDateFormatToDisplay:obj.time];
//
//    }else{
//        marker.place = obj.locationName;
//        marker.time = [AppDelegate peopleFollowingText:obj.peopleFollowing];
//
//    }
//
////    if (droppedMarker && droppedMarker.position.longitude != 0 && droppedMarker.position.latitude != 0)
////    {
////        AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
////
////        CLLocation *locA = [[CLLocation alloc] initWithLatitude:droppedMarker.position.latitude longitude:droppedMarker.position.longitude];
////
////        CLLocation *locB = [[CLLocation alloc] initWithLatitude:[appDel.latitude doubleValue] longitude:[appDel.longitude doubleValue]];
////
////        CLLocationDistance distance = [locA distanceFromLocation:locB];
////
////        NSLog(@"Gmap Distance %lf",distance);
////        if (distance < 10)
////        {
////            NSLog(@"Gmap selected loc is same as current loc");
////
////        }
////        else
////            droppedMarker.map = gMapView;
////    }
//}

-(void)drawDirectionsToDestination{
    //    //[loaderView stopLoading];
    GMSMutablePath *gmsPath = [[GMSMutablePath alloc] init];
    
    for (int i = 0; i < self.decodedPolylineArray.count; i++) {
        [gmsPath addCoordinate:[[self.decodedPolylineArray objectAtIndex:i] coordinate]];
    }
    
    GMSPolyline *gmsPline = [GMSPolyline polylineWithPath:gmsPath];
    gmsPline.strokeColor = [UIColor redColor];//shashank
    gmsPline.strokeWidth = 2.50f;
    gmsPline.geodesic = YES;
    gmsPline.map = gMapView;
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:gmsPath];
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
    [gMapView moveCamera:update];
    
}
-(void)getDirectionRoutesFrom:(NSString *)saddr to:(NSString *)daddr withTravelMode:(NSString *)travelMode andWithUsingWaypoints:(NSArray *) waypoints
{
    //    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //
    ////    loaderView = [[CustomLoaderView alloc] initWithFrame:CGRectZero andType:1];
    ////    loaderView.loaderText = @"Loading Directions..";
    ////    [appDel.window.rootViewController.view addSubview:loaderView];
    //
    //    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
    //        loaderView.frame = appDel.window.rootViewController.view.frame;
    //    }
    //    else{
    //        loaderView.frame = CGRectMake(0, 0, 1024, 768);
    //    }
    //    [loaderView setLoaderViewFrame];
    
    receivedData = [[NSMutableData alloc] init];
    self.decodedPolylineArray = [[NSMutableArray alloc] init];
    
    NSMutableString *wayPointsStr = [[NSMutableString alloc] init];
    
    for (int w =0; w < [waypoints count] ;w++)
    {
        NSDictionary *wayPointDic =  [waypoints objectAtIndex:w];
        
        NSDictionary *dicMapPoints = [waypoints objectAtIndex:w];
        
        NSDictionary *dictCoordinates = [dicMapPoints objectForKey:@"map"];
        if (w == 0)
        {
            [wayPointsStr appendFormat:@"%f,%f",[[dictCoordinates objectForKey:@"lt"] doubleValue],[[dictCoordinates objectForKey:@"ln"] doubleValue]];
        }
        else
        {
            [wayPointsStr appendFormat:@"|%f,%f",[[dictCoordinates objectForKey:@"lt"] doubleValue],[[dictCoordinates objectForKey:@"ln"] doubleValue]];
        }
        
        
        
        //        if (w == 0)
        //        {
        //            [wayPointsStr appendFormat:@"%f,%f",[[wayPointDic objectForKey:@"lt"] doubleValue],[[wayPointDic objectForKey:@"ln"] doubleValue]];
        //        }
        //        else
        //        {
        //            [wayPointsStr appendFormat:@"|%f,%f",[[wayPointDic objectForKey:@"lt"] doubleValue],
    }
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=%@&sensor=false&waypoints=%@", saddr, daddr, travelMode, wayPointsStr];
    NSURL* apiUrl = [NSURL URLWithString:[apiUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    DLog(@"%@",apiUrlStr);
    NSURLRequest *request = [NSURLRequest requestWithURL:apiUrl];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self  startImmediately:NO];
    [urlConnection start];
    
    //    [loaderView startLoading];
    
}

-(void)getDirectionRoutesFrom:(NSString *)saddr to:(NSString *)daddr withTravelMode:(NSString *)travelMode
{
    AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    
    currLocation = [NSString stringWithFormat:@"%f,%f", [appDel.latitude doubleValue], [appDel.longitude doubleValue]];
    
    loaderView = [[CustomLoaderView alloc] initWithFrame:CGRectZero andType:1];
    loaderView.loaderText = @"Loading Directions..";
    [appDel.window.rootViewController.view addSubview:loaderView];
    
    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
        loaderView.frame = appDel.window.rootViewController.view.frame;
    }
    else{
        loaderView.frame = CGRectMake(0, 0, 1024, 768);
    }
    [loaderView setLoaderViewFrame];
    receivedData = [[NSMutableData alloc] init];
    self.decodedPolylineArray = [[NSMutableArray alloc] init];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=%@&sensor=false", currLocation, daddr, travelMode];
    NSURL* apiUrl = [NSURL URLWithString:[apiUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    DLog(@"%@",apiUrlStr);
    NSURLRequest *request = [NSURLRequest requestWithURL:apiUrl];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self  startImmediately:NO];
    [urlConnection start];
    
    [loaderView startLoading];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    [receivedData setLength:0];
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    NSLog(@"error: %@", [error localizedDescription]);
    
    [AppDelegate showAlertWithMessage:[error localizedDescription] andTitle:@"Map Directions" andBtnTitle:@"OK"];
    
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    
    [receivedData appendData:data];
    
}
-(id)parseData:(NSData *)data{
    
    NSError *error = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    if (error != nil) {
        NSLog(@"Error parsing JSON.");
        // return nil;
        NSDictionary *dic = @{@"message":@"Server Error",@"success":@"false"};
        return dic;
        
    }
    else {
        //        NSLog(@"Array: %@", jsonData);
        return jsonData;
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    //    NSLog(@"recieved data %@", receivedData);
    //[loaderView stopLoading];
    if (!receivedData) {
        return;
    }
    else{
        NSString *string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        
        //SBJsonParser
        
        // SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        //        NSDictionary *resultDictionary =[string JSONValue];// [jsonParser objectWithString:string];
        NSMutableArray *stepsArray = [[NSMutableArray alloc] init];
        
        @try {
            stepsArray = [[[[[resultDictionary objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];
        }
        @catch (NSException *exception) {
            NSLog(@"exception :%@",exception);
        }
        
        int i = 0;
        for (i = 0; i<stepsArray.count; i++) {
            @try {
                NSString *polylineStr = [[[stepsArray objectAtIndex:i] objectForKey:@"polyline"] objectForKey:@"points"];
                [self.decodedPolylineArray addObjectsFromArray:[self decodePolyLine:polylineStr]];
            }
            @catch (NSException *exception) {
                NSLog(@"i vallllll = %d",i);
                NSLog(@"exception :%@", exception);
                
                [AppDelegate showAlertWithMessage:@"Cannot draw the directions to selected destination." andTitle:@"Map Directions" andBtnTitle:@"OK"];
                
            }
        }
        
        if (self.decodedPolylineArray.count<=60000) {
            [self drawDirectionsToDestination]; // removedTemporarly
            if ([self.delegate respondsToSelector:@selector(durationResponse:)])
            {
                [self.delegate performSelectorOnMainThread:@selector(durationResponse:) withObject:([[[[resultDictionary objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0]) waitUntilDone:NO];
                
            }
        }
        else if (self.decodedPolylineArray.count == 0) {
            
            [AppDelegate showAlertWithMessage:@"Cannot draw the directions to selected destination." andTitle:@"Map Directions" andBtnTitle:@"OK"];
        }
        else{
            [AppDelegate showAlertWithMessage:@"Destination is too long to draw the directions." andTitle:@"Map Directions" andBtnTitle:@"OK"];
        }
    }
}

-(NSMutableArray *)decodePolyLine:(NSString *)encodedStr {
    NSMutableString *encoded = [[NSMutableString alloc] initWithCapacity:[encodedStr length]];
    [encoded appendString:encodedStr];
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
        [array addObject:(CLLocation *)location];
    }
    
    return array;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    
    self.currentLocation = newLocation.coordinate;
    CLLocation *loc = newLocation;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude zoom:ZOOM_LEVEL2];
    [gMapView setCamera:camera];
    
    [manager stopUpdatingLocation];
    
    
    
}
-(void) reloadMapViewWithLatitude:(NSString *)lat andWithLogitude:(NSString *) lng
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[lat doubleValue] longitude:[lng doubleValue] zoom:ZOOM_LEVEL2];
    [gMapView performSelectorOnMainThread:@selector(setCamera:) withObject:camera waitUntilDone:YES];
    
}
-(void) reloadMapViewWithArrayOfLatLng:(NSMutableArray *) array
{
    //    return;//Removed Bouncing
    
    self.isMapReoldedWithLatestData = YES;
    
    CLLocationCoordinate2D firstPosition = CLLocationCoordinate2DMake([[[array objectAtIndex:0] valueForKey:@"lat"] doubleValue], [[[array objectAtIndex:0] valueForKey:@"lng"] doubleValue]);
    
    GMSCoordinateBounds *bounds= [[GMSCoordinateBounds alloc] initWithCoordinate:firstPosition coordinate:firstPosition];
    
    for (int i = 1; i < [array count]; i++)
    {
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[[array objectAtIndex:i] valueForKey:@"lat"] doubleValue], [[[array objectAtIndex:i] valueForKey:@"lng"] doubleValue]);
        
        bounds = [bounds includingCoordinate:position];
    }
    [gMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:50.0]];
    double distance=[self getDistanceMetresBetweenLocationCoordinates:bounds.northEast toCoordinates:bounds.southWest];
    
    NSLog(@"zoom level :%f",distance);
    //    if(distance<1000){
    //       // CLLocationCoordinate2D coor = [gMapView.projection coordinateForPoint:gMapView.center];
    //        CLLocationCoordinate2D coor = [self midpointBetweenCoordinate:bounds.northEast andCoordinate:bounds.southWest];
    //
    //        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:coor.latitude longitude:coor.longitude zoom:16];
    //        gMapView.camera = camera;
    //
    //    }
    
    
    
}

-(double) getDistanceMetresBetweenLocationCoordinates:(CLLocationCoordinate2D )coord1 toCoordinates:( CLLocationCoordinate2D) coord2
{
    CLLocation* location1 =
    [[CLLocation alloc]
     initWithLatitude: coord1.latitude
     longitude: coord1.longitude];
    CLLocation* location2 =
    [[CLLocation alloc]
     initWithLatitude: coord2.latitude
     longitude: coord2.longitude];
    
    return [location1 distanceFromLocation: location2];
}

#define ToRadian(x) ((x) * M_PI/180)
#define ToDegrees(x) ((x) * 180/M_PI)

- (CLLocationCoordinate2D)midpointBetweenCoordinate:(CLLocationCoordinate2D)c1 andCoordinate:(CLLocationCoordinate2D)c2
{
    c1.latitude = ToRadian(c1.latitude);
    c2.latitude = ToRadian(c2.latitude);
    CLLocationDegrees dLon = ToRadian(c2.longitude - c1.longitude);
    CLLocationDegrees bx = cos(c2.latitude) * cos(dLon);
    CLLocationDegrees by = cos(c2.latitude) * sin(dLon);
    CLLocationDegrees latitude = atan2(sin(c1.latitude) + sin(c2.latitude), sqrt((cos(c1.latitude) + bx) * (cos(c1.latitude) + bx) + by*by));
    CLLocationDegrees longitude = ToRadian(c1.longitude) + atan2(by, cos(c1.latitude) + bx);
    
    CLLocationCoordinate2D midpointCoordinate;
    midpointCoordinate.longitude = ToDegrees(longitude);
    midpointCoordinate.latitude = ToDegrees(latitude);
    
    return midpointCoordinate;
}
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    NSLog(@"%@",[error description]);
    
    
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *loc = [locations lastObject];
    
    self.currentLocation = loc.coordinate;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude zoom:ZOOM_LEVEL2];
    [gMapView setCamera:camera];
    [manager stopUpdatingLocation];
}

/*
 - (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
 CLLocation *loc = manager.location;
 self.currentLocation = loc.coordinate;
 
 GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude zoom:ZOOM_LEVEL2];
 [gMapView setCamera:camera];
 // [manager stopUpdatingLocation];
 }*/

#pragma mark MapViewDelegate Methods
-(UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(CustomGMSMarker *)marker{
    
    return nil;
    
    self.isMapReoldedWithLatestData = YES;
    
    if (![marker isKindOfClass:[CustomGMSMarker class]])
    {
        return nil;
    }
    {
        //To dim the selected Image
        if (marker.isEvent)
        {
            NSString *eventTypeIcon = [NSString stringWithFormat:@"%@_event_type_0",selectedMarker1.imageTypeName];
            if ([selectedMarker1.imageTypeName rangeOfString:@"Musician"].location != NSNotFound) {
                eventTypeIcon = @"Musician_event_type_0.png";
            }
            if(!selectedMarker1.imageTypeName.length)
                eventTypeIcon = @"Other_event_type_0.png";
            
            selectedMarker1.icon = [UIImage imageNamed:eventTypeIcon];
        }
        else
        {
            NSString *venueTypeIcon = [NSString stringWithFormat:@"%@_venue_type_0",selectedMarker1.imageTypeName];
            
            if ([selectedMarker1.imageTypeName rangeOfString:@"Theatre"].location != NSNotFound) {
                venueTypeIcon = @"Theatre_venue_type_0.png";
            }
            else if ([selectedMarker1.imageTypeName rangeOfString:@"Bar"].location != NSNotFound) {
                venueTypeIcon = @"Bar_venue_type_0.png";
            }
            else if([selectedMarker1.imageTypeName rangeOfString:@"Recreational"].location != NSNotFound) {
                venueTypeIcon = @"Recreational_venue_type_0.png";
            }
            else if([selectedMarker1.imageTypeName rangeOfString:@"Caf"].location != NSNotFound) {
                venueTypeIcon = @"Cafe_venue_type_0.png";
            }
            if(!selectedMarker1.imageTypeName.length)
                venueTypeIcon = @"Other_venue_type_0.png";
            
            selectedMarker1.icon = [UIImage imageNamed:venueTypeIcon];
        }
    }
    
    {
        //To Get selected Image
        if (marker.isEvent)
        {
            NSString *eventTypeIcon = [NSString stringWithFormat:@"%@_event_type_1",marker.imageTypeName];
            if ([marker.imageTypeName rangeOfString:@"Musician"].location != NSNotFound) {
                eventTypeIcon = @"Musician_event_type_1.png";
            }
            
            if(!marker.imageTypeName.length)
                eventTypeIcon = @"Other_event_type_1.png";
            
            marker.icon = [UIImage imageNamed:eventTypeIcon];
            
            selectedMarker1 = marker;
            
        }
        else
        {
            NSString *venueTypeIcon = [NSString stringWithFormat:@"%@_venue_type_1",marker.imageTypeName];
            
            if ([marker.imageTypeName rangeOfString:@"Theatre"].location != NSNotFound) {
                venueTypeIcon = @"Theatre_venue_type_1.png";
            }
            else if ([marker.imageTypeName rangeOfString:@"Bar"].location != NSNotFound) {
                venueTypeIcon = @"Bar_venue_type_1.png";
            }
            else if([marker.imageTypeName rangeOfString:@"Recreational"].location != NSNotFound) {
                venueTypeIcon = @"Recreational_venue_type_1.png";
            }
            else if([marker.imageTypeName rangeOfString:@"Caf"].location != NSNotFound) {
                venueTypeIcon = @"Cafe_venue_type_1.png";
            }
            
            if(!marker.imageTypeName.length)
                venueTypeIcon = @"Other_venue_type_1.png";
            
            marker.icon = [UIImage imageNamed:venueTypeIcon];
            
            selectedMarker1 = marker;
            
        }
    }
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 195.0, 105.0)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *popoverBGimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5.0, 195.0, 95.0)];
    popoverBGimg.userInteractionEnabled = YES;
    popoverBGimg.image = [UIImage imageNamed:@"popover.png"];
    [bgView addSubview:popoverBGimg];
    //    [titleLabel setLabelText:marker.title];
    [titleLabel1 setText:marker.title];
    
    [bgView addSubview:titleLabel1];
    
    UIButton *placeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    placeBtn.frame = CGRectMake(5.0, 40+12+4.0, 185, 15.0);
    placeBtn.backgroundColor = [UIColor clearColor];
    placeBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:10.0];
    [placeBtn setTitle:marker.place forState:UIControlStateNormal];
    placeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [placeBtn setImageEdgeInsets:UIEdgeInsetsMake(2.0, 0.0, 0.0, 5.0)];
    if (marker.isEvent)
    {
        [placeBtn setTitleColor:[UIColor colorWithRed:118.0/255.0 green:192.0/255.0 blue:224.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [placeBtn setImage:[UIImage imageNamed:@"location_icon_large.png"] forState:UIControlStateNormal];
    }
    else
    {
        [placeBtn setTitleColor:[UIColor colorWithRed:254.0/255.0 green:127.0/255.0 blue:119.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [placeBtn setImage:[UIImage imageNamed:@"location_popover_orange.png"] forState:UIControlStateNormal];//need to change
    }
    [bgView addSubview:placeBtn];
    
    UIButton *timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    timeBtn.frame = CGRectMake(5.0, 40+15.0+15.0, 185, 15.0);
    timeBtn.backgroundColor = [UIColor clearColor];
    timeBtn.titleLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:10.0];
    [timeBtn setTitle:marker.time forState:UIControlStateNormal];
    timeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [timeBtn setImageEdgeInsets:UIEdgeInsetsMake(2.0, 0, 0, 5.0)];
    if (marker.isEvent)
    {
        [timeBtn setTitleColor:[UIColor colorWithRed:118.0/255.0 green:192.0/255.0 blue:224.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [timeBtn setImage:[UIImage imageNamed:@"time_icon_large.png"] forState:UIControlStateNormal];
    }
    else
    {
        [timeBtn setTitleColor:[UIColor colorWithRed:254.0/255.0 green:127.0/255.0 blue:119.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [timeBtn setImage:[UIImage imageNamed:@"people_count.png"] forState:UIControlStateNormal];//need to change
    }
    [bgView addSubview:timeBtn];
    
    UIView *imgHolderView = [[UIView alloc] initWithFrame:CGRectMake(81, 0, 33, 33)];
    imgHolderView.layer.cornerRadius = 16.5;
    imgHolderView.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:imgHolderView];
    
    EGOImageView *iconImage = [[EGOImageView alloc] initWithFrame:CGRectMake(81, 1.5, 33, 33)];
    //  iconImage.placeholderImage = [UIImage imageNamed:@"food_type_info_popover.png"];
    iconImage.contentMode = UIViewContentModeScaleAspectFill;
    
    iconImage.clipsToBounds = YES;
    if (marker.isEvent)
    {
        NSString *eventTypeIcon = [NSString stringWithFormat:@"%@_event_type",marker.imageTypeName];
        if ([marker.imageTypeName rangeOfString:@"Musician"].location != NSNotFound) {
            eventTypeIcon = @"Musician_event_type.png";
        }
        if(!marker.imageTypeName.length){
            eventTypeIcon = @"Other_event_type.png";
            iconImage.contentMode = UIViewContentModeCenter;
            
        }
        
        iconImage.image = [UIImage imageNamed:eventTypeIcon];
        
    }
    else
    {
        NSString *venueTypeIcon = [NSString stringWithFormat:@"%@_venue_type",marker.imageTypeName];
        
        if ([marker.imageTypeName rangeOfString:@"Theatre"].location != NSNotFound) {
            venueTypeIcon = @"Theatre_venue_type.png";
        }
        else if ([marker.imageTypeName rangeOfString:@"Bar"].location != NSNotFound) {
            venueTypeIcon = @"Bar_venue_type.png";
        }
        else if([marker.imageTypeName rangeOfString:@"Recreational"].location != NSNotFound) {
            venueTypeIcon = @"Recreational_venue_type.png";
        }
        else if([marker.imageTypeName rangeOfString:@"Caf"].location != NSNotFound) {
            venueTypeIcon = @"Cafe_venue_type.png";
        }
        if(!marker.imageTypeName.length){
            venueTypeIcon = @"Other_venue_type.png";
            iconImage.contentMode = UIViewContentModeCenter;
            
        }
        
        iconImage.image = [UIImage imageNamed:venueTypeIcon];
        
    }
    if (marker.isEvent)
        iconImage.backgroundColor = [UIColor colorWithRed:117.0/255.0 green:192.0/255.0 blue:221.0/255.0 alpha:1.0];
    else
        iconImage.backgroundColor = [UIColor colorWithRed:254.0/255.0 green:127.0/255.0 blue:119.0/255.0 alpha:1.0];
    iconImage.layer.cornerRadius = 16.5;
    [bgView addSubview:iconImage];
    
    [bgView bringSubviewToFront:self];
    
    
    return bgView;
}


- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(CustomGMSMarker *)marker;
{
    
    
    return NO;
}
- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    return;
    
    if (selectedMarker1)
    {
        if (selectedMarker1.isEvent)
        {
            NSString *eventTypeIcon = [NSString stringWithFormat:@"%@_event_type_0",selectedMarker1.imageTypeName];
            if ([selectedMarker1.imageTypeName rangeOfString:@"Musician"].location != NSNotFound) {
                eventTypeIcon = @"Musician_event_type.png";
            }
            if(selectedMarker1.imageTypeName.length)
                selectedMarker1.icon = [UIImage imageNamed:eventTypeIcon];
            else
                selectedMarker1.icon = [UIImage imageNamed:@"Other_event_type_0.png"];
            
        }
        else
        {
            NSString *venueTypeIcon = [NSString stringWithFormat:@"%@_venue_type_0",selectedMarker1.imageTypeName];
            
            if ([selectedMarker1.imageTypeName rangeOfString:@"Theatre"].location != NSNotFound) {
                venueTypeIcon = @"Theatre_venue_type_0.png";
            }
            else if ([selectedMarker1.imageTypeName rangeOfString:@"Bar"].location != NSNotFound) {
                venueTypeIcon = @"Bar_venue_type_0.png";
            }
            else if([selectedMarker1.imageTypeName rangeOfString:@"Recreational"].location != NSNotFound) {
                venueTypeIcon = @"Recreational_venue_type_0.png";
            }
            else if([selectedMarker1.imageTypeName rangeOfString:@"Caf"].location != NSNotFound) {
                venueTypeIcon = @"Cafe_venue_type_0.png";
            }
            if(selectedMarker1.imageTypeName.length)
                selectedMarker1.icon = [UIImage imageNamed:venueTypeIcon];
            else
                selectedMarker1.icon = [UIImage imageNamed:@"Other_venue_type_0.png"];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(viewMiniDetailsButtonClicked:)]) {
        [self.delegate performSelector:@selector(viewMiniDetailsButtonClicked:) withObject:nil];
    }
    
}
- (void)mapView:(GMSMapView *)mapView willMove:(BOOL)gesture;
{
    //    if(gesture){
    //    iToast *toast =[iToast makeText:@"Long press to select a location."];
    //        int yValue = mapView.center.y-60;
    //        if(IS_WIDESCREEN)
    //            yValue = mapView.center.y-100;
    //    [toast setPostion:CGPointMake(mapView.center.x, yValue) ];
    //    [toast show:iToastTypeWarning];
    //    }
    
    
}
-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(CustomGMSMarker *)marker{
    
    if (![marker isKindOfClass:[CustomGMSMarker class]])
    {
        return ;
    }
    NSLog(@"tapped on: %d", marker.markerindex);
    if ([self.delegate respondsToSelector:@selector(googlemapViewTappedOnMarker:)]) {
        [self.delegate performSelector:@selector(googlemapViewTappedOnMarker:) withObject:marker];
    }
}

-(void) mapView:(GMSMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSLog(@"didLongPressAtCoordinate %f %f",coordinate.latitude,coordinate.longitude);
    
    if (droppedMarker)
    {
        droppedMarker.position = coordinate;
        droppedMarker.map = gMapView;
    }
    else
    {
        droppedMarker =[[GMSMarker alloc] init];
        
        droppedMarker.icon = [UIImage imageNamed:@"orange_pin.png"];
        droppedMarker.title = @"Selected location";
        droppedMarker.position = coordinate;
        droppedMarker.map = gMapView;
    }
    
    if ([self.delegate respondsToSelector:@selector(getCurrentCityWithLat:andLong:)]) {
        [self.delegate getCurrentCityWithLat:coordinate.latitude andLong:coordinate.longitude];
        
        //        [self.delegate performSelector:@selector(getCurrentCity:) withObject:coordinate.latitude withObject:coordinate.longitude];
    }
    
}
-(void) selectedLocationPinWithLat:(double) lat andWithLogi:(double) lng
{
    AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CLLocation *locA = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:[appDel.latitude doubleValue] longitude:[appDel.longitude doubleValue]];
    
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
    NSLog(@"Gmap Distance %lf",distance);
    //    if (distance < 12)
    //        return;
    
    //    if (droppedMarker && droppedMarker.position.longitude != 0 && droppedMarker.position.latitude != 0)
    //    {
    //
    //        CLLocation *locA = [[CLLocation alloc] initWithLatitude:droppedMarker.position.latitude longitude:droppedMarker.position.longitude];
    //
    //        CLLocation *locB = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    //
    //        CLLocationDistance distance = [locA distanceFromLocation:locB];
    //
    //        NSLog(@"Gmap Distance %lf",distance);
    //        if (distance < 5)
    //        {
    //            NSLog(@"..........Gmap selected loc is same as current loc");
    //            return;
    //        }
    //    }
    CLLocationCoordinate2D coordinate;
    
    coordinate.latitude = lat;
    coordinate.longitude = lng;
    
    NSLog(@"selectedLocationPinWithLat %f %f",coordinate.latitude,coordinate.longitude);
    
    if (droppedMarker)
    {
        droppedMarker.position = coordinate;
        droppedMarker.map = gMapView;
    }
    else
    {
        droppedMarker =[[GMSMarker alloc] init];
        
        droppedMarker.icon = [UIImage imageNamed:@"orange_pin1.png"];
        droppedMarker.title = @"Selected location";
        droppedMarker.position = coordinate;
        droppedMarker.map = gMapView;
    }
}
-(void)changeFrame{
    gMapView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
-(void) clearAllMarkers
{
    @synchronized(gMapView) {
        
        [gMapView clear];
    }
}
#pragma mark Map postion Changed
-(void) mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    //    CGPoint centrePoint = CGPointMake(gMapView.frame.size.width/2, gMapView.frame.size.height/2);
    //    CLLocationCoordinate2D centreLocation = [gMapView.projection coordinateForPoint: centrePoint];
    //
    //    NSLog(@"%lf , %lf, %lf", [self calcualteTheRadius],centreLocation.latitude,centreLocation.longitude);
}
-(void) mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    return;// Shashank tem remove this
    
    if (self.isMapReoldedWithLatestData)
    {
        self.isMapReoldedWithLatestData = NO;
        return;
    }
    CGPoint centrePoint = CGPointMake(gMapView.frame.size.width/2, gMapView.frame.size.height/2);
    CLLocationCoordinate2D centreLocation = [gMapView.projection coordinateForPoint: centrePoint];
    
    NSLog(@"%lf , %lf, %lf", [self calcualteTheRadius],centreLocation.latitude,centreLocation.longitude);
    
    @synchronized(self)
    {
        //Set the radius
        if ([self.delegate respondsToSelector:@selector(mapIsMovedAndRadius:)]) {
            [self.delegate mapIsMovedAndRadius:[NSString stringWithFormat:@"%lf",[self calcualteTheRadius]/1000.0]];
        }
    }
    if ([self.delegate respondsToSelector:@selector(getCurrentCityWithLat:andLong:)])
    {
        //Set map centre loctaion as selected latitude and longituted 
        [self.delegate getCurrentCityWithLat:centreLocation.latitude andLong:centreLocation.longitude];
    }
}
-(double) calcualteTheRadius
{
    GMSVisibleRegion visibleRegion = gMapView.projection.visibleRegion;
    
    double verticalDistance = GMSGeometryDistance(visibleRegion.farLeft, visibleRegion.nearLeft);
    double horizontalDistance = GMSGeometryDistance(visibleRegion.farLeft, visibleRegion.farRight);
    
    return MAX(horizontalDistance, verticalDistance)*0.45;
}

@end
