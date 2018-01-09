//
//  AppDelegate.m
//  PiingApp
//
//  Created by SHASHANK on 02/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MenuViewController.h"

#import <MessageUI/MessageUI.h>
#import <GoogleMaps/GoogleMaps.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "ListViewController.h"
#import "Reachability.h"
#import "EmptyViewController.h"
#import "UIImage+animatedGIF.h"
#import <AVFoundation/AVFoundation.h>
#import "FXBlurView.h"

//#import <NMAKit/NMAKit.h>

#define kHelloMapAppID @"lSHejKIbA3nQpAvGBzLn"

#define kHelloMapAppCode @"zEcsUrZEcaj69GAB5GxahA"

#define kHelloMapLicenseKey @"NOjEI84pXsXYULUYS/UGRLuhiWhEQbtwihut/FGxPTGFAbTZb0KAgJ96f05SmMwMvghqiT3+LmKAojE2BuN31+rUaBwUMEKHhnHXnFJq76+GhDQMEKfo0VGFexvn1lyTeRPKj8OV+IArZtNP+Y7bi4DcDCO30nplbM+M2GoVvduXYVc89wdGsxMn706l7sVQVyFJlw286PrUALqR8SCTSLttPZ1dP0i9BNuvrXitIttB3E5SW1oeA8XpFdqbKgsB040kIyzj3Tc2fpFwO4WQlzQdMPEaSAoRAO4x4EcO9YPcmo6CfkCdwQagrk408QQgZuY9UhnK9FUtUoFhzaUpjjWKdBMGItVJeDyIOwwUCBijq/VJZ6MDGb4ZwN6SuSRJje1PI7TA4y9DIXbVjhkkTsosw+nB3ASMpZDfevI8lFUkgcmB9bsKD2nHTfrgDkk5k4+xDqLsVgSXaw6ac86I8rua3Kegg761jDiX0LVaPLUgucC6JY8kqiqPJc1u3z19cX9dX/FzDrqeA9eookEYjgbpTDC7udCOp7R0LECu3n0PvShCwxU0n50MraremqmArFCQmXl9OSS6ict3zohmkohwEr8ZIRsphfpZ49DKls4hMFmxpic6q3pB8J1lwMOveyklBd0uP1LtTPuSvs1ucsHXE9c86P5WXeAr6A+b2wk="



@interface AppDelegate ()<MFMessageComposeViewControllerDelegate, MBProgressHUDDelegate, RESideMenuDelegate>
{
    CustomLoaderView *loaderView;
    
    NSMutableDictionary *dictSaveData;
    
    RESideMenu *sideMenuViewController;
    
    AVAudioPlayer *myAudioPlayer;
    
    BOOL notificationcame;
}

@property BOOL socketIsConnected;

@end

@implementation AppDelegate

@synthesize latitude;
@synthesize longitude;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // TODO: ENTER YOUR APPLICATION CREDENTIALS HERE!
    //[NMAApplicationContext setAppId:kHelloMapAppID appCode:kHelloMapAppCode licenseKey:kHelloMapLicenseKey];
    
    //[NMAApplicationContext setAppId:kHelloMapAppID appCode:kHelloMapAppCode licenseKey:kHelloMapLicenseKey];
    
    
//    self.latitude = @"1.274791";
//    self.longitude = @"103.855519";
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat height = screenBounds.size.height;
    
    
    if (height == 568.0)
    {
        self.FONT_SIZE_CUSTOM = 13.0f;
        self.HEADER_LABEL_FONT_SIZE = 18.0f;
    }
    else if (height == 480.0)
    {
        self.FONT_SIZE_CUSTOM = 13.0f;
        self.HEADER_LABEL_FONT_SIZE = 18.0f;
    }
    else if (height == 667.0)
    {
        self.FONT_SIZE_CUSTOM = 15.0f;
        self.HEADER_LABEL_FONT_SIZE = 20.0f;
    }
    else if (height == 736.0)
    {
        self.FONT_SIZE_CUSTOM = 16.0f;
        self.HEADER_LABEL_FONT_SIZE = 22.0f;
    }
    else
    {
        self.FONT_SIZE_CUSTOM = 16.0f;
        self.HEADER_LABEL_FONT_SIZE = 22.0f;
    }
    
    self.dictPriceImages = [[NSMutableDictionary alloc]init];
    self.dictPriceSelectedImages = [[NSMutableDictionary alloc]init];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Scanned_Bags"])
    {
        self.dictScannedBags = [[NSMutableDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:@"Scanned_Bags"]];
    }
    else
    {
        self.dictScannedBags = [[NSMutableDictionary alloc]init];
    }
    
    self.dictEachSegmentCount = [[NSMutableDictionary alloc]init];
    
    self.dict_UserLocation = [[NSMutableDictionary alloc]init];
    
    self.window = [[UIWindow alloc] initWithFrame:screenBounds];
    
    if (screenBounds.size.height == 812)
    {
        self.window.frame = CGRectMake(0, 30, screen_width, screen_height);
        NSLog(@"screen height : %f", screen_height);
    }
    
    dictSaveData = [[NSMutableDictionary alloc]init];
    
    //Initialization
    [Fabric with:@[CrashlyticsKit]];
    
    [[CoreDataMethods sharedInstance] copyCoreDataDBintoDocumentsFolder];
    
    [GMSServices provideAPIKey:GOOGLE_API_KEY];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerDeviceForPNSWithDevToken) name:@"registerDeviceForPNSWithDevToken" object:nil];
    
    self.UUID = [SSKeychain passwordForService:@"com.piing.piingo" account:@"Piingo"];
    if (self.UUID) {
        DLog(@"UUID from key chain: %@", self.UUID);
    }
    else{
        self.UUID = [AppDelegate GetUUID];
        DLog(@"New uuid: %@", self.UUID);
    }
    
    UNUserNotificationCenter *notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
    
    [notificationCenter requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(!error){
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            }];
        }
    }];
    
