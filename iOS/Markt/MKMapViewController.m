//
//  MKMapViewController.m
//  Markt
//
//  Created by Abhishek Sen on 6/18/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKMapViewController.h"
#import "MKiBeaconManager.h"
#import "MKBayesian.h"
#import "MKSVM.h"
#import "MKAlphaTrimmedMeanFilter.h"
#import <AFNetworking.h>
#import <TSMessage.h>
#import <SVProgressHUD.h>
#import "Constants.h"

@interface MKMapViewController ()
@property (strong, nonatomic) IBOutlet UILabel *lableOne;
@property (strong, nonatomic) IBOutlet UILabel *lableTwo;
@property (strong, nonatomic) IBOutlet UILabel *labelThree;
@property (strong, nonatomic) IBOutlet UILabel *labelFive;
@property (strong, nonatomic) IBOutlet UILabel *labelSeven;
@property (strong, nonatomic) IBOutlet UILabel *labelFour;
@property (strong, nonatomic) IBOutlet UILabel *labelSix;
@property (strong, nonatomic) IBOutlet UILabel *labelEight;
@property (strong, nonatomic) IBOutlet UILabel *labelNine;
@property (strong, nonatomic) IBOutlet UILabel *labelTen;
@property (strong, nonatomic) IBOutlet UILabel *iPad1Label;
@property (strong, nonatomic) IBOutlet UILabel *iPad2Label;
@property (strong, nonatomic) IBOutlet UILabel *iPhone1Label;
@property (strong, nonatomic) IBOutlet UISwitch *svmMode;

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
@property (strong, nonatomic) UILabel *currentLabel;

- (IBAction)resetPriorsClicked:(id)sender;
- (void)updateMapLabelColours:(int)number;
@end

@implementation MKMapViewController
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
@synthesize lableOne;
@synthesize labelEight;
@synthesize labelFive;
@synthesize labelFour;
@synthesize labelNine;
@synthesize labelSeven;
@synthesize labelSix;
@synthesize labelTen;
@synthesize labelThree;
@synthesize lableTwo;
@synthesize currentLabel;

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
    // Dispose of any resources that can be recreated.
}

/**
 *  Update the map labels to reflect the user's position
 *
 *  @param number
 */
- (void)updateMapLabelColours:(int)number
{
  NSLog(@"New Cell %d", number);
  // Clear old label's color
  currentLabel.textColor = [UIColor clearColor];
  currentLabel.textColor = [UIColor blackColor];
  
  switch (number) {
    case 1:
      lableOne.textColor = [UIColor blueColor];
      currentLabel = lableOne;
      break;
    case 2:
      lableTwo.textColor = [UIColor blueColor];
      currentLabel = lableTwo;
      break;
    case 3:
      labelThree.textColor = [UIColor blueColor];
      currentLabel = labelThree;
      break;
    case 4:
      labelFour.textColor = [UIColor blueColor];
      currentLabel = labelFour;
      break;
    case 5:
      labelFive.textColor = [UIColor blueColor];
      currentLabel = labelFive;
      break;
    case 6:
      labelSix.textColor = [UIColor blueColor];
      currentLabel = labelSix;
      break;
    case 7:
      labelSeven.textColor = [UIColor blueColor];
      currentLabel = labelSeven;
      break;
    case 8:
      labelEight.textColor = [UIColor blueColor];
      currentLabel = labelEight;
      break;
    case 9:
      labelNine.textColor = [UIColor blueColor];
      currentLabel = labelNine;
      break;
    case 10:
      labelTen.textColor = [UIColor blueColor];
      currentLabel = labelTen;
      break;
    default:
      break;
  }
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
  //self.cellLabel.text = [NSString stringWithFormat:@"Cell %d", (int)cell];
  [self updateMapLabelColours:(int)cell];
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
  [self updateMapLabelColours:[cellId intValue]];
  //cellLabel.text = [NSString stringWithFormat:@"Cell %@", cellId];
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
