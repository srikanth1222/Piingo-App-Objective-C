//
//  MapOrdersViewController.m
//  PiingApp
//
//  Created by Veedepu Srikanth on 04/05/17.
//  Copyright © 2017 shashank. All rights reserved.
//

#import "MapOrdersViewController.h"
#import "AppDelegate.h"


@interface MapOrdersViewController ()
{
    GoogleMapView2 *addressMapView;
    
    NSMutableArray *arrayImages;
    AppDelegate *appDel;
}

@end

@implementation MapOrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    
    addressMapView = [[GoogleMapView2 alloc] initWithFrame:CGRectMake(0, 0, screen_width, screen_height)];
    addressMapView.delegate = self;
    [self.view addSubview:addressMapView];
    arrayImages = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < 10; i++)
    {
        NSMutableArray *array1 = [[NSMutableArray alloc]init];
        
        if (i == 0)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_black%d", j+1]];
            }
        }
        else if (i == 1)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_blue%d", j+1]];
            }
        }
        else if (i == 2)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_green%d", j+1]];
            }
        }
        else if (i == 3)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_grey%d", j+1]];
            }
        }
        else if (i == 4)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_icon1%d", j+1]];
            }
        }
        else if (i == 5)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_icon2%d", j+1]];
            }
        }
        else if (i == 6)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_icon3%d", j+1]];
            }
        }
        else if (i == 7)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_icon4%d", j+1]];
            }
        }
        else if (i == 8)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_icon5%d", j+1]];
            }
        }
        else if (i == 9)
        {
            for (int j = 0; j < 50; j++)
            {
                [array1 addObject:[NSString stringWithFormat:@"marker_icon6%d", j+1]];
            }
        }
        
        [arrayImages addObject:array1];
    }
    
    [addressMapView clearAllMarkers];
    
    [self loadLatandLongofAddresses];
}

-(void) loadLatandLongofAddresses
{
    for (int i=0; i<[self.arrOrders count]; i++)
    {
        NSDictionary *dictmain = [self.arrOrders objectAtIndex:i];
        
        NSArray *arrayMain = [dictmain objectForKey:@"ol"];
        
        NSArray *arrayImage = [arrayImages objectAtIndex:i];
        
        for (int j = 0; j < [arrayMain count]; j++)
        {
            NSDictionary *dict = [[[[dictmain objectForKey:@"ol"] objectAtIndex:j] objectForKey:@"currentAddress"] objectAtIndex:0];
            
            if ([[dict objectForKey:@"lat"] floatValue] != 0.0)
            {
             [addressMapView addMarker:[[NSDictionary alloc] initWithObjectsAndKeys:[dict objectForKey:@"lat"],@"lat",[dict objectForKey:@"lon"], @"lon", [arrayImage objectAtIndex:j], @"markImage", [dictmain objectForKey:@"slot"], @"timeslot", [[[dictmain objectForKey:@"ol"] objectAtIndex:j] objectForKey:@"oid"], @"oid", @"no",@"clearAll", nil] withIndex:1];
            }
        }
    }
    
    [addressMapView addMarker:[[NSDictionary alloc] initWithObjectsAndKeys:appDel.latitude, @"lat", appDel.longitude, @"lon", @"piingo_van", @"markImage", @"no", @"clearAll", nil] withIndex:1];
    
    [addressMapView focusMapToShowAllMarkers];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