//    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
//    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    
    //We have to make sure that the Background App Refresh is enable for the Location updates to work in the background.
    if([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusDenied){
        
        [self showAlertWithMessage:@"The app doesn't work without the Background App Refresh enabled. To turn it on, go to Settings > General > Background App Refresh" andTitle:@"" andBtnTitle:@"OK"];
        
    }
    else if ([[UIApplication sharedApplication] backgroundRefreshStatus] == UIBackgroundRefreshStatusRestricted)
    {
        [self showAlertWithMessage:@"The functions of this app are limited because the Background App Refresh is disable." andTitle:@"" andBtnTitle:@"OK"];
    }
    else
    {
        // NSLocationAlwaysUsageDescription
        
        self.locationTracker = [[LocationTracker alloc]init];
        [self.locationTracker startLocationTracking];
        
        //Send the best location to server every 60 seconds
        //You may adjust the time interval depends on the need of your app.
        
        NSTimeInterval time = 1.5;
        self.locationUpdateTimer =
        [NSTimer scheduledTimerWithTimeInterval:time
                                         target:self
                                       selector:@selector(updateLocation)
                                       userInfo:nil
                                        repeats:YES];
    }
    
    
    iToastSettings *toastSettings = [iToastSettings getSharedSettings];
    
    [toastSettings setGravity:iToastGravityNone];
    toastSettings.postition = CGPointMake(screen_width/2,screen_height - 100);
    toastSettings.useShadow = NO;
    toastSettings.fontSize = 14;
    toastSettings.imageLocation = iToastImageLocationTop;
    toastSettings.duration = 2300;
    
    //    loaderView = [[CustomLoaderView alloc] initWithFrame:CGRectZero andType:1];
    //    loaderView.loaderText = @"Loading ...";
    //    loaderView.frame = self.window.rootViewController.view.frame;
    //    [self.window.rootViewController.view addSubview:loaderView];
    //    loaderView.hidden =YES;
    
    EmptyViewController *empty = [[EmptyViewController alloc]initWithNibName:@"EmptyViewController" bundle:nil];
    self.window.rootViewController = empty;
    [self.window addSubview:empty.view];
    
    self.HUD = [[MBProgressHUD alloc] initWithWindow:self.window];
    self.HUD.mode = MBProgressHUDModeCustomView;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 80)];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"loader_gif" withExtension:@"gif"];
    //NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *animatedImage = [UIImage animatedImageWithAnimatedGIFURL:url];
    imageView.image = animatedImage;
    //self.HUD.dimBackground = YES;
    self.HUD.customView = imageView;
    self.HUD.color = [UIColor clearColor];
    self.HUD.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.6];
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    self.HUD.delegate = self;
    //self.HUD.labelText = @"Loading";
    [self.window addSubview:self.HUD];
    
    
    //login
    // EMIT connect piingob  //  params - uid, t, lat, lon
    
    
    //updateorderstatusbypiingocheckin
    // EMIT piingob checkin  //  params - uid, t, lat, lon
    
    
    // Logout
    // EMIT piingob checkout  //  params - uid, t, lat, lon
    
    
    //When ever piingostartorder service calls
    // EMIT  piingob startorder  // params - uid, t, lat, lon, orderId
    
    
    //When ever piingoatthedoor service calls
    // EMIT  piingob atthedoor  // params - uid, t, lat, lon, orderId
    
    
    //When ever confirmorder service calls
    // EMIT  piingob finishorder  // params - uid, t, lat, lon, orderId
    
    
    // ON  piingob taskupdate  // params - uid, t, lat, lon, orderId  // response {s, message }
    
    
    //When ever login and for track service calls
    // EMIT  piingob track  // params - uid, t, lat, lon, orderId
    
    
    
    //    [SIOSocket socketWithHost: @"http://52.74.59.25:9009" response: ^(SIOSocket *socket)
    //     {
    //         self.socket = socket;
    //
    //         __weak typeof(self) weakSelf = self;
    //         self.socket.onConnect = ^()
    //         {
    //             DLog(@"Connected");
    //             weakSelf.socketIsConnected = YES;
    //         };
    //
    //         [self.socket on: @"join" callback: ^(SIOParameterArray *args)
    //          {
    //              DLog(@"Join");
    //          }];
    //
    //         [self.socket on: @"update" callback: ^(SIOParameterArray *args)
    //          {
    //              DLog(@"update");
    //
    //          }];
    //
    //         [self.socket on: @"disappear" callback: ^(SIOParameterArray *args)
    //          {
    //              DLog(@"disappear");
    //
    //              NSString *pinID = [args firstObject];
    //
    //              DLog(@"%@",pinID);
    //
    //          }];
    //     }];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:PID])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PID];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"userEmail"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userEmail"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN])
    {
        //[[NSUserDefaults standardUserDefaults] setObject:@"rfIJlk22kds" forKey:PIINGO_TOEKN];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"piingoFirstName"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoFirstName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"piingoLastName"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoLastName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"piingoImageURL"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoImageURL"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"piingoMobileNumber"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoMobileNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    //[[NSUserDefaults standardUserDefaults] setObject:@"rfIJlk22kds" forKey:PIINGO_TOEKN];//remove this
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:77.0/255.0 green:77.0/255.0 blue:77.0/255.0 alpha:1.0], NSForegroundColorAttributeName, [UIFont fontWithName:APPFONT_REGULAR size:18.0], NSFontAttributeName, nil] forState:UIControlStateNormal];
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont fontWithName:APPFONT_REGULAR size:18.0], NSFontAttributeName, nil]];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"nav_bg3.png"] forBarMetrics:UIBarMetricsDefault];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:PID] length] > 0)
    {
        [self checkCheckinStatus];
        
        JobOrdersViewController *jobOrdersVC = [[JobOrdersViewController alloc] initWithNibName:@"JobOrdersViewController" bundle:nil];
        self.jobOrdersList = jobOrdersVC;
        
        MenuViewController *leftMenuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:jobOrdersVC];
        ListViewController *listVC = [[ListViewController alloc] init];
        
        sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                            leftMenuViewController:leftMenuViewController
                                                           rightMenuViewController:listVC];
        
        sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Stars"];
        sideMenuViewController.menuPreferredStatusBarStyle = 1;
        sideMenuViewController.delegate = self;
        sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
        sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
        sideMenuViewController.contentViewShadowOpacity = 0.3;
        sideMenuViewController.contentViewShadowRadius = 5;
        sideMenuViewController.contentViewShadowEnabled = YES;
        sideMenuViewController.parallaxEnabled = NO;
        
        self.window.rootViewController = sideMenuViewController;
        [self.window addSubview:sideMenuViewController.view];

    }
    else
    {
        LoginViewController *homeViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        
        UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:homeViewController];
        
        [self.window setRootViewController:rootNavController];
    }
    
    [self.window makeKeyAndVisible];
    
    //[self setWindow:window];
    return YES;
}


