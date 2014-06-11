//
//  MKiBeaconManager.m
//  Markt
//
//  Created by Xin Wang on 5/14/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKiBeaconManager.h"
@interface MKiBeaconManager()
@end

@implementation MKiBeaconManager

- (id)initWithUUID:(NSString *)uuid identifier:(NSString *)identifier
{
    self = [super initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:uuid] identifier:identifier];
    return self;
}

@end
