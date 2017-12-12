//
//  PanicViewController.m
//  PiingApp
//
//  Created by SHASHANK on 08/03/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "PanicViewController.h"
#import "MultiplePulsingHaloLayer.h"

@interface PanicViewController ()
{
    MultiplePulsingHaloLayer *multiLayer;
}
@property (nonatomic, weak) MultiplePulsingHaloLayer *mutiHalo;

@end

@implementation PanicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Panic";
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupMenuBarButtonItems];

    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    animatedImageView.image = [UIImage imageNamed:@"app_bg"];
    [self.view addSubview: animatedImageView];
    
    UIView *bgImg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screen_width , screen_height)];
    bgImg.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.75];
    [self.view addSubview:bgImg];

//    UIImageView *iconImgview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
//    iconImgview.center = CGPointMake(screen_width/2, screen_height/2);
//    iconImgview.image = [UIImage imageNamed:@"emergencyBtnIcon1.gif"];
//    [self.view addSubview:iconImgview];
    
    UIButton *panicButton = [UIButton buttonWithType:UIButtonTypeCustom];
    panicButton.frame = CGRectMake(0, 0, 100, 100);
    panicButton.center = CGPointMake(screen_width/2, screen_height/2);
    [panicButton setBackgroundImage:[UIImage imageNamed:@"circle_green"] forState:UIControlStateNormal];
    [panicButton setBackgroundImage:[UIImage imageNamed:@"circle_red"] forState:UIControlStateSelected];
    [panicButton setBackgroundImage:[UIImage imageNamed:@"circle_green"] forState:UIControlStateHighlighted];
    [panicButton addTarget:self action:@selector(panicBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:panicButton];

    multiLayer = [[MultiplePulsingHaloLayer alloc] initWithHaloLayerNum:3 andStartInterval:1];
    self.mutiHalo = multiLayer;
    self.mutiHalo.position = panicButton.center;
    self.mutiHalo.useTimingFunction = NO;
    [self.mutiHalo buildSublayers];
    self.mutiHalo.radius = screen_width-50;
    //        [self.mutiHalo setHaloLayerColor:[[UIColor colorWithRed:.703 green:.703 blue:.703 alpha:1.0] colorWithAlphaComponent:0.8].CGColor];
    [self.mutiHalo setHaloLayerColor:[UIColor redColor].CGColor];
    [self.view.layer insertSublayer:self.mutiHalo below:panicButton.layer];
    
    multiLayer.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) panicBtnClicked:(UIButton *) sender
{
    sender.selected = !sender.selected;
    multiLayer.hidden = !sender.selected;
}
#pragma mark - UIBarButtonItems

- (void)setupMenuBarButtonItems {
//        self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
    if(self.menuContainerViewController.menuState == MFSideMenuStateClosed &&
       ![[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
        self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
    }
}

- (UIBarButtonItem *)leftMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithImage:[UIImage imageNamed:@"listButton"] style:UIBarButtonItemStylePlain
            target:self
            action:@selector(leftSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    return [[UIBarButtonItem alloc]
            initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(rightSideMenuButtonPressed:)];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStylePlain
                                           target:self
                                           action:@selector(backButtonPressed:)];
}


#pragma mark -
#pragma mark - UIBarButtonItem Callbacks

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)leftSideMenuButtonPressed:(id)sender {
    
    AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    [appDel.sideMenuViewController presentLeftMenuViewController];
}

- (void)rightSideMenuButtonPressed:(id)sender {
    
    AppDelegate *appDel = (AppDelegate *) [[UIApplication sharedApplication]delegate];
    [appDel.sideMenuViewController presentRightMenuViewController];
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