-(void)updateLocation
{    
    NSLog(@"updateLocation");
    
    //[self showAlertWithMessage:@"updagting location" andTitle:@"" andBtnTitle:@"OK"];
    
    [self.locationTracker updateLocationToServer];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:PID] length] > 0)
    {
        [dictSaveData removeObjectForKey:@"reachable"];
        
        [self connectPiingobWhenLogin];
    }
}


-(void) connectPiingobWhenLogin
{
    
    // Allocate a reachability object
    Reachability* reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Set the blocks
    reach.reachableBlock = ^(Reachability*reach)
    {
        // keep in mind this is called on a background thread
        // and if you are updating the UI it needs to happen
        // on the main thread, like this:
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"REACHABLE!");
            
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:PID] length])
            {
                return;
            }
            
            if ([[dictSaveData objectForKey:@"reachable"] isEqualToString:@"YES"])
            {
                return;
            }
            
            [dictSaveData setObject:@"YES" forKey:@"reachable"];
            
            
            if (!self.socketIO)
            {
                
                if ([dictSaveData objectForKey:@"socketentered"])
                {
                    return;
                }
                
                NSURL* url = [[NSURL alloc] initWithString:BASE_TRACKING_URL];
                
                SocketIOClient* socket = [[SocketIOClient alloc] initWithSocketURL:url config:nil];
                
                [dictSaveData setObject:@"YES" forKey:@"socketentered"];
                
                if (![dictSaveData objectForKey:@"connect"])
                {
                    
                    [socket on:@"connect" callback:^(NSArray* data, SocketAckEmitter* ack) {
                        
                        NSLog(@"socket connected");
                        
                        self.socketIO = ack.socket;
                        
                        if ([self.latitude length])
                        {
                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", self.strDeviceToken, @"deviceToken", @"IOS", @"deviceType", nil];
                            
                            [socket emitWithAck:@"connect piingob" with:@[dic]](0, ^(NSArray* data) {
                                
                                NSLog(@"connect piingob : %@", data);
                                
                                [dictSaveData setObject:@"connected" forKey:@"connect"];
                                
                                NSMutableDictionary *dictMagnetoValues = [[NSMutableDictionary alloc]init];
                                [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.xValue] forKey:@"x"];
                                [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.yValue] forKey:@"y"];
                                [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.zValue] forKey:@"z"];
                                
                                CGFloat directionValue = self.vehicle_direction;
                                
                                NSString *strDirectionVal = [NSString stringWithFormat:@"%f", directionValue];
                                
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", self.strDeviceToken, @"deviceToken", @"IOS", @"deviceType", dictMagnetoValues, @"ac", strDirectionVal, @"heading", nil];
                                
                                [self.socketIO emitWithAck:@"piingob track" with:@[dic]](0, ^(NSArray* data) {
                                    
                                    NSLog(@"piingob track : %@", data);
                                    
                                });
                            });
                        }
                    }];
                    
                    
                    [socket on:@"new order" callback:^(NSArray* data, SocketAckEmitter* ack) {
                        
                        
                        NSLog(@"socket connected for new order");
                        
                        if ([data count])
                        {
                            
                            NSLog(@"New Order Details : %@", data);
                            
                            NSDictionary *dicResponse = [data objectAtIndex:0];
                            
                            //[self.jobOrdersList getCurrentOrders];
                            
//                            NSURL *fileURL1 = [NSURL URLWithString:@"/System/Library/Audio/UISounds/ReceivedMessage.caf"]; // see list below
//                            SystemSoundID soundID;
//                            AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL1,&soundID);
//                            AudioServicesPlaySystemSound(soundID);
                            
                            [self playAudio:dicResponse];
                            
                            if ([self.latitude length])
                            {
                                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", [dicResponse objectForKey:@"orderId"], @"orderId", nil];
                                
                                [socket emitWithAck:@"piingob neworderconfirm" with:@[dic]](0, ^(NSArray* data) {
                                    
                                    NSLog(@"piingob neworderconfirm : %@", data);
                                    
                                });
                            }
                        }
                    }];
                    
                    
                    [socket on:@"Rescheduled" callback:^(NSArray* data, SocketAckEmitter* ack) {
                        
                        
                        NSLog(@"socket connected for Rescheduled");
                        
                        if ([data count])
                        {
                            
                            NSLog(@"Rescheduled Order Details : %@", data);
                            
                            NSDictionary *dicResponse = [data objectAtIndex:0];
                            
                            //[self.jobOrdersList getCurrentOrders];
                            
                            [self playAudio:dicResponse];
                        }
                    }];
                    
                    [socket on:@"Cancelled" callback:^(NSArray* data, SocketAckEmitter* ack) {
                        
                        
                        NSLog(@"socket connected for Cancelled");
                        
                        if ([data count])
                        {
                            
                            NSLog(@"Cancelled Order Details : %@", data);
                            
                            NSDictionary *dicResponse = [data objectAtIndex:0];
                            
                            //[self.jobOrdersList getCurrentOrders];
                            
                            [self playAudio:dicResponse];
                        }
                    }];
                    
                    
                    
                    
                    
                    
                    
                    //                    [socket on:@"reconnect" callback:^(NSArray* data, SocketAckEmitter* ack) {
                    //
                    //                        NSLog(@"socket re - connected");
                    //
                    //                       // self.socketIO = ack.socket;
                    //
                    //                        if ([self.latitude length])
                    //                        {
                    //                            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", nil];
                    //
                    //                            [socket emitWithAck:@"connect piingob" with:@[dic]](0, ^(NSArray* data) {
                    //
                    //                                NSLog(@"connect piingob : %@", data);
                    //
                    //                                [self.socketIO emitWithAck:@"piingob checkin" with:@[dic]](0, ^(NSArray* data) {
                    //
                    //                                    NSLog(@"piingob checkin : %@", data);
                    //
                    //                                    [self.socketIO emitWithAck:@"piingob track" with:@[dic]](0, ^(NSArray* data) {
                    //
                    //                                        NSLog(@"piingob track : %@", data);
                    //
                    //                                    });
                    //                                });
                    //                            });
                    //
                    //
                    //                        }
                    //                    }];
                }
                
                [socket connect];
                
            }
            else if (![dictSaveData objectForKey:@"connect"])
            {
                
                if ([self.latitude length] && self.socketIO)
                {
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", self.strDeviceToken, @"deviceToken", @"IOS", @"deviceType", nil];
                    
                    [self.socketIO emitWithAck:@"connect piingob" with:@[dic]](0, ^(NSArray* data) {
                        
                        NSLog(@"connect piingob : %@", data);
                        
                        [dictSaveData setObject:@"connected" forKey:@"connect"];
                        
                        NSMutableDictionary *dictMagnetoValues = [[NSMutableDictionary alloc]init];
                        [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.xValue] forKey:@"x"];
                        [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.yValue] forKey:@"y"];
                        [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.zValue] forKey:@"z"];
                        
                        CGFloat directionValue = self.vehicle_direction;
                        
                        NSString *strDirectionVal = [NSString stringWithFormat:@"%f", directionValue];
                        
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", self.strDeviceToken, @"deviceToken", @"IOS", @"deviceType", dictMagnetoValues, @"ac", strDirectionVal, @"heading", nil];
                        
                        [self.socketIO emitWithAck:@"piingob track" with:@[dic]](0, ^(NSArray* data) {
                            
                            NSLog(@"piingob track : %@", data);
                            
                        });
                    });
                }
            }
            
            else if ([dictSaveData objectForKey:@"connect"])
            {
                NSMutableDictionary *dictMagnetoValues = [[NSMutableDictionary alloc]init];
                [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.xValue] forKey:@"x"];
                [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.yValue] forKey:@"y"];
                [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.zValue] forKey:@"z"];
                
                CGFloat directionValue = self.vehicle_direction;
                
                NSString *strDirectionVal = [NSString stringWithFormat:@"%f", directionValue];
                
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", self.strDeviceToken, @"deviceToken", @"IOS", @"deviceType", dictMagnetoValues, @"ac", strDirectionVal, @"heading", nil];
                
                if (self.socketIO)
                {
                    [self.socketIO emitWithAck:@"piingob track" with:@[dic]](0, ^(NSArray* data) {
                        
                        NSLog(@"piingob track : %@", data);
                        
//                        if (self.piingo_GoogleMap && [self.dict_UserLocation objectForKey:@"lat"])
//                        {
//                            [self refreshGoogleMapsDirections];
//                        }
                        
                    });
                }
            }
        });
    };
    
    reach.unreachableBlock = ^(Reachability*reach)
    {
        NSLog(@"UNREACHABLE!");
        
        [dictSaveData setObject:@"NO" forKey:@"reachable"];
        
    };
    
    // Start the notifier, which will cause the reachability object to retain itself!
    [reach startNotifier];
    
}

