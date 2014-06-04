//
//  MKLocationViewController.m
//  Markt
//
//  Created by sutar on 5/18/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKLocationViewController.h"
#import "MKiBeaconManager.h"
#import "MKBayesian.h"
#import "MKCellTests.h"

#define IPAD1 0
#define IPAD2 1
#define IPHONE1 2
#define PROB 0
#define CELL 1

@interface MKLocationViewController ()
@property (strong, nonatomic) NSDictionary *ibeaconData;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPad1;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPad2;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPhone1;
@property (strong, nonatomic) MKBayesian *bayesian;
@property (strong, nonatomic) NSMutableArray *RSSIArray;
@end

@implementation MKLocationViewController



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
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self setupiBeaconData];
    [self addiBeacons];
    self.bayesian = [MKBayesian sharedManager];
    self.RSSIArray = [[NSMutableArray alloc] initWithObjects:@-99, @-99, @-99, nil];
//    [self testBayesian];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Bayesian
- (void)testBayesian
{
//    NSArray *testData = [MKCellTests generateMovingDataForCell12357];
    NSArray *testDataCell1 = [MKCellTests generateTestDataCell1];
    NSArray *testDataCell7 = [MKCellTests generateTestDataCell7];
    for (int i = 0; i < [testDataCell1 count]/5; i++) {
        [self.bayesian estimateCellWithRSSIs:testDataCell1[i]];
        NSNumber *max = [testDataCell1[i] valueForKeyPath:@"@max.self"];
        NSArray *probsCellsArray = [self.bayesian getEstimatedProbsAndCells];
        NSLog(@"%@, highest: %d, estimated: cell %@", probsCellsArray, (int)[testDataCell1[i] indexOfObject:max], probsCellsArray[[testDataCell1[i] indexOfObject:max]][1]);
    }
    NSLog(@"///////////////////////////////");
//    [self.bayesian initPriors];
    for (int i = 0; i < [testDataCell7 count]/3; i++) {
        [self.bayesian estimateCellWithRSSIs:testDataCell7[i]];
        NSNumber *max = [testDataCell7[i] valueForKeyPath:@"@max.self"];
        NSArray *probsCellsArray = [self.bayesian getEstimatedProbsAndCells];
        NSLog(@"%@, highest: %d, estimated: cell %@", probsCellsArray, (int)[testDataCell7[i] indexOfObject:max], probsCellsArray[[testDataCell7[i] indexOfObject:max]][1]);
    }
}

- (NSInteger)deviceIndexWithMaxRSSI
{
    NSNumber *max = [self.RSSIArray valueForKeyPath:@"@max.self"];
    // return device index
    return [self.RSSIArray indexOfObject:max];
}

- (void)updateCellAccordingToHighestRSSI
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        // background thread
        [self.bayesian estimateCellWithRSSIs:self.RSSIArray];
        NSInteger highestRSSIDevice = [self deviceIndexWithMaxRSSI];
        NSArray *probsCellsArray = [self.bayesian getEstimatedProbsAndCells];
        
        NSNumber *cellId = probsCellsArray[highestRSSIDevice][CELL];
        // issue: for cell 4, this method does not work
        // TODO: this is a workaround
        if ([self.RSSIArray[IPAD2] isEqualToNumber:@-99] && [self.RSSIArray[IPHONE1] isEqualToNumber:@-99])
            cellId = @4;
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            // update UI
            self.cellLabel.text = [NSString stringWithFormat:@"Cell %@", cellId];
            self.debugTextView.text = [NSString
                                       stringWithFormat:@"iPad1: [%@, %@]\niPad2: [%@, %@]\niPhone1:[%@, %@]\nPriors:[%@, %@, %@]",
                                       probsCellsArray[IPAD1][PROB], probsCellsArray[IPAD1][CELL],
                                       probsCellsArray[IPAD2][PROB], probsCellsArray[IPAD2][CELL],
                                       probsCellsArray[IPHONE1][PROB], probsCellsArray[IPHONE1][CELL],
                                       self.bayesian.priors[IPAD1], self.bayesian.priors[IPAD2], self.bayesian.priors[IPHONE1]];
            
            //    self.debugTextView.text = [NSString stringWithFormat:@"%@", self.RSSIArray];
        });
    });
}

#pragma mark - iBeacon
- (void)addiBeacons
{
    self.ibeaconRegioniPad1 = [[MKiBeaconManager alloc] initWithUUID:UUID1 identifier:@"iPad1"];
    self.ibeaconRegioniPad2 = [[MKiBeaconManager alloc] initWithUUID:UUID2 identifier:@"iPad2"];
    self.ibeaconRegioniPhone1 = [[MKiBeaconManager alloc] initWithUUID:UUID3 identifier:@"iPhone1"];
    [self monitorRegion:self.ibeaconRegioniPad1];
    [self monitorRegion:self.ibeaconRegioniPad2];
    [self monitorRegion:self.ibeaconRegioniPhone1];
}

- (void)monitorRegion:(CLBeaconRegion *)region
{
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager startRangingBeaconsInRegion:region];
}

- (void)setupiBeaconData
{
    if (self.ibeaconData == nil) {
        self.ibeaconData = [[NSDictionary alloc] initWithObjects:@[
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
    [self.bayesian initPriors];
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
    NSInteger rssiTrimmed = beacon.rssi == 0 ? -99 : beacon.rssi;
    NSNumber *rssi = [NSNumber numberWithInteger:rssiTrimmed];
    if ([uuid isEqualToString:UUID1]) {
        [self.RSSIArray setObject:rssi atIndexedSubscript:IPAD1];
        return;
    }
    
    if ([uuid isEqualToString:UUID2]) {
        [self.RSSIArray setObject:rssi atIndexedSubscript:IPAD2];
        return;
    }
    
    if ([uuid isEqualToString:UUID3]) {
        [self.RSSIArray setObject:rssi atIndexedSubscript:IPHONE1];
        return;
    }
}

#pragma mark - Delegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    self.debugTextView.text = [NSString stringWithFormat:@"Entered: %@", region];
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] == 0)
        return;
    
    for (CLBeacon *beacon in beacons) {
        // update the labels
        NSDictionary *beaconData = self.ibeaconData[beacon.proximityUUID.UUIDString];
        [self setiBeacnInfo:beaconData rssi:beacon.rssi];
        // update RSSI array
        [self updateRSSIArrayValue:beacon];
        self.debugTextView.text = [NSString stringWithFormat:@"[%@, %@, %@]", self.RSSIArray[IPAD1], self.RSSIArray[IPAD2], self.RSSIArray[IPHONE1]];
    }
    [self updateCellAccordingToHighestRSSI];
}



@end
