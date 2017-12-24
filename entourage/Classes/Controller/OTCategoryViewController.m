//
//  OTCategoryViewController.m
//  entourage
//
//  Created by veronica.gliga on 21/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCategoryViewController.h"
#import "OTCategoryType.h"
#import "OTCategoryFromJsonService.h"
#import "OTCategoryEditCell.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"
#import "UIBarButtonItem+factory.h"

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

@end

@implementation OTCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
#if BETA
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
#endif
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate")
                                                        withTarget:self
                                                         andAction:@selector(saveNewCategory)
                                                           andFont:@"SFUIText-Bold"
                                                           colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    self.dataSource = [OTCategoryFromJsonService getData];
    self.categoryTableView.tableFooterView = [UIView new];
    self.categoryTableView.rowHeight = UITableViewAutomaticDimension;
    self.categoryTableView.estimatedRowHeight = 140;
    [self.categoryTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    OTCategoryType *categoryType = self.dataSource[section];
    return categoryType.isExpanded ? categoryType.categories.count : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    OTCategoryType * categoryType = self.dataSource[section];
    UITableViewCell *headerCell = [tableView dequeueReusableCellWithIdentifier:@"HeaderCell"];
    
    UIButton *sectionButton = [headerCell viewWithTag:SECTION_BUTTON_TAG];
    sectionButton.tag = section;
    NSString *buttonTitle = [categoryType.type isEqualToString:@"ask_for_help"] ?
                                @"JE CHERCHE..." : @"JE ME PROPOSE DE…";
    [sectionButton setTitle:buttonTitle
                   forState:UIControlStateNormal];
    [sectionButton addTarget:self
                      action:@selector(tapCategory:)
            forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [headerCell viewWithTag:SECTION_EXPAND_TAG];
    imageView.tag = section;
    if (!categoryType.isExpanded) {
        imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(tapImageView:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    [imageView addGestureRecognizer:singleTap];

    return headerCell;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTCategoryEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    UILabel *titleLabel = [cell viewWithTag:SUBCATEGORY_TITLE_TAG];
    UIImageView *categoryIcon = [cell viewWithTag:CATEGORY_ICON_TAG];
    OTCategoryType * categoryType = self.dataSource[indexPath.section];
    OTCategory *category = categoryType.categories[indexPath.row];
    if(self.selectedCategory != nil) {
        category.isSelected = [self.selectedCategory.title isEqualToString:category.title];
    }
    [titleLabel setText:category.title];
    [categoryIcon setImage:[UIImage imageNamed: [NSString stringWithFormat:@"%@_%@", categoryType.type, category.category]]];
    [cell configureWith:category];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OTCategoryType *item = self.dataSource[indexPath.section];
    OTCategory *itemCategory = item.categories[indexPath.row];
    itemCategory.isSelected = !itemCategory.isSelected;
    for(OTCategoryType *categoryType in self.dataSource)
        for(OTCategory *category in categoryType.categories)
            if(category != itemCategory) {
                category.isSelected = NO;
            }
    self.selectedCategory = itemCategory;
    [tableView reloadData];
}

#pragma mark - private methods

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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://blog.entourage.social/2017/04/28/quelles-actions-faire-avec-entourage/"]];
}

@end