-(void) playAudio:(NSDictionary *) dicResponse
{
    notificationcame = YES;
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    NSLog(@"Activating audio session");
    if (![audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:&error]) {
        NSLog(@"Unable to set audio session category: %@", error);
    }
    BOOL result = [audioSession setActive:YES error:&error];
    if (!result) {
        NSLog(@"Error activating audio session: %@", error);
    }
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    
    
    //start a background sound
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"notification_sound" ofType: @"mp3"];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
    
    if (!myAudioPlayer)
    {
        myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    }
    
    myAudioPlayer.numberOfLoops = -1; //infinite loop
    [myAudioPlayer prepareToPlay];
    [myAudioPlayer play];
    
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@""
                                 message:[dicResponse objectForKey:@"message"]
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [myAudioPlayer stop];
                             
                             AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                             NSError *error = nil;
                             NSLog(@"Deactivating audio session");
                             BOOL result = [audioSession setActive:NO error:&error];
                             if (!result) {
                                 NSLog(@"Error deactivating audio session: %@", error);
                             }
                             
                             notificationcame = NO;
                             
                             UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
                             NSArray *controllers = [NSArray arrayWithObject:self.jobOrdersList];
                             navigationController.viewControllers = controllers;
                             
                             [self.sideMenuViewController hideMenuViewController];
                             
                             [self.jobOrdersList getCurrentOrders];
                             
                         }];
    
    [alert addAction:ok];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:alert animated:YES completion:nil];
}

