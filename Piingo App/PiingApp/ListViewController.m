//
//  ListViewController.m
//  Piing
//
//  Created by Piing on 11/7/15.
//  Copyright © 2015 shashank. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()
{
    ListView *listView;
}
@end

@implementation ListViewController

-(instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self performSelector:@selector(view) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
        
    }
    
    return self;
    
}

-(void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    
    float someWidth = ([[UIScreen mainScreen] bounds].size.width-([[UIScreen mainScreen] bounds].size.width/1.2));
    
    listView = [[ListView alloc] initWithFrame:CGRectMake(screen_width/2-someWidth, 0.0, screen_width/2+someWidth, CGRectGetHeight(self.view.bounds)) andDisplayList:self.itemList];
    listView.delegate = self.delegate;
    
    listView.items = self.itemList;
    listView.isFrom = self.isFrom;
    
    [self.view addSubview:listView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    listView.items = self.itemList;
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    listView.items = self.itemList;
//to reload
}

-(void)setIsFrom:(NSString *)isFrom {
    _isFrom = isFrom;
    
    listView.isFrom = isFrom;
    
}

-(void)setItemList:(NSArray *)itemList {
    _itemList = itemList;
    
    listView.items = _itemList;
    
}

-(void)setSelectedItem:(NSString *)selectedItem {
    _selectedItem = selectedItem;
    listView.selectedItem = selectedItem;
    
}

-(void)setDelegate:(id)delegate {
    _delegate = delegate;
    
    listView.delegate = delegate;
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
