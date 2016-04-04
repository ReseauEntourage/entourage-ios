//
//  OTUserEditViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 01/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTUserEditViewController.h"
// Controller
#import "UIViewController+menu.h"

#import "UIColor+entourage.h"
#import "NSUserDefaults+OT.h"

typedef NS_ENUM(NSInteger) {
    SectionTypeSummary,
    SectionTypeInfoPrivate,
    SectionTypeInfoPublic,
    SectionTypeAssociations,
    SectionTypeDelete
} SectionType;

@interface OTUserEditViewController()

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
    
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeSummary: {
            return 3;
        }
        case SectionTypeInfoPrivate: {
            return 0;
        }
        case SectionTypeInfoPublic: {
            return 1;
        }
        case SectionTypeAssociations: {
            return 1;
        }
        default:
            return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return (section == 0) ? 0.0f : 45.0f;
    
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
            if (indexPath.row == 0)
                return CELLHEIGHT_TITLE;
            else
                return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeInfoPublic: {
            return CELLHEIGHT_DEFAULT;
        }
        case SectionTypeAssociations: {
            if (indexPath.row == 0)
                return CELLHEIGHT_TITLE;
            else
                return CELLHEIGHT_ENTOURAGES;
        }
            
        default:
            return CELLHEIGHT_DEFAULT;;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *headerView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    headerView.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    headerView.textColor = [UIColor appGreyishBrownColor];
    headerView.backgroundColor = [UIColor appPaleGreyColor];
    headerView.text = @"Informations privées";
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
            cellID = indexPath.row == 0 ? @"TitleProfileCell" : @"VerificationProfileCell";
            break;
        }
        case SectionTypeInfoPublic: {
            cellID = @"EntouragesProfileCell";
            break;
        }
        case SectionTypeAssociations: {
            cellID = indexPath.row == 0 ? @"TitleProfileCell" : @"AssociationProfileCell";
            break;
        }
        default:
            break;
    }
    NSLog(@"cell id: %@", cellID);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    switch (indexPath.section) {
        case SectionTypeSummary: {
            if (indexPath.row == 0) {
                [self setupSummaryProfileCell:cell];
                
            } else {
                NSString *title = indexPath.row == 1 ? @"Prénom" : @"Nom";
                UITextField *textField = indexPath.row == 1 ? self.firstNameTextField : self.lastNameTextField;
                [self setupInfoCell:cell withTitle:title withTextField:textField];

            }
            break;
        }
        case SectionTypeInfoPrivate: {
            if (indexPath.row == 0)
                [self setupTitleProfileCell:cell withTitle:@"Identification vérifiée"];
            else {
//                if (indexPath.row == 1)
//                    [self setupVerificationProfileCell:cell
//                                             withCheck:@"Adresse e-mail"
//                                             andStatus:NO];
//                else
//                    [self setupVerificationProfileCell:cell
//                                             withCheck:@"Numéro de téléphone"
//                                             andStatus:YES];
            }
            break;
        }
        case SectionTypeInfoPublic: {
            [self setupEntouragesProfileCell:cell];
            break;
        }
        case SectionTypeAssociations: {
            if (indexPath.row == 0)
                [self setupTitleProfileCell:cell withTitle:@"Association(s)"];
            else
                [self setupAssociationProfileCell:cell
                             withAssociationTitle:@"Aux captifs la liberation" andAssociationTitle:nil];
            break;
        }
            
    }
    
    return cell;
}
#define SUMMARY_AVATAR 1

#define CELL_TITLE 10
#define CELL_TEXTFIELD 20



#define VERIFICATION_LABEL 1
#define VERIFICATION_STATUS 2

#define NOENTOURAGES 1

#define ASSOCIATION_TITLE 1
#define ASSOCIATION_IMAGE 2


- (void)setupSummaryProfileCell:(UITableViewCell *)cell
{
    
    UIButton *avatarButton = [cell viewWithTag:SUMMARY_AVATAR];
    avatarButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [avatarButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [avatarButton.layer setShadowOpacity:0.5];
    [avatarButton.layer setShadowRadius:4.0];
    [avatarButton.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupTitleProfileCell:(UITableViewCell *)cell withTitle:(NSString *)title {
    UILabel *titleLabel = [cell viewWithTag:CELL_TITLE];
    titleLabel.text = title;
    
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupInfoCell:(UITableViewCell *)cell
            withTitle:(NSString *)title
        withTextField:(UITextField *)myTextField
{
    UILabel *titleLabel = [cell viewWithTag:CELL_TITLE];
    titleLabel.text = title;
    
    
    UITextField *nameTextField = [cell viewWithTag:CELL_TEXTFIELD];
    myTextField = nameTextField;
    nameTextField.text = self.user.displayName;
}

- (void)setupEntouragesProfileCell:(UITableViewCell *)cell {
    UILabel *noEntouragesLabel = [cell viewWithTag:NOENTOURAGES];
    noEntouragesLabel.text = [NSString stringWithFormat:@"%d", 1];
}

- (void)setupAssociationProfileCell:(UITableViewCell *)cell
               withAssociationTitle:(NSString *)title
                andAssociationTitle:(NSString *)imageURL
{
    UILabel *titleLabel = [cell viewWithTag:ASSOCIATION_TITLE];
    titleLabel.text = title;
    
    //UIButton *associationImageButton = [cell viewWithTag:ASSOCIATION_IMAGE];
}


@end
