//
//  OTLocationSearchTableViewController.h
//  entourage
//
//  Created by Ciprian Habuc on 07/06/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OTLocationSelectorViewController.h"

@interface OTLocationSearchTableViewController : UITableViewController<UISearchResultsUpdating>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, weak) id<HandleMapSearch> pinDelegate;

@end
