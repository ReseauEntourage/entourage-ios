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
#import "entourage-Swift.h"

@interface OTEntourageEditorViewController()

@property (nonatomic, weak) IBOutlet OTEditEntourageTableSource *editTableSource;
@property (nonatomic, weak) IBOutlet OTEntourageDisclaimerBehavior *disclaimer;
@property (nonatomic, weak) IBOutlet OTEditEntourageNavigationBehavior *editNavBehavior;

@end

@implementation OTEntourageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    
    [self setupCloseModal];
    
    [self setupData];
}
    
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // EMA-2140
    // Select by default the category: "Partager un repas, un café":
    // "entourage_type": "contribution",
    // "display_category": "social",
    if (![self isCategorySelected] && !self.isEditingEvent) {
        self.editTableSource.entourage.categoryObject = [OTCategoryFromJsonService categoryWithType:@"contribution" subcategory:@"social"];
        [self.editTableSource.tblEditEntourage reloadData];
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
    } else  {
    
        self.title = OTLocalizedString(@"action").uppercaseString;
        if (self.entourage) {
            self.type = self.entourage.type;
            self.location = self.entourage.location;
        } else {
            [self setupEmptyEntourage];
        }
        
        [self.disclaimer showDisclaimer];
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
}

- (void)setupEmptyEvent {
    self.entourage = [[OTEntourage alloc] initWithGroupType:GROUP_TYPE_OUTING];
    self.entourage.categoryObject = [OTCategoryFromJsonService
                                     categoryWithType:@"contribution" subcategory:@"event"];
}

- (void)sendEntourage:(UIButton*)sender {
    [OTLogger logEvent:@"ConfirmCreateEntourage"];
    
    if (![self isCategorySelected] || ![self isTitleValid]) {
        return;
    }
    
    if (self.entourage.uid) {
        [self updateEntourage:sender];
    }
    else {
        [self createEntourage:sender];
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

- (BOOL)isCategorySelected {
    if (!self.editTableSource.entourage.categoryObject.category.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"categoryNotSelected")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"OK")
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
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
         if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)]) {
            [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject:sentEntourage];
         }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotCreated")];
        sender.enabled = YES;
    }];
}

- (void)updateEntourage:(UIButton *)sender {
    sender.enabled = NO;
    [SVProgressHUD show];
    [[OTEncounterService new] updateEntourage:self.editTableSource.entourage
                                  withSuccess:^(OTEntourage *sentEntourage) {
        self.entourage = sentEntourage;
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageUpdated")];
                                      if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)]) {
                                          [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject: self.editTableSource.entourage];
                                      }
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotUpdated")];
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