-(void) refreshGoogleMapsDirections
{
    
//    [self.piingo_GoogleMap getDirectionRoutesFrom:[NSString stringWithFormat:@"%lf,%lf", [self.latitude doubleValue], [self.longitude doubleValue]] to:[NSString stringWithFormat:@"%lf,%lf", [[self.dict_UserLocation objectForKey:@"lat"] doubleValue], [[self.dict_UserLocation objectForKey:@"lon"] doubleValue]] withTravelMode:@"driving" andWithUsingWaypoints:nil];
    
    [self.piingo_GoogleMap getDirectionRoutesFrom:[NSString stringWithFormat:@"%lf,%lf", [self.latitude doubleValue], [self.longitude doubleValue]] to:[NSString stringWithFormat:@"%lf,%lf", [[self.dict_UserLocation objectForKey:@"lat"] doubleValue], [[self.dict_UserLocation objectForKey:@"lon"] doubleValue]] withTravelMode:@"driving" andWithUsingWaypoints:nil];
}

+(CGFloat) getLabelHeightForSemiBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_SEMI_BOLD size:fontSize] } context:nil].size;
    
    return size.height;
}

+(CGFloat) getLabelHeightForBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:fontSize] } context:nil].size;
    
    return size.height;
}

+(CGFloat) getLabelHeightForMediumText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:fontSize] } context:nil].size;
    
    return size.height;
}


+(CGFloat) getLabelHeightForRegularText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:fontSize] } context:nil].size;
    
    return size.height;
}


+(CGSize) getLabelSizeForSemiBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_SEMI_BOLD size:fontSize] } context:nil].size;
    
    return size;
}

+(CGSize) getLabelSizeForBoldText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_BOLD size:fontSize] } context:nil].size;
    
    return size;
}

+(CGSize) getLabelSizeForRegularText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_REGULAR size:fontSize] } context:nil].size;
    
    return size;
}

+(CGSize) getLabelSizeForMediumText:(NSString *)strText WithWidth:(CGFloat)width FontSize:(CGFloat)fontSize
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{ NSFontAttributeName:[UIFont fontWithName:APPFONT_MEDIUM size:fontSize] } context:nil].size;
    
    return size;
}

+(CGSize) getAttributedTextHeightForText:(NSMutableAttributedString *)strText WithWidth:(CGFloat)width
{
    CGSize size = [strText boundingRectWithSize:CGSizeMake(width, FLT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin) context:nil].size;
    
    return size;
}



