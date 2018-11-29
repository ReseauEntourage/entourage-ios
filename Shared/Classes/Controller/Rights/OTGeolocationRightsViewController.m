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

@import Firebase;

@interface OTGeolocationRightsViewController ()
<
    UITextFieldDelegate,
    GMSAutocompleteFetcherDelegate,
    UITextFieldAutoSuggestionDataSource
>

@property (nonatomic) GMSAutocompleteFetcher *googlePlaceFetcher;
@property (nonatomic) GMSAutocompletePrediction *selectedAddress;
@property (nonatomic, readwrite) NSArray<GMSAutocompletePrediction*> *googlePlacePredictions;

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
    
    self.textField.autoSuggestionDataSource = self;
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
    
    // Create the fetcher.
    self.googlePlaceFetcher = [[GMSAutocompleteFetcher alloc] initWithBounds:bounds
                                                       filter:filter];
    self.googlePlaceFetcher.delegate = self;
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
    
    if (![currentUser isRegisteredForPushNotifications]) {
        [self goToNotifications];
    } else {
        [OTAppState navigateToAuthenticatedLandingScreen];
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
    [self.googlePlaceFetcher sourceTextHasChanged:textField.text];
}

#pragma mark - GMSAutocompleteFetcherDelegate -

- (void)didAutocompleteWithPredictions:(NSArray *)predictions {
    self.googlePlacePredictions = predictions;
    [self.textField reloadContents];
}

- (void)didFailAutocompleteWithError:(NSError *)error {
    self.googlePlacePredictions = @[];
}

#pragma mark - UITextFieldAutoSuggestionDataSource

- (UITableViewCell *)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {

    static NSString *cellIdentifier = @"PlaceAutoSuggestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.contentView.backgroundColor = UIColor.clearColor;
    cell.backgroundColor = [[ApplicationTheme shared].backgroundThemeColor colorWithAlphaComponent:0.8];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 2;
    UIFont *regularFont = [UIFont fontWithName:@"SFUIText-Light" size:15];
    UIFont *boldFont = [UIFont fontWithName:@"SFUIText-Bold" size:15];
    
    if (self.googlePlacePredictions.count > indexPath.row) {
        GMSAutocompletePrediction *prediction = self.googlePlacePredictions[indexPath.row];
        
        if (prediction) {
            NSMutableAttributedString *bolded = [prediction.attributedFullText mutableCopy];
            [bolded enumerateAttribute:kGMSAutocompleteMatchAttribute
                                       inRange:NSMakeRange(0, bolded.length)
                                       options:0
                                    usingBlock:^(id value, NSRange range, BOOL *stop) {
                                            UIFont *font = (value == nil) ? regularFont : boldFont;
                                            [bolded addAttribute:NSFontAttributeName value:font range:range];
                                        }];
            
            cell.textLabel.attributedText = bolded;
        }
    }
    
    return cell;
}

- (NSInteger)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section forText:(NSString *)text {
    return self.googlePlacePredictions.count;
}

- (void)autoSuggestionField:(UITextField *)field textChanged:(NSString *)text {
    [self.googlePlaceFetcher sourceTextHasChanged:text];
}

- (CGFloat)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {
    return 44;
}

- (void)autoSuggestionField:(UITextField *)field tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath forText:(NSString *)text {
    NSLog(@"Selected suggestion at index row - %ld", (long)indexPath.row);
    GMSAutocompletePrediction *prediction = self.googlePlacePredictions[indexPath.row];
    if (prediction) {
        self.textField.text = [prediction attributedFullText].string;
        self.selectedAddress = prediction;
        [self.textField resignFirstResponder];
    }
}

@end
