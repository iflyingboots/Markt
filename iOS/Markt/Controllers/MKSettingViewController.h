//
//  MKSettingViewController.h
//  Markt
//
//  Created by sutar on 5/26/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKSettingViewController : UIViewController
- (IBAction)addKeyword:(id)sender;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
