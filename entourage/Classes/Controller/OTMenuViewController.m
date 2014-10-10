//
//  OTMenuViewController.m
//  entourage
//
//  Created by Cedric Pointel on 10/10/2014.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTMenuViewController.h"

NSString * const OTMenuTableViewCellIdentifier = @"OTMenuTableViewCellIdentifier";

@interface OTMenuViewController () <UITableViewDataSource, UITableViewDelegate>

/**************************************************************************************************/
#pragma mark - Getters and Setters

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation OTMenuViewController

/**************************************************************************************************/
#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:OTMenuTableViewCellIdentifier];
}

@end
    