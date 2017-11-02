//
//  OTUserEditViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTAppDelegate.h"
#import "OTConsts.h"
#import "OTUserEditViewController.h"
#import "UIViewController+menu.h"
#import "OTUserEditPasswordViewController.h"
#import "OTUserPictureViewController.h"
#import "UIButton+entourage.h"
#import "OTAuthService.h"
#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"
#import "UIButton+AFNetworking.h"
#import "SVProgressHUD.h"
#import "A0SimpleKeychain.h"
#import "NSString+Validators.h"
#import "UIBarButtonItem+factory.h"
#import "OTMailTextCheckBehavior.h"
#import "UIImageView+entourage.h"
#import "OTUserTableConfigurator.h"
#import "OTTextWithCount.h"
#import "OTAboutMeViewController.h"

typedef NS_ENUM(NSInteger) {
    SectionTypeSummary,
    SectionTypeAbout,
    SectionTypeAssociations,
    SectionTypeInfoPrivate,
    SectionTypeDelete,
    SectionTypeInfoPublic
} SectionType;

#define EDIT_PICTURE_SEGUE @"EditPictureSegue"
#define EDIT_PASSWORD_SEGUE @"EditPasswordSegue"
#define NOTIFY_LOGOUT @"loginFailureNotification"

@interface OTUserEditViewController() <UITableViewDelegate, UITableViewDataSource, OTUserEditPasswordProtocol, OTUserEditAboutProtocol, UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet OTMailTextCheckBehavior *checkMailBehavior;


@property (nonatomic, strong) UITextField *firstNameTextField;
@property (nonatomic, strong) UITextField *lastNameTextField;
@property (nonatomic, strong) UITextView *aboutMeTextView;

@property (nonatomic, strong) OTUser *user;
@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSArray *associationRows;

@end

@implementation OTUserEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = OTLocalizedString(@"profile").uppercaseString;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 1000;
    [self setupCloseModal];
    [self showSaveButton];
    self.user = [[NSUserDefaults standardUserDefaults] currentUser];
    self.sections = @[@(SectionTypeSummary), @(SectionTypeAbout), @(SectionTypeAssociations), @(SectionTypeInfoPrivate), @(SectionTypeDelete)];
    self.associationRows = [OTUserTableConfigurator getAssociationRowsForUserEdit:self.user];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilePictureUpdated:) name:@kNotificationProfilePictureUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:@kNotificationAboutMeUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [OTLogger logEvent:@"Screen09_2EditMyProfileView"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EDIT_PASSWORD_SEGUE]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        OTUserEditPasswordViewController *controller = (OTUserEditPasswordViewController*)navController.topViewController;
        controller.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"AboutMeSegue"]) {
        OTAboutMeViewController *controller = (OTAboutMeViewController*)segue.destinationViewController;
        controller.delegate = self;
        controller.aboutMeMessage = self.aboutMeTextView.text;
    }
}

- (void)appActive {
    [self.tableView reloadData];
}

#pragma mark - Private

- (void)profilePictureUpdated:(NSNotification *)notification {
    self.user.avatarURL = [[[NSUserDefaults standardUserDefaults] currentUser] avatarURL];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)showSaveButton {
    UIBarButtonItem *saveButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"save") withTarget:self andAction:@selector(updateUser) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

