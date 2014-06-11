//
//  MKMainViewController.h
//  Markt
//
//  Created by Xin Wang on 5/13/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import CoreBluetooth;

@interface MKMeasureViewController : UIViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *cellLabel;
@property (strong, nonatomic) IBOutlet UISlider *cellSlider;
@property (strong, nonatomic) IBOutlet UITextView *debugTextView;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIButton *stopButton;
@property (strong, nonatomic) IBOutlet UILabel *ibeaconInfo1;
@property (strong, nonatomic) IBOutlet UILabel *ibeaconInfo2;
@property (strong, nonatomic) IBOutlet UILabel *ibeaconInfo3;
@property (strong, nonatomic) IBOutlet UILabel *ibeaconInfo4;
- (IBAction)resetButtonClicked:(id)sender;


- (IBAction)cellSliderChanged:(id)sender;
- (IBAction)startButtonClicked:(id)sender;
- (IBAction)stopButtonClicked:(id)sender;

@end
