//
//  MKLocationViewController.h
//  Markt
//
//  Created by sutar on 5/18/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import CoreBluetooth;

@interface MKLocationViewController : UIViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *iPad1Label;
@property (strong, nonatomic) IBOutlet UILabel *iPad2Label;
@property (strong, nonatomic) IBOutlet UILabel *iPhone1Label;

@end