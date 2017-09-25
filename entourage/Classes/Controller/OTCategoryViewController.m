//
//  OTCategoryViewController.m
//  entourage
//
//  Created by veronica.gliga on 21/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTCategoryViewController.h"
#import "OTCategory.h"
#import "OTCategoryType.h"
#import "OTCategoryFromJsonService.h"

#define SECTION_HEIGHT 44.f
#define CATEGORY_TITLE_TAG 1
#define SUBCATEGORY_TITLE_TAG 2

@interface OTCategoryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITableView *categoryTableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation OTCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSource = [OTCategoryFromJsonService getData];
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
    
    UIButton *sectionButton = [[UIButton alloc] initWithFrame:headerView.bounds];
    [sectionButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    sectionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [sectionButton setTitle:[categoryType.type isEqualToString:@"ask_for_help"] ? @"JE CHERCHE..." : @"JE ME PROPOSE DE…"
                   forState:UIControlStateNormal];
    sectionButton.tag = section;
    [sectionButton addTarget:self
                      action:@selector(tapCategory:)
            forControlEvents:UIControlEventTouchUpInside];
    
    [headerView addSubview:sectionButton];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CategoryCell"];
    UILabel *titleLabel = [cell viewWithTag:SUBCATEGORY_TITLE_TAG];
    
    OTCategoryType * categoryType = self.dataSource[indexPath.section];
    OTCategory *category = categoryType.categories[indexPath.row];
    [titleLabel setText:category.title];
    
    return cell;
}

#pragma mark - UITableViewDataSource

#pragma mark - private methods

- (void)tapCategory:(UIButton *)sender {
    
    NSInteger section = sender.tag;
    OTCategoryType *categoryType = self.dataSource[section];
    categoryType.isExpanded = !categoryType.isExpanded;
    [self.categoryTableView reloadData];
}

@end
