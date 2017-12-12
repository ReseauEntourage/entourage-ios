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
#import "UIViewController+menu.h"
#import "UITextField+indentation.h"
#import "UIBarButtonItem+factory.h"
#import "SVProgressHUD.h"
#import "OTEntourageDisclaimerBehavior.h"
#import "OTEditEntourageTableSource.h"
#import "OTEditEntourageNavigationBehavior.h"

@interface OTEntourageEditorViewController()

@property (nonatomic, weak) IBOutlet OTEditEntourageTableSource *editTableSource;
@property (nonatomic, weak) IBOutlet OTEntourageDisclaimerBehavior *disclaimer;
@property (nonatomic, weak) IBOutlet OTEditEntourageNavigationBehavior *editNavBehavior;

@end

@implementation OTEntourageEditorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"action").uppercaseString;
    [self setupData];
    [self.editTableSource configureWith:self.entourage];
    [self setupCloseModal];
#if BETA
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
#endif
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate")
                                                        withTarget:self
                                                         andAction:@selector(sendEntourage:)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    [self.disclaimer showDisclaimer];
}

#pragma mark - Private

- (void)setupData {
    if(self.entourage) {
        self.type = self.entourage.type;
        self.location = self.entourage.location;
    } else {
        self.entourage = [OTEntourage new];
        self.entourage.status = ENTOURAGE_STATUS_OPEN;
        self.entourage.type = self.type;
        self.entourage.location = self.location;
    }
}

- (void)sendEntourage:(UIButton*)sender {
    [OTLogger logEvent:@"ConfirmCreateEntourage"];
    if(![self isCategorySelected] || ![self isTitleValid])
            return;
    if(self.entourage.uid)
        [self updateEntourage:sender];
    else
        [self createEntourage:sender];
}

- (BOOL)isTitleValid {
    NSArray* words = [self.editTableSource.entourage.title componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
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

- (BOOL)isCategorySelected {
    if (!self.editTableSource.entourage.categoryObject.category.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:OTLocalizedString(@"categoryNotSelected")
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK"
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
                                withSuccess:^(OTEntourage *sentEntourage)
     {
        self.entourage = sentEntourage;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEntourageCreated object:nil];
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageCreated")];
        [OTLogger logEvent:@"CreateEntourageSuccess"];
        if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)])
            [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject:self.editTableSource.entourage];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotCreated")];
        sender.enabled = YES;
    }];
}

- (void)updateEntourage:(UIButton *)sender {
    sender.enabled = NO;
    [SVProgressHUD show];
    [[OTEncounterService new] updateEntourage:self.editTableSource.entourage withSuccess:^(OTEntourage *sentEntourage) {
        self.entourage = sentEntourage;
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"entourageUpdated")];
        if ([self.entourageEditorDelegate respondsToSelector:@selector(didEditEntourage:)])
            [self.entourageEditorDelegate performSelector:@selector(didEditEntourage:) withObject: self.editTableSource.entourage];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"entourageNotUpdated")];
        sender.enabled = YES;
    }];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([self.disclaimer prepareSegue:segue])
        return;
    if([self.editNavBehavior prepareSegue:segue])
        return;
}

@end
