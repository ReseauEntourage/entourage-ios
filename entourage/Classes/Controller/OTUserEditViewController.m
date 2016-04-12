//
//  OTUserEditViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

// Controllers
#import "OTUserEditViewController.h"
#import "UIViewController+menu.h"
#import "OTUserEditPasswordViewController.h"
#import "UIButton+entourage.h"

// Service
#import "OTAuthService.h"

// Helpers
#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"
#import "UIButton+AFNetworking.h"
#import "SVProgressHUD.h"
#import "A0SimpleKeychain.h"
#import "NSString+Validators.h"

typedef NS_ENUM(NSInteger) {
    SectionTypeSummary,
    SectionTypeInfoPrivate,
    
    SectionTypeAssociations,
    SectionTypeDelete,
    SectionTypeInfoPublic// to be the 3rd in version 1.2
} SectionType;

#define EDIT_PASSWORD_SEGUE @"EditPasswordSegue"

@interface OTUserEditViewController() <UITableViewDelegate, UITableViewDataSource, OTUserEditPasswordProtocol>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UITextField *firstNameTextField;
@property (nonatomic, strong) UITextField *lastNameTextField;

@end

@implementation OTUserEditViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PROFIL";
    [self setupCloseModal];
    [self showSaveButton];
    
    self.user = [[NSUserDefaults standardUserDefaults] currentUser];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EDIT_PASSWORD_SEGUE]) {
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        OTUserEditPasswordViewController *controller = (OTUserEditPasswordViewController*)navController.topViewController;
        controller.delegate = self;
    }
}

/**************************************************************************************************/
#pragma mark - Private

- (void)showSaveButton {
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Enregistrer"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(updateUser)];
    [saveButton setTintColor:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:saveButton];
}

- (void)updateUser {
    NSString *firstName = [self editedTextAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:SectionTypeSummary]];
    NSString *lastName = [self editedTextAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:SectionTypeSummary]];
    
    NSString *email = [self editedTextAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SectionTypeInfoPrivate]];
    
    NSString *warning = nil;
    if (![email isValidEmail])
        //TODO: @Francois: please translate
        warning = @"Invalid email";
    if (lastName.length < 2)
        //TODO: @Francois: please translate
        warning = @"Invalid last name";
    if (firstName.length < 2)
        //TODO: @Francois: please translate
        warning = @"Invalid first name";
    
   
    if (warning != nil) {
        //TODO: @Francois: please translate
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:warning
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Fermer"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    self.user.firstName = firstName;
    self.user.lastName = lastName;
    self.user.email = email;
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"user_edit_saving", @"")];
    [[OTAuthService new] updateUserInformationWithUser:self.user
                                               success:^(OTUser *user) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"user_edit_saved_ok", @"")];
        [[NSUserDefaults standardUserDefaults] setCurrentUser:user];
        if (self.user.password != nil) {
            [[A0SimpleKeychain keychain] setString:self.user.password forKey:kKeychainPassword];
        }
        
    } failure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"user_edit_saved_error", @"")];
        NSLog(@"%@", [error description]);
    }];
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4; //5 in version 1.2
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeSummary: {
            return 3;
        }
        case SectionTypeInfoPrivate: {
            return 3;
        }
        case SectionTypeInfoPublic: {
            return 1;
        }
        case SectionTypeAssociations: {
            return self.user.organization == nil ? 0 : 1;
        }
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    CGFloat height = 0.0f;
    switch (section) {
        case SectionTypeInfoPrivate:
        case SectionTypeInfoPublic:
            height = 45.0f;
            break;
        case SectionTypeAssociations:
            height = self.user.organization == nil ? 0.0f : 45.0f;
            break;
        case SectionTypeDelete:
            height = 45.0f;
        default:
            break;
    }
    return height;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return .5f;
    
}

