//
//  OTGMSAutoCompleteViewController.m
//  entourage
//
//  Created by Work on 27/11/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTGMSAutoCompleteViewController.h"
#import <Foundation/Foundation.h>
#import <GooglePlaces/GooglePlaces.h>
#import "entourage-Swift.h"

@interface OTGMSAutoCompleteViewController () < GMSAutocompleteViewControllerDelegate >
@end

@implementation OTGMSAutoCompleteViewController

- (void)setup:(GMSPlacesAutocompleteTypeFilter)filterType {
    // Set bounds to France.
    CLLocationCoordinate2D neBoundsCorner = CLLocationCoordinate2DMake(50.77, 6.04);
    CLLocationCoordinate2D swBoundsCorner = CLLocationCoordinate2DMake(43.57, -1.97);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:neBoundsCorner
                                                                       coordinate:swBoundsCorner];
    
    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = filterType;
    
    // Create and set Autocomplete VC
    [self setAutocompleteBounds:bounds];
    [self setAutocompleteFilter:filter];

    self.primaryTextHighlightColor = [ApplicationTheme shared].backgroundThemeColor;
    self.primaryTextColor = self.secondaryTextColor;
    self.tintColor = [ApplicationTheme shared].backgroundThemeColor;
    
    // Color of typed text in the search bar.
    NSDictionary *searchBarTextAttributes = @{
                                              NSForegroundColorAttributeName: [UIColor whiteColor],
                                              NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                              };
    [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
    .defaultTextAttributes = searchBarTextAttributes;
    
    // Color of the placeholder text in the search bar prior to text entry.
    NSDictionary *placeholderAttributes = @{
                                            NSForegroundColorAttributeName: [UIColor whiteColor],
                                            NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                            };
    
    // Color of the default search text.
    NSAttributedString *attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:OTLocalizedString(@"searchForAddress")
                                    attributes:placeholderAttributes];
    [UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]]
    .attributedPlaceholder = attributedPlaceholder;
    
    // To style the two image icons in the search bar (the magnifying glass
    // icon and the 'clear text' icon), replace them with different images.
    [[UISearchBar appearance] setImage:[UIImage imageNamed:@"whiteSearch"]
                      forSearchBarIcon:UISearchBarIconSearch
                                 state:UIControlStateNormal];
    
    // Color of the in-progress spinner.
    [[UIActivityIndicatorView appearance] setColor:[ApplicationTheme shared].backgroundThemeColor];
}

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    // TO OVERRIDE
}

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error {
    // TO OVERRIDE
}

- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController {
    // TO OVERRIDE
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
