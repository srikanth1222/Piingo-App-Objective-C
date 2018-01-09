//
//  UpdatePaymentOrderViewController.m
//  PiingApp
//
//  Created by SHASHANK on 17/08/15.
//  Copyright (c) 2015 shashank. All rights reserved.
//

#import "UpdatePaymentOrderViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface UpdatePaymentOrderViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    UITableView *cardTableView;
    NSMutableArray *cardDetailsArray;
    
    AppDelegate *appDel;
    NSInteger selctedCC;
    NSInteger originalSelected;
    
    NSDictionary *orderDetailDic;
    
    UIBarButtonItem *updateEnable;
    UIBarButtonItem *updateDisable;
    
}
@property (nonatomic, strong) NSDictionary *orderDetailDic;

@end

@implementation UpdatePaymentOrderViewController

@synthesize orderDetailDic;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andIscurrentJobDetails:(id) jobDetails
{
    self = [super init];
    if (self) {
       
        self.orderDetailDic = jobDetails;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Payment Mode";
    
    selctedCC = 0;
    
    UIButton *upDateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    upDateBtn.frame = CGRectMake(0, 0, 60, 20);
    [upDateBtn addTarget:self action:@selector(updateBarBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    upDateBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
    upDateBtn.backgroundColor = [UIColor clearColor];
    [upDateBtn setTitle:@"Pay Now" forState:UIControlStateNormal];
    [upDateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    updateEnable = [[UIBarButtonItem alloc] initWithCustomView:upDateBtn];
    
    
    UIButton *upDateBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    upDateBtn1.frame = CGRectMake(0, 0, 60, 20);
    [upDateBtn1 addTarget:self action:@selector(updateBarBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    upDateBtn1.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
    upDateBtn1.backgroundColor = [UIColor clearColor];
    [upDateBtn1 setTitle:@"Pay Now" forState:UIControlStateNormal];
    [upDateBtn1 setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    updateDisable = [[UIBarButtonItem alloc] initWithCustomView:upDateBtn1];
    
    self.navigationItem.rightBarButtonItem = updateDisable;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    UIButton *cencelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cencelBtn.frame = CGRectMake(0, 0, 50, 20);
    [cencelBtn addTarget:self action:@selector(cancelBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    cencelBtn.titleLabel.font = [UIFont fontWithName:APPFONT_BOLD size:14.0];
    cencelBtn.backgroundColor = [UIColor clearColor];
    [cencelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cencelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [cencelBtn setImage:[UIImage imageNamed:@"add_card"] forState:UIControlStateNormal];
    
    UIBarButtonItem *cancelBarBtn = [[UIBarButtonItem alloc] initWithCustomView:cencelBtn];
    self.navigationItem.leftBarButtonItem = cancelBarBtn;
    
    cardDetailsArray = [[NSMutableArray alloc] init];
    appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    cardTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,screen_width, screen_height-64)];
    cardTableView.delegate = self;
    cardTableView.dataSource = self;
    cardTableView.separatorColor = [UIColor clearColor];
    cardTableView.backgroundColor = [UIColor clearColor];
    cardTableView.backgroundView = nil;
    cardTableView.separatorColor = [UIColor colorWithRed:203.0/255.0 green:203.0/255.0 blue:203.0/255.0 alpha:1.0];
    //    cardTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:cardTableView];


}
-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getSavedCards];
    
}
-(void) dismissVC
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void) getSavedCards
{
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    WebserviceMethods *weSer = [[WebserviceMethods alloc] init];
    
    [weSer sendAsynchronousRequestForComponent:@"getcards" methodName:@"/services.do" type:@"GET" parameters:[NSDictionary dictionaryWithObjectsAndKeys:[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t",[orderDetailDic objectForKey:@"uid"],@"uid", nil, nil] delegate:self];
}
-(void) receivedResponse:(id) response
{
    [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
    
    if ([[[response objectForKey:@"s"] lowercaseString] isEqualToString:@"y"])
    {
        [cardDetailsArray removeAllObjects];
        [cardDetailsArray addObjectsFromArray:[response objectForKey:@"cards"]];
        
        
        for (NSDictionary *dic in cardDetailsArray)
        {
            if ([[dic objectForKey:@"uucardid"] isEqualToString:[self.orderDetailDic objectForKey:@"carduid"]])
            {
                selctedCC = [cardDetailsArray indexOfObject:dic]+1;
                originalSelected = selctedCC;
            }
        }
        
        [cardTableView reloadData];
        
    }
    else
    {
        [AppDelegate showAlertWithMessage:[response objectForKey:@"e"] andTitle:@"Error" andBtnTitle:@"OK"];
    }
    
}
-(void) updateBarBtnClicked
{
    
    NSString *paymentType = selctedCC > 0 ? @"2":@"1";
    NSString *cardUUID = selctedCC > 0 ? [[cardDetailsArray objectAtIndex:selctedCC-1]objectForKey:@"uucardid"]:@"1";
    
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[orderDetailDic objectForKey:@"uid"],@"uid",cardUUID,@"uucardid",paymentType,@"ptid",[orderDetailDic objectForKey:@"cobid"],@"cobid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@updatecarddeatailsfororder/services.do?", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        {
            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] caseInsensitiveCompare:@"y"] == NSOrderedSame)
            {
                if (selctedCC == 0)
                {
                    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Update Success" message:@"Please collect the bill amount and confirm." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAc = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        if (selctedCC == 0)
                        {
                            [self cashPayment];
                        }
                        else
                        {
                            [self creditcardpayment];
                        }
                    }];
                    
                    [successAlert addAction:okAc];
                    [self presentViewController:successAlert animated:YES completion:nil];
                    
                }
                else
                {
                    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Update Success" message:@"Do you want to Re-conform the order?" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAc = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        if (selctedCC == 0)
                        {
                            [self cashPayment];
                        }
                        else
                        {
                            [self creditcardpayment];
                        }
                    }];
                    
                    UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                        [successAlert dismissViewControllerAnimated:YES completion:nil];
                        
                    }];
                    
                    [successAlert addAction:okAc];
                    [successAlert addAction:cancelAc];
                    
                    [self presentViewController:successAlert animated:YES completion:nil];
                }
            }
            else
            {
                if ([[responseObj objectForKey:@"e"] isEqual:@"28"])
                {
                    [AppDelegate showAlertWithMessage:@"Invalid Card number used OR card not found" andTitle:@"Error" andBtnTitle:@"OK"];
                    
                }
                else
                {
                    [AppDelegate showAlertWithMessage:@"Invalid Card number used OR card not found" andTitle:@"Error" andBtnTitle:@"OK"];
                }
            }
        }
    }];

}


