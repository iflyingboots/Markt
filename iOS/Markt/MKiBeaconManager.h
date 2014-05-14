//
//  MKiBeaconManager.h
//  Markt
//
//  Created by sutar on 5/14/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreLocation;

@interface MKiBeaconManager :CLBeaconRegion

- (id)initWithUUID:(NSString *)uuid identifier:(NSString *)identifier;
@end
