//
//  MKAlphaTrimmedMeanFilter.h
//  Markt
//
//  Created by Abhishek Sen on 6/10/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MKAlphaTrimmedMeanFilter : NSObject

+ (instancetype)sharedManager;
- (NSArray *)processNewRSSIData:(NSArray *)RSSIs;
- (void)updateAlphaValue:(int)alphaVal;
- (void)updateFilterSize:(int)filterLengthVal;
@end
