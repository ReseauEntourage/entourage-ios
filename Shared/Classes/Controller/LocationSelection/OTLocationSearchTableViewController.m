//
//  OTLocationSearchTableViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 07/06/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTLocationSearchTableViewController.h"

@interface OTLocationSearchTableViewController () 

@property (nonatomic, strong) NSArray<MKMapItem *> *matchingItems;


@end

@implementation OTLocationSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.matchingItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locationSearchCell" forIndexPath:indexPath];
    
    // Configure the cell...
    MKPlacemark *selectedItem = self.matchingItems[indexPath.row].placemark;
    cell.textLabel.text = selectedItem.name;
    cell.detailTextLabel.text = selectedItem.locality;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.pinDelegate respondsToSelector:@selector(dropPinZoomIn:)])
        [self.pinDelegate dropPinZoomIn:_matchingItems[indexPath.row].placemark];
}


#pragma mark UISearchResultsUpdating

- (void) updateSearchResultsForSearchController:(UISearchController *)searchController {
    MKLocalSearchRequest *request = [MKLocalSearchRequest new];
    request.naturalLanguageQuery = searchController.searchBar.text;
    request.region = self.mapView.region;
    
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        self.matchingItems = response == nil ? @[] : response.mapItems;
        if(error == nil)
            [self.tableView reloadData];
    }];
}

@end
