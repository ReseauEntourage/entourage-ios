//
//  OTToursTableViewController.m
//  entourage
//
//  Created by Nicolas Telera on 19/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTToursTableViewController.h"
#import "OTTour.h"

/*************************************************************************************************/
#pragma mark - OTToursTableViewController

@interface OTToursTableViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *backButton;

@end

@implementation OTToursTableViewController

/**************************************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

/**************************************************************************************************/
#pragma mark - Public Methods

- (void)configureWithTours:(NSMutableArray *)closeTours {
    self.tableData = closeTours;
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TourCell"
                                                            forIndexPath:indexPath];
    OTTour *tour = self.tableData[indexPath.row];
    cell.textLabel.text = tour.status;
    if ([tour.tourType isEqualToString:@"social"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_social.png"];
    }
    else if ([tour.tourType isEqualToString:@"other"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_other.png"];
    }
    else if ([tour.tourType isEqualToString:@"food"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_food.png"];
    }
    return cell;
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