-(void) cancelBtnClicked
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) cashPayment
{
    [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[orderDetailDic objectForKey:@"uid"],@"uid",@"D",@"s",[orderDetailDic objectForKey:@"cobid"],@"cobid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@deliverystatusupdate/services.do?", BASE_URL];
    
    [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
        
        [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
        
        {
            if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] caseInsensitiveCompare:@"y"] == NSOrderedSame)
            {
                UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Successfully Order Delivered" message:@"Please dont forget to collect the money" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *okAc = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    if ([self.delegate respondsToSelector:@selector(didConformPatyment)])
                    {
                        [self dismissViewControllerAnimated:YES completion:^{
                            
                            [self.delegate didConformPatyment];
                            
                        }];
                    }
                }];
                
                [successAlert addAction:okAc];
                [self presentViewController:successAlert animated:YES completion:nil];
            }
            else
            {
                //[appDel displayErrorMessagErrorResponse:responseObj];
                
                [AppDelegate showAlertWithMessage:@"Have some problem in conform the order please retry to conform." andTitle:@"Error" andBtnTitle:@"OK"];
                
            }
        }
    }];

}


-(void) creditcardpayment
{
    {
        
        [NSThread detachNewThreadSelector:@selector(showLoader) toTarget:appDel withObject:nil];
        
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[orderDetailDic objectForKey:@"uid"],@"uid",[orderDetailDic objectForKey:@"carduid"],@"uucardid",[self.strTotalAmount stringByReplacingOccurrencesOfString:@"$" withString:@""],@"amount",[orderDetailDic objectForKey:@"cobid"],@"cobid",[[NSUserDefaults standardUserDefaults] objectForKey:PIINGO_TOEKN],@"t", nil];
        
        NSString *urlStr = [NSString stringWithFormat:@"%@transactionbycardidbycobid/services.do?", BASE_URL];
        
        [WebserviceMethods sendRequestWithURLString:urlStr requestMethod:@"POST" withDetailsDictionary:dict andResponseCallBack:^(NSURLResponse *response, NSError *error, id responseObj) {
            
            [NSThread detachNewThreadSelector:@selector(hideLoader) toTarget:appDel withObject:nil];
            
            {
                if ([responseObj objectForKey:@"s"] && [[responseObj objectForKey:@"s"] caseInsensitiveCompare:@"y"] == NSOrderedSame)
                {
                    UIAlertController *successAlert = [UIAlertController alertControllerWithTitle:@"Successfully Order Delivered" message:@"Please dont forget to collect the money" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *okAc = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        if ([self.delegate respondsToSelector:@selector(didConformPatyment)])
                        {
                            [self dismissViewControllerAnimated:YES completion:^{
                                
                                [self.delegate didConformPatyment];
                                
                            }];
                        }
                    }];
                    
                    [successAlert addAction:okAc];
                    [self presentViewController:successAlert animated:YES completion:nil];
                }
                else
                {
                    [AppDelegate showAlertWithMessage:@"Please choose another payment mode" andTitle:@"Transaction Failed" andBtnTitle:@"OK"];
                    
                }
            }
            
        }];
        
    }
}


