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
@synthesize labelItemLocation;
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

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


/**
 *  Get the device index with highest RSSI
 *
 *  @return device index
 */
- (NSInteger)deviceIndexWithMaxRSSI
{
    NSNumber *max = [RSSIArray valueForKeyPath:@"@max.self"];
    // return device index
    return [RSSIArray indexOfObject:max];
}

#pragma mark - SVM
/**
 *  Update cell label according to SVM prediction
 */
- (void)updateCellSVM
{
    NSArray *alphaArray = [alphaTrMeanFilter processNewRSSIData:RSSIArray ];

    NSInteger cell = [self.svm predict:alphaArray];
    self.cellLabel.text = [NSString stringWithFormat:@"Cell %d", (int)cell];
}

#pragma mark - Bayesian
/**
 *  Update cell label according to Bayesian filter results
 */
- (void)updateCellAccordingToHighestRSSI
{
        // Estimate Cell with Filtered RSSI Data (from newly received RSSI info)
        NSArray *alphaArray = [alphaTrMeanFilter processNewRSSIData:RSSIArray];
        [bayesian estimateCellWithRSSIs:alphaArray];
    
        NSInteger highestRSSIDevice = [self deviceIndexWithMaxRSSI];
        NSArray *probsCellsArray = [bayesian getEstimatedProbsAndCells];
        
        NSNumber *cellId = probsCellsArray[highestRSSIDevice][CELL];
    
        cellLabel.text = [NSString stringWithFormat:@"Cell %@", cellId];
}

#pragma mark - iBeacon
/**
 *  Add iBeacon devices
 */
- (void)addiBeacons
{
    ibeaconRegioniPad1 = [[MKiBeaconManager alloc] initWithUUID:UUID1 identifier:@"iPad1"];
    ibeaconRegioniPad2 = [[MKiBeaconManager alloc] initWithUUID:UUID2 identifier:@"iPad2"];
    ibeaconRegioniPhone1 = [[MKiBeaconManager alloc] initWithUUID:UUID3 identifier:@"iPhone1"];
    [self monitorRegion:ibeaconRegioniPad1];
    [self monitorRegion:ibeaconRegioniPad2];
    [self monitorRegion:ibeaconRegioniPhone1];
}

/**
 *  Start to monitor region
 *
 *  @param region
 */
- (void)monitorRegion:(CLBeaconRegion *)region
{
    [locationManager startMonitoringForRegion:region];
    [locationManager startRangingBeaconsInRegion:region];
}

/**
 *  Set up iBeacon device info
 */
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

/**
 *  Update RSSI array value from reading
 *
 *  @param beacon
 */
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

/**
 *  iBeacon region delegation
 *
 *  @param manager
 *  @param beacons
 *  @param region
 */
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
    /* two modes */
    if (self.svmMode.on == NO) {
        [self updateCellAccordingToHighestRSSI];
    } else {
        [self updateCellSVM];
    }

}

@end
