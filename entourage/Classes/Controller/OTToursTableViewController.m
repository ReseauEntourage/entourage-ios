//
//  OTToursTableViewController.m
//  entourage
//
//  Created by Nicolas Telera on 19/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

// Controller
#import "OTToursTableViewController.h"
#import "OTTourViewController.h"

// Model
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTOrganization.h"

/*************************************************************************************************/
#pragma mark - OTToursTableViewController

@interface OTToursTableViewController ()

@property (nonatomic, strong) OTTour *selectedTour;

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
    self.tableData = (NSMutableArray *)[self.tableData sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [[[(OTTour *)a tourPoints] objectAtIndex:0] passingTime];
        NSDate *second = [[[(OTTour *)b tourPoints] objectAtIndex:0] passingTime];
        return [second compare:first];
    }];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TourCell" forIndexPath:indexPath];
    
    OTTour *tour = self.tableData[indexPath.row];
    
    cell.textLabel.text = tour.organizationName;
    NSString *type;
    if ([tour.tourType isEqualToString:@"barehands"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_bare_hands.png"];
        type = @"A mains nues";
    }
    else if ([tour.tourType isEqualToString:@"medical"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_medical.png"];
        type = @"Médical";
    }
    else if ([tour.tourType isEqualToString:@"alimentary"]) {
        cell.imageView.image = [UIImage imageNamed:@"ic_alimentary.png"];
        type = @"Alimentaire";
    }
    if ([tour.tourPoints count] != 0) {
        NSString *date = [self formatDateForDisplay:[(OTTourPoint *)[tour.tourPoints objectAtIndex:0] passingTime]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  -  %@", date, type];
    } else {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@  -  %@", @"--/--/---", type];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedTour = self.tableData[indexPath.row];
    [self performSegueWithIdentifier:@"OTSelectedTour" sender:self];
}

/********************************************************************************/
#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OTSelectedTour"]) {
        OTTourViewController *controller = (OTTourViewController *)segue.destinationViewController;
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [controller configureWithTour:self.selectedTour];
    }
}

/**************************************************************************************************/
#pragma mark - Actions

- (IBAction)closeModal:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
