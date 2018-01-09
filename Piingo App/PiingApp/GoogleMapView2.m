//
//  GoogleMapView2.m
//  GoogleMapsPOC
//
//  Created by Shashank on 17/05/15.
//  Copyright (c) 2015 Shashank. All rights reserved.//

#import "GoogleMapView2.h"
#import "AppDelegate.h"

#define ZOOM_LEVEL   20

#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiansToDegrees(x) (x * 180.0 / M_PI)

@interface GoogleMapView2 ()
{
    GMSPolyline *gmsPline;
    GMSCoordinateBounds *bounds;
    
    NSMutableDictionary *dictSaveGoogleData;
    
    NSString *strSourcAddr;
    NSString *strDestinationAddr;
    
    NSMutableArray *arrWayPoints;
    
    AppDelegate *appDel;
}

@end

CustomGMSMarker *selectedMarker;
//AutomaticScrollView *titleLabel;
UILabel *titleLabel;

@implementation GoogleMapView2
@synthesize delegate, mapLocation,currentLocation, decodedPolylineArray, isMapReoldedWithLatestData, allMarkersArray;;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        selectedMarker = [[CustomGMSMarker alloc] init];
        allMarkersArray = [[NSMutableArray alloc] init];
        
        arrWayPoints = [[NSMutableArray alloc]init];
        
        piingoMarker = [[GMSMarker alloc] init];
        clientMarker = [[GMSMarker alloc] init];
        
        
        
        //        self.locationManager = [[CLLocationManager alloc] init];
        //        self.locationManager.delegate = self;
        //        if(IS_OS_8_OR_LATER) {
        //            [self.locationManager requestWhenInUseAuthorization];  // For foreground access
        ////            [self.locationManager requestAlwaysAuthorization]; // For background access
        //        }
        //
        //        [self.locationManager startUpdatingLocation];
        
        //        startLocation = self.locationManager.location;
        //        currLocation = [NSString stringWithFormat:@"%f,%f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
        
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude zoom:ZOOM_LEVEL];
        
        gMapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) camera:nil];
        gMapView.settings.rotateGestures = NO;
        gMapView.settings.tiltGestures = NO;
        gMapView.camera = camera;
        gMapView.delegate = self;
        gMapView.myLocationEnabled = NO;
        gMapView.settings.rotateGestures = YES;
        [self addSubview:gMapView];
        [gMapView setMinZoom:10 maxZoom:20];
        
        //        gMapView.settings.compassButton = YES;
        //        gMapView.settings.myLocationButton =YES;
        
        
        
        //[gMapView animateToZoom:17];
        //[gMapView animateToBearing:90];
        
        
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 40-2, 185, 15.0+2)];
        //        [titleLabel setLabelFont:[UIFont fontWithName:APPFONT_SEMIBOLD size:12.0]];
        //        [titleLabel setLabelTextAlignment:NSTextAlignmentCenter];
        //        [titleLabel setLabelTextColor:[UIColor colorWithRed:114.0/255.0	green:131.0/255.0 blue:139.0/255.0 alpha:1.0]];
        titleLabel.textColor = [UIColor colorWithRed:114.0/255.0	green:131.0/255.0 blue:139.0/255.0 alpha:1.0];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:APPFONT_SEMI_BOLD size:12.0];
        
        
        dictSaveGoogleData = [[NSMutableDictionary alloc]init];
        
    }
    
    return self;
}


-(void) addClientMarker:(id) obj
{
    DLog(@"Lat %lf long %f %@ %@", clientMarker.position.latitude, clientMarker.position.longitude,[obj objectForKey:@"lat"],[obj objectForKey:@"lon"]);
    
    //    clientMarker.map = nil;
    //    clientMarker = nil;
    //
    //    clientMarker = [[GMSMarker alloc] init];
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[obj objectForKey:@"lat"] doubleValue];
    coordinates.longitude = [[obj objectForKey:@"lon"] doubleValue];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:2.0];
    clientMarker.position = coordinates;
    [CATransaction commit];
    
    clientMarker.position = coordinates;
    clientMarker.icon = [UIImage imageNamed:@"home_map"];
    //    clientMarker.groundAnchor = CGPointMake(0.5, 0.5);
    //    clientMarker.rotation = 90;
    //clientMarker.appearAnimation = kGMSMarkerAnimationPop;
    clientMarker.map = gMapView;
    
    [allMarkersArray removeObject:clientMarker];
    
    [allMarkersArray addObject:clientMarker];
    
}


