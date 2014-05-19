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
    [self testBayesian];

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
    for (int i = 0; i < [testDataCell1 count]; i++) {
        NSArray *newPrior = [self.bayesian estimateCellWithRSSIs:testDataCell1[i]];
        [self getEstimatedCell:newPrior];
    }
    
    
}

- (void)getEstimatedCell:(NSArray *)probs
{
    NSAssert([probs count] == 3, @"Probs count should be 3");
    for (int i = 0; i < 3; i++) {
        NSNumber *maxProb = [probs[i] valueForKeyPath:@"@max.self"];
        NSUInteger index = [probs[i] indexOfObject:maxProb];
        NSUInteger cell = index + 1;
        NSLog(@"Device%d prob: %f -> cell %d", i, [maxProb floatValue], cell);
    }
    NSLog(@"\n");
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

#pragma mark - Services
- (void)setiBeacnInfo:(NSDictionary *)iBeaconInfo rssi:(NSInteger)rssi
{
    NSString *text = [NSString stringWithFormat:@"%d", (int)rssi];
    [self setValue:text forKeyPath:iBeaconInfo[@"label"]];
}


#pragma mark - Delegate
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"enter: %@", region);
}

-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] == 0)
        return;
    for (CLBeacon *beacon in beacons) {
        NSDictionary *beaconData = self.ibeaconData[beacon.proximityUUID.UUIDString];
        [self setiBeacnInfo:beaconData rssi:beacon.rssi];
    }
}


@end
