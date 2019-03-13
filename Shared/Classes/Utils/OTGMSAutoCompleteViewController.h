//
//  OTGMSAutoCompleteViewController.h
//  entourage
//
//  Created by Work on 27/11/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <GooglePlaces/GooglePlaces.h>

@protocol OTGMSAutoCompleteViewControllerProtocol <GMSAutocompleteViewControllerDelegate>

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place;
- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error;
- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController;

@end

@interface OTGMSAutoCompleteViewController : GMSAutocompleteViewController

- (void)setup:(GMSPlacesAutocompleteTypeFilter)filterType;

@end
