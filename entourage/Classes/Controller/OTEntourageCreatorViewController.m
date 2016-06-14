//
//  OTEntourageCreatorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 10/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageCreatorViewController.h"
#import "OTTextView.h"
#import "OTConsts.h"
#import "OTEntourage.h"
#import "OTLocationSelectorViewController.h"
#import "OTEncounterService.h"

// Helpers
#import "UIViewController+menu.h"
#import "UITextField+indentation.h"

// Progress HUD
#import "SVProgressHUD.h"

@interface OTEntourageCreatorViewController() <LocationSelectionDelegate>

@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet OTTextView *titleTextView;
@property (nonatomic, weak) IBOutlet OTTextView *descriptionTextView;

@end


@implementation OTEntourageCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"validate")
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(sendEntourage:)];
    [self.navigationItem setRightBarButtonItem:menuButton];
    
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *typeString = [self.type isEqualToString: ENTOURAGE_DEMANDE] ? OTLocalizedString(@"demande") : OTLocalizedString(@"contribution");
    self.title =  typeString.uppercaseString;
}



- (void)viewWillDisappear:(BOOL)animated {
    self.title = @"";
}

#pragma mark - Private

- (void)setupUI {
    [self.titleTextView         setTextContainerInset:UIEdgeInsetsMake(TEXTVIEW_PADDING_TOP, TEXTVIEW_PADDING, TEXTVIEW_PADDING_BOTTOM, 2*TEXTVIEW_PADDING)];
    [self.descriptionTextView   setTextContainerInset:UIEdgeInsetsMake(TEXTVIEW_PADDING_TOP, TEXTVIEW_PADDING, TEXTVIEW_PADDING_BOTTOM, 2*TEXTVIEW_PADDING)];
    NSString *typeString = [self.type isEqualToString: ENTOURAGE_DEMANDE] ? OTLocalizedString(@"demande") : OTLocalizedString(@"contribution");
    NSString *titlePlaceholder = [NSString stringWithFormat:OTLocalizedString(@"entourageTitle"), typeString.lowercaseString];
    [self.titleTextView setPlaceholder:titlePlaceholder];
    [self.titleTextView showCharCount];
    [self.descriptionTextView setPlaceholder:OTLocalizedString(@"detailedDescription")];

    [self updateLocationTitle];
}

- (void)updateLocationTitle {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.thoroughfare !=  nil) {
            [self.locationButton setTitle:placemark.thoroughfare forState:UIControlStateNormal];
        } else {
            [self.locationButton setTitle:placemark.locality forState:UIControlStateNormal];
        }
    }];
}

- (void)sendEntourage:(UIButton*)sender {
    NSArray* words = [self.titleTextView.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    
    if (!nospacestring.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"invalidTitle")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alert animated:YES completion:nil];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {}];
        
        [alert addAction:defaultAction];
        return;
    }
    
    
    sender.enabled = NO;
    __block OTEntourage *entourage = [[OTEntourage alloc] init];
    entourage.type = self.type;
    entourage.location = self.location;
    entourage.title = self.titleTextView.text;
    entourage.desc = self.descriptionTextView.text;
    entourage.status = ENTOURAGE_STATUS_OPEN;
    [SVProgressHUD show];
    [[OTEncounterService new] sendEntourage:entourage
                                withSuccess:^(OTEntourage *sentEncounter) {
                                    [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageCreated")];
                                    if ([self.entourageCreatorDelegate respondsToSelector:@selector(didCreateEntourage)]) {
                                        [self.entourageCreatorDelegate performSelector:@selector(didCreateEntourage)];
                                    }
                                } failure:^(NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotCreated")];
                                    sender.enabled = YES;
                                }];
}

#pragma mark - LocationSelectionDelegate

- (void)didSelectLocation:(CLLocation *)selectedLocation {
    self.location = selectedLocation;
    
    [self updateLocationTitle];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    UIViewController *destinationViewController = segue.destinationViewController;
    if ([destinationViewController isKindOfClass:[OTLocationSelectorViewController class]]) {
        ((OTLocationSelectorViewController*)destinationViewController).locationSelectionDelegate = self;
    }
}

@end
