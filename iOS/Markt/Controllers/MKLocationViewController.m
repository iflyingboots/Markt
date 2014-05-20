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
    self.RSSIArray = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, nil];
//    [self testBayesian];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Bayesian
- (void)testBayesian
{
    NSArray *testDataCell1 = [MKCellTests generateTestDataCell1];
    for (int i = 0; i < [testDataCell1 count]/5; i++) {
        [self.bayesian estimateCellWithRSSIs:testDataCell1[i]];
        NSArray *probsCellsArray = [self.bayesian getEstimatedProbsAndCells];
        NSLog(@"%@", probsCellsArray);
    }
}

- (NSInteger)deviceIndexWithMaxRSSI
{
    NSNumber *max = [self.RSSIArray valueForKeyPath:@"@max.self"];
    return [self.RSSIArray indexOfObject:max];
}

- (void)updateCellAccordingToHighestRSSI
{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        [self.bayesian estimateCellWithRSSIs:self.RSSIArray];
        NSArray *probsCellsArray = [self.bayesian getEstimatedProbsAndCells];
        NSInteger highestRSSIDevice = [self deviceIndexWithMaxRSSI];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            //Run UI Updates
            self.cellLabel.text = [NSString stringWithFormat:@"Cell %d", [probsCellsArray[highestRSSIDevice][1] intValue]];
            self.debugTextView.text = [NSString
                                       stringWithFormat:@"iPad1: [%@, %@]\niPad2: [%@, %@]\niPhone1:[%@, %@]",
                                       probsCellsArray[0][0], probsCellsArray[0][1],
                                       probsCellsArray[1][0], probsCellsArray[1][1],
                                       probsCellsArray[2][0], probsCellsArray[2][1]];
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
    NSLog(@"%@", self.bayesian.priors);
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
        [self.RSSIArray setObject:rssi atIndexedSubscript:0];
        return;
    }
    
    if ([uuid isEqualToString:UUID2]) {
        [self.RSSIArray setObject:rssi atIndexedSubscript:1];
        return;
    }
    
    if ([uuid isEqualToString:UUID3]) {
        [self.RSSIArray setObject:rssi atIndexedSubscript:2];
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
        // change the labels
        NSDictionary *beaconData = self.ibeaconData[beacon.proximityUUID.UUIDString];
        [self setiBeacnInfo:beaconData rssi:beacon.rssi];
        // update RSSI array
        [self updateRSSIArrayValue:beacon];
        self.debugTextView.text = [NSString stringWithFormat:@"[%@, %@, %@]", self.RSSIArray[0], self.RSSIArray[1], self.RSSIArray[2]];
    }
    [self updateCellAccordingToHighestRSSI];
}



@end
