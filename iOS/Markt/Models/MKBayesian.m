//
//  MKBayesian.m
//  Markt
//
//  Created by sutar on 5/19/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

// Bundle files, located in `Data' folder
#define IPAD1_DIST_FILE @"iPad1_dist"
#define IPAD2_DIST_FILE @"iPad2_dist"
#define IPHONE1_DIST_FILE @"iPhone1_dist"

#define MEAN 0
#define STD  1

#import "MKBayesian.h"

@interface MKBayesian ()
@property (strong, nonatomic) NSMutableArray *distributions;
@end

@implementation MKBayesian


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

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *iPad1Dist = [self readDistribution:IPAD1_DIST_FILE];
        NSArray *iPad2Dist = [self readDistribution:IPAD2_DIST_FILE];
        NSArray *iPhone1Dist = [self readDistribution:IPHONE1_DIST_FILE];
        self.distributions = [[NSMutableArray alloc] initWithObjects:iPad1Dist, iPad2Dist, iPhone1Dist, nil];
        [self initPriors];
    }
    return self;
}

/**
 *  Normal Distribution Probability Density Function
 *
 *  @param x       Input x value
 *  @param mean    Mean
 *  @param std_dev Standard Deviation
 *
 *  @return probablity
 */
float normpdf(float x, float mean, float std_dev) {
    return(1.0 / (sqrtf(2 * M_PI) * std_dev) * expf(- (x - mean) * (x - mean) / (2 * std_dev * std_dev)));
}


- (CGFloat)calculateProbByRSSI:(NSInteger)RSSI andCell:(NSUInteger)cell andDeviceDist:(NSArray *)dist
{
    NSAssert(cell > 0, @"cell must greater than 0");
    NSAssert(cell <= CELL_NUM, @"cell must less than CELL_NUM");
    // cell [1, 10]
    cell = cell - 1;
    return normpdf((float)RSSI, [dist[cell][MEAN] floatValue], [dist[cell][STD] floatValue]);
}

/**
 *  Returns the dot product of two length-equal vectors
 *
 *  @param vec1
 *  @param vec2
 *
 *  @return dot product
 */
- (NSMutableArray *)dotProductVec1:(NSMutableArray *)vec1 andVec2:(NSMutableArray*)vec2
{
    NSAssert([vec1 count] == [vec2 count], @"The vector lengths must be equal");
    NSMutableArray *result = [[NSMutableArray alloc] initWithCapacity:[vec1 count]];
    NSUInteger len = [vec1 count];
    for (int i = 0; i < len; i++) {
        float product = [vec1[i] floatValue] * [vec2[i] floatValue];
        [result addObject:[NSNumber numberWithFloat:product]];
    }
    return result;
}

/**
 *  Calculates probs (10 cells) by given RSSI and one device (AP)
 *
 *  @param RSSI integer
 *  @param dist distribution of one AP (device)
 *
 *  @return cell propbalities according to given distribution
 */
- (NSArray *)calculateCellProbWithRSSI:(NSInteger)RSSI andDevice:(NSArray *)dist
{
    NSAssert([dist count] == CELL_NUM, @"The number of device distributions must be equal to CELL_NUM");
    NSMutableArray *probs = [[NSMutableArray alloc] initWithCapacity:CELL_NUM];
    NSUInteger cell = 1;
    for (int i = 0; i < [dist count]; i++) {
        float probability = [self calculateProbByRSSI:RSSI andCell:cell andDeviceDist:dist];
        [probs addObject:[NSNumber numberWithFloat:probability]];
        cell++;
    }
    return probs;
}


/**
 *  Estimates which cell you are in
 *  according to the given three RSSI values
 *
 *  @param RSSIs array
 *
 *  @return nomalized posterior probabilities (values are used for the next prior probablities)
 */
- (NSArray *)estimateCellWithRSSIs:(NSArray *)RSSIs
{
    // RSSIs = [iPad1, iPad2, iPhone1]
    NSAssert([RSSIs count] == 3, @"RSSIs muste be 3");
    NSMutableArray *probs = [[NSMutableArray alloc] initWithCapacity:3];
    NSMutableArray *posteriors = [[NSMutableArray alloc] initWithCapacity:3];
    
    for (int i = 0; i < 3; i++) {
        NSArray *cellProb = [self calculateCellProbWithRSSI:[RSSIs[i] intValue] andDevice:self.distributions[i]];
        [probs addObject:cellProb];
    }
    
    for (int i = 0; i < 3; i++) {
        NSMutableArray *postprob = [self dotProductVec1:self.priors[i] andVec2:probs[i]];
        [posteriors addObject:postprob];
    }
    
    // normalize
    for (NSMutableArray *postprob in posteriors) {
        float sum = [[postprob valueForKeyPath:@"@sum.self"] floatValue];
        NSUInteger count = [postprob count];
        // @TODO: check if 10
        NSAssert(count == 10, @"should be 10, right?");
        for (int i = 0; i < count; i++) {
            float nomalized = [postprob[i] floatValue] / sum;
            [postprob setObject:[NSNumber numberWithFloat:nomalized] atIndexedSubscript:i];
        }
    }
    
    self.priors = posteriors;
    
    return posteriors;
}

/**
 *  Initializes all prior probabilities
 */
- (void)initPriors
{
    if (self.priors != nil) {
        self.priors = nil;
    }
    self.priors = [[NSMutableArray alloc] init];
    for (int i = 0; i < 3; i++) {
        [self.priors addObject:[NSMutableArray arrayWithArray:@[@0.1, @0.1, @0.1, @0.1, @0.1, @0.1, @0.1, @0.1, @0.1, @0.1]]];
    }
}

/**
 *  Reads access point distribution from txt file
 *
 *  @param filename
 *
 *  @return ditribution array (10 items, each contains mean and std)
 */
- (NSArray *)readDistribution:(NSString *)filename
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"txt"];
    NSError *error = nil;
    NSString *data = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Read dist error: %@", error.localizedDescription);
    }
    
    NSMutableArray *distArray = [NSMutableArray arrayWithCapacity:CELL_NUM];
    
    // for each cell (one cell per line)
    for (NSString *line in [data componentsSeparatedByString:@"\n"]) {
        // cellId, mean, std
        NSArray *items = [line componentsSeparatedByString:@","];
        [distArray addObject:@[items[1], items[2]]];
    }
    
    assert([distArray count] == 10);
    
    return  (NSArray *)distArray;
}


/**
 *  Gets estimated probabilities and cells
 *  Returns [
 *           [iPad1MaxProb, estimatedCell],
 *           [iPad2MaxProb, estimatedCell],
 *           [iPhone1MaxProb, estimatedCell],
 *          ]
 *  @return array
 */
- (NSArray *)getEstimatedProbsAndCells
{
    NSMutableArray *estimatedProbsAndCells = [NSMutableArray arrayWithCapacity:3];
    for (int i = 0; i < 3; i++) {
        // get max prob in each AP
        NSNumber *maxProb = [self.priors[i] valueForKeyPath:@"@max.self"];
        // and the index
        NSUInteger index = [self.priors[i] indexOfObject:maxProb];
        // plus 1 means the acutal cell index
        NSNumber *cell = [NSNumber numberWithInt:index + 1];
        // (prob, cell)
        [estimatedProbsAndCells addObject:[NSArray arrayWithObjects:maxProb, cell, nil]];
//        NSLog(@"Device%d prob: %f -> cell %d", i, [maxProb floatValue], [cell intValue]);
    }
    return estimatedProbsAndCells;
}

@end
