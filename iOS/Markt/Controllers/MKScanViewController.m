//
//  MKScanViewController.m
//  Markt
//
//  Created by Xin Wang on 5/19/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKScanViewController.h"
#import "MKIngredientsViewController.h"
#import <TSMessage.h>

@interface MKScanViewController () <AVCaptureMetadataOutputObjectsDelegate>

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureInput *input;
@property (strong, nonatomic) AVCaptureMetadataOutput *output;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *prevLayer;
@property (strong, nonatomic) UILabel *barcodeLabel;
@property (strong, nonatomic) UIView *hightlightView;
@property (copy, nonatomic) NSString *barcodeString;

@end

@implementation MKScanViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self configureUI];
    [self configureScanner];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI

- (void)configureUI
{
    self.hightlightView = [[UIView alloc] init];
    self.hightlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.hightlightView.layer.borderColor = [UIColor greenColor].CGColor;
    self.hightlightView.layer.borderWidth = 3;
    [self.view addSubview:self.hightlightView];
    
    self.barcodeLabel = [[UILabel alloc] init];
    self.barcodeLabel.frame = CGRectMake(0, 20, self.view.bounds.size.width, 40);
    self.barcodeLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.barcodeLabel.backgroundColor = [UIColor clearColor];
    self.barcodeLabel.textColor = [UIColor whiteColor];
    self.barcodeLabel.text = @"Scanning";
    self.barcodeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.barcodeLabel];
}

- (void)configureScanner
{
    self.session = [[AVCaptureSession alloc] init];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
    if (self.input) {
        [self.session addInput:self.input];
    } else {
        [TSMessage showNotificationInViewController:self title:error.localizedDescription subtitle:nil type:TSMessageNotificationTypeError];
    }
    
    // Create a new serial dispatch queue.
    dispatch_queue_t dispatchQueue;
    dispatchQueue = dispatch_queue_create("myQueue", NULL);
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatchQueue];
    [self.session addOutput:self.output];
    
    self.output.metadataObjectTypes = @[AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code, AVMetadataObjectTypeQRCode];
    
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.prevLayer.frame = self.view.frame;
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.prevLayer];
    
    [self.session startRunning];
    
    [self.view bringSubviewToFront:_hightlightView];
    [self.view bringSubviewToFront:_barcodeLabel];

}

#pragma mark - Delegates
/**
 *  Barcode scanning delegation
 *
 *  @param captureOutput
 *  @param metadataObjects
 *  @param connection
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barcodeObject;
    NSString *detectionString = nil;
    
    if (metadataObjects != nil &&  [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadata = [metadataObjects firstObject];
        barcodeObject = (AVMetadataMachineReadableCodeObject *)[self.prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
        highlightViewRect = barcodeObject.bounds;
        detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
        
        if (detectionString != nil) {
            self.barcodeLabel.text = detectionString;
            self.barcodeString = detectionString;
        } else {
            self.barcodeLabel.text = @"Scanning";
        }
    }
    
    self.hightlightView.frame = highlightViewRect;
    
    if (self.barcodeString != nil) {
        [self.session stopRunning];
        self.session = nil;
        [self presentIngredientsController];
    }
    
}

#pragma mark - Present ingredients controller
/**
 *  Present a new view controller
 */
- (void)presentIngredientsController
{
    MKIngredientsViewController *ingredientsViewController = [[MKIngredientsViewController alloc] init];
    ingredientsViewController.barcode = self.barcodeString;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:ingredientsViewController];
    navigationController.navigationBar.titleTextAttributes =  [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}



@end
