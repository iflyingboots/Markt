//
//  MKSettingViewController.m
//  Markt
//
//  Created by sutar on 5/26/14.
//  Copyright (c) 2014 SPS. All rights reserved.
//

#import "MKSettingViewController.h"

@interface MKSettingViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
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

#pragma mark - Actions

- (IBAction)addKeyword:(id)sender
{
    UIAlertView *inputView = [[UIAlertView alloc] init];
    inputView.delegate = self;
    [inputView setTitle:@"Enter the keyword"];
    [inputView addButtonWithTitle:@"Okay"];
    inputView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [inputView show];
}

- (void)storeUserKeywords
{
    [[NSUserDefaults standardUserDefaults] setObject:self.userKeywords forKey:@"userKeywords"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)loadUserKeywords
{
    return (NSArray *)[[NSUserDefaults standardUserDefaults] objectForKey:@"userKeywords"];
}

#pragma mark - Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UITextField *inputField = [alertView textFieldAtIndex:0];
    NSString *inputString = inputField.text;
    [self.userKeywords addObject:inputString];
    [self storeUserKeywords];
    [self.tableView reloadData];
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
//    [self.tableView reloadData];
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
