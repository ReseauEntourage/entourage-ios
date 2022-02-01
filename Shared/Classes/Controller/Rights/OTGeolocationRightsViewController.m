//
//  OTGeolocationRightsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTGeolocationRightsViewController.h"
#import "OTConsts.h"
#import "UIView+entourage.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "UINavigationController+entourage.h"
#import "UIBarButtonItem+factory.h"
#import "OTAppConfiguration.h"
#import "UITextField+AutoSuggestion.h"
#import "OTGMSAutoCompleteViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "OTAuthService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "entourage-Swift.h"

@import Firebase;

@interface OTGeolocationRightsViewController ()
<
    OTGMSAutoCompleteViewControllerProtocol,
    UITextFieldDelegate
>

@property (nonatomic) OTGMSAutoCompleteViewController *googlePlaceViewController;
@property (nonatomic) GMSPlace *selectedAddress;

@end

@implementation OTGeolocationRightsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [ApplicationTheme shared].backgroundThemeColor;
    
    self.continueButton.backgroundColor = [UIColor whiteColor];
    self.continueButton.layer.cornerRadius = self.continueButton.frame.size.width / 2;
    UIImage *image = [self.continueButton imageForState:UIControlStateNormal];
    [self.continueButton setImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.continueButton.tintColor = [ApplicationTheme shared].backgroundThemeColor;
    self.privacyIconImage.image = [self.privacyIconImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.privacyIconImage.tintColor = [UIColor whiteColor];

    self.rightsDescLabel.attributedText = [OTAppAppearance defineActionZoneFormattedDescription];
    self.rightsTitleLabel.text = [OTAppAppearance defineActionZoneTitleForUser:nil];
    self.textField.placeholder = [OTAppAppearance defineActionZoneSampleAddress];
    
    [self setupGoogleAutocompleteViewController];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.isShownOnStartup) {
        self.title = @"";
        [self.navigationController presentTransparentNavigationBar];
        
        if (![OTAppConfiguration shouldAlwaysRequestUserToAddActionZone]) {
            [self addIgnoreButton];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(locationAuthorizationChanged:)
                                                 name: kNotificationLocationAuthorizationChanged
                                               object:nil];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)setupGoogleAutocompleteViewController {
    GMSPlacesAutocompleteTypeFilter filterType;
    if ([OTAppConfiguration isApplicationTypeEntourage]) {
        filterType = kGMSPlacesAutocompleteTypeFilterGeocode;
    } else {
        filterType = kGMSPlacesAutocompleteTypeFilterNoFilter;
    }

    self.googlePlaceViewController = [[OTGMSAutoCompleteViewController alloc] init];
    [self.googlePlaceViewController setup:filterType];
    self.googlePlaceViewController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}

- (void)addIgnoreButton {
    UIBarButtonItem *ignoreButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"doIgnore").capitalizedString
                                                          withTarget:self
                                                           andAction:@selector(ignore)
                                                             andFont:@"SFUIText-Bold"
                                                             colored:[UIColor whiteColor]];
    [self.navigationItem setRightBarButtonItem:ignoreButton];
}

#pragma mark - Private

#pragma mark - App authorization notifications

- (void)locationAuthorizationChanged:(NSNotification *)notification {
    BOOL locationAllowed = [notification readAllowedLocation];
    [FIRAnalytics setUserPropertyString:(locationAllowed ? @"YES" : @"NO") forName:@"EntourageGeolocEnable"];
    
    [OTPushNotificationsService getAuthorizationStatusWithCompletionHandler:^(UNAuthorizationStatus status) {
        if (@available(iOS 12.0, *)) {
            if (status == UNAuthorizationStatusProvisional)
                status = UNAuthorizationStatusNotDetermined;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (status == UNAuthorizationStatusNotDetermined) {
                [self goToNotifications];
            } else {
                [OTAppState navigateToAuthenticatedLandingScreen];
            }
        });
    }];
}

#pragma mark - IBAction

- (void)goToNotifications {
    [self performSegueWithIdentifier:@"GeoToNotificationsSegue" sender:self];
}

- (void)ignore {
    [[OTLocationManager sharedInstance] startLocationUpdates];
}

- (IBAction)doContinue {
    
    if (!self.selectedAddress.placeID) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"invalidAddress") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self.textField resignFirstResponder];
    
    [SVProgressHUD show];
    [OTAuthService updateUserAddressWithPlaceId:self.selectedAddress.placeID isSecondaryAddress:NO completion:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
        } else {
            [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"addressSaved")];
            
            OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
            
            if (self.isShownOnStartup) {
                [OTLogger logEvent:@"AcceptGeoloc"];
                
                [OTPushNotificationsService getAuthorizationStatusWithCompletionHandler:^(UNAuthorizationStatus status) {
                    if (@available(iOS 12.0, *)) {
                        if (status == UNAuthorizationStatusProvisional)
                            status = UNAuthorizationStatusNotDetermined;
                    }

                    BOOL pushNotificationsEnabled = status != UNAuthorizationStatusNotDetermined;
                    
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        if ([OTLocationManager sharedInstance].isAuthorized &&
                            pushNotificationsEnabled &&
                            [currentUser hasActionZoneDefined]) {
                            [OTAppState navigateToAuthenticatedLandingScreen];
                        }
                        else if (!pushNotificationsEnabled) {
                            [self goToNotifications];
                        }
                        else if (![OTLocationManager sharedInstance].isAuthorized ) {
                            [[OTLocationManager sharedInstance] startLocationUpdates];
                            
                        } else {
                            [OTAppState navigateToAuthenticatedLandingScreen];
                        }
                    });
                }];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self presentViewController:self.googlePlaceViewController animated:YES completion:nil];
}

#pragma mark - GMSAutocompleteViewControllerDelegate

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(nonnull GMSPlace *)place {
    [self.textField setText:place.formattedAddress];
    self.selectedAddress = place;

    [self doContinue];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewController:(nonnull GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(nonnull NSError *)error {
    NSLog(@"%@", error);
    // TODO : Deal with error
}

- (void)wasCancelled:(nonnull GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
