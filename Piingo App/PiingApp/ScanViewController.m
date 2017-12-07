//
//  ScanController.m
//  BarcodeScanner
//
//  Created by Vijay Subrahmanian on 09/05/15.
//  Copyright (c) 2015 Vijay Subrahmanian. All rights reserved.
//

#import "ScanViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface ScanViewController () <AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate>
{
    AppDelegate *appDel;
    
    BOOL IsTfOpen;
}

@property (weak, nonatomic) IBOutlet UITextView *scannedBarcode;
@property (weak, nonatomic) IBOutlet UIView *cameraPreviewView;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;
@property (nonatomic, weak) IBOutlet UIButton *receiveBagButton;
@property (nonatomic, weak) IBOutlet UILabel *lblCount;

@end


@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    appDel = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    tfManualBagId.delegate = self;
    IsTfOpen = NO;
    
    if (!self.isFromReceiveBag)
    {
        _receiveBagButton.hidden = YES;
        self.lblCount.text = [NSString stringWithFormat:@"%d/%ld", [[appDel.dictScannedBags objectForKey:[NSString stringWithFormat:@"%@-%@",self.strOid, @"BagsCount"]] intValue], appDel.totalBags];
    }
    else
    {
        self.lblCount.text = [NSString stringWithFormat:@"%ld/%ld", appDel.scannedBagsCount, appDel.totalBags];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _receiveBagButton.enabled = NO;
    [self setupScanningSession];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Start the camera capture session as soon as the view appears completely.
    [self.captureSession startRunning];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)rescanButtonPressed:(id)sender {
    // Start scanning again.
    [self.captureSession startRunning];
}

-(IBAction)receiveBagClicked:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(didScanCompleteWithBagNo:)])
    {
        [self.captureSession stopRunning];
        
        NSString *strMatch = @"";
        
        if ([self.scannedBarcode.text length])
        {
            strMatch = self.scannedBarcode.text;
        }
        else
        {
            strMatch = tfManualBagId.text;
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self.delegate didScanCompleteWithBagNo:strMatch];
            
        }];
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    
    //[self.captureSession stopRunning];
    
    [tfManualBagId resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

// Local method to setup camera scanning session.
- (void)setupScanningSession {
    // Initalising hte Capture session before doing any video capture/scanning.
    self.captureSession = [[AVCaptureSession alloc] init];
    
    NSError *error;
    // Set camera capture device to default and the media type to video.
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    // Set video capture input: If there a problem initialising the camera, it will give am error.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    
    if (!input) {
        NSLog(@"Error Getting Camera Input");
        return;
    }
    // Adding input souce for capture session. i.e., Camera
    [self.captureSession addInput:input];
    
    AVCaptureMetadataOutput *captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
    // Set output to capture session. Initalising an output object we will use later.
    [self.captureSession addOutput:captureMetadataOutput];
    
    // Create a new queue and set delegate for metadata objects scanned.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("scanQueue", NULL);
    [captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
    // Delegate should implement captureOutput:didOutputMetadataObjects:fromConnection: to get callbacks on detected metadata.
    [captureMetadataOutput setMetadataObjectTypes:[captureMetadataOutput availableMetadataObjectTypes]];
    
    // Layer that will display what the camera is capturing.
    self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.captureLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.captureLayer setFrame:self.cameraPreviewView.layer.bounds];
    // Adding the camera AVCaptureVideoPreviewLayer to our view's layer.
    [self.cameraPreviewView.layer addSublayer:self.captureLayer];
}

// AVCaptureMetadataOutputObjectsDelegate method
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    // Do your action on barcode capture here:
    NSString *capturedBarcode = nil;
    
    // Specify the barcodes you want to read here:
    NSArray *supportedBarcodeTypes = @[AVMetadataObjectTypeUPCECode,
                                       AVMetadataObjectTypeCode39Code,
                                       AVMetadataObjectTypeCode39Mod43Code,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode93Code,
                                       AVMetadataObjectTypeCode128Code,
                                       AVMetadataObjectTypePDF417Code,
                                       AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeAztecCode];
    
    // In all scanned values..
    for (AVMetadataObject *barcodeMetadata in metadataObjects) {
        // ..check if it is a suported barcode
        for (NSString *supportedBarcode in supportedBarcodeTypes) {
            
            if ([supportedBarcode isEqualToString:barcodeMetadata.type]) {
                // This is a supported barcode
                // Note barcodeMetadata is of type AVMetadataObject
                // AND barcodeObject is of type AVMetadataMachineReadableCodeObject
                AVMetadataMachineReadableCodeObject *barcodeObject = (AVMetadataMachineReadableCodeObject *)[self.captureLayer transformedMetadataObjectForMetadataObject:barcodeMetadata];
                capturedBarcode = [barcodeObject stringValue];
                // Got the barcode. Set the text in the UI and break out of the loop.
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    
                    
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
                    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:@"beep_sound" ofType: @"mp3"];
                    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:soundFilePath ];
                    
                    AVAudioPlayer *myAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
                    [myAudioPlayer prepareToPlay];
                    [myAudioPlayer play];
                    
                    _receiveBagButton.enabled = YES;
                    
                    
                    [self.captureSession stopRunning];
                    self.scannedBarcode.text = capturedBarcode;
                    
                    tfManualBagId.text = @"";
                    [tfManualBagId resignFirstResponder];
                    
                    if (!self.isFromReceiveBag)
                    {
                        [self checkBagFound];
                    }
                });
                return;
            }
        }
    }
}

