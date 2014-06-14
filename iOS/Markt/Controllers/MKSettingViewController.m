//
//  MKSettingViewController.m
//  Markt
//
//  Created by Xin Wang on 5/26/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKSettingViewController.h"
#import <AFNetworking.h>
#import <SVProgressHUD.h>
#import <TSMessage.h>

#define SEARCH_ALERT_TAG 10
#define ADD_ALERT_TAG 11

@interface MKSettingViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, UINavigationBarDelegate>
@property (strong, nonatomic) NSMutableArray *userKeywords;
@end

@implementation MKSettingViewController

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
    self.userKeywords = [NSMutableArray arrayWithArray:[self loadUserKeywords]];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - API

- (void)getItemLocation:(NSString *)item
{
    NSString *URLString = [NSString stringWithFormat:@"http://markt.wangx.in/item/%@", item];
    [SVProgressHUD show];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:URLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSString *msg = [NSString stringWithFormat:@"Cell %@", responseObject[@"cell"]];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        [TSMessage showNotificationInViewController:self title:error.localizedDescription subtitle:nil type:TSMessageNotificationTypeError];
    }];
}



#pragma mark - Actions

- (IBAction)searchButtonClicked:(id)sender
{
    UIAlertView *inputView = [[UIAlertView alloc] init];
    inputView.delegate = self;
    inputView.tag = SEARCH_ALERT_TAG;
    [inputView setTitle:@"Search item"];
    [inputView addButtonWithTitle:@"Search"];
    inputView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [inputView show];
}

/**
 *  Add a keyword from user input
 *
 *  @param sender
 */
- (IBAction)addKeyword:(id)sender
{
    UIAlertView *inputView = [[UIAlertView alloc] init];
    inputView.tag = ADD_ALERT_TAG;
    inputView.delegate = self;
    [inputView setTitle:@"Enter the keyword"];
    [inputView addButtonWithTitle:@"Okay"];
    inputView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [inputView show];
}

/**
 *  Store keywords to user defaults
 */
- (void)storeUserKeywords
{
    [[NSUserDefaults standardUserDefaults] setObject:self.userKeywords forKey:@"userKeywords"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  Loads keywords from user defaults
 *
 *  @return NSArray
 */
- (NSArray *)loadUserKeywords
{
    return (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userKeywords"];
}

#pragma mark - Delegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    UITextField *inputField = [alertView textFieldAtIndex:0];
    NSString *inputString = inputField.text;
    if (alertView.tag == ADD_ALERT_TAG) {
        [self.userKeywords addObject:inputString];
        [self storeUserKeywords];
        [self.tableView reloadData];
    }
    if (alertView.tag == SEARCH_ALERT_TAG) {
        [self getItemLocation:inputString];
    }

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }
    [self.userKeywords removeObjectAtIndex:indexPath.row];
    [self storeUserKeywords];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


#pragma mark - Data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.userKeywords count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"KeywordCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = self.userKeywords[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
