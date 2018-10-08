//
//  OTEntourageEditorViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 10/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

#import "OTEntourageEditorViewController.h"
#import "OTTextWithCount.h"
#import "OTConsts.h"
#import "OTEntourage.h"
#import "OTLocationSelectorViewController.h"
#import "OTEncounterService.h"
#import "UIColor+entourage.h"
#import "UIViewController+menu.h"
#import "UITextField+indentation.h"
#import "UIBarButtonItem+factory.h"
#import "OTEntourageDisclaimerBehavior.h"
#import "OTEditEntourageTableSource.h"
#import "OTEditEntourageNavigationBehavior.h"
#import "OTCategoryFromJsonService.h"
#import "UIStoryboard+entourage.h"
#import "OTAddActionFirstConsentViewController.h"
#import "entourage-Swift.h"

@interface OTEntourageEditorViewController()

@property (nonatomic, weak) IBOutlet OTEditEntourageTableSource *editTableSource;
@property (nonatomic, weak) IBOutlet OTEntourageDisclaimerBehavior *disclaimer;
@property (nonatomic, weak) IBOutlet OTEditEntourageNavigationBehavior *editNavBehavior;

@end

@implementation OTEntourageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController];
    
    [self setupCloseModal];
    
    [self setupData];
}
    
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![self isCategorySelected] && !self.isEditingEvent) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"categoryNotSelected")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK")
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Private

- (void)setupData {
    NSString *menuButtonTitle = OTLocalizedString(@"validate");
    
    if (self.isEditingEvent) {
        
        self.title = [OTAppAppearance eventTitle].uppercaseString;
        if (self.entourage) {
            self.location = self.entourage.location;
        } else {
            [self setupEmptyEvent];
        }
        
        if ([OTAppConfiguration shouldShowAddEventDisclaimer]) {
            [self.disclaimer showCreateEventDisclaimer];
        }
        
    } else  {
        self.title = OTLocalizedString(@"action").uppercaseString;
        if (self.entourage) {
            self.type = self.entourage.type;
            self.location = self.entourage.location;
        } else {
            [self setupEmptyEntourage];
        }
        
        if ([OTAppConfiguration shouldShowAddEventDisclaimer]) {
            [self.disclaimer showDisclaimer];
        }
    }

    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:menuButtonTitle.capitalizedString
                                                        withTarget:self
                                                         andAction:@selector(sendEntourage:)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[ApplicationTheme shared].secondaryNavigationBarTintColor];
    [self.navigationItem setRightBarButtonItem:menuButton];
    
    [self.editTableSource configureWith:self.entourage];
}

- (void)setupEmptyEntourage {
    self.entourage = [OTEntourage new];
    self.entourage.status = ENTOURAGE_STATUS_OPEN;
    self.entourage.type = self.type;
    self.entourage.location = self.location;
    
    // EMA-2140
    // Select by default the category: "Partager un repas, un café":
    // "entourage_type": "contribution",
    // "display_category": "social",
    self.entourage.categoryObject = [OTCategoryFromJsonService categoryWithType:@"contribution" subcategory:@"social"];;
    self.entourage.type = self.entourage.categoryObject.entourage_type;
    self.entourage.category = self.entourage.categoryObject.category;
}

- (void)setupEmptyEvent {
    self.entourage = [[OTEntourage alloc] initWithGroupType:GROUP_TYPE_OUTING];
    self.entourage.status = ENTOURAGE_STATUS_OPEN;
    self.entourage.categoryObject = [OTCategoryFromJsonService sampleEntourageEventCategory];
}

- (void)sendEntourage:(UIButton*)sender {
    [OTLogger logEvent:@"ConfirmCreateEntourage"];
    
    if ([self.entourage isOuting]) {
        if (![self isTitleValid] || ![self isAddressValid] || ![self isEventDateValid]) {
            return;
        }
    }
    else if (![self isCategorySelected] || ![self isTitleValid]) {
        return;
    }
    
    if (self.entourage.uid) {
        [self updateEntourage:sender];
    }
    else {
        if ([OTAppConfiguration shouldAskForConsentWhenCreatingEntourage:self.entourage]) {
            [self showAddActionUserConsentView:sender];
        } else {
            [self createEntourage:sender];
        }
    }
}

