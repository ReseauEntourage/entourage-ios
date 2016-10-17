//
//  OTEntourageEditorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 10/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourageEditorViewController.h"
#import "OTTextWithCount.h"
#import "OTConsts.h"
#import "OTEntourage.h"
#import "OTLocationSelectorViewController.h"
#import "OTEncounterService.h"
#import "UIColor+entourage.h"

// Helpers
#import "UIViewController+menu.h"
#import "UITextField+indentation.h"
#import "UIBarButtonItem+factory.h"

#import "OTCountSpeechBehavior.h"

// Progress HUD
#import "SVProgressHUD.h"
#import "OTEntourageDisclaimerBehavior.h"

@interface OTEntourageEditorViewController() <LocationSelectionDelegate>

@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet OTTextWithCount *titleTextView;
@property (nonatomic, weak) IBOutlet OTTextWithCount *descriptionTextView;

@property (nonatomic, weak) IBOutlet OTCountSpeechBehavior *titleSpeechBehavior;
@property (nonatomic, weak) IBOutlet OTCountSpeechBehavior *descriptionSpeechBehavior;
@property (nonatomic, weak) IBOutlet OTEntourageDisclaimerBehavior *disclaimer;

@end

@implementation OTEntourageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self.titleSpeechBehavior initialize];
    [self.descriptionSpeechBehavior initialize];
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate") withTarget:self andAction:@selector(sendEntourage:) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    [self.disclaimer showDisclaimer];
}

- (void)viewWillAppear:(BOOL)animated {
    NSString *typeString = [self.type isEqualToString: ENTOURAGE_DEMANDE] ? OTLocalizedString(@"demande") : OTLocalizedString(@"contribution");
    self.title =  typeString.uppercaseString;
}

#pragma mark - Private

- (void)setupUI {
    BOOL isDemand = [self.type isEqualToString: ENTOURAGE_DEMANDE];
    self.titleTextView.maxLength = 150;
    self.titleTextView.placeholder = OTLocalizedString(isDemand ? @"edit_demand_title" : @"edit_contribution_title");
    self.titleTextView.editingPlaceholder = [NSString stringWithFormat:OTLocalizedString(@"edit_entourage_title"), [OTLocalizedString(isDemand ? @"demande" : @"contribution") lowercaseString]];
    self.descriptionTextView.placeholder = OTLocalizedString(isDemand ? @"edit_demand_desc" : @"edit_contribution_desc");
    self.descriptionTextView.editingPlaceholder = OTLocalizedString(@"detailedDescription");
    if(self.entourage) {
        self.type = self.entourage.type;
        self.location = self.entourage.location;
        if(self.entourage.title.length > 0) {
            self.titleTextView.textView.text = self.entourage.title;
            [self.titleTextView updateAfterSpeech];
        }
        if(self.entourage.desc.length > 0) {
            self.descriptionTextView.textView.text = self.entourage.desc;
            [self.descriptionTextView updateAfterSpeech];
        }
    }
    [self updateLocationTitle];
}

- (void)updateLocationTitle {
    CLGeocoder *geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error)
            NSLog(@"error: %@", error.description);
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.thoroughfare !=  nil)
            [self.locationButton setTitle:placemark.thoroughfare forState:UIControlStateNormal];
        else
            [self.locationButton setTitle:placemark.locality forState:UIControlStateNormal];
    }];
}

- (void)sendEntourage:(UIButton*)sender {
    if(![self isTitleValid])
        return;
    
    if(self.entourage)
        [self updateEntourage:sender];
    else
        [self createEntourage:sender];
}

- (BOOL)isTitleValid {
    NSArray* words = [self.titleTextView.textView.text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    if (!nospacestring.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"invalidTitle") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (void)createEntourage:(UIButton *)sender {
    sender.enabled = NO;
    __block OTEntourage *entourage = [OTEntourage new];
    entourage.type = self.type;
    entourage.location = self.location;
    entourage.title = self.titleTextView.textView.text;
    entourage.desc = self.descriptionTextView.textView.text;
    entourage.status = ENTOURAGE_STATUS_OPEN;
    [SVProgressHUD show];
    [[OTEncounterService new] sendEntourage:entourage withSuccess:^(OTEntourage *sentEntourage) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageCreated")];
        if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)]) [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject:sentEntourage];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotCreated")];
        sender.enabled = YES;
    }];
}

- (void)updateEntourage:(UIButton *)sender {
    sender.enabled = NO;
    __block OTEntourage *entourage = [OTEntourage new];
    entourage.uid = self.entourage.uid;
    entourage.type = self.type;
    entourage.location = self.location;
    entourage.title = self.titleTextView.textView.text;
    entourage.desc = self.descriptionTextView.textView.text;
    entourage.status = self.entourage.status;
    [SVProgressHUD show];
    [[OTEncounterService new] updateEntourage:entourage withSuccess:^(OTEntourage *sentEntourage) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageUpdated")];
        if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)]) [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject:sentEntourage];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotUpdated")];
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
    if([self.disclaimer prepareSegue:segue])
        return;
    
    UIViewController *destinationViewController = segue.destinationViewController;
    if ([destinationViewController isKindOfClass:[OTLocationSelectorViewController class]]) {
        [Flurry logEvent:@"ChangeLocationClick"];
        OTLocationSelectorViewController* controller = (OTLocationSelectorViewController *)destinationViewController;
        controller.locationSelectionDelegate = self;
        controller.selectedLocation = self.location;
    }
}

@end
