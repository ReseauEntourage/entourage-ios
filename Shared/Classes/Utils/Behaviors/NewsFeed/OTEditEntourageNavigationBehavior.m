//
//  OTEditEntourageNavigationBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 18/05/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTEditEntourageNavigationBehavior.h"
#import "OTLocationSelectorViewController.h"
#import "OTEditEntourageTableSource.h"
#import "OTEditEntourageTitleViewController.h"
#import "OTEditEntourageDescViewController.h"
#import "OTCategoryViewController.h"
#import <GooglePlaces/GooglePlaces.h>
#import <CoreLocation/CoreLocation.h>
#import "LSLDatePickerDialog.h"
#import "entourage-Swift.h"

@interface OTEditEntourageNavigationBehavior ()
<
    LocationSelectionDelegate,
    EditTitleDelegate,
    EditDescriptionDelegate,
    CategorySelectionDelegate,
    GMSAutocompleteViewControllerDelegate
>

@property (nonatomic, strong) OTEntourage *entourage;

@end

@implementation OTEditEntourageNavigationBehavior

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue {
    UIViewController *destinationViewController = segue.destinationViewController;
    if (destinationViewController.navigationController) {
        [OTAppConfiguration configureNavigationControllerAppearance:destinationViewController.navigationController];
    }
    
    if ([segue.identifier isEqualToString:@"CategoryEditSegue"]) {
        OTCategoryViewController* controller = (OTCategoryViewController *)destinationViewController;
        controller.categorySelectionDelegate = self;
        controller.selectedCategory = self.entourage.categoryObject;
        return YES;
    }
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        [OTLogger logEvent:@"ChangeLocationClick"];
        OTLocationSelectorViewController* controller = (OTLocationSelectorViewController *)destinationViewController;
        controller.locationSelectionDelegate = self;
        controller.selectedLocation = self.entourage.location;
        return YES;
    }
    if ([segue.identifier isEqualToString:@"TitleEditSegue"]) {
        OTEditEntourageTitleViewController* controller = (OTEditEntourageTitleViewController *)destinationViewController;
        controller.delegate = self;
        controller.currentTitle = self.entourage.title;
        controller.currentEntourage = self.entourage;
        return YES;
    }
    if ([segue.identifier isEqualToString:@"DescriptionEditSegue"]) {
        OTEditEntourageDescViewController* controller = (OTEditEntourageDescViewController *)destinationViewController;
        controller.delegate = self;
        controller.currentDescription = self.entourage.desc;
        controller.currentEntourage = self.entourage;
        return YES;
    }
    return NO;
}

- (void)editLocation:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"EditLocation" sender:self];
}

- (void)editTitle:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"TitleEditSegue" sender:self];
}

- (void)editDescription:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"DescriptionEditSegue" sender:self];
}

- (void)editCategory:(OTEntourage *)entourage {
    self.entourage = entourage;
    [self.owner performSegueWithIdentifier:@"CategoryEditSegue" sender:self];
}

- (void)editDate:(OTEntourage *)entourage {
    self.entourage = entourage;
    
    LSLDatePickerDialog *dpDialog = [[LSLDatePickerDialog alloc] init];
    [dpDialog showWithTitle:OTLocalizedString(@"addEventDate")
            doneButtonTitle:OTLocalizedString(@"save").uppercaseString
          cancelButtonTitle:OTLocalizedString(@"cancel").uppercaseString
                defaultDate:[NSDate date]
                minimumDate:nil
                maximumDate:nil
           buttonTitleColor:[ApplicationTheme shared].backgroundThemeColor
             datePickerMode:UIDatePickerModeDateAndTime
                   callback:^(NSDate * _Nullable date) {
                       if (date) {
                           [self.editEntourageSource updateEventStartDate:date];
                       }
                   }
     ];
}

- (void)editAddress:(OTEntourage *)entourage {
    [self showGooglePlacesAutocompleteAddressController];
}

- (void)showGooglePlacesAutocompleteAddressController {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.primaryTextHighlightColor = [ApplicationTheme shared].backgroundThemeColor;
    acController.primaryTextColor = acController.secondaryTextColor;
    acController.tintColor = [ApplicationTheme shared].backgroundThemeColor;
    acController.autocompleteBoundsMode = kGMSAutocompleteBoundsModeRestrict;
    
    [OTAppConfiguration configureNavigationControllerAppearance:acController.navigationController];
    
    /*
     * if we have the device location: 20km radius around the user (so 40x40km square)
     * else: North-East lat=51,lng=9 to South-West lat=42,lng=-5 (a rectangle roughly around France)
     The other parameters are left to their default ("bounds mode" set to "bias", no "type" filtering).
     */
    acController.autocompleteBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:(CLLocationCoordinate2DMake(51, 9))
                                                                           coordinate:CLLocationCoordinate2DMake(42, -5)];
    
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
    
    [self.owner presentViewController:acController animated:YES completion:nil];
}

#pragma mark - LocationSelectionDelegate

- (void)didSelectLocation:(CLLocation *)selectedLocation {
    self.entourage.location = selectedLocation;
    [self.editEntourageSource updateLocationTitle];
}

#pragma mark - EditTitleDelegate

- (void)titleEdited:(NSString *)title {
    self.entourage.title = title;
    [self.editEntourageSource updateTexts];
}

#pragma mark - EditDescriptionDelegate

- (void)descriptionEdited:(NSString *)description {
    self.entourage.desc = description;
    [self.editEntourageSource updateTexts];
}

#pragma mark - CategorySelectionDelegate

- (void)didSelectCategory:(OTCategory *)category {
    self.entourage.categoryObject = category;
    self.entourage.category = category.category;
    self.entourage.entourage_type = category.entourage_type;
    [self.editEntourageSource updateTexts];
}

#pragma mark - Google Places -

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self.owner dismissViewControllerAnimated:YES completion:nil];
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    NSLog(@"Place attributions %@", place.attributions.string);
    
    self.entourage.streetAddress = place.formattedAddress;
    self.entourage.location = [[CLLocation alloc] initWithLatitude:place.coordinate.latitude longitude:place.coordinate.longitude];
    self.entourage.googlePlaceId = place.placeID;
    self.entourage.placeName = place.name;
    
    [self.editEntourageSource updateLocationAddress:place.formattedAddress
                                          placeName:place.name
                                            placeId:place.placeID
                                     displayAddress:place.formattedAddress];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self.owner dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self.owner dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

@end
