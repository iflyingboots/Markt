//
//  MKLocationViewController.m
//  Markt
//
//  Created by Xin Wang on 5/18/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKLocationViewController.h"
#import "MKiBeaconManager.h"
#import "MKBayesian.h"
#import "MKCellTests.h"
#import "MKSVM.h"
#import "MKAlphaTrimmedMeanFilter.h"
#import <AFNetworking.h>
#import <TSMessage.h>
#import <SVProgressHUD.h>
#import "Constants.h"

@interface MKLocationViewController ()
@property (strong, nonatomic) NSDictionary *ibeaconData;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPad1;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPad2;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPhone1;
@property (strong, nonatomic) MKBayesian *bayesian;
@property (strong, nonatomic) NSMutableArray *RSSIArray;
@property (strong, nonatomic) MKSVM *svm;

@property (strong, nonatomic) MKAlphaTrimmedMeanFilter *alphaTrMeanFilter;
@property (strong, nonatomic) NSDictionary *itemLookupResponseData;
@property (strong, nonatomic) NSNumber *itemCellLocation;
- (void)lookupItemLocation:(NSString *)itemName;
@end

@implementation MKLocationViewController
@synthesize textFilterLength;
@synthesize textFilterAlphaLength;
@synthesize textItemName;
@synthesize labelItemLocation;
@synthesize itemLookupActivityIndicator;
@synthesize itemLookupResponseData;
@synthesize itemCellLocation;
@synthesize bayesian;
@synthesize locationManager;
@synthesize alphaTrMeanFilter;
@synthesize RSSIArray;
@synthesize ibeaconData;
@synthesize ibeaconRegioniPad1;
@synthesize ibeaconRegioniPad2;
@synthesize ibeaconRegioniPhone1;
@synthesize cellLabel;
@synthesize debugTextView;

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
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [self setupiBeaconData];
    [self addiBeacons];
    self.svm = [[MKSVM alloc] init];
    bayesian = [MKBayesian sharedManager];
    alphaTrMeanFilter = [MKAlphaTrimmedMeanFilter sharedManager];
    RSSIArray = [[NSMutableArray alloc] initWithObjects:@-99, @-99, @-99, nil];
//    [self testBayesian];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Bayesian
- (void)testBayesian
{
    NSArray *testDataCell1 = [MKCellTests generateTestDataCell1];
    NSArray *testDataCell7 = [MKCellTests generateTestDataCell7];
    for (int i = 0; i < [testDataCell1 count]/5; i++) {
        [bayesian estimateCellWithRSSIs:testDataCell1[i]];
        NSNumber *max = [testDataCell1[i] valueForKeyPath:@"@max.self"];
        NSArray *probsCellsArray = [bayesian getEstimatedProbsAndCells];
        NSLog(@"%@, highest: %d, estimated: cell %@", probsCellsArray, (int)[testDataCell1[i] indexOfObject:max], probsCellsArray[[testDataCell1[i] indexOfObject:max]][1]);
    }
    NSLog(@"///////////////////////////////");
//    [self.bayesian initPriors];
    for (int i = 0; i < [testDataCell7 count]/3; i++) {
        [bayesian estimateCellWithRSSIs:testDataCell7[i]];
        NSNumber *max = [testDataCell7[i] valueForKeyPath:@"@max.self"];
        NSArray *probsCellsArray = [bayesian getEstimatedProbsAndCells];
        NSLog(@"%@, highest: %d, estimated: cell %@", probsCellsArray, (int)[testDataCell7[i] indexOfObject:max], probsCellsArray[[testDataCell7[i] indexOfObject:max]][1]);
    }
}

- (NSInteger)deviceIndexWithMaxRSSI
{
    NSNumber *max = [RSSIArray valueForKeyPath:@"@max.self"];
    // return device index
    return [RSSIArray indexOfObject:max];
}

- (void)updateCellSVM
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        NSInteger cell = [self.svm predict:self.RSSIArray];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            self.cellLabel.text = [NSString stringWithFormat:@"Cell %d", (int)cell];
            self.debugTextView.text = @"SVM mode on";
        });
    });
}

- (void)updateCellAccordingToHighestRSSI
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // background thread
      
        // Estimate Cell with Filtered RSSI Data (from newly received RSSI info)
        [bayesian estimateCellWithRSSIs:[alphaTrMeanFilter processNewRSSIData:RSSIArray]];
      
        //[self.bayesian estimateCellWithRSSIs:self.RSSIArray];
        NSInteger highestRSSIDevice = [self deviceIndexWithMaxRSSI];
        NSArray *probsCellsArray = [bayesian getEstimatedProbsAndCells];
        
        NSNumber *cellId = probsCellsArray[highestRSSIDevice][CELL];
//        // issue: for cell 4, this method does not work
//        // TODO: this is a workaround
//        if ([self.RSSIArray[IPAD2] isEqualToNumber:@-99] && [self.RSSIArray[IPHONE1] isEqualToNumber:@-99])
//            cellId = @4;
      
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // update UI
            cellLabel.text = [NSString stringWithFormat:@"Cell %@", cellId];
            debugTextView.text = [NSString
                                       stringWithFormat:@"iPad1: [%@, %@]\niPad2: [%@, %@]\niPhone1:[%@, %@]\nPriors:[%@, %@, %@]",
                                       probsCellsArray[IPAD1][PROB], probsCellsArray[IPAD1][CELL],
                                       probsCellsArray[IPAD2][PROB], probsCellsArray[IPAD2][CELL],
                                       probsCellsArray[IPHONE1][PROB], probsCellsArray[IPHONE1][CELL],
                                       bayesian.priors[IPAD1], bayesian.priors[IPAD2], bayesian.priors[IPHONE1]];
            
            //    self.debugTextView.text = [NSString stringWithFormat:@"%@", self.RSSIArray];
        });
    });
}