-(void) addPiingoMarkder:(id) obj
{
    DLog(@"Lat %lf long %lf %@ %@", piingoMarker.position.latitude, piingoMarker.position.longitude,[obj objectForKey:@"lat"],[obj objectForKey:@"lon"]);
    
    //    piingoMarker.map = nil;
    //    piingoMarker = nil;
    //
    //    piingoMarker = [[GMSMarker alloc] init];
    
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[obj objectForKey:@"lat"] doubleValue];
    coordinates.longitude = [[obj objectForKey:@"lon"] doubleValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:5.5f];
    piingoMarker.position = coordinates;
    piingoMarker.map = gMapView;
    [UIView commitAnimations];
    
    
    
    //piingoMarker.icon = [UIImage imageNamed:@"piingo_map"];
    
    piingoMarker.icon = [UIImage imageNamed:@"piingo_van"];
    
    if (appDel.vehicle_direction != 0)
    {
       // piingoMarker.rotation = appDel.vehicle_direction;
    }
    
//    piingoMarker.flat = YES;
//    double degrees = [self DegreeBearing];
    
    
    
    //    piingoMarker.icon = [UIImage imageNamed:@"piingo_van"];
    //
    //    CLLocationDegrees degrees = 90;
    //    piingoMarker.groundAnchor = CGPointMake(0.5, 0.5);
    //    piingoMarker.rotation = degrees;
    
    //piingoMarker.appearAnimation = kGMSMarkerAnimationPop;
    //piingoMarker.groundAnchor = CGPointMake(0.5, 0.5);
    //piingoMarker.rotation = 90;
    //piingoMarker.rotation = [self setLatLonForDistanceAndAngle];
    //piingoMarker.flat = YES;
    
    
    
    //[self getHeadingForDirectionFromCoordinate];
    
    
    [allMarkersArray removeObject:piingoMarker];
    
    [allMarkersArray addObject:piingoMarker];
    
    //[self focusMapToShowAllMarkers];
}



- (void) getHeadingForDirectionFromCoordinate
{
    float fLat = degreesToRadians(piingoMarker.position.latitude);
    float fLng = degreesToRadians(piingoMarker.position.longitude);
    
    float tLat = degreesToRadians(clientMarker.position.latitude);
    float tLng = degreesToRadians(clientMarker.position.longitude);
    
    float degree = radiansToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    piingoMarker.icon = [UIImage imageNamed:@"piingo_van"];
    piingoMarker.flat = YES;
    
    //piingoMarker.rotation = gMapView
    
    if (degree >= 0)
    {
        piingoMarker.rotation = degree;
    }
    else
    {
        piingoMarker.rotation = 360+degree;
    }
    
    //piingoMarker.groundAnchor = CGPointMake(0.5, 0.5);
    
    //    [UIView animateWithDuration:5.0 delay:0.0 options:0 animations:^{
    //
    //        if (degree >= 0)
    //        {
    //            piingoMarker.rotation = degree;
    //        }
    //        else
    //        {
    //            piingoMarker.rotation = 360+degree;
    //        }
    //
    //    } completion:^(BOOL finished) {
    //
    //    }];
}


-(double) DegreeBearing
{
    double dlon = [self ToRad:(piingoMarker.position.longitude - clientMarker.position.longitude)];
    
    double dPhi = log(tan([self ToRad:(piingoMarker.position.latitude) / 2 + M_PI / 4]) / tan([self ToRad:(clientMarker.position.latitude) / 2 + M_PI / 4]));
    
    if  (fabs(dlon) > M_PI)
    {
        dlon = (dlon > 0) ? (dlon - 2*M_PI) : (2*M_PI + dlon);
    }
    
    return [self ToBearing:(atan2(dlon, dPhi))];
}