#define CELLHEIGHT_SUMMARY 135.0f
#define CELLHEIGHT_TITLE    33.0f
#define CELLHEIGHT_ENTOURAGES  80.0f
#define CELLHEIGHT_DEFAULT  51.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionTypeSummary: {
            
            if (indexPath.row == 0)
                return CELLHEIGHT_SUMMARY;
            else
                return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeInfoPrivate: {
            return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeInfoPublic: {
            return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeAssociations: {
            return CELLHEIGHT_ENTOURAGES;
        }
            
        default:
            return CELLHEIGHT_DEFAULT;;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = @"";
    switch (section) {
        case SectionTypeInfoPrivate: {
            title = @"Informations privées";
            break;
        }
        case SectionTypeInfoPublic: {
            title = @"Informations publiques";
            break;
        }
        case SectionTypeAssociations: {
            title = @"Association(s)";
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
    switch (indexPath.section) {
        case SectionTypeSummary: {
            cellID = indexPath.row == 0 ? @"SummaryProfileCell" : @"EditProfileCell";
            break;
        }
        case SectionTypeInfoPrivate: {
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
                default:
                    break;
            }
            break;
        }
        case SectionTypeInfoPublic: {
            cellID = @"EditProfileCell";
            break;
        }
        case SectionTypeAssociations: {
            cellID = @"AssociationProfileCell";
            break;
        }
        case SectionTypeDelete: {
            cellID = @"DeleteProfileCell";
            break;
        }
        default:
            break;
    }
    //NSLog(@"cell id: %@ at %@", cellID, indexPath.description);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    switch (indexPath.section) {
        case SectionTypeSummary: {
            if (indexPath.row == 0) {
                [self setupSummaryProfileCell:cell];
                
            } else {
                NSString *title = indexPath.row == 1 ? @"Prénom" : @"Nom";
                NSString *text = indexPath.row == 1 ? self.user.firstName : self.user.lastName;
                UITextField *textField = indexPath.row == 1 ? self.firstNameTextField : self.lastNameTextField;
                [self setupInfoCell:cell withTitle:title withTextField:textField andText:text];

            }
            break;
        }
        case SectionTypeInfoPrivate: {
            switch (indexPath.row) {
                case 0:
                    [self setupInfoCell:cell withTitle:@"E-mail" withTextField:nil andText:self.user.email];
                    break;
                case 1:
                    //nothing
                    break;
                case 2:
                    [self setupPhoneCell:cell withPhone:self.user.phone];
                    break;
                default:
                    break;
            }
            break;
        }
        case SectionTypeInfoPublic: {
            [self setupInfoCell:cell withTitle:@"Quartier" withTextField:nil andText:@"ROU"];
            break;
        }
        case SectionTypeAssociations: {
            if (self.user.organization != nil) {
                [self setupAssociationProfileCell:cell
                             withAssociationTitle:self.user.organization.name
                              andAssociationImage:self.user.organization.logoUrl];
            }
            break;
        }
            
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionTypeInfoPrivate:
            if (indexPath.row == 1) {
                [self performSegueWithIdentifier:EDIT_PASSWORD_SEGUE sender:nil];
            }
            break;
        case SectionTypeDelete: {
            //TODO: @Francois: please translate
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:@"Are you sure you want to delete your account?"                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
      
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Fermer"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * _Nonnull action) {}];
            
            [alert addAction:defaultAction];
            UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Oui"
                                                                    style:UIAlertActionStyleDestructive
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      NSLog(@"delete account");
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

/**************************************************************************************************/
#pragma mark - TableViewCells Setup

#define SUMMARY_AVATAR 1
#define SUMMARY_AVATAR_SHADOW 10


#define CELL_TITLE_TAG 10
#define CELL_TEXTFIELD_TAG 20

#define PHONE_LABEL_TAG 1

#define VERIFICATION_LABEL_TAG 1
#define VERIFICATION_STATUS_TAG 2

#define NOENTOURAGES_TAG 1

#define ASSOCIATION_TITLE_TAG 1
#define ASSOCIATION_IMAGE_TAG 2


- (void)setupSummaryProfileCell:(UITableViewCell *)cell
{
    
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

- (void)setupInfoCell:(UITableViewCell *)cell
            withTitle:(NSString *)title
        withTextField:(UITextField *)myTextField
              andText:(NSString *)text
{
    UILabel *titleLabel = [cell viewWithTag:CELL_TITLE_TAG];
    titleLabel.text = title;
    
    
    UITextField *nameTextField = [cell viewWithTag:CELL_TEXTFIELD_TAG];
    myTextField = nameTextField;
    nameTextField.text = text;
}

- (NSString *)editedTextAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField * textField = [cell viewWithTag:CELL_TEXTFIELD_TAG];
    if (textField != nil && [textField isKindOfClass:[UITextField class]]) {
        return textField.text;
    }
    return nil;
}


- (void)setupAssociationProfileCell:(UITableViewCell *)cell
               withAssociationTitle:(NSString *)title
                andAssociationImage:(NSString *)imageURL
{
    UILabel *titleLabel = [cell viewWithTag:ASSOCIATION_TITLE_TAG];
    titleLabel.text = title;
    
    UIButton *associationImageButton = [cell viewWithTag:ASSOCIATION_IMAGE_TAG];
    if (associationImageButton != nil && imageURL != nil) {
        [associationImageButton setImageForState:UIControlStateNormal withURL:[NSURL URLWithString:imageURL]];
    }
}

- (void)setupPhoneCell:(UITableViewCell *)cell
             withPhone:(NSString *)phone
{
    UILabel *phoneLabel = [cell viewWithTag:PHONE_LABEL_TAG];
    if (phoneLabel != nil) {
        phoneLabel.text = phone;
    }
}

/**************************************************************************************************/
#pragma mark - OTUserEditPasswordProtocol

- (void)setNewPassword:(NSString *)password
{
    self.user.password = password;
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

@end
