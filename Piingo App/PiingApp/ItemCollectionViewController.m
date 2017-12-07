//
//  ItemCollectionViewController.m
//  PiingApp
//
//  Created by SHASHANK on 25/04/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "ItemCollectionViewController.h"
#import "ItemCollectionViewCell.h"
#import "NSNull+JSON.h"


@interface ItemCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *isAnyItemsArray;
    UIBarButtonItem *updateBarBtn;
    
    AppDelegate *appDel;
    
    NSMutableArray *arrayChanges;
}
@end

@implementation ItemCollectionViewController
@synthesize selecteItemisedArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    self.view.backgroundColor = [UIColor colorWithRed:239.0/255.0 green:239.0/255.0 blue:239.0/255.0 alpha:1.0];
    self.title = @"Item details";
    
    arrayChanges = [[NSMutableArray alloc]init];
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake((screen_width-40.0)/3.0, 50);
    //    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    UICollectionView *itemCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 80.0, screen_width-20, screen_height-80.0) collectionViewLayout:flowLayout];
    itemCollectionView.delegate = self;
    itemCollectionView.dataSource = self;
    itemCollectionView.backgroundColor = [UIColor clearColor];
    itemCollectionView.backgroundView = nil;
    [itemCollectionView registerClass:[ItemCollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:itemCollectionView];
    
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 30, 30);
    [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setImage:[UIImage imageNamed:@"back_btn"] forState:UIControlStateNormal];
    
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    updateBtn.frame = CGRectMake(0, 0, 80, 30);
    updateBtn.backgroundColor = [UIColor clearColor];
    updateBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [updateBtn addTarget:self action:@selector(updateBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [updateBtn setTitleColor:[UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [updateBtn setTitle:@"Update" forState:UIControlStateNormal];
    [updateBtn setTitleColor:[[UIColor colorWithRed:98.0/255.0 green:98.0/255.0 blue:98.0/255.0 alpha:1.0] colorWithAlphaComponent:0.8] forState:UIControlStateSelected];
    
    updateBarBtn = [[UIBarButtonItem alloc] initWithCustomView:updateBtn];
    UIBarButtonItem *backBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    self.navigationItem.backBarButtonItem = backBarBtn;
    self.navigationItem.rightBarButtonItem = updateBarBtn;
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [selecteItemisedArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    
    ItemCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    
    [cell setDetails:[selecteItemisedArray objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ItemCollectionViewCell *selectedCell = (ItemCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath];
    [selectedCell clickBtn];
    
    //self.navigationItem.rightBarButtonItem = updateBarBtn;
    
    if ([selectedCell getTickMarkStatus])
    {
        [[selecteItemisedArray objectAtIndex:indexPath.row] setValue:@"Y" forKey:@"selectedItem"];
        
        if (appDel.isPartialDelivery)
        {
            [[selecteItemisedArray objectAtIndex:indexPath.row] setValue:@"N" forKey:@"Partial"];
        }
        else if (appDel.isRewash)
        {
            [[selecteItemisedArray objectAtIndex:indexPath.row] setValue:@"N" forKey:@"Rewash"];
        }
        
        [arrayChanges removeObject:indexPath];
    }
    else
    {
        [[selecteItemisedArray objectAtIndex:indexPath.row] setValue:@"N" forKey:@"selectedItem"];
        
        if (appDel.isPartialDelivery)
        {
            [[selecteItemisedArray objectAtIndex:indexPath.row] setValue:@"Y" forKey:@"Partial"];
        }
        else if (appDel.isRewash)
        {
            [[selecteItemisedArray objectAtIndex:indexPath.row] setValue:@"Y" forKey:@"Rewash"];
        }
        
        [arrayChanges addObject:indexPath];
    }
    
//    if ([arrayChanges count])
//    {
//        self.navigationItem.rightBarButtonItem = updateBarBtn;
//    }
//    else
//    {
//        self.navigationItem.rightBarButtonItem = nil;
//    }
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark UIControl Actions
-(void) backBtnClicked
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) updateBtnClicked
{
    if ([self.delegate respondsToSelector:@selector(didUpdateToPartialDelivery:)])
    {
        [self.delegate didUpdateToPartialDelivery:selecteItemisedArray];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}


@end