-(double) ToRad: (double)degrees
{
    return degrees*(M_PI/180);
}

-(double) ToBearing:(double)radians
{
    double doubledata = ([self ToDegrees:(radians) + 360]);
    
    doubledata = (int) doubledata % 360;
    
    //double anotherDouble = doubledata - (doubledata/360) * 360;
    
    return doubledata;
}

-(double) ToDegrees: (double)radians
{
    return radians * 180 / M_PI;
}


-(void) addMarker:(id) obj withIndex:(int) index
{
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[obj objectForKey:@"lat"] doubleValue];
    coordinates.longitude = [[obj objectForKey:@"lon"] doubleValue];
    
    CustomGMSMarker *marker = [[CustomGMSMarker alloc] init];
    marker.title = [obj objectForKey:@"oid"];
    marker.snippet = [obj objectForKey:@"timeslot"];
    marker.tappable = YES;
    [CATransaction begin];
    [CATransaction setAnimationDuration:2.0];
    marker.position = coordinates;
    [CATransaction commit];
    
    marker.icon = [UIImage imageNamed:@"piingo_map"];
    
    if ([obj objectForKey:@"markImage"] || [[obj objectForKey:@"markImage"] length] > 0)
    {
        marker.icon = [UIImage imageNamed:[obj objectForKey:@"markImage"]];
    }
    if ([[[obj objectForKey:@"clearAll"] lowercaseString] isEqualToString:@"yes"])
    {
        [self clearAllMarkers];
    }
    
    marker.infoWindowAnchor = CGPointMake(0.38, 0.0);
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = gMapView;
    
    [gMapView setSelectedMarker:marker];
    
    //    marker.groundAnchor = CGPointMake(0.5, 0.5);
    //    marker.rotation = 90;
    
    //    marker.title = obj.name;
    //    marker.markerindex = index;
    //    marker.isEvent = obj.isEvent;
    //    marker.imageTypeName = obj.type;
    //
    //    marker.place = obj.eventVenue;
    //    marker.time = [AppDelegate peopleFollowingText:obj.peopleFollowing];
    
    [allMarkersArray addObject:marker];
    
    //[self focusMapToShowAllMarkers];
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

-(void)drawDirectionsToDestination
{
    
    //[self clearAllMarkers];
    
    //    for (int i=0; i<[arrWayPoints count]; i++)
    //    {
    //        NSMutableDictionary *dict = [arrWayPoints objectAtIndex:i];
    //        [self addCustomMarkers:dict];
    //    }
    
//    if ([strSourcAddr length])
//    {
//        NSMutableDictionary *dictUser = [[NSMutableDictionary alloc]init];
//        NSArray *arrayUser = [strSourcAddr componentsSeparatedByString:@","];
//        
//        [dictUser setObject:[arrayUser objectAtIndex:0] forKey:@"lat"];
//        [dictUser setObject:[arrayUser objectAtIndex:1] forKey:@"lon"];
//        
//        [self addClientMarker:dictUser];
//    }
    
    if ([strSourcAddr length])
    {
        NSMutableDictionary *dictPiingo = [[NSMutableDictionary alloc]init];
        NSArray *arrayPiingo = [strSourcAddr componentsSeparatedByString:@","];
        
        [dictPiingo setObject:[arrayPiingo objectAtIndex:0] forKey:@"lat"];
        [dictPiingo setObject:[arrayPiingo objectAtIndex:1] forKey:@"lon"];
        
        [self addPiingoMarkder:dictPiingo];
    }
    
    
    
    GMSMutablePath *gmsPath = [[GMSMutablePath alloc] init];
    
    for (int i = 0; i < self.decodedPolylineArray.count; i++) {
        [gmsPath addCoordinate:[[self.decodedPolylineArray objectAtIndex:i] coordinate]];
    }
    
    gmsPline.map = nil;
    gmsPline = nil;
    
    gmsPline = [GMSPolyline polylineWithPath:gmsPath];
    gmsPline.strokeColor = BLUE_COLOR;
    gmsPline.strokeWidth = 4.0f;
    gmsPline.geodesic = YES;
    gmsPline.map = gMapView;
    
    if (!bounds)
    {
        bounds = [[GMSCoordinateBounds alloc] init];
    }
    
    [bounds includingPath:gmsPath];
    
    [gMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withPadding:60.0f]];
    
    //[GMSCameraUpdate zoomTo:20];
    
    //    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
    //    [gMapView moveCamera:update];
    
    if (![dictSaveGoogleData objectForKey:@"animated"])
    {
        [dictSaveGoogleData setObject:@"YES" forKey:@"animated"];
        //[gMapView animateToZoom:18];
    }
}

