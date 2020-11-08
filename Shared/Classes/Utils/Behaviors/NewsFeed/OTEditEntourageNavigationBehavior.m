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
#import "OTGMSAutoCompleteViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "LSLDatePickerDialog.h"
#import "entourage-Swift.h"

@interface OTEditEntourageNavigationBehavior ()
<
    LocationSelectionDelegate,
    EditTitleDelegate,
    EditDescriptionDelegate,
    CategorySelectionDelegate,
    OTGMSAutoCompleteViewControllerProtocol
>

@property (nonatomic, strong) OTEntourage *entourage;

@end

@implementation OTEditEntourageNavigationBehavior

- (BOOL)prepareSegue:(UIStoryboardSegue *)segue isAskForHelp:(BOOL) isAskForHelp {
    UIViewController *destinationViewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"CategoryEditSegue"]) {
        if (destinationViewController.navigationController) {
            [OTAppConfiguration configureNavigationControllerAppearance:destinationViewController.navigationController withMainColor:[UIColor whiteColor] andSecondaryColor:[UIColor redColor]];
        }
        
        OTCategoryViewController* controller = (OTCategoryViewController *)destinationViewController;
        controller.categorySelectionDelegate = self;
        controller.selectedCategory = self.entourage.categoryObject;
        controller.isAskForHelp = isAskForHelp;
        return YES;
    }
    
    if (destinationViewController.navigationController) {
        [OTAppConfiguration configureNavigationControllerAppearance:destinationViewController.navigationController];
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

- (void)editEventConfidentiality:(OTEntourage *)entourage {
    self.entourage = entourage;
}

- (void)editDate:(OTEntourage *)entourage isStart:(BOOL)isStartDate {
    self.entourage = entourage;
    
    NSDate *defaultDate;
    NSString * _title = @"";
    NSDate *minimalDate = nil;
    if (isStartDate) {
        _title = OTLocalizedString(@"addEventStartDate");
        if (entourage.startsAt != nil) {
            defaultDate = entourage.startsAt;
        } else {
            defaultDate = [NSDate date];
        }
    }
    else {
        _title = OTLocalizedString(@"addEventEndDate");
        minimalDate = entourage.startsAt;
        if (entourage.endsAt != nil) {
            defaultDate = entourage.endsAt;
        } else {
            defaultDate = [NSDate date];
        }
    }
   
    
    LSLDatePickerDialog *dpDialog = [[LSLDatePickerDialog alloc] init];
    [dpDialog showWithTitle:_title
            doneButtonTitle:OTLocalizedString(@"save").uppercaseString
          cancelButtonTitle:OTLocalizedString(@"cancel").uppercaseString
                defaultDate:defaultDate
                minimumDate:minimalDate
                maximumDate:nil
           buttonTitleColor:[ApplicationTheme shared].backgroundThemeColor
             datePickerMode:UIDatePickerModeDateAndTime
                   callback:^(NSDate * _Nullable date) {
                       if (date) {
                           if (isStartDate) {
                               [self.editEntourageSource updateEventStartDate:date];
                           }
                           else {
                               [self.editEntourageSource updateEventEndDate:date];
                           }
                       }
                   }
     ];
}

- (void)editAddress:(OTEntourage *)entourage {
    self.entourage = entourage;
    
    [self showGooglePlacesAutocompleteAddressController];
}

- (void)showGooglePlacesAutocompleteAddressController {
    OTGMSAutoCompleteViewController *acController = [[OTGMSAutoCompleteViewController alloc] init];
    [acController setup:kGMSPlacesAutocompleteTypeFilterNoFilter];
    acController.delegate = self;
    acController.tintColor = [UIColor appOrangeColor];
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

@end