- (void)showAddActionUserConsentView:(UIButton*)sender {
    UIStoryboard *storyboard = [UIStoryboard entourageEditorStoryboard];
    OTAddActionFirstConsentViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OTAddActionFirstConsentViewController"];
    __weak typeof(vc) weakVC = vc;
    vc.completionBlock = ^(OTAddActionConsentAnswerType answer) {
        switch (answer) {
                 //Case 1) When: on step 1, the user clicks on one of the 2 following answers : "Non, pour une association" and "Non, pour moi"
            case OTAddActionConsentAnswerTypeAddForMe:
            case OTAddActionConsentAnswerTypeAddForOtherOrganisation:
                // Case 2.a) When on step 2, the user clicks on : "Oui, j'ai son accord"
            case OTAddActionConsentAnswerTypeAcceptActionDistribution: {
                [weakVC.navigationController popToViewController:self animated:NO];
                /*
                 If Case 1, or Case 2.a) then: create the action (with status = open as usual). As usual, show the minipopup "Entourage créé", and redirect the user to the Screen14.1 Discussion of this new action.
                 */
                [self createEntourage:sender];
            }
                break;
                
            case OTAddActionConsentAnswerTypeRequestModeration:
                // TODO: set pending status to self.entourage
                //[self createEntourage:sender];
                [weakVC.navigationController popToViewController:self animated:NO];
                
            default:
                break;
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)isTitleValid {
    NSArray* words = [self.editTableSource.entourage.title componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* nospacestring = [words componentsJoinedByString:@""];
    if (!nospacestring.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"invalidTitle") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (BOOL)isAddressValid {
    NSString *address = self.editTableSource.entourage.streetAddress ?: self.editTableSource.entourage.displayAddress;
    NSArray *words = [address componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *nospacestring = [words componentsJoinedByString:@""];
    if (!nospacestring.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"invalidAddress") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    return YES;
}

- (BOOL)isEventDateValid {
    if (!self.editTableSource.entourage.startsAt) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"invalidDate") message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (BOOL)isCategorySelected {
    if (!self.editTableSource.entourage.categoryObject.category.length) {
        return NO;
    }
    
    return YES;
}

- (void)createEntourage:(UIButton *)sender {
    sender.enabled = NO;
    [SVProgressHUD show];
    [[OTEncounterService new] sendEntourage:self.editTableSource.entourage
                                withSuccess:^(OTEntourage *sentEntourage) {
                                    self.entourage = sentEntourage;
                                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEntourageCreated object:nil];
                                    [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageCreated")];
                                    [OTLogger logEvent:@"CreateEntourageSuccess"];
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)]) {
                                            [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject:sentEntourage];
                                        }
                                    });
                                } failure:^(NSError *error) {
                                    [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotCreated")];
                                    sender.enabled = YES;
                                }];
}

- (void)updateEntourage:(UIButton *)sender {
    sender.enabled = NO;
    [SVProgressHUD show];
    [[OTEncounterService new]
     updateEntourage:self.editTableSource.entourage
     withSuccess:^(OTEntourage *sentEntourage) {
         self.entourage = sentEntourage;
         NSString *successTitle = [sentEntourage isOuting] ?
            OTLocalizedString(@"eventUpdated") :
            OTLocalizedString(@"entourageUpdated");
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [SVProgressHUD showSuccessWithStatus:successTitle];
             if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)]) {
                 [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject: self.entourage];
             }
         });
     } failure:^(NSError *error) {
         NSString *errorTitle = [self.entourage isOuting] ?
            OTLocalizedString(@"eventNotUpdated") :
            OTLocalizedString(@"entourageNotUpdated");
         [SVProgressHUD showErrorWithStatus:errorTitle];
         sender.enabled = YES;
     }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.disclaimer prepareSegue:segue]) {
        return;
    }
    
    if ([self.editNavBehavior prepareSegue:segue]) {
        return;
    }
}

@end
