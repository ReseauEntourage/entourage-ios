//
//  OTToursTableViewController.m
//  entourage
//
//  Created by Nicolas Telera on 19/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTToursTableViewController.h"
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTOrganization.h"

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

- (NSString *)formatDateForDisplay:(NSDate *)date {
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"dd/MM/yyyy"];
    return [formatter stringFromDate:date];
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
    OTOrganization *organization = [[OTOrganization alloc] initWithDictionary:tour.organization];

    NSString *type;
    if ([tour.tourType isEqualToString:@"social"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_social.png"];
        type = @"A mains nues";
    }
    else if ([tour.tourType isEqualToString:@"other"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_other.png"];
        type = @"Médical";
    }
    else if ([tour.tourType isEqualToString:@"food"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_food.png"];
        type = @"Alimentaire";
    }
    cell.textLabel.text = organization.name;
    if ([tour.tourPoints count] != 0) {
        NSString *date = [self formatDateForDisplay:[(OTTourPoint *)[tour.tourPoints objectAtIndex:0] passingTime]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  -  %@", date, type];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  -  %@", @"--/--/---", type];
    }
    return cell;
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
