//
//  MKBayesian.h
//  Markt
//
//  Created by sutar on 5/19/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKBayesian : NSObject

@property (strong, nonatomic) NSMutableArray *priors;

+ (instancetype)sharedManager;
- (NSArray *)estimateCellWithRSSIs:(NSArray *)RSSIs;
@end