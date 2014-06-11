//
//  MKIngredientsViewController.m
//  Markt
//
//  Created by Xin Wang on 5/29/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKIngredientsViewController.h"
#import <AFNetworking.h>
#import <TSMessage.h>
#import <SVProgressHUD.h>

@interface MKIngredientsViewController () <UITableViewDelegate, UITableViewDataSource, UIBarPositioningDelegate>
@property (strong, nonatomic) NSDictionary *ingredientsData;
@end

@implementation MKIngredientsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
    dismissButton.tintColor = [UIColor whiteColor];
    self.navigationItem.title = self.barcode;
    self.navigationItem.leftBarButtonItem = dismissButton;
    [self getIngredientsData];
    self.tableView.scrollEnabled = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - API

- (NSArray *)loadUserKeywords
{
    return (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userKeywords"];
}


- (void)getIngredientsData
{
    NSArray *userKeywords = [self loadUserKeywords];
    NSString *keywords = [userKeywords componentsJoinedByString:@","];

    NSString *URLString = [NSString stringWithFormat:@"http://markt.wangx.in/contains/%@/%@", self.barcode, keywords];
    [SVProgressHUD show];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        self.ingredientsData = responseObject;
        self.ingredientsTextView.text = self.ingredientsData[@"ingredients"];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [TSMessage showNotificationInViewController:self title:error.localizedDescription subtitle:nil type:TSMessageNotificationTypeError];
    }];
}

#pragma mark - Delegates
- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

#pragma mark - Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.ingredientsData[@"allergen"] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AllergenCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *allergenNameLabel;
    UILabel *allergenInfoLabel;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        allergenNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, 150, 20)];
        allergenInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 50, 20)];
        [cell addSubview:allergenNameLabel];
        [cell addSubview:allergenInfoLabel];
    }
    
    NSUInteger row = indexPath.row;
    allergenNameLabel.text = self.ingredientsData[@"allergen"][row][@"name"];
    allergenInfoLabel.text = self.ingredientsData[@"allergen"][row][@"contains"];
    if ([allergenInfoLabel.text isEqualToString:@"Yes"]) {
        allergenInfoLabel.textColor = [UIColor redColor];
    }
    
    return cell;
}

@end