#pragma mark Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1+[cardDetailsArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    CellIdentifier = [NSString stringWithFormat:@"%ldCell",(long)indexPath.section];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
        cell.textLabel.textColor = [UIColor colorWithRed:82.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0];
    }
    
    if (selctedCC == indexPath.row )
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (indexPath.row == 0)
        cell.textLabel.text = @"Cash On Delivery";
    else
        cell.textLabel.text  = [[cardDetailsArray objectAtIndex:indexPath.row-1] objectForKey:@"maskednumber"];
    
    return cell;
    
    
}
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier;
//    CellIdentifier = [NSString stringWithFormat:@"%ldCell",(long)indexPath.section];
//    
//    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
//        
//        cell.backgroundColor = [UIColor colorWithRed:237.0/255.0 green:237.0/255.0 blue:237.0/255.0 alpha:0.6];
//        cell.layer.borderColor = [UIColor colorWithRed:222.0/255.0 green:222.0/255.0 blue:222.0/255.0 alpha:0.6].CGColor;
//        cell.layer.borderWidth = 1.0;
//        
//        UILabel *addressnameLbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 12.5, tableView.frame.size.width-35.0 - 15, 35.0)];
//        addressnameLbl.tag = 10;
//        addressnameLbl.numberOfLines = 2;
//        addressnameLbl.backgroundColor = [UIColor clearColor];
//        addressnameLbl.font = [UIFont fontWithName:APPFONT_REGULAR size:13.0];
//        addressnameLbl.textColor = [UIColor colorWithRed:82.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0];
//        [cell addSubview:addressnameLbl];
//        
//        UIImageView *defaultImage = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(addressnameLbl.frame), CGRectGetMinY(addressnameLbl.frame), 19, 19)];
//        defaultImage.tag = 11;
//        defaultImage.image = [UIImage imageNamed:@"uncheck"];
//        [cell addSubview:defaultImage];
//    }
//    UILabel *addressnameLbl = (UILabel *)[cell viewWithTag:10];
//    
//    //        CardIOCreditCardInfo *info = [cardDetailsArray objectAtIndex:indexPath.row];
//    
//    UIImageView *defaultImage = (UIImageView *)[cell viewWithTag:11];
//    
//    addressnameLbl.text = [NSString stringWithFormat:@"Number: %@\nexpiry: %@/%@", [[cardDetailsArray objectAtIndex:indexPath.row] objectForKey:@"maskednumber"],[[cardDetailsArray objectAtIndex:indexPath.row] objectForKey:@"expirymonth"], [[cardDetailsArray objectAtIndex:indexPath.row] objectForKey:@"expiryyear"]];
//    
// 
//        if (selctedCC == indexPath.row )
//            defaultImage.image = [UIImage imageNamed:@"check"];
//        else
//            defaultImage.image = [UIImage imageNamed:@"uncheck"];
//    
//    dispatch_async(kBgQueue, ^{
//        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[cardDetailsArray objectAtIndex:indexPath.row] objectForKey:@"expiryyear"]]];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            cell.imageView.image = [UIImage imageWithData:imgData];
//        });
//    });
//    
//    cell.accessoryView = defaultImage;
//    
//    return cell;
//    
//    
//}

#pragma mark TableView Delegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    selctedCC = indexPath.row;
    
    if (selctedCC == originalSelected)
    {
        self.navigationItem.rightBarButtonItem = updateDisable;
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    else
    {
        self.navigationItem.rightBarButtonItem = updateEnable;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0;
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
