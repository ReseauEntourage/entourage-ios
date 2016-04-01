//
//  OTUserViewController.m
//  entourage
//
//  Created by Nicolas Telera on 17/11/2015.
//  Copyright © 2015 OCTO Technology. All rights reserved.
//

#import "OTUserViewController.h"

// Controller
#import "UIViewController+menu.h"

// Service
#import "OTAuthService.h"

// Model
#import "OTUser.h"

// Helper
#import "NSUserDefaults+OT.h"
#import "NSString+Validators.h"
#import "UIColor+entourage.h"

// View
#import "SVProgressHUD.h"

typedef NS_ENUM(NSInteger) {
    SectionTypeSummary,
    SectionTypeVerification,
    SectionTypeEntourages,
    SectionTypeAssociations
} SectionType;


@interface OTUserViewController ()

@property (nonatomic, strong) OTUser *user;

@end

@implementation OTUserViewController

/********************************************************************************/
#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PROFIL";
    //[self createMenuButton];
    [self setupCloseModal];
}

- (void)viewWillAppear:(BOOL)animated {
    self.user = [[NSUserDefaults standardUserDefaults] currentUser];
    
    OTUser *currentUser = [[NSUserDefaults standardUserDefaults] currentUser];
    if (self.user.sid == currentUser.sid) {
        [self showEditButton];
    }
}

/**************************************************************************************************/
#pragma mark - Private

- (void)showEditButton {
    UIBarButtonItem *chatButton = [[UIBarButtonItem alloc] initWithTitle:@"Editer"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showEditView)];
    [chatButton setTintColor:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:chatButton];
    //self.navigationController.navigationBar.barTintColor = [UIColor appOrangeColor];
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
}

- (void)showEditView {
    
}

/**************************************************************************************************/
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case SectionTypeSummary: {
            return 1;
        }
        case SectionTypeVerification: {
            return 3;
        }
        case SectionTypeEntourages: {
            return 1;
        }
        case SectionTypeAssociations: {
            return 2;
        }
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   
    return (section == 0) ? 0.0f : 15.0f;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return .5f;
    
}

#define CELLHEIGHT_SUMMARY 237.0f
#define CELLHEIGHT_TITLE    33.0f
#define CELLHEIGHT_ENTOURAGES  80.0f
#define CELLHEIGHT_DEFAULT  48.0f

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case SectionTypeSummary: {
            return CELLHEIGHT_SUMMARY;
        }
        case SectionTypeVerification: {
            if (indexPath.row == 0)
                return CELLHEIGHT_TITLE;
            else
                return CELLHEIGHT_DEFAULT;
            }
        case SectionTypeEntourages: {
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
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 15)];
    headerView.backgroundColor = [UIColor appPaleGreyColor];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID;
    switch (indexPath.section) {
        case SectionTypeSummary: {
            cellID = @"SummaryProfileCell";
            break;
        }
        case SectionTypeVerification: {
            cellID = indexPath.row == 0 ? @"TitleProfileCell" : @"VerificationProfileCell";
            break;
        }
        case SectionTypeEntourages: {
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
            [self setupSummaryProfileCell:cell];
            break;
        }
        case SectionTypeVerification: {
            if (indexPath.row == 0)
                [self setupTitleProfileCell:cell withTitle:@"Identification vérifiée"];
            else {
                if (indexPath.row == 1)
                    [self setupVerificationProfileCell:cell
                                             withCheck:@"Adresse e-mail"
                                             andStatus:NO];
                else
                    [self setupVerificationProfileCell:cell
                                             withCheck:@"Numéro de téléphone"
                                             andStatus:YES];
            }
            break;
        }
        case SectionTypeEntourages: {
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
#define SUMMARY_NAME 2
#define SUMMARY_ROLE 3
#define SUMMARY_DATE 4
#define SUMMARY_ADDRESS 5

#define TITLE 6

#define VERIFICATION_LABEL 1
#define VERIFICATION_STATUS 2

#define NOENTOURAGES 1

#define ASSOCIATION_TITLE 1
#define ASSOCIATION_IMAGE 2


- (void)setupSummaryProfileCell:(UITableViewCell *)cell {
    
    UIButton *avatarButton = [cell viewWithTag:SUMMARY_AVATAR];
    avatarButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [avatarButton.layer setShadowColor:[UIColor blackColor].CGColor];
    [avatarButton.layer setShadowOpacity:0.5];
    [avatarButton.layer setShadowRadius:4.0];
    [avatarButton.layer setShadowOffset:CGSizeMake(0.0, 1.0)];

    UILabel *nameLabel = [cell viewWithTag:SUMMARY_NAME];
    nameLabel.text = self.user.displayName;
    
    UILabel *roleLabel = [cell viewWithTag:SUMMARY_ROLE];
    roleLabel.text = @"Ambassadeur";//self.currentUser.role;
    
    UILabel *dateLabel = [cell viewWithTag:SUMMARY_DATE];
    dateLabel.text = @"Membre depuis juillet 2014";//self.currentUser.joinDate;

    UILabel *addressLabel = [cell viewWithTag:SUMMARY_ADDRESS];
    addressLabel.text = @"Paris, France";//self.currentUser.address;
}

- (void)setupTitleProfileCell:(UITableViewCell *)cell withTitle:(NSString *)title {
    UILabel *titleLabel = [cell viewWithTag:TITLE];
    titleLabel.text = title;
    
    cell.separatorInset = UIEdgeInsetsMake(0.f, cell.bounds.size.width, 0.f, 0.f);
}

- (void)setupVerificationProfileCell:(UITableViewCell *)cell
                           withCheck:(NSString *)checkString
                           andStatus:(BOOL)isChecked
{
    UILabel *checkLabel = [cell viewWithTag:VERIFICATION_LABEL];
    checkLabel.text = checkString;
    
    UIButton *statusButton = [cell viewWithTag:VERIFICATION_STATUS];
    NSString *statusImage = isChecked ? @"verified" : @"notVerified";
    [statusButton setImage:[UIImage imageNamed: statusImage] forState:UIControlStateNormal];
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
