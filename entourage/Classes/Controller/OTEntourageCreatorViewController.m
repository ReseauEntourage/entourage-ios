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

#import "OTEncounterService.h"

// Helpers
#import "UIViewController+menu.h"
#import "UITextField+indentation.h"

// Progress HUD
#import "SVProgressHUD.h"

@interface OTEntourageCreatorViewController()

@property (nonatomic, weak) IBOutlet UILabel *locationLabel;
@property (nonatomic, weak) IBOutlet OTTextView *titleTextView;
@property (nonatomic, weak) IBOutlet OTTextView *descriptionTextView;

@end


@implementation OTEntourageCreatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     NSString *typeString = [self.type isEqualToString: ENTOURAGE_DEMANDE] ? OTLocalizedString(@"demande") : OTLocalizedString(@"contribution");
    self.title =  typeString.uppercaseString;
    
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:@"Valider"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(sendEntourage)];
    [self.navigationItem setRightBarButtonItem:menuButton];
    
    [self setupUI];
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

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:self.location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            NSLog(@"error: %@", error.description);
        }
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark.thoroughfare !=  nil) {
            self.locationLabel.text = placemark.thoroughfare;
        } else {
            self.locationLabel.text = placemark.locality;
        }
    }];

}

- (void)sendEntourage {
    __block OTEntourage *entourage = [[OTEntourage alloc] init];
    entourage.type = self.type;
    entourage.location = self.location;
    entourage.title = self.titleTextView.text;
    entourage.desc = self.descriptionTextView.text;
    
    [[OTEncounterService new] sendEntourage:entourage
                                withSuccess:^(OTEntourage *sentEncounter) {
                                    [SVProgressHUD showSuccessWithStatus:@"Entourage créée"];
                                    if ([self.entourageCreatorDelegate respondsToSelector:@selector(didCreateEntourage)]) {
                                        [self.entourageCreatorDelegate performSelector:@selector(didCreateEntourage)];
                                    }
                                } failure:^(NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:@"Echec de la création de entourage"];
                                }];
}

@end
