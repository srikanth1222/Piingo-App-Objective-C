//
//  ScanController.h
//  BarcodeScanner
//
//  Created by Vijay Subrahmanian on 09/05/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ScanViewControllerDelegate <NSObject>

-(void) didScanCompleteWithBagNo:(NSString *)strBag;

@end


@interface ScanViewController : UIViewController
{
    IBOutlet UITextField *tfManualBagId;
}

@property (weak, nonatomic) id <ScanViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isFromReceiveBag;
@property (nonatomic, strong) NSMutableArray *arrayTotalBags;
@property (nonatomic, strong) NSString *strOid;

@end
