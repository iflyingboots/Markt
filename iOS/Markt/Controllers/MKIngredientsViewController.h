//
//  MKIngredientsViewController.h
//  Markt
//
//  Created by Xin Wang on 5/29/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MKIngredientsViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextView *ingredientsTextView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (copy, nonatomic) NSString *barcode;
@end
