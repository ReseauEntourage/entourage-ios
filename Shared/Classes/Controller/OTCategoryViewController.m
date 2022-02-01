//
//  OTCategoryViewController.m
//  entourage
//
//  Created by veronica.gliga on 21/09/2017.
//  Copyright © 2017 Entourage. All rights reserved.
//

#import "OTCategoryViewController.h"
#import "OTCategoryType.h"
#import "OTCategoryFromJsonService.h"
#import "OTCategoryEditCell.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "UIBarButtonItem+factory.h"
#import "OTSafariService.h"
#import "entourage-Swift.h"

//#define SECTION_HEIGHT 44.f
#define CATEGORY_TITLE_TAG 1
#define SUBCATEGORY_TITLE_TAG 2
#define CATEGORY_ICON_TAG 3
#define SELECTED_IMAGE_TAG 4

#define SECTION_BUTTON_TAG  1
#define SECTION_EXPAND_TAG  5


@interface OTCategoryViewController ()

@property (nonatomic, weak) IBOutlet UITableView *categoryTableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic) NSInteger sectionSelected;

@end

@implementation OTCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.isAskForHelp) {
        self.sectionSelected = 0;
    }
    else {
        self.sectionSelected = 1;
    }
    
    self.dataSource = [OTCategoryFromJsonService getData];
    
    self.categoryTableView.tableFooterView = [UIView new];
    self.categoryTableView.rowHeight = UITableViewAutomaticDimension;
    self.categoryTableView.estimatedRowHeight = 140;
    [self.categoryTableView reloadData];

    [OTAppConfiguration configureNavigationControllerAppearance:self.navigationController withMainColor:[UIColor whiteColor] andSecondaryColor:[UIColor appOrangeColor]];
    
    
    UIImage *menuImage = [[UIImage imageNamed:@"backItem"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] init];
    menuButton.image = menuImage;
    menuButton.tintColor = [UIColor appOrangeColor];
    [menuButton setTarget:self];
    [menuButton setAction:@selector(dismissModal)];
    
    [self.navigationItem setLeftBarButtonItem:menuButton];
}

-(void)dismissModal {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    OTCategoryType *categoryType = self.dataSource[self.sectionSelected];
    return categoryType.isExpanded ? categoryType.categories.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    OTCategoryType * categoryType = self.dataSource[self.sectionSelected];
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    UIButton *sectionButton = [headerCell viewWithTag:SECTION_BUTTON_TAG];
    sectionButton.tag = self.sectionSelected;
    NSString *buttonTitle = [categoryType.type isEqualToString:@"ask_for_help"] ?
                                OTLocalizedString(@"JE CHERCHE...") : OTLocalizedString(@"JE ME PROPOSE DE…");
    [sectionButton setTitle:buttonTitle
                   forState:UIControlStateNormal];

    return headerCell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTCategoryEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    UILabel *titleLabel = [cell viewWithTag:SUBCATEGORY_TITLE_TAG];
    UIImageView *categoryIcon = [cell viewWithTag:CATEGORY_ICON_TAG];
    OTCategoryType * categoryType = self.dataSource[self.sectionSelected];
    OTCategory *category = categoryType.categories[indexPath.row];
    if (self.selectedCategory != nil) {
        category.isSelected = [self.selectedCategory.title isEqualToString:category.title];
    }
    [titleLabel setText:category.title];
    [categoryIcon setImage:[UIImage imageNamed: [NSString stringWithFormat:@"%@_%@", categoryType.type, category.category]]];
    [cell configureWith:category];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self selectCategoryAtIndex:indexPath];
}

#pragma mark - private methods
    
- (void)selectCategoryAtIndex:(NSIndexPath*)indexPath {
    OTCategoryType *item = self.dataSource[self.sectionSelected];
    OTCategory *itemCategory = item.categories[indexPath.row];
    itemCategory.isSelected = !itemCategory.isSelected;
    
    for (OTCategoryType *categoryType in self.dataSource) {
        for (OTCategory *category in categoryType.categories) {
            if (category != itemCategory) {
                category.isSelected = NO;
            }
        }
    }
    
    self.selectedCategory = itemCategory;
    [self.categoryTableView reloadData];
    
    [self saveNewCategory];
}
    
- (NSIndexPath*)indexPathForCategoryWithType:(NSString*)type subcategory:(NSString*)subCat {
    NSInteger section = 0;
    NSInteger row = 0;
    for (OTCategoryType *categoryType in self.dataSource) {
        for (OTCategory *category in categoryType.categories) {
            if ([category.entourage_type isEqualToString:type] &&
                [category.category isEqualToString:subCat]) {
                    return [NSIndexPath indexPathForRow:row inSection:section];
            }
            row++;
        }
        row = 0;
        section++;
    }
    
    return [NSIndexPath indexPathForRow:row inSection:section];
}

- (void)tapCategory:(UIButton *)sender {
    NSInteger section = sender.tag;
    OTCategoryType *categoryType = self.dataSource[section];
    categoryType.isExpanded = !categoryType.isExpanded;
    [self.categoryTableView reloadData];
}

- (void)tapImageView: (UIGestureRecognizer *)sender {
    NSInteger section = sender.view.tag;
    OTCategoryType *categoryType = self.dataSource[section];
    categoryType.isExpanded = !categoryType.isExpanded;
    [self.categoryTableView reloadData];
}

- (void)saveNewCategory {
    if ([self.categorySelectionDelegate respondsToSelector:@selector(didSelectCategory:)]) {
        [self.categorySelectionDelegate didSelectCategory:self.selectedCategory];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)openLink:(id)sender {
    NSString *url = @"https://blog.entourage.social/2017/04/28/quelles-actions-faire-avec-entourage/";
    [OTSafariService launchInAppBrowserWithUrlString:url viewController:self.navigationController];
}

@end
