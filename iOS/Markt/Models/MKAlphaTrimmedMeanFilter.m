//
//  MKAlphaTrimmedMeanFilter.m
//  Markt
//
//  Created by Abhishek Sen on 6/10/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKAlphaTrimmedMeanFilter.h"
#import "Constants.h"

@interface MKAlphaTrimmedMeanFilter ()
@property (strong, nonatomic) NSArray *rssiWindow;
@property (strong, nonatomic) NSNumber *alpha;
@property (strong, nonatomic) NSNumber *filterSize;
- (void) resetRSSIFilterWindow;
@end

@implementation MKAlphaTrimmedMeanFilter
@synthesize rssiWindow;
@synthesize alpha;
@synthesize filterSize;
bool filterReset = TRUE;

/**
 *  Singleton
 *
 *  @return instancetype
 */
+ (instancetype)sharedManager
{
  static id _sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _sharedManager = [[self alloc] init];
  });
  return _sharedManager;
}

/**
 *  Custom init function
 *
 *  @return id
 */
-(id) init
{
  if ( self = [super init] ) {
    rssiWindow = [[NSArray alloc] initWithObjects:
                   [[NSMutableArray alloc] initWithCapacity:DEFAULT_FILTER_SIZE],
                   [[NSMutableArray alloc] initWithCapacity:DEFAULT_FILTER_SIZE],
                   [[NSMutableArray alloc] initWithCapacity:DEFAULT_FILTER_SIZE],
                   nil];

    alpha = [NSNumber numberWithInt:DEFAULT_ALPHA_VAL];
    filterSize = [NSNumber numberWithInt:DEFAULT_FILTER_SIZE];
    
    [self resetRSSIFilterWindow];
  }
  return self;
}

/**
 *  Insert newly received RSSI data into filter banks and sort in ascending order
 *
 *  @return void
 */
- (void) insertNewRSSIDataAndSortInAscendingOrder:(NSArray *)RSSIs
{
  NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];

  // Insert new RSSI Data into sliding window of size ALPHA_MEAN_FILTER_SIZE
  for (int i = 0; i < self.rssiWindow.count; i++) {
    NSMutableArray *rssiCellFilter = (NSMutableArray *)self.rssiWindow[i];
    
    // First time populate filter banks with first received RSSI value
    if (filterReset) {
      [rssiCellFilter removeAllObjects];
      for (int j = 0; j < filterSize.intValue; j++) {
        [rssiCellFilter addObject:RSSIs[i]];
      }
    } else {
      [rssiCellFilter removeLastObject];
      [rssiCellFilter insertObject:RSSIs[i] atIndex:0];
    }
    
    // Sort in ascending order
//    [rssiCellFilter sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
      [rssiCellFilter sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
          if ([obj1 floatValue] > [obj2 floatValue])
              return NSOrderedDescending;
          else if ([obj1 floatValue] < [obj2 floatValue])
              return NSOrderedAscending;
          return NSOrderedSame;
      }];

  }
  
  // Reset filter flag
  if (filterReset) {
    filterReset = false;
  }
    
}

/**
 *  Alpha Trimming Filter Function
 *  Returns [
 *           iPad1FilteredInstantaneousRSSI,
 *           iPad2FilteredInstantaneousRSSI,
 *           iPhone1FilteredInstantaneousRSSI,
 *          ]
 *  @return NSArray
 */
- (NSArray *) performAlphaTrimmingFilter
{
  NSMutableArray *filteredRSSIData = [[NSMutableArray alloc] initWithCapacity:NUM_CELLS];
  int numElemToDiscard = (int)alpha/2;
  
  // Trim and treat window edge RSSI data
  for (int i = 0; i < self.rssiWindow.count; i++) {
    NSMutableArray *rssiCellFilter = (NSMutableArray *)self.rssiWindow[i];
    
    // Trim head for numElemToDiscard elements and extend window edge
    for (int j = numElemToDiscard - 1, k = numElemToDiscard + 1; ((j > 0) && (k < rssiCellFilter.count)); j--, k++) {
      rssiCellFilter[j] = rssiCellFilter[k];
    }

    // Trim tail for numElemToDiscard elements and extend window edge
    for (int j = (rssiCellFilter.count - (numElemToDiscard - 1) - 1), k = (rssiCellFilter.count - (numElemToDiscard - 1) - 1 - 1); ((k > 0) && (j < rssiCellFilter.count)); j++, k--) {
      rssiCellFilter[j] = rssiCellFilter[k];
    }
    
    // Compute sum and average and use this filtered RSSI value for the cell -
    float average = [[rssiCellFilter valueForKeyPath:@"@sum.self"] floatValue]/rssiCellFilter.count;
    //[filteredRSSIData addObject:[NSNumber numberWithFloat:average]];
      [filteredRSSIData insertObject:[NSNumber numberWithFloat:average] atIndex:i];
  }

  NSLog(@"Filtered RSSI iPad1: %@, iPad2: %@, iPhone1: %@", filteredRSSIData[IPAD1], filteredRSSIData[IPAD2], filteredRSSIData[IPHONE1]);
  return filteredRSSIData;
}

/**
 *  Process real-time RSSI data from all iBeacons
 *
 *  @return NSArray
 */
- (NSArray *)processNewRSSIData:(NSArray *)RSSIs
{
  NSLog(@"RAW RSSI iPad1: %@, iPad2: %@, iPhone1: %@", RSSIs[IPAD1], RSSIs[IPAD2], RSSIs[IPHONE1]);
  [self insertNewRSSIDataAndSortInAscendingOrder:RSSIs];
  return [self performAlphaTrimmingFilter];
}

/**
 *  Reset Filter Window Length
 *
 *  @return void
 */
- (void) resetRSSIFilterWindow
{
  filterReset = TRUE;
  for (int i = 0; i < self.rssiWindow.count; i++) {
    NSMutableArray *rssiCellFilter = (NSMutableArray *)self.rssiWindow[i];
    for (int j = 0; j < filterSize.intValue; j++) {
      [rssiCellFilter addObject:[NSNumber numberWithInt:NULL_RSSI]];
    }
  }
}

/**
 *  Update alpha parameter
 *
 *  @return void
 */
- (void)updateAlphaValue:(int)alphaVal
{
  if ((alphaVal < filterSize.intValue) && (alphaVal > 0) && ((alphaVal & 0x1) == 0)) {
    alpha = [NSNumber numberWithInt:alphaVal];
    [self resetRSSIFilterWindow];
    NSLog(@"RSSI Filter Window reset with alpha value %d", alphaVal);
  } else {
    NSLog(@"Invalid alpha val %d entered. Rejecting change", alphaVal);
  }
}

/**
 *  Update filter size parameter
 *
 *  @return void
 */
- (void)updateFilterSize:(int)filterLengthVal
{
  if ((filterLengthVal > alpha.intValue) && (filterLengthVal > 0) && (filterLengthVal < MAX_FILTER_SIZE)) {
    filterSize = [NSNumber numberWithInt:filterLengthVal];
    [self resetRSSIFilterWindow];
    NSLog(@"RSSI Filter Window reset with filter length %d", filterLengthVal);
  } else {
    NSLog(@"Invalid alpha val %d entered. Rejecting change", filterLengthVal);
  }
}
@end
