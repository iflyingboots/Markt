//
//  MKDateManager.m
//  Markt
//
//  Created by sutar on 5/14/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKDateManager.h"

@implementation MKDateManager

+ (NSString *)timestamp
{
    return [NSString stringWithFormat:@"%ld", (long)[[NSDate new] timeIntervalSince1970]];
}

+ (NSString *)datetime
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd-HHmmss"];
    return [dateFormatter stringFromDate:date];
}

@end