-(void) applyBlurEffectForView:(UIView *)vieww Style:(NSString *)style
{
    UIBlurEffect *blurEffect;
    
    if ([style caseInsensitiveCompare:BLUR_EFFECT_STYLE_DARK] == NSOrderedSame)
    {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    else if ([style caseInsensitiveCompare:BLUR_EFFECT_STYLE_LIGHT] == NSOrderedSame)
    {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    }
    else if ([style caseInsensitiveCompare:BLUR_EFFECT_STYLE_EXTRA_LIGHT] == NSOrderedSame)
    {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    }
    
    UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    bluredEffectView.tag = 987654;
    bluredEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [bluredEffectView setFrame:vieww.bounds];
    
    // Vibrancy Effect
    
    //    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    //    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    //    [vibrancyEffectView setFrame:vieww.bounds];
    //
    //    // Add Vibrancy View to Blur View
    //    [bluredEffectView.contentView addSubview:vibrancyEffectView];
    
    bluredEffectView.alpha = 1.0;
    [vieww addSubview:bluredEffectView];
    [vieww sendSubviewToBack:bluredEffectView];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

-(void)displayErrorMessagErrorResponse:(NSDictionary *)response {
    
    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:self withObject:nil];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        if ([[response objectForKey:@"error"] length])
        {
            [self showAlertWithMessage:[response objectForKey:@"error"] andTitle:@"" andBtnTitle:@"OK"];
            
            if([[response objectForKey:@"s"] intValue] == 100)
            {
                [self staticLogout];
            }
        }
        else if([[response objectForKey:@"s"] intValue] == 1)
        {
            [self showAlertWithMessage:@"Data Processing Failed." andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 2)
        {
            [self showAlertWithMessage:@"Email Doesn't Exists" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 3)
        {
            [self showAlertWithMessage:@"Email Already Exists" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 4)
        {
            [self showAlertWithMessage:@"Mobile Number Already Exists" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 5)
        {
            [self showAlertWithMessage:@"Zone Change while updating Address" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 6)
        {
            [self showAlertWithMessage:@"Today is Pickup or Delivery Date Address Update Not Allowed" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 7)
        {
            [self showAlertWithMessage:@"Current Password Doesn't Exists" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 8)
        {
            [self showAlertWithMessage:@"Error while saving data" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 9)
        {
            [self showAlertWithMessage:@"Error while saving data" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 10)
        {
            [self showAlertWithMessage:@"Invalid Input." andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 11)
        {
            [self showAlertWithMessage:@"Referral Code Is Invalid" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 12)
        {
            [self showAlertWithMessage:@"Already registered with this Email Id and activation process is not completed" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 13)
        {
            [self showAlertWithMessage:@"Restriction for Registration with single device more than 3 Times" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 14)
        {
            [self showAlertWithMessage:@"Guest Order Details Saved Successfully" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 15)
        {
            [self showAlertWithMessage:@"Order Already Confirmed" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 17)
        {
            [self showAlertWithMessage:@"Currently there are no piingo available for this zone" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 21)
        {
            [self showAlertWithMessage:@"Card Details does not exist" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 22)
        {
            [self showAlertWithMessage:@"Piingo Id Doesn't Exists" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 23)
        {
            [self showAlertWithMessage:@"Order Doesn't Exists With This Cobid" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 24)
        {
            [self showAlertWithMessage:@"Promocode Does Not Exist" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 25)
        {
            [self showAlertWithMessage:@"ManualTagNo Does Not Exist" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 50)
        {
            [self showAlertWithMessage:@"Please enter valid Verification code" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 51)
        {
            [self showAlertWithMessage:@"Activation Code Expired" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 52)
        {
            [self showAlertWithMessage:@"Zip Code does not exists/ not found" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 53)
        {
            [self showAlertWithMessage:@"Account Not Activated" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 54)
        {
            [self showAlertWithMessage:@"Aname Already Exists" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 55)
        {
            [self showAlertWithMessage:@"Account doesn't exists with this User Id" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 100)
        {
            [self showAlertWithMessage:@"Invalid Token." andTitle:nil andBtnTitle:@"OK"];
            [self staticLogout];
        }
        else if([[response objectForKey:@"s"] intValue] == 101)
        {
            [self showAlertWithMessage:@"Error Response from CSS from client order booking" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 102)
        {
            [self showAlertWithMessage:@"Service Denied Details from CSS" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 103)
        {
            [self showAlertWithMessage:@"Confirm Book Now Failed Due to Internal Error in CSS Way Points" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 104)
        {
            [self showAlertWithMessage:@"Error Response from CSS from clientorderdetails" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if([[response objectForKey:@"s"] intValue] == 105)
        {
            [self showAlertWithMessage:@"Error Response from CSS from update client order booking" andTitle:@"" andBtnTitle:@"OK"];
        }
        else if (response == nil)
        {
            //[self showAlertWithMessage:@"The Internet connection appears to be offline." andTitle:@"" andBtnTitle:@"OK"];
            
            [self showAlertWithMessage:@"Oops! Something tore. We are working on it right now. Please check back." andTitle:@"" andBtnTitle:@"OK"];
            
        }
        
    }];
}

- (void)showAlertWithMessage:(NSString *)msg andTitle:(NSString *)title andBtnTitle:(NSString *)btnTitle{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alertController addAction:defaultAction];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:alertController animated:YES completion:nil];
}

+ (void)showAlertWithMessage:(NSString *)msg andTitle:(NSString *)title andBtnTitle:(NSString *)btnTitle{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alertController addAction:defaultAction];
    
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    while (topController.presentedViewController)
    {
        topController = topController.presentedViewController;
    }
    
    [topController presentViewController:alertController animated:YES completion:nil];
}


-(void)registerDeviceForPNSWithDevToken
{
    NSLog(@"registerDeviceForPNSWithDevToken %@",self.strDeviceToken);
    
    if ([self.strDeviceToken length] > 0 && [[[NSUserDefaults standardUserDefaults] objectForKey:PID] length] > 0)
    {
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"IOS", @"deviceType", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.strDeviceToken, @"deviceToken", [[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/registerdevice", BASE_URL];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dic andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            if([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1) {
                
                //[self showAlertWithMessage:@"saved Device token" andTitle:@"" andBtnTitle:@"OK"];
                
                NSLog(@"stored device token in service");
            }
            else {
                
                //[self showAlertWithMessage:@"Not saved Device token" andTitle:@"" andBtnTitle:@"OK"];
                
                NSLog(@"failed to store device token in service");
                
            }
        }];
    }
    else
    {
        //[self showAlertWithMessage:@"Method not called. Device token" andTitle:@"" andBtnTitle:@"OK"];
    }
}


#pragma mark Remote notifications Start of APNS

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    NSString *devTokenStr = [devToken description];
    devTokenStr = [devTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    devTokenStr = [devTokenStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
    devTokenStr = [devTokenStr stringByReplacingOccurrencesOfString:@">" withString:@""];
    
    self.strDeviceToken = devTokenStr;
    
    //[self showAlertWithMessage:self.strDeviceToken andTitle:@"" andBtnTitle:@"OK"];
}


-(void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    if ([userInfo objectForKey:@"aps"])
    {
        if (!notificationcame)
        {
            NSDictionary *dictDetail = [userInfo objectForKey:@"aps"];
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@""
                                         message:[dictDetail objectForKey:@"alert"]
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction
                                 actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [myAudioPlayer stop];
                                     
                                     AVAudioSession *audioSession = [AVAudioSession sharedInstance];
                                     NSError *error = nil;
                                     NSLog(@"Deactivating audio session");
                                     BOOL result = [audioSession setActive:NO error:&error];
                                     if (!result) {
                                         NSLog(@"Error deactivating audio session: %@", error);
                                     }
                                     
                                     UINavigationController *navigationController = (UINavigationController *) self.sideMenuViewController.contentViewController;
                                     NSArray *controllers = [NSArray arrayWithObject:self.jobOrdersList];
                                     navigationController.viewControllers = controllers;
                                     
                                     [self.sideMenuViewController hideMenuViewController];
                                     
                                     [self.jobOrdersList getCurrentOrders];
                                     
                                 }];
            
            [alert addAction:ok];
            
            UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
            
            while (topController.presentedViewController)
            {
                topController = topController.presentedViewController;
            }
            
            [topController presentViewController:alert animated:YES completion:nil];
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //    if (locationUpdateTimer)
    //    {
    //        if ([locationUpdateTimer isValid])
    //        {
    //            [locationUpdateTimer invalidate];
    //            locationUpdateTimer = nil;
    //        }
    //    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //    if (locationUpdateTimer)
    //    {
    //        if ([locationUpdateTimer isValid])
    //        {
    //            [locationUpdateTimer invalidate];
    //            locationUpdateTimer = nil;
    //        }
    //    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //    if (!locationUpdateTimer)
    //    {
    //        if ([[[NSUserDefaults standardUserDefaults] objectForKey:PID] length] > 0)
    //        {
    //            [self updateLatLngToServer];
    //
    //            locationUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateLatLngToServer) userInfo:nil repeats:YES];
    //        }
    //    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"registerDeviceForPNSWithDevToken" object:nil];
    
    [self.socketIO disconnect];
    
    //    if (locationUpdateTimer)
    //    {
    //        if ([locationUpdateTimer isValid])
    //        {
    //            [locationUpdateTimer invalidate];
    //            locationUpdateTimer = nil;
    //        }
    //    }
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "shahsank.PiingApp" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PiingApp" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PiingApp.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}
#pragma mark CustomLoade Methods
-(void) showLoader{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.window addSubview:self.HUD];
        [self.window bringSubviewToFront:self.HUD];
        [self.HUD show:NO];
        
    }];
    
}

-(void)hideLoader{
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self.HUD hide:NO];
        
    }];
}

#pragma mark UIControlMethods
-(void) setRootVC
{
    [self checkCheckinStatus];
    
    [self connectPiingobWhenLogin];
    
    JobOrdersViewController *jobOrdersVC = [[JobOrdersViewController alloc] initWithNibName:@"JobOrdersViewController" bundle:nil];
    self.jobOrdersList = jobOrdersVC;
    
    UINavigationController *myNavCon = (UINavigationController*)self.window.rootViewController;
    [myNavCon popToRootViewControllerAnimated:YES];
    
    MenuViewController *leftMenuViewController = [[MenuViewController alloc] initWithNibName:@"MenuViewController" bundle:nil];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:jobOrdersVC];
    ListViewController *listVC = [[ListViewController alloc] init];
    
    sideMenuViewController = [[RESideMenu alloc] initWithContentViewController:navigationController
                                                        leftMenuViewController:leftMenuViewController
                                                       rightMenuViewController:listVC];
    
    sideMenuViewController.backgroundImage = [UIImage imageNamed:@"Stars"];
    sideMenuViewController.menuPreferredStatusBarStyle = 1;
    sideMenuViewController.delegate = self;
    sideMenuViewController.contentViewShadowColor = [UIColor blackColor];
    sideMenuViewController.contentViewShadowOffset = CGSizeMake(0, 0);
    sideMenuViewController.contentViewShadowOpacity = 0.3;
    sideMenuViewController.contentViewShadowRadius = 5;
    sideMenuViewController.contentViewShadowEnabled = YES;
    sideMenuViewController.parallaxEnabled = NO;
    
    self.window.rootViewController = sideMenuViewController;
    [self.window addSubview:sideMenuViewController.view];
    
}

-(RESideMenu *)sideMenuViewController {
    
    if([self.window.rootViewController isKindOfClass:[RESideMenu class]])
        return (RESideMenu *)self.window.rootViewController;
    
    return nil;
}


#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    DLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    DLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    DLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    DLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}


-(void) piingoLogout
{
    self.isFirstTimeConnected = NO;
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:self withObject:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/piingo/logout", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:self withObject:nil];
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            [self staticLogout];
        }
        else
        {
            [self displayErrorMessagErrorResponse:responseObj];
        }
        
    }];
    
}

-(void) staticLogout
{
    
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", nil];
//    
//    if (self.socketIO)
//    {
//        [self.socketIO emitWithAck:@"piingob checkout" with:@[dic]](0, ^(NSArray* data) {
//            
//            NSLog(@"piingob checkout : %@", data);
//            
//            [self.socketIO disconnect];
//            self.socketIO = nil;
//            
//            [dictSaveData removeAllObjects];
//            
//            //        [self.locationUpdateTimer invalidate];
//            //        self.locationUpdateTimer = nil;
//        });
//    }
    
    /////
    
    [self.socketIO disconnect];
    self.socketIO = nil;
    
    [dictSaveData removeAllObjects];
    
    /////
    
    self.isFirstTimeConnected = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"checkInStatus"];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PID];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"userEmail"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:PIINGO_TOEKN];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoFirstName"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoLastName"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoImageURL"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"piingoMobileNumber"];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Scroll_Horizantal"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    LoginViewController *loginVC = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    UINavigationController *rootNavController = [[UINavigationController alloc] initWithRootViewController:loginVC];
     
    self.window.rootViewController = rootNavController;
}

#pragma mark call Support Methods
-(void) callSupportMethodClicked
{
    UIDevice *device = [UIDevice currentDevice];
    
    if ([[device model] isEqualToString:@"iPhone"] && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
    {
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:@"+6568014548"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        
    } else {
        
        [self showAlertWithMessage:@"Your device doesn't support this feature." andTitle:@"" andBtnTitle:@"OK"];
    }
}
#pragma mark SMS Support Methods
-(void) smsSupportClicked
{
    [self showSMS:@"Test"];
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            [self showAlertWithMessage:@"Failed to send SMS!" andTitle:@"Error" andBtnTitle:@"OK"];
            
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    
    [self.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}
- (void)showSMS:(NSString*)file {
    
    if(![MFMessageComposeViewController canSendText]) {
        
        [self showAlertWithMessage:@"Your device doesn't support SMS!" andTitle:@"Error" andBtnTitle:@"OK"];
        return;
    }
    
    NSArray *recipents = @[@"12345678", @"72345524"];
    NSString *message = [NSString stringWithFormat:@"Just sent the %@ file to your email. Please check!", file];
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipents];
    [messageController setBody:message];
    
    // Present message view controller on screen
    [self.window.rootViewController presentViewController:messageController animated:YES completion:nil];
}
-(void) updateLatLngToServer
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:PID] length] > 0)
    {
        if ([self.latitude length])
        {
            NSMutableDictionary *dictMagnetoValues = [[NSMutableDictionary alloc]init];
            [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.xValue] forKey:@"x"];
            [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.yValue] forKey:@"y"];
            [dictMagnetoValues setObject:[NSString stringWithFormat:@"%f", self.zValue] forKey:@"z"];
            
            CGFloat directionValue = self.vehicle_direction;
            
            NSString *strDirectionVal = [NSString stringWithFormat:@"%f", directionValue];
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"uid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", self.latitude, @"lat", self.longitude, @"lon", self.strDeviceToken, @"deviceToken", @"IOS", @"deviceType", dictMagnetoValues, @"ac", strDirectionVal, @"heading", nil];
            
            if (self.socketIO)
            {
                [self.socketIO emitWithAck:@"piingob track" with:@[dic]](0, ^(NSArray* data) {
                    
                    NSLog(@"piingob track : %@", data);
                    
                });
            }
        }
    }
}


-(void)receivedResponse:(id) response
{
    DLog(@"AppDel Response RegisterDevice %@",response);
}


-(void) checkCheckinStatus
{
    NSString *versionNumber = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID], @"pid", [[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN], @"t", versionNumber, @"ver", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@piingoapp/piingo/checkshift", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] intValue] == 1)
        {
            if ([[responseObj objectForKey:@"status"] intValue] == 1)
            {
                [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"checkInStatus"];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"checkInStatus"];
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] isEqualToString:@"0"])
            {
                self.checkInSwitch.enabled = NO;
                [self.checkInSwitch setOn:YES];
            }
            else
            {
                self.checkInSwitch.enabled = YES;
                [self.checkInSwitch setOn:NO];
            }
        }
        else
        {
            //[[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"checkInStatus"];
            
            [self displayErrorMessagErrorResponse:responseObj];
        }
    }];
}


-(void) spacingForTitle:(UILabel *)lblTitle TitleString:(NSString *)strTitle
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strTitle];
    
    float spacing = 2.0f;
    [attributedString addAttribute:NSKernAttributeName
                             value:@(spacing)
                             range:NSMakeRange(0, [strTitle length])];
    
    lblTitle.attributedText = attributedString;
}

-(void) applyCustomBlurEffetForView:(UIView *) view WithBlurRadius:(float)radius
{
    FXBlurView *blurEffect = [[FXBlurView alloc]initWithFrame:view.bounds];
    blurEffect.tag = 98765;
    blurEffect.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurEffect.tintColor = [UIColor blackColor];
    blurEffect.blurRadius = radius;
    blurEffect.dynamic = NO;
    [view addSubview:blurEffect];
    //[blurEffect setNeedsDisplay];
    
    //[view sendSubviewToBack:blurEffect];
    
    //    [UIView animateWithDuration:0.2 delay:0.0 options:0 animations:^{
    //
    //        [blurEffect setNeedsDisplay];
    //
    //    } completion:^(BOOL finished) {
    //
    //
    //    }];
    
    //    [blurEffect updateAsynchronously:YES completion:^{
    //        
    //        
    //    }];
}

//-(void) checkCheckinStatus
//{
//    NSDate *date = [NSDate date];
//    
//    NSDateFormatter *df = [[NSDateFormatter alloc]init];
//    [df setDateFormat:@"dd-MM-yyyy"];
//    NSString *strDate = [df stringFromDate:date];
//    
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:PID]] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"IS_TODAY_CHECKEDIN"] isEqualToString:strDate])
//    {
//        [self.checkInSwitch setOn:YES];
//        self.checkInSwitch.enabled = NO;
//    }
//    else
//    {
//        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PID],@"pid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
//        
//        NSString *urlStr = [NSString stringWithFormat:@"%@piingocheckinstatus/services.do?", BASE_URL];
//        
//        for (NSString *key in [dict allKeys])
//        {
//            NSString *value = [dict objectForKey:key];
//            
//            urlStr = [urlStr stringByAppendingFormat:@"&%@=%@",key,value];
//        }
//        
//        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"GET" withDetailsDictionary:nil andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
//            
//            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] caseInsensitiveCompare:@"y"] == NSOrderedSame)
//            {
//                if ([[responseObj objectForKey:@"checkinstatus"] caseInsensitiveCompare:@"y"] == NSOrderedSame)
//                {
//                    [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:PID] forKey:@"checkInStatus"];
//                }
//                else
//                {
//                    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"checkInStatus"];
//                }
//                
//                [[NSUserDefaults standardUserDefaults] setObject:strDate forKey:@"IS_TODAY_CHECKEDIN"];
//                
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//                if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"checkInStatus"] boolValue])
//                {
//                    self.checkInSwitch.enabled = NO;
//                    [self.checkInSwitch setOn:YES];
//                }
//                else
//                {
//                    self.checkInSwitch.enabled = YES;
//                    [self.checkInSwitch setOn:NO];
//                }
//            }
//            else
//            {
//                //[[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"checkInStatus"];
//                
//                [self displayErrorMessagErrorResponse:responseObj];
//            }
//        }];
//    }
//}


+(BOOL) validateTextFieldWithText :(NSString*)text With:(NSString*)validateText  {
    
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", validateText];
    return [test evaluateWithObject:text];
}



#pragma mark UUID Related
+ (NSString *)GetUUID{
    NSString *uuid;
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    
    uuid = (__bridge NSString *)string;
    
    [SSKeychain setPassword:uuid forService:@"com.piing.piingo" account:@"Piingo"];
    return uuid ;
}
@end