- (void)updateUser {
    [OTLogger logEvent:@"SaveProfileEdits"];
    NSString *firstName = [self editedTextAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:SectionTypeSummary] withDefault:self.user.firstName];
    NSString *lastName = [self editedTextAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:SectionTypeSummary] withDefault:self.user.lastName];
    NSString *email = [[self editedTextAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionTypeInfoPrivate] withDefault:self.user.email] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *about = [self editedTextViewAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionTypeAbout] withDefault:self.user.about];
    NSString *warning = nil;
    if (![email isValidEmail])
        warning = OTLocalizedString(@"invalidEmail");
    if (lastName.length < 2)
        warning =  OTLocalizedString(@"invalidLastName");
    if (firstName.length < 2)
        warning =  OTLocalizedString(@"invalidFirstName");
    if (warning != nil) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:warning preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle: OTLocalizedString(@"close") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    self.user.firstName = firstName;
    self.user.lastName = lastName;
    self.user.email = email;
    self.user.about = about;
    [SVProgressHUD showWithStatus:OTLocalizedString(@"user_edit_saving")];
    [[OTAuthService new] updateUserInformationWithUser:self.user success:^(OTUser *user) {
        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"user_edit_saved_ok")];
        [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
        if (self.user.password != nil) {
            [[A0SimpleKeychain keychain] setString:self.user.password forKey:kKeychainPassword];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:OTLocalizedString(@"user_edit_saved_error")];
        NSLog(@"%@", [error description]);
    }];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int mappedSection = [[self.sections objectAtIndex:section] intValue];
    switch (mappedSection) {
        case SectionTypeSummary:
            return 3;
        case SectionTypeInfoPrivate:
            return 4;
        case SectionTypeAssociations:
            return self.associationRows.count;
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    int mappedSection = [[self.sections objectAtIndex:section] intValue];
    CGFloat height = 0.0f;
    switch (mappedSection) {
        case SectionTypeInfoPrivate:
        case SectionTypeInfoPublic:
        case SectionTypeAbout:
            height = 46.0f;
            break;
        case SectionTypeAssociations:
            height = 46.0f;
            break;
        case SectionTypeDelete:
            height = 23.0f;
            break;
        default:
            break;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return .5f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    int mappedSection = [[self.sections objectAtIndex:section] intValue];
    NSString *title = @"";
    switch (mappedSection) {
        case SectionTypeInfoPrivate: {
            title = OTLocalizedString(@"privateInfo");
            break;
        }
        case SectionTypeInfoPublic: {
            title =  OTLocalizedString(@"publicInfo");
            break;
        }
        case SectionTypeAssociations: {
            title =  OTLocalizedString(@"organizations");
            break;
        }
        case SectionTypeAbout: {
            title = OTLocalizedString(@"about");
            break;
        }
        default:
            title = @"";
    }
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    headerView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    headerView.textColor = [UIColor appGreyishBrownColor];
    headerView.backgroundColor = [UIColor appPaleGreyColor];
    headerView.text = title;
    headerView.textAlignment = NSTextAlignmentCenter;
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID;
    int mappedSection = [[self.sections objectAtIndex:indexPath.section] intValue];
    switch (mappedSection) {
        case SectionTypeSummary:
            cellID = indexPath.row == 0 ? @"SummaryProfileCell" : @"EditProfileCell";
            break;
        case SectionTypeInfoPrivate:
            switch (indexPath.row) {
                case 0:
                    cellID = @"EditProfileCell";
                    break;
                case 1:
                    cellID = @"EditPasswordCell";
                    break;
                case 2:
                    cellID = @"PhoneCell";
                    break;
                case 3:
                    cellID = @"NotificationsCell";
                    break;
                default:
                    break;
            }
            break;
        case SectionTypeInfoPublic:
            cellID = @"EditProfileCell";
            break;
        case SectionTypeAssociations:
            switch ([self.associationRows[indexPath.row] intValue]) {
                case AssociationRowTypePartnerSelect:
                    cellID = @"SupportAssociationCell";
                    break;
                default:
                    cellID = @"AssociationProfileCell";
                    break;
            }
            break;
        case SectionTypeAbout :
            if([self.user.about isEqualToString: @""])
                cellID = @"AboutMeCell";
            else
                cellID = @"AboutCell";
            break;
        case SectionTypeDelete:
            cellID = @"DeleteProfileCell";
            break;
        default:
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    switch (mappedSection) {
        case SectionTypeSummary: {
            if (indexPath.row == 0) {
                [self setupSummaryProfileCell:cell];
            } else {
                NSString *title = indexPath.row == 1 ? OTLocalizedString(@"firstName") : OTLocalizedString(@"lastName");
                NSString *text = indexPath.row == 1 ? self.user.firstName : self.user.lastName;
                UITextField *textField = indexPath.row == 1 ? self.firstNameTextField : self.lastNameTextField;
                [self setupInfoCell:cell withTitle:title withTextField:textField andText:text];
            }
            break;
        }
        case SectionTypeInfoPrivate: {
            switch (indexPath.row) {
                case 0:
                    [self setupInfoCell:cell withTitle:OTLocalizedString(@"user_edit_email") withTextField:nil andText:self.user.email];
                    break;
                case 2:
                    [self setupPhoneCell:cell withPhone:self.user.phone];
                    break;
                case 3:
                    [self setupNotificationCell:cell];
                    break;
                default:
                    break;
            }
            break;
        }
        case SectionTypeInfoPublic: {
            [self setupInfoCell:cell withTitle:OTLocalizedString(@"user_edit_quartier") withTextField:nil andText:@""];
            break;
        }
        case SectionTypeAssociations: {
            switch ([self.associationRows[indexPath.row] intValue]) {
                case AssociationRowTypePartner:
                    [self setupAssociationPartnerCell:cell withPartner:self.user.partner];
                    break;
                case AssociationRowTypeOrganisation:
                    [self setupAssociationProfileCell:cell withAssociationTitle:self.user.organization.name andAssociationImage:self.user.organization.logoUrl];
                    break;
                default:
                    break;
            }
            break;
        }
        case SectionTypeAbout : {
            [self setupAboutMeCell:cell withText:self.user.about];
            break;
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int mappedSection = [[self.sections objectAtIndex:indexPath.section] intValue];
    switch (mappedSection) {
        case SectionTypeInfoPrivate:
            switch (indexPath.row) {
                case 1:
                    [self performSegueWithIdentifier:EDIT_PASSWORD_SEGUE sender:nil];
                    break;
                case 3:
                    [OTLogger logEvent:@"ToNotifications"];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    break;
                default:
                    break;
            }
            break;
        case SectionTypeDelete: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:OTLocalizedString(@"user_edit_delete") preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"closeAlert")                                                                    style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
            [alert addAction:defaultAction];
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:OTLocalizedString(@"yes") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                    [[OTAuthService new] deleteAccountForUser:0 success:^{
                        NSLog(@"deleted account.");
                        NSMutableArray *loggedNumbers = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kTutorialDone]];
                        [loggedNumbers removeObject:[NSUserDefaults standardUserDefaults].currentUser.phone];
                        [[NSUserDefaults standardUserDefaults] setObject:loggedNumbers forKey:kTutorialDone];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_LOGOUT object:self];
                    } failure:^(NSError *error) {
                        NSLog(@"Something went wrong");
                        [SVProgressHUD showSuccessWithStatus:OTLocalizedString(@"user_edit_saved_ok")];
                    }];
                }];
            [alert addAction:deleteAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

#pragma mark - TableViewCells Setup

#define SUMMARY_AVATAR 1
#define SUMMARY_AVATAR_SHADOW 10

#define CELL_TITLE_TAG 10
#define CELL_TEXTFIELD_TAG 20

#define PHONE_LABEL_TAG 1

#define NOTIFICATION_STATUS_IMAGE_TAG 1

#define VERIFICATION_LABEL_TAG 1
#define VERIFICATION_STATUS_TAG 2

#define NOENTOURAGES_TAG 1

#define ASSOCIATION_TITLE_TAG 1
#define ASSOCIATION_IMAGE_TAG 2
#define ASSOCIATION_SUPPORT_TYPE 3

#define PUBLIC_ASSOCIATION_TEXT_TAG 1

#define ABOUT_ME_TEXT 21

- (void)setupSummaryProfileCell:(UITableViewCell *)cell {
    UIImageView *imgAssociation = [cell viewWithTag:99];
    imgAssociation.hidden = self.user.partner == nil;
    [imgAssociation setupFromUrl:self.user.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    
    UIView *avatarShadow = [cell viewWithTag:SUMMARY_AVATAR_SHADOW];
    [avatarShadow.layer setShadowColor:[UIColor blackColor].CGColor];
    [avatarShadow.layer setShadowOpacity:0.5];
    [avatarShadow.layer setShadowRadius:4.0];
    [avatarShadow.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    UIButton *avatarButton = [cell viewWithTag:SUMMARY_AVATAR];
    avatarButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [avatarButton setupAsProfilePictureFromUrl:self.user.avatarURL withPlaceholder:@"user"];
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupTitleProfileCell:(UITableViewCell *)cell withTitle:(NSString *)title {
    UILabel *titleLabel = [cell viewWithTag:CELL_TITLE_TAG];
    titleLabel.text = title;
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupInfoCell:(UITableViewCell *)cell withTitle:(NSString *)title withTextField:(UITextField *)myTextField andText:(NSString *)text {
    UILabel *titleLabel = [cell viewWithTag:CELL_TITLE_TAG];
    titleLabel.text = title;
    UITextField *nameTextField = [cell viewWithTag:CELL_TEXTFIELD_TAG];
    nameTextField.text = text;
    nameTextField.tintColor = [UIColor appOrangeColor];
}

- (NSString *)editedTextAtIndexPath:(NSIndexPath *)indexPath withDefault:(NSString *)defaultValue {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(!cell)
        return defaultValue;
    UITextField * textField = [cell viewWithTag:CELL_TEXTFIELD_TAG];
    if (textField != nil && [textField isKindOfClass:[UITextField class]])
        return textField.text;
    return nil;
}

- (NSString *)editedTextViewAtIndexPath:(NSIndexPath *)indexPath withDefault:(NSString *)defaultValue {
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(!cell)
        return defaultValue;
    UITextView * textView = [cell viewWithTag:ABOUT_ME_TEXT];
    textView.delegate = self;
    if (textView != nil && [textView isKindOfClass:[UITextView class]])
        return textView.text;
    return @"";
}

- (void)setupAssociationProfileCell:(UITableViewCell *)cell withAssociationTitle:(NSString *)title andAssociationImage:(NSString *)imageURL {
    UILabel *titleLabel = [cell viewWithTag:ASSOCIATION_TITLE_TAG];
    titleLabel.text = title;
    UIButton *associationImageButton = [cell viewWithTag:ASSOCIATION_IMAGE_TAG];
    if (associationImageButton != nil && [imageURL class] != [NSNull class] && imageURL.length > 0)
        [associationImageButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imageURL]];
    UILabel *lblSupportType = [cell viewWithTag:ASSOCIATION_SUPPORT_TYPE];
    lblSupportType.text = OTLocalizedString(@"marauder");
}

- (void)setupAssociationPartnerCell:(UITableViewCell *)cell withPartner:(OTAssociation *)partner {
    UILabel *titleLabel = [cell viewWithTag:ASSOCIATION_TITLE_TAG];
    titleLabel.text = partner.name;
    UIButton *associationImageButton = [cell viewWithTag:ASSOCIATION_IMAGE_TAG];
    [associationImageButton setImage:nil forState:UIControlStateNormal];
    NSString *imageUrl = partner.largeLogoUrl;
    if (associationImageButton != nil && [imageUrl class] != [NSNull class] && imageUrl.length > 0)
        [associationImageButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imageUrl]];
    UILabel *lblSupportType = [cell viewWithTag:ASSOCIATION_SUPPORT_TYPE];
    lblSupportType.text = OTLocalizedString(@"sympathizant");
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)setupAboutMeCell:(UITableViewCell *)cell withText:(NSString *)aboutText {
    self.aboutMeTextView = [cell viewWithTag:ABOUT_ME_TEXT];
    self.aboutMeTextView.delegate = self;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(addAboutMeDescription)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [self.aboutMeTextView addGestureRecognizer:singleTap];
    self.aboutMeTextView.text = aboutText;
}

- (void)setupPhoneCell:(UITableViewCell *)cell withPhone:(NSString *)phone {
    UILabel *phoneLabel = [cell viewWithTag:PHONE_LABEL_TAG];
    if (phoneLabel != nil)
        phoneLabel.text = phone;
}

- (void)setupNotificationCell:(UITableViewCell *)cell {
    UIImageView *imgStatus = [cell viewWithTag:NOTIFICATION_STATUS_IMAGE_TAG];
    BOOL disabledNotifications = [[UIApplication sharedApplication] currentUserNotificationSettings].types == UIUserNotificationTypeNone;
    imgStatus.image = [UIImage imageNamed:(disabledNotifications ? @"notVerified" : @"verified")];
}

#pragma mark - OTUserEditPasswordProtocol

- (void)setNewPassword:(NSString *)password {
    self.user.password = password;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - OTUserEditAboutMeProtocol

- (void)setNewAboutMe:(NSString *)aboutMe {
    self.user.about = aboutMe;
    [self appActive];
}

- (void)addAboutMeDescription {
    [self performSegueWithIdentifier:@"AboutMeSegue" sender:nil];
}

@end
