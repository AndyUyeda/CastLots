//
//  MoreViewController.m
//  A2:42
//
//  Created by Andy Uyeda on 5/13/15.
//  Copyright (c) 2015 Andy Uyeda. All rights reserved.
//

#import "MoreViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

NSMutableArray *titleArray;



- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.titleView = [[UIView alloc] init];
    self.revealViewController.delegate = self;
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    titleArray = [[prefs objectForKey:@"recentTitles"] mutableCopy];
    NSLog(@"%@",titleArray);
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [titleArray count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Recent";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:[titleArray objectAtIndex:indexPath.row] forKey:@"load"];
    [prefs synchronize];
    [self.revealViewController revealToggle:self];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