-(void) checkBagFound
{
    BOOL foundBagNo = NO;
    
    NSMutableArray *arrayScannedBags = [[NSMutableArray alloc]init];
    
    NSString *strMatch = @"";
    
    if ([self.scannedBarcode.text length])
    {
        strMatch = self.scannedBarcode.text;
    }
    else
    {
        strMatch = tfManualBagId.text;
    }
    
    for (int i = 0; i < [self.arrayTotalBags count]; i++)
    {
        NSDictionary *dictMain = [self.arrayTotalBags objectAtIndex:i];
        
        NSDictionary *dict = [[dictMain objectForKey:@"Bag"] objectAtIndex:0];
        
        if ([[dict objectForKey:@"BagNo"] isEqualToString:strMatch])
        {
            if (![arrayScannedBags containsObject:strMatch])
            {
                [arrayScannedBags addObject:strMatch];
                
                appDel.scannedBagsCount++;
            }
            else
            {
                [AppDelegate showAlertWithMessage:@"Already scanned this bag." andTitle:@"" andBtnTitle:@"OK"];
                
                return;
            }
            
            foundBagNo = YES;
            
            break;
        }
    }
    
    if ([arrayScannedBags count])
    {
        [appDel.dictScannedBags setObject:arrayScannedBags forKey:self.strOid];
        [appDel.dictScannedBags setObject:[NSString stringWithFormat:@"%ld", appDel.scannedBagsCount] forKey:[NSString stringWithFormat:@"%@-%@",self.strOid, @"BagsCount"]];
        
        [[NSUserDefaults standardUserDefaults] setObject:appDel.dictScannedBags forKey:@"Scanned_Bags"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (foundBagNo)
    {
        [AppDelegate showAlertWithMessage:@"This bag is related to this order" andTitle:@"Success" andBtnTitle:@"OK"];
    }
    else
    {
        [AppDelegate showAlertWithMessage:@"This bag is not related to this order!!" andTitle:@"Error" andBtnTitle:@"OK"];
    }
    
    self.lblCount.text = [NSString stringWithFormat:@"%ld/%ld", appDel.scannedBagsCount, appDel.totalBags];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    IsTfOpen = YES;
}


- (void)keyboardFrameWillChange:(NSNotification *)notification
{
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //CGRect keyboardBeginFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    CGRect newFrame = appDel.window.frame;
    CGRect keyboardFrameEnd = [self.view convertRect:keyboardEndFrame toView:nil];
    //CGRect keyboardFrameBegin = [self.view convertRect:keyboardBeginFrame toView:nil];
    
    if (IsTfOpen)
    {
        newFrame.origin.y = -(newFrame.size.height - keyboardFrameEnd.origin.y);
    }
    else
    {
        newFrame.origin.y = 0;
    }
    
    self.view.frame = newFrame;
    
    [UIView commitAnimations];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ([str length] == 0)
    {
        _receiveBagButton.enabled = NO;
    }
    else
    {
        _receiveBagButton.enabled = YES;
    }
    
    self.scannedBarcode.text = @"";
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    IsTfOpen = NO;
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text length])
    {
        if (!self.isFromReceiveBag)
        {
            [self checkBagFound];
        }
    }
}


@end






