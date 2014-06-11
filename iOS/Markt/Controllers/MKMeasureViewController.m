//
//  MKMainViewController.m
//  Markt
//
//  Created by Xin Wang on 5/13/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//


#import "MKMeasureViewController.h"
#import "MKFileManager.h"
#import "MKDateManager.h"
#import "MKiBeaconManager.h"

@interface MKMeasureViewController ()
@property (assign, nonatomic) NSUInteger currentCell;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPad1;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPad2;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPhone1;
@property (strong, nonatomic) MKiBeaconManager *ibeaconRegioniPhone2;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSDictionary *ibeaconData;
@property (assign, nonatomic) BOOL isLogging;
@property (strong, nonatomic) MKFileManager *fileManager;
@end

@implementation MKMeasureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
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
    [self setupiBeaconData];
    if (self.fileManager == nil) {
        self.fileManager = [[MKFileManager alloc] initWithFileName:@"rssi.txt"];
    }
    self.isLogging = NO;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.ibeaconRegioniPad1 = [[MKiBeaconManager alloc] initWithUUID:UUID1 identifier:@"iPad1"];
    self.ibeaconRegioniPad2 = [[MKiBeaconManager alloc] initWithUUID:UUID2 identifier:@"iPad2"];
    self.ibeaconRegioniPhone1 = [[MKiBeaconManager alloc] initWithUUID:UUID3 identifier:@"iPhone1"];
    self.ibeaconRegioniPhone2 = [[MKiBeaconManager alloc] initWithUUID:UUID4 identifier:@"iPhone2"];
    [self monitorRegion:self.ibeaconRegioniPad1];
    [self monitorRegion:self.ibeaconRegioniPad2];
    [self monitorRegion:self.ibeaconRegioniPhone1];
    [self monitorRegion:self.ibeaconRegioniPhone2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Service
- (void)monitorRegion:(CLBeaconRegion *)region
{
    [self.locationManager startMonitoringForRegion:region];
    [self.locationManager startRangingBeaconsInRegion:region];
}

- (void)setupiBeaconData
{
    if (self.ibeaconData == nil) {
        self.ibeaconData = [[NSDictionary alloc] initWithObjects:@[
                                @{@"label": @"ibeaconInfo1.text", @"identifier": @"iPad1"},
                                @{@"label": @"ibeaconInfo2.text", @"identifier": @"iPad2"},
                                @{@"label": @"ibeaconInfo3.text", @"identifier": @"iPhone1"},
                                @{@"label": @"ibeaconInfo4.text", @"identifier": @"iPhone2"},
                            ]
                            forKeys:@[UUID1, UUID2, UUID3, UUID4]];
    }
}

- (void)setiBeacnInfo:(NSDictionary *)iBeaconInfo rssi:(NSInteger)rssi
{
    NSString *text = [NSString stringWithFormat:@"%@: %d",iBeaconInfo[@"identifier"], (int)rssi];
    [self setValue:text forKeyPath:iBeaconInfo[@"label"]];
}

#pragma mark - Logging
- (void)logRssi
{
    NSString *timestamp = [MKDateManager timestamp];
    NSString *content = [NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@\n", timestamp, self.cellLabel.text, self.ibeaconInfo1.text, self.ibeaconInfo2.text, self.ibeaconInfo3.text, self.ibeaconInfo4.text];
    self.debugTextView.text = content;
    [self.fileManager write:content append:YES];
}

#pragma mark - Actions

- (IBAction)resetButtonClicked:(id)sender
{
    [self.fileManager write:@"" append:NO];
    
}

- (IBAction)cellSliderChanged:(id)sender
{
    self.currentCell = (NSUInteger)self.cellSlider.value;
    self.cellLabel.text = [NSString stringWithFormat:@"cell%ld", (unsigned long)self.currentCell];
}

- (IBAction)startButtonClicked:(id)sender
{
    self.isLogging = YES;
}

- (IBAction)stopButtonClicked:(id)sender
{
    self.isLogging = NO;
    self.debugTextView.text = @"stopped, start reading file";
    self.debugTextView.text = [self.fileManager readAll];
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
    if (self.isLogging) {
        [self logRssi];
    }
}
@end