-(void) addCustomMarkers:(id) obj
{
    CLLocationCoordinate2D coordinates;
    
    if ([obj objectForKey:@"lat"])
    {
        coordinates.latitude = [[obj objectForKey:@"lat"] doubleValue];
        coordinates.longitude = [[obj objectForKey:@"lon"] doubleValue];
    }
    else if ([obj objectForKey:@"lt"])
    {
        coordinates.latitude = [[obj objectForKey:@"lt"] doubleValue];
        coordinates.longitude = [[obj objectForKey:@"ln"] doubleValue];
    }
    
    CustomGMSMarker *marker = [[CustomGMSMarker alloc] init];
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:2.0];
    marker.position = coordinates;
    [CATransaction commit];
    
    marker.icon = [UIImage imageNamed:@"home_map"];
    marker.infoWindowAnchor = CGPointMake(0.38, 0.0);
    //marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = gMapView;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    [appDel showAlertWithMessage:@"Update google maps route - Heading" andTitle:@"" andBtnTitle:@"OK"];
    
    //float heading = newHeading.magneticHeading; //in degrees
    //float headingDegrees = (heading*M_PI/180); //assuming needle points to top of iphone. convert to radians
    //self.bearingView.transform = CGAffineTransformMakeRotation(headingDegrees);
}

