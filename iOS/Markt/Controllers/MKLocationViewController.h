//
//  MKLocationViewController.h
//  Markt
//
//  Created by Xin Wang on 5/18/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CoreLocation;
@import CoreBluetooth;

@interface MKLocationViewController : UIViewController <CLLocationManagerDelegate>
@property (strong, nonatomic) IBOutlet UILabel *iPad1Label;
@property (strong, nonatomic) IBOutlet UILabel *iPad2Label;
@property (strong, nonatomic) IBOutlet UILabel *iPhone1Label;
@property (strong, nonatomic) IBOutlet UITextView *debugTextView;
@property (strong, nonatomic) IBOutlet UILabel *cellLabel;
@property (strong, nonatomic) IBOutlet UISwitch *svmMode;
@property (strong, nonatomic) IBOutlet UITextField *textFilterLength;
@property (strong, nonatomic) IBOutlet UITextField *textFilterAlphaLength;
@property (strong, nonatomic) IBOutlet UILabel *labelItemLocation;

- (IBAction)resetPriorsClicked:(id)sender;
- (IBAction)textFilterLengthUpdated:(id)sender;
- (IBAction)textFilterAlphaLengthUpdated:(id)sender;
- (IBAction)textItemParameterUpdated:(id)sender;
- (IBAction)textFieldAlphaLengthDidEndOnExit:(id)sender;
- (IBAction)textFieldFilterLengthDidEndOnExit:(id)sender;

@end
