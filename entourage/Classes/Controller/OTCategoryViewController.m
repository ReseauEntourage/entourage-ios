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

#define SECTION_HEIGHT 44.f
#define CATEGORY_TITLE_TAG 1
#define SUBCATEGORY_TITLE_TAG 2
#define CATEGORY_ICON_TAG 3
#define SELECTED_IMAGE_TAG 4

#define SELECTED_IMAGE @"24HSelected"
#define UNSELECTED_IMAGE @"24HInactive"


@interface OTCategoryViewController ()

@property (nonatomic, weak) IBOutlet UITableView *categoryTableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation OTCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.tintColor = [UIColor appOrangeColor];
    UIBarButtonItem *menuButton = [UIBarButtonItem createWithTitle:OTLocalizedString(@"validate") withTarget:self andAction:@selector(saveNewCategory) colored:[UIColor appOrangeColor]];
    [self.navigationItem setRightBarButtonItem:menuButton];
    self.dataSource = [OTCategoryFromJsonService getData];
    self.categoryTableView.rowHeight = UITableViewAutomaticDimension;
    [self.categoryTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    OTCategoryType *categoryType = self.dataSource[section];
    return categoryType.isExpanded ? categoryType.categories.count : 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return SECTION_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    OTCategoryType * categoryType = self.dataSource[section];

    UIView *headerView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, SECTION_HEIGHT)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *sectionButton = [[UIButton alloc] initWithFrame:headerView.bounds];
    [sectionButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    sectionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [sectionButton.titleLabel setFont:[UIFont fontWithName:@"SFUIText-Semibold" size:15]];
    [sectionButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 15.0, 0.0, 17.0)];
    [sectionButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, sectionButton.bounds.size.width - 27.0, 0.0, 7.0)];
    [sectionButton setTitle:[categoryType.type isEqualToString:@"ask_for_help"] ? @"JE CHERCHE..." : @"JE ME PROPOSE DE…"
                   forState:UIControlStateNormal];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowForMenu"]];
    if(categoryType.isExpanded) {
        imageView.center = self.view.center;
        imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    [sectionButton setImage:imageView.image forState:UIControlStateNormal];
    sectionButton.tag = section;
    [sectionButton addTarget:self
                      action:@selector(tapCategory:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:sectionButton];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OTCategoryEditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    UILabel *titleLabel = [cell viewWithTag:SUBCATEGORY_TITLE_TAG];
    UIImageView *categoryIcon = [cell viewWithTag:CATEGORY_ICON_TAG];
    OTCategoryType * categoryType = self.dataSource[indexPath.section];
    OTCategory *category = categoryType.categories[indexPath.row];
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
