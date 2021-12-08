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
#import "OTAddActionConfidentialityViewController.h"
#import "entourage-Swift.h"

@interface OTEntourageEditorViewController()

@property (nonatomic, weak) IBOutlet OTEditEntourageTableSource *editTableSource;
@property (nonatomic, weak) IBOutlet OTEntourageDisclaimerBehavior *disclaimer;
@property (nonatomic, weak) IBOutlet OTEditEntourageNavigationBehavior *editNavBehavior;
@property (weak, nonatomic) IBOutlet UIView *ui_view_bottom_event_help;
@property (weak, nonatomic) IBOutlet UIButton *ui_button_event_help;


@property(nonatomic) BOOL isFirstLaunch;
@end

@implementation OTEntourageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isFirstLaunch = YES;
    
    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController withMainColor:[UIColor whiteColor] andSecondaryColor:[UIColor appOrangeColor]];
    [self setupCloseModalWithoutTintWithTint:[UIColor appOrangeColor]];
    
    [self setupData];
}
    
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isFirstLaunch) {
        self.isFirstLaunch = NO;
        return;
    }
    
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
        
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:OTLocalizedString(@"add_event_help_button")];
        [attributeString addAttribute:NSUnderlineStyleAttributeName
                                value:[NSNumber numberWithInt:1]
                                range:(NSRange){0,[attributeString length]}];
        [attributeString addAttribute:NSForegroundColorAttributeName value:[UIColor appOrangeColor] range:(NSRange){0,[attributeString length]}];
        
        [self.ui_button_event_help setAttributedTitle:attributeString forState:UIControlStateNormal];
        
        self.title = [OTAppAppearance eventTitle].uppercaseString;
        if (self.entourage) {
            self.location = self.entourage.location;
        } else {
            [self setupEmptyEvent];
        }
        
        if ([OTAppConfiguration shouldShowAddEventDisclaimer]) {
            [self.disclaimer showCreateEventDisclaimer];
        }
        
        [self.ui_view_bottom_event_help setHidden:NO];
        
    } else  {
        self.title = OTLocalizedString(@"action").uppercaseString;
        if (self.entourage) {
            self.type = self.entourage.type;
            self.location = self.entourage.location;
            
            self.isAskForHelp = [self.entourage.categoryObject.entourage_type isEqualToString:@"ask_for_help"];
           
        } else {
            [self setupEmptyEntourage];
        }
        
        if ([OTAppConfiguration shouldShowAddEventDisclaimer]) {
            [self.disclaimer showDisclaimer];
        }
        
         [self.ui_view_bottom_event_help setHidden:YES];
    }

    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:menuButtonTitle.capitalizedString
                                                        withTarget:self
                                                         andAction:@selector(sendEntourage:)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    
    [self.editTableSource configureWith:self.entourage];
    
    if (!self.isEditingEvent && self.entourage.categoryObject == nil) {
        [self.editNavBehavior editCategory:self.entourage];
    }
}

- (void)dismissModal {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    self.entourage.categoryObject = nil;
    self.entourage.isPublic = [NSNumber numberWithBool:YES];
    self.entourage.type = self.entourage.categoryObject.entourage_type;
    self.entourage.category = self.entourage.categoryObject.category;
}

- (void)setupEmptyEvent {
    self.entourage = [[OTEntourage alloc] initWithGroupType:GROUP_TYPE_OUTING];
    self.entourage.status = ENTOURAGE_STATUS_OPEN;
    self.entourage.isPublic = [NSNumber numberWithInt:1]; //
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
    
    if ([OTAppConfiguration shouldAskForConfidentialityWhenCreatingEntourage:self.entourage]) {
        [self showAddActionConfidentialityView:sender];
    }
    else if ([OTAppConfiguration shouldAskForConsentWhenCreatingEntourage:self.entourage]) {
        [self showAddActionUserConsentView:sender];
    } else {
        [self createOrUpdateEntourage:sender completion:nil];
    }
}

- (void)showAddActionConfidentialityView:(UIButton*)sender {
    UIStoryboard *storyboard = [UIStoryboard entourageEditorStoryboard];
    OTAddActionConfidentialityViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OTAddActionConfidentialityViewController"];
    __weak typeof(vc) weakVC = vc;
    
    vc.completionBlock = ^(BOOL requiresValidation) {
        self.entourage.isPublic = @(!requiresValidation);
        self.editTableSource.entourage.isPublic = self.entourage.isPublic;
        [self createOrUpdateEntourage:sender completion:^{
            [weakVC.navigationController popToViewController:self animated:NO];
        }];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
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
                /*
                 If Case 1, or Case 2.a) then: create the action (with status = open as usual). As usual, show the minipopup "Entourage créé", and redirect the user to the Screen14.1 Discussion of this new action.
                 */
                self.entourage.consentObtained = @(YES);
                self.editTableSource.entourage.consentObtained = self.entourage.consentObtained;
                [self createOrUpdateEntourage:sender
                                   completion:^{
                    [weakVC.navigationController popToViewController:self animated:NO];
                }];
            }
                break;
                
            case OTAddActionConsentAnswerTypeRequestModeration:{
                [self createOrUpdateEntourage:sender completion:^{
                    [weakVC.navigationController popToViewController:self animated:NO];
                }];
            }
                break;
            default:
                break;
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)createOrUpdateEntourage:(UIButton*)sender
                     completion:(void(^)(void))completion {
    if (self.entourage.uid) {
        [self updateEntourage:sender completion:completion];
    } else {
        [self createEntourage:sender completion:completion];
    }
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

- (void)createEntourage:(UIButton *)sender completion:(void(^)(void))completion {
    sender.enabled = NO;
    [SVProgressHUD show];
    [[OTEncounterService new] sendEntourage:self.editTableSource.entourage
                                withSuccess:^(OTEntourage *sentEntourage) {
        self.entourage = sentEntourage;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEntourageCreated object:nil];
        [SVProgressHUD dismiss];
        //  [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageCreated")];
        
        [OTLogger logEvent:@"CreateEntourageSuccess"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)]) {
                [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject:sentEntourage];
                if (completion) {
                    completion();
                }
            }
        });
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotCreated")];
        sender.enabled = YES;
        if (completion) {
            completion();
        }
    }];
}

- (void)updateEntourage:(UIButton *)sender completion:(void(^)(void))completion {
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
                 [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:)
                                                    withObject: self.entourage];
                 if (completion) {
                     completion();
                 }
             }
         });
     } failure:^(NSError *error) {
         NSString *errorTitle = [self.entourage isOuting] ?
            OTLocalizedString(@"eventNotUpdated") :
            OTLocalizedString(@"entourageNotUpdated");
         [SVProgressHUD showErrorWithStatus:errorTitle];
         sender.enabled = YES;
         if (completion) {
             completion();
         }
     }];
}

- (IBAction)action_show_event_help:(id)sender {
    
    NSString *relativeUrl = [NSString stringWithFormat:API_URL_MENU_OPTIONS,EVENT_GUIDE_ID,TOKEN];
       NSString *urlForm = [NSString stringWithFormat: @"%@%@", [OTHTTPRequestManager sharedInstance].baseURL, relativeUrl];
    
    [OTSafariService launchInAppBrowserWithUrlString:urlForm viewController:self];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self.disclaimer prepareSegue:segue]) {
        return;
    }
    
    if ([self.editNavBehavior prepareSegue:segue isAskForHelp:self.isAskForHelp]) {
        return;
    }
}

@end
