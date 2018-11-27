//
//  OTGeolocationRightsViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 13/07/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTGeolocationRightsViewController.h"
#import "OTConsts.h"
#import "UIView+entourage.h"
#import "OTLocationManager.h"
#import "NSNotification+entourage.h"
#import "UINavigationController+entourage.h"
#import "UIBarButtonItem+factory.h"
#import <Mixpanel/Mixpanel.h>
#import "OTAppConfiguration.h"
#import "UITextField+AutoSuggestion.h"
#import <GooglePlaces/GooglePlaces.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "OTAuthService.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "entourage-Swift.h"
#import "UIColor+entourage.h"

@import Firebase;

@interface OTGeolocationRightsViewController ()
<
    GMSAutocompleteViewControllerDelegate,
    UITextFieldDelegate
>

@property (nonatomic) GMSAutocompleteViewController *googlePlaceViewController;
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
    
    [self setupGoogleAutocompleteFetcher];
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

- (void)setupGoogleAutocompleteFetcher {
    
    self.textField.minCharsToShow = 2;
    self.textField.maxNumberOfRows = 3;
    [self.textField observeTextFieldChanges];
    
    [self.textField addTarget:self
                   action:@selector(textFieldDidChange:)
         forControlEvents:UIControlEventEditingChanged];
    
    // Set bounds to France, non comprehensive but including Lille, Rennes, Grenoble, Lyon, Paris
    CLLocationCoordinate2D neBoundsCorner = CLLocationCoordinate2DMake(50.77, 6.04);
    CLLocationCoordinate2D swBoundsCorner = CLLocationCoordinate2DMake(43.57, -1.97);
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:neBoundsCorner
                                                                       coordinate:swBoundsCorner];
    
    // Set up the autocomplete filter.
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    if ([OTAppConfiguration isApplicationTypeEntourage]) {
        filter.type = kGMSPlacesAutocompleteTypeFilterGeocode;
    } else if ([OTAppConfiguration isApplicationTypeVoisinAge]) {
        filter.type = kGMSPlacesAutocompleteTypeFilterAddress;
    }
    
    // Create and set Autocomplete VC
    self.googlePlaceViewController = [[GMSAutocompleteViewController alloc] init];
    [self.googlePlaceViewController setAutocompleteBounds:bounds];
    [self.googlePlaceViewController setAutocompleteFilter:filter];
    
    self.googlePlaceViewController.primaryTextHighlightColor = UIColor.appOrangeColor;
    
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
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    BOOL locationAllowed = [notification readAllowedLocation];
    [mixpanel.people set:@{@"EntourageGeolocEnable": locationAllowed ? @"YES" : @"NO"}];
    [FIRAnalytics setUserPropertyString:(locationAllowed ? @"YES" : @"NO") forName:@"EntourageGeolocEnable"];
    
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    
    if ([currentUser hasActionZoneDefined]) {
        if (![currentUser isRegisteredForPushNotifications]) {
            [self goToNotifications];
        } else {
            [OTAppState navigateToAuthenticatedLandingScreen];
        }
    }
    else if (!locationAllowed) {
        [self performSegueWithIdentifier:@"NoLocationRightsSegue" sender:self];
    }
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
    [OTAuthService updateUserAddressWithPlaceId:self.selectedAddress.placeID completion:^(NSError *error) {
        if (error) {
            [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"generic_error")];
        } else {
            [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"addressSaved")];
            
            if (self.isShownOnStartup) {
                OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
                [OTLogger logEvent:@"AcceptGeoloc"];
                BOOL pushNotificationsEnabled = [currentUser isRegisteredForPushNotifications];
                
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
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField {
    NSLog(@"%@", textField.text);
}

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