- (void)lookupItemLocation:(NSString *)itemName
{
  NSLog(@"Looking up cell location info for: %@", itemName);
  [itemLookupActivityIndicator startAnimating];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
    // TODO: This needs to be implemented on the server side
    // Background thread to lookup item's cell location from server
    NSString *URLString = [NSString stringWithFormat:@"http://markt.wangx.in/location/%@", itemName];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      [itemLookupActivityIndicator stopAnimating];
      itemLookupResponseData = responseObject;
      itemCellLocation = itemLookupResponseData[@"location"];
      labelItemLocation.text = [NSString stringWithFormat:@"Cell %@", itemCellLocation];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      [itemLookupActivityIndicator stopAnimating];
      labelItemLocation.text = @"Unknown";
    }];
  });
}

#pragma mark - iBeacon
- (void)addiBeacons
{
    ibeaconRegioniPad1 = [[MKiBeaconManager alloc] initWithUUID:UUID1 identifier:@"iPad1"];
    ibeaconRegioniPad2 = [[MKiBeaconManager alloc] initWithUUID:UUID2 identifier:@"iPad2"];
    ibeaconRegioniPhone1 = [[MKiBeaconManager alloc] initWithUUID:UUID3 identifier:@"iPhone1"];
    [self monitorRegion:ibeaconRegioniPad1];
    [self monitorRegion:ibeaconRegioniPad2];
    [self monitorRegion:ibeaconRegioniPhone1];
}

- (void)monitorRegion:(CLBeaconRegion *)region
{
    [locationManager startMonitoringForRegion:region];
    [locationManager startRangingBeaconsInRegion:region];
}

- (void)setupiBeaconData
{
    if (ibeaconData == nil) {
        ibeaconData = [[NSDictionary alloc] initWithObjects:@[
                   @{@"label": @"iPad1Label.text", @"identifier": @"iPad1"},
                   @{@"label": @"iPad2Label.text", @"identifier": @"iPad2"},
                   @{@"label": @"iPhone1Label.text", @"identifier": @"iPhone1"},
                   ]
         forKeys:@[UUID1, UUID2, UUID3]];
    }
}

#pragma mark - Actions
- (IBAction)resetPriorsClicked:(id)sender
{
  [bayesian initPriors];
}

- (IBAction)textFieldItemNameDidEndOnExit:(id)sender {
  UITextField *textField = (UITextField *)sender;
  
  // Clear Item Location Label
  labelItemLocation.text = @"";

  // TODO: Lookup item cell location info from server and show in labelItemLocation
  // This will return a 1,2,3...10 value for each of our test items and then we'll show it in the label
  if ([textField.text length] > 0) {
    [self lookupItemLocation:textField.text];
  }
}

- (IBAction)textFieldAlphaLengthDidEndOnExit:(id)sender {
  UITextField *textField = (UITextField *)sender;
  [alphaTrMeanFilter updateAlphaValue:[textField.text intValue]];
  [bayesian initPriors];
}

- (IBAction)textFieldFilterLengthDidEndOnExit:(id)sender {
  UITextField *textField = (UITextField *)sender;
  [alphaTrMeanFilter updateFilterSize:[textField.text intValue]];
  [bayesian initPriors];
}

#pragma mark - Services
- (void)setiBeacnInfo:(NSDictionary *)iBeaconInfo rssi:(NSInteger)rssi
{
    NSString *text = [NSString stringWithFormat:@"%d", (int)rssi];
    [self setValue:text forKeyPath:iBeaconInfo[@"label"]];
}

- (void)updateRSSIArrayValue:(CLBeacon *)beacon
{
    NSString *uuid = beacon.proximityUUID.UUIDString;
    NSInteger rssiTrimmed = beacon.rssi == 0 ? NULL_RSSI : beacon.rssi;
    NSNumber *rssi = [NSNumber numberWithInteger:rssiTrimmed];
    if ([uuid isEqualToString:UUID1]) {
        [RSSIArray setObject:rssi atIndexedSubscript:IPAD1];
        return;
    }
    
    if ([uuid isEqualToString:UUID2]) {
        [RSSIArray setObject:rssi atIndexedSubscript:IPAD2];
        return;
    }
    
    if ([uuid isEqualToString:UUID3]) {
        [RSSIArray setObject:rssi atIndexedSubscript:IPHONE1];
        return;
    }
}

#pragma mark - Delegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    debugTextView.text = [NSString stringWithFormat:@"Entered: %@", region];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] == 0)
        return;
    
    for (CLBeacon *beacon in beacons) {
        // update the labels
        NSDictionary *beaconData = ibeaconData[beacon.proximityUUID.UUIDString];
        [self setiBeacnInfo:beaconData rssi:beacon.rssi];
        // update RSSI array
        [self updateRSSIArrayValue:beacon];
    }
    if (self.svmMode.on == NO) {
        [self updateCellAccordingToHighestRSSI];
    } else {
        [self updateCellSVM];
    }

}

@end
