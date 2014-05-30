//
//  MKScanViewController.m
//  Markt
//
//  Created by sutar on 5/19/14.
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
//    self.barcodeLabel.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
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
    
    self.output = [[AVCaptureMetadataOutput alloc] init];
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [self.session addOutput:self.output];
    
    self.output.metadataObjectTypes = [self.output availableMetadataObjectTypes];
    
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.prevLayer.frame = self.view.frame;
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.prevLayer];
    
    [self.session startRunning];
    
    [self.view bringSubviewToFront:_hightlightView];
    [self.view bringSubviewToFront:_barcodeLabel];

}

#pragma mark - Delegates
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barcodeObject;
    NSString *detectionString = nil;
    NSArray *barcodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
                              AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
                              AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];
    
    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barcodeTypes) {
            if ([metadata.type isEqualToString:type]) {
                barcodeObject = (AVMetadataMachineReadableCodeObject *)[self.prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = barcodeObject.bounds;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }
        
        if (detectionString != nil) {
            self.barcodeLabel.text = detectionString;
            self.barcodeString = detectionString;
            break;
        } else {
            self.barcodeLabel.text = @"Scanning";
        }
    }
    
    self.hightlightView.frame = highlightViewRect;
    
    if (self.barcodeString != nil) {
        [self.session stopRunning];
        MKIngredientsViewController *ingredientsViewController = [[MKIngredientsViewController alloc] init];
        ingredientsViewController.barcode = self.barcodeString;
        [self presentViewController:ingredientsViewController animated:YES completion:nil];
    }
    
}



@end