-(void)getDirectionRoutesFrom:(NSString *)saddr to:(NSString *)daddr withTravelMode:(NSString *)travelMode andWithUsingWaypoints:(NSArray *) arraywaypoints
{
    //    AppDelegate *appDel = [PiingHandler sharedHandler].appDel;
    //
    //    loaderView = [[CustomLoaderView alloc] initWithFrame:CGRectZero andType:1];
    //    loaderView.loaderText = @"Loading Directions..";
    //    [appDel.window.rootViewController.view addSubview:loaderView];
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
    
    [arrWayPoints removeAllObjects];
    
    NSMutableString *wayPointsStr = [[NSMutableString alloc] init];
    
    if ([arraywaypoints count])
    {
        for (int w = 0; w < [arraywaypoints count] ;w++)
        {
            NSDictionary *dictCoordinates = [arraywaypoints objectAtIndex:w];
            
            NSString *str;
            
            if ([dictCoordinates objectForKey:@"lat"])
            {
                str = [NSString stringWithFormat:@"%f", [[dictCoordinates objectForKey:@"lat"]doubleValue]];
            }
            else if ([dictCoordinates objectForKey:@"lt"])
            {
                str = [NSString stringWithFormat:@"%f", [[dictCoordinates objectForKey:@"lt"]doubleValue]];
            }
            
            if ([saddr containsString:str])
            {
                continue;
            }
            
            if (![wayPointsStr length])
            {
                if ([dictCoordinates objectForKey:@"lat"])
                {
                    [wayPointsStr appendFormat:@"%f,%f",[[dictCoordinates objectForKey:@"lat"] doubleValue],[[dictCoordinates objectForKey:@"lon"] doubleValue]];
                }
                else if ([dictCoordinates objectForKey:@"lt"])
                {
                    [wayPointsStr appendFormat:@"%f,%f",[[dictCoordinates objectForKey:@"lt"] doubleValue],[[dictCoordinates objectForKey:@"ln"] doubleValue]];
                }
            }
            else
            {
                if ([dictCoordinates objectForKey:@"lat"])
                {
                    [wayPointsStr appendFormat:@"|%f,%f",[[dictCoordinates objectForKey:@"lat"] doubleValue],[[dictCoordinates objectForKey:@"lon"] doubleValue]];
                }
                else if ([dictCoordinates objectForKey:@"lt"])
                {
                    [wayPointsStr appendFormat:@"|%f,%f",[[dictCoordinates objectForKey:@"lt"] doubleValue],[[dictCoordinates objectForKey:@"ln"] doubleValue]];
                }
            }
            
            [arrWayPoints addObject:dictCoordinates];
            
        }
        
    }
    
    //    if ([dictSaveGoogleData objectForKey:@"destination"])
    //    {
    //        daddr = @"17.4368,78.4439";
    //    }
    //
    //    [dictSaveGoogleData setObject:@"YES" forKey:@"destination"];
    
    
    
    //
    //    CLLocationCoordinate2D coordinates;
    //    coordinates.latitude = 17.4368;
    //    coordinates.longitude = 78.4439;
    //
    //    CustomGMSMarker *marker = [[CustomGMSMarker alloc] init];
    //    marker.position = coordinates;
    //    marker.icon = [UIImage imageNamed:@"piingo_map"];
    //    marker.infoWindowAnchor = CGPointMake(0.38, 0.0);
    //    marker.appearAnimation = kGMSMarkerAnimationPop;
    //    marker.map = gMapView;
    //
    //    saddr = @"17.3688,78.5247";
    //
    //    coordinates.latitude = 17.3688;
    //    coordinates.longitude = 78.5247;
    //
    //    marker = [[CustomGMSMarker alloc] init];
    //    marker.position = coordinates;
    //    marker.icon = [UIImage imageNamed:@"piingo_map"];
    //    marker.infoWindowAnchor = CGPointMake(0.38, 0.0);
    //    marker.appearAnimation = kGMSMarkerAnimationPop;
    //    marker.map = gMapView;
    //
    //    wayPointsStr = [@"17.3667,78.5000" mutableCopy];
    //
    //    coordinates.latitude = 17.3667;
    //    coordinates.longitude = 78.5000;
    //
    //    marker = [[CustomGMSMarker alloc] init];
    //    marker.position = coordinates;
    //    marker.icon = [UIImage imageNamed:@"piingo_map"];
    //    marker.infoWindowAnchor = CGPointMake(0.38, 0.0);
    //    marker.appearAnimation = kGMSMarkerAnimationPop;
    //    marker.map = gMapView;
    
    
    strSourcAddr = saddr;
    strDestinationAddr = daddr;
    
    NSString *strAvoid = @"tolls|highways|ferries";
    NSString *strTraffic_model = @"optimistic";
    
    travelMode = @"driving";
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&waypoints=%@&mode=%@&avoid=%@&traffic_model=%@&departure_time=%ld&sensor=false&key=%@", saddr, daddr, wayPointsStr, travelMode, strAvoid, strTraffic_model, (long) timeInterval, GOOGLE_API_KEY];
    
    NSURL* apiUrl = [NSURL URLWithString:[apiUrlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    DLog(@"%@",apiUrlStr);
    NSURLRequest *request = [NSURLRequest requestWithURL:apiUrl];
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self  startImmediately:NO];
    [urlConnection start];
    
    [loaderView startLoading];
    
}
-(void)getDirectionRoutesFrom:(NSString *)saddr to:(NSString *)daddr withTravelMode:(NSString *)travelMode
{
    
    currLocation = [NSString stringWithFormat:@"%f,%f", [appDel.latitude doubleValue], [appDel.longitude doubleValue]];
    
    //    loaderView = [[CustomLoaderView alloc] initWithFrame:CGRectZero andType:1];
    //    loaderView.loaderText = @"Loading Directions..";
    //    [appDel.window.rootViewController.view addSubview:loaderView];
    //
    //    if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
    //        loaderView.frame = appDel.window.rootViewController.view.frame;
    //    }
    //    else{
    //        loaderView.frame = CGRectMake(0, 0, 1024, 768);
    //    }
    //    [loaderView setLoaderViewFrame];
    receivedData = [[NSMutableData alloc] init];
    //self.decodedPolylineArray = [[NSMutableArray alloc] init];
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&mode=%@&sensor=false&departure_time=%f&key=%@", currLocation, daddr, travelMode, timeInterval, GOOGLE_API_KEY];
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
    
    [self showAlertWithMessage:[error localizedDescription] andTitle:@"Map Directions" andBtnTitle:@"OK"];
    
    [loaderView stopLoading];
    
}

- (void)showAlertWithMessage:(NSString *)msg andTitle:(NSString *)title andBtnTitle:(NSString *)btnTitle{
    
    UIAlertController* errorMessageAlert = [UIAlertController alertControllerWithTitle:nil
                                                                               message:msg
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:btnTitle style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [errorMessageAlert addAction:defaultAction];
    [appDel.window.rootViewController presentViewController:errorMessageAlert animated:YES completion:nil];
    
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
    
    
    if (!receivedData) {
        return;
    }
    else{
        NSString *string = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        if ([[resultDictionary objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"] || [[resultDictionary objectForKey:@"status"] isEqualToString:@"NOT_FOUND"])
        {
            [self showAlertWithMessage:@"Cannot draw the directions to selected destination / ZERO_RESULTS found" andTitle:@"Map Directions" andBtnTitle:@"OK"];
            
            return;
        }
        else if ([[resultDictionary objectForKey:@"status"] isEqualToString:@"NOT_FOUND"])
        {
            [delegate durationResponse:resultDictionary];
        }
        else
        {
            [self.decodedPolylineArray removeAllObjects];
            
            NSMutableArray *stepsArray = [[NSMutableArray alloc] init];
            
            if ([[resultDictionary objectForKey:@"routes"] count])
            {
                [delegate durationResponse:[[[[[resultDictionary objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"duration"]];
                
                @try {
                    
                    NSArray *arraSteps = [[[resultDictionary objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"];
                    
                    //[stepsArray addObject:[[arraSteps objectAtIndex:0] objectForKey:@"steps"]];
                    
                    for (int i=0; i<[arraSteps count]; i++)
                    {
                        [stepsArray addObjectsFromArray:[[arraSteps objectAtIndex:i] objectForKey:@"steps"]];
                    }
                    
                    // stepsArray = [[[[[resultDictionary objectForKey:@"routes"] objectAtIndex:0] objectForKey:@"legs"] objectAtIndex:0] objectForKey:@"steps"];
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
                        
                        [self showAlertWithMessage:@"Cannot draw the directions to selected destination" andTitle:@"Map Directions" andBtnTitle:@"OK"];
                        
                     
                    }
                }
                
                //if (self.decodedPolylineArray.count<=60000) {
                
                if (self.decodedPolylineArray.count) {
                    [self drawDirectionsToDestination];
                }
                else if (self.decodedPolylineArray.count == 0) {
                    
                    [self showAlertWithMessage:@"Cannot draw the directions to selected destination" andTitle:@"Map Directions" andBtnTitle:@"OK"];
                }
                else{
                    
                    [self showAlertWithMessage:@"Destination is too long to draw the directions." andTitle:@"Map Directions" andBtnTitle:@"OK"];
                }
                
            }
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
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude zoom:ZOOM_LEVEL];
    [gMapView setCamera:camera];
    
    [manager stopUpdatingLocation];
    
    
    
}
-(void) reloadMapViewWithLatitude:(NSString *)lat andWithLogitude:(NSString *) lng
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[lat doubleValue] longitude:[lng doubleValue] zoom:ZOOM_LEVEL];
    [gMapView performSelectorOnMainThread:@selector(setCamera:) withObject:camera waitUntilDone:YES];
    
}
-(void) reloadMapViewWithArrayOfLatLng:(NSMutableArray *) array
{
    //    return;//Removed Bouncing
    
    self.isMapReoldedWithLatestData = YES;
    
    CLLocationCoordinate2D firstPosition = CLLocationCoordinate2DMake([[[array objectAtIndex:0] valueForKey:@"lat"] doubleValue], [[[array objectAtIndex:0] valueForKey:@"lng"] doubleValue]);
    
    GMSCoordinateBounds *bounds1 = [[GMSCoordinateBounds alloc] initWithCoordinate:firstPosition coordinate:firstPosition];
    
    for (int i = 1; i < [array count]; i++)
    {
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[[array objectAtIndex:i] valueForKey:@"lat"] doubleValue], [[[array objectAtIndex:i] valueForKey:@"lng"] doubleValue]);
        
        bounds1 = [bounds1 includingCoordinate:position];
    }
    
    [gMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds1 withPadding:60.0]];
    double distance=[self getDistanceMetresBetweenLocationCoordinates:bounds1.northEast toCoordinates:bounds1.southWest];
    
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
    
    [manager stopUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *loc = [locations lastObject];
    
    self.currentLocation = loc.coordinate;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude zoom:ZOOM_LEVEL];
    [gMapView setCamera:camera];
    [manager stopUpdatingLocation];
}

/*
 - (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
 CLLocation *loc = manager.location;
 self.currentLocation = loc.coordinate;
 
 GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.coordinate.latitude longitude:loc.coordinate.longitude zoom:ZOOM_LEVEL];
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
            NSString *eventTypeIcon = [NSString stringWithFormat:@"%@_event_type_0",selectedMarker.imageTypeName];
            if ([selectedMarker.imageTypeName rangeOfString:@"Musician"].location != NSNotFound) {
                eventTypeIcon = @"Musician_event_type_0.png";
            }
            if(!selectedMarker.imageTypeName.length)
                eventTypeIcon = @"Other_event_type_0.png";
            
            selectedMarker.icon = [UIImage imageNamed:eventTypeIcon];
        }
        else
        {
            NSString *venueTypeIcon = [NSString stringWithFormat:@"%@_venue_type_0",selectedMarker.imageTypeName];
            
            if ([selectedMarker.imageTypeName rangeOfString:@"Theatre"].location != NSNotFound) {
                venueTypeIcon = @"Theatre_venue_type_0.png";
            }
            else if ([selectedMarker.imageTypeName rangeOfString:@"Bar"].location != NSNotFound) {
                venueTypeIcon = @"Bar_venue_type_0.png";
            }
            else if([selectedMarker.imageTypeName rangeOfString:@"Recreational"].location != NSNotFound) {
                venueTypeIcon = @"Recreational_venue_type_0.png";
            }
            else if([selectedMarker.imageTypeName rangeOfString:@"Caf"].location != NSNotFound) {
                venueTypeIcon = @"Cafe_venue_type_0.png";
            }
            if(!selectedMarker.imageTypeName.length)
                venueTypeIcon = @"Other_venue_type_0.png";
            
            selectedMarker.icon = [UIImage imageNamed:venueTypeIcon];
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
            
            selectedMarker = marker;
            
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
            
            selectedMarker = marker;
            
        }
    }
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 195.0, 105.0)];
    bgView.backgroundColor = [UIColor clearColor];
    
    UIImageView *popoverBGimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5.0, 195.0, 95.0)];
    popoverBGimg.userInteractionEnabled = YES;
    popoverBGimg.image = [UIImage imageNamed:@"popover.png"];
    [bgView addSubview:popoverBGimg];
    //    [titleLabel setLabelText:marker.title];
    [titleLabel setText:marker.title];
    
    [bgView addSubview:titleLabel];
    
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(googlemapViewTappedOnMarker:)])
    {
        [self.delegate googlemapViewTappedOnMarker:marker];
    }
    
    return NO;
}
- (void)mapView:(GMSMapView *)mapView
didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
{
    return;
    
    if (selectedMarker)
    {
        if (selectedMarker.isEvent)
        {
            NSString *eventTypeIcon = [NSString stringWithFormat:@"%@_event_type_0",selectedMarker.imageTypeName];
            if ([selectedMarker.imageTypeName rangeOfString:@"Musician"].location != NSNotFound) {
                eventTypeIcon = @"Musician_event_type.png";
            }
            if(selectedMarker.imageTypeName.length)
                selectedMarker.icon = [UIImage imageNamed:eventTypeIcon];
            else
                selectedMarker.icon = [UIImage imageNamed:@"Other_event_type_0.png"];
            
        }
        else
        {
            NSString *venueTypeIcon = [NSString stringWithFormat:@"%@_venue_type_0",selectedMarker.imageTypeName];
            
            if ([selectedMarker.imageTypeName rangeOfString:@"Theatre"].location != NSNotFound) {
                venueTypeIcon = @"Theatre_venue_type_0.png";
            }
            else if ([selectedMarker.imageTypeName rangeOfString:@"Bar"].location != NSNotFound) {
                venueTypeIcon = @"Bar_venue_type_0.png";
            }
            else if([selectedMarker.imageTypeName rangeOfString:@"Recreational"].location != NSNotFound) {
                venueTypeIcon = @"Recreational_venue_type_0.png";
            }
            else if([selectedMarker.imageTypeName rangeOfString:@"Caf"].location != NSNotFound) {
                venueTypeIcon = @"Cafe_venue_type_0.png";
            }
            if(selectedMarker.imageTypeName.length)
                selectedMarker.icon = [UIImage imageNamed:venueTypeIcon];
            else
                selectedMarker.icon = [UIImage imageNamed:@"Other_venue_type_0.png"];
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
    [allMarkersArray removeAllObjects];
    
    [gMapView clear];
    
}
- (void)focusMapToShowAllMarkers
{
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    for (GMSMarker *marker in allMarkersArray) {
        [path addCoordinate: marker.position];
    }
    
    GMSCoordinateBounds *bounds1 = [[GMSCoordinateBounds alloc] initWithPath:path];
    [gMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds1 withPadding:60.0f]];
    
    if ([allMarkersArray count] == 1)
    {
        [gMapView animateToZoom:15];
    }
    
}

#pragma mark Map postion Changed
-(void) mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    //    CGPoint centrePoint = CGPointMake(gMapView.frame.size.width/2, gMapView.frame.size.height/2);
    //    CLLocationCoordinate2D centreLocation = [gMapView.projection coordinateForPoint: centrePoint];
    //
    //    NSLog(@"%lf , %lf, %lf", [self calcualteTheRadius],centreLocation.latitude,centreLocation.longitude);
    
    CLLocationDirection mapBearing = position.bearing;
    piingoMarker.rotation = appDel.vehicle_direction - mapBearing;
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

-(void) replaceMarker:(id) obj PositionAtIndex:(NSInteger) page
{
    CustomGMSMarker *marker = [allMarkersArray objectAtIndex:page];
    
    //[allMarkersArray removeObjectAtIndex:page];
    
    CustomGMSMarker *marker1 = marker;
    
    marker.map = nil;
    
    //marker1 = [[CustomGMSMarker alloc]init];
    CLLocationCoordinate2D coordinates;
    coordinates.latitude = [[obj objectForKey:@"lat"] doubleValue];
    coordinates.longitude = [[obj objectForKey:@"lon"] doubleValue];
    marker1.position = coordinates;
    marker.icon = [UIImage imageNamed:[obj objectForKey:@"markImage"]];
    marker1.infoWindowAnchor = CGPointMake(0.38, 0.0);
    marker1.appearAnimation = kGMSMarkerAnimationPop;
    marker1.map = gMapView;
    
    [allMarkersArray replaceObjectAtIndex:page withObject:marker1];
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    for (GMSMarker *marker in allMarkersArray) {
        [path addCoordinate: marker.position];
    }
    
    GMSCoordinateBounds *bounds1 = [[GMSCoordinateBounds alloc] initWithPath:path];
    [gMapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds1 withPadding:60.0f]];
    
    if ([allMarkersArray count] == 1)
    {
        [gMapView animateToZoom:13];
    }
    
    
}

@end
