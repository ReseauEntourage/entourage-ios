//
//  OTFiltersViewController.m
//  entourage
//
//  Created by Ciprian Habuc on 20/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFiltersViewController.h"
#import "UIViewController+menu.h"
#import "UIColor+entourage.h"
#import "OTConsts.h"

#define FILTER_IMAGE_TAG 1
#define FILTER_DESCRIPTION_TAG 2
#define FILTER_SWITCH_TAG 3

#define FILTER_TIMEFRAME_BUTTON_START_TAG 1
#define FILTER_TIMEFRAME_BUTTON_END_TAG 3

#define FILTER_SECTION_TITLE_TAG 1

@interface OTFiltersViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *filterTableView;

@property (nonatomic, strong) NSArray* sections;
@property (nonatomic, strong) NSArray* items;
@property (nonatomic, strong) NSArray* maraudeIcons;

@property (nonatomic, strong) NSMutableArray* timeframeButtons;

@end

@implementation OTFiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =  OTLocalizedString(@"filters").uppercaseString;
    
    [self setupCloseModal];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithTitle:OTLocalizedString(@"save").capitalizedString
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(saveFilters)];
    [self.navigationItem setRightBarButtonItem:menuButton];
    
    [self initData];
    
    self.filterTableView.tableFooterView = [[UIView alloc] init];
}

- (void) initData {
    self.sections = @[
                      OTLocalizedString(@"filter_maraudes_title"),
                      OTLocalizedString(@"filter_entourages_title"),
                      OTLocalizedString(@"filter_timeframe_title")
                      ];
    
    self.items = @[
                   @[
                       OTLocalizedString(@"filter_maraude_medical"),
                       OTLocalizedString(@"filter_maraude_bare_hands"),
                       OTLocalizedString(@"filter_maraude_alimentary")
                       ],
                   @[
                       OTLocalizedString(@"filter_entourage_demand"),
                       OTLocalizedString(@"filter_entourage_contribution"),
                       OTLocalizedString(@"filter_entourage_show_tours"),
                       OTLocalizedString(@"filter_entourage_only_my_entourages")
                       ],
                   @[
                       @""
                       ]
                   ];
    
    self.maraudeIcons = @[
                          @"medicalActive",
                          @"socialActive",
                          @"distributiveActive"
                          ];
    
    self.timeframeButtons = [NSMutableArray new];
}

- (void)saveFilters {
    
}

- (IBAction)timeframeButtonClicked:(UIButton *)sender {
    for (UIButton* timeframeButton in self.timeframeButtons) {
        [timeframeButton setSelected:NO];
    }
    [sender setSelected:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.isOngoingTour ? self.sections.count : self.sections.count - 1) ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int arrayShift = self.isOngoingTour ? 0 : 1;
    return ((NSArray*)self.items[section+arrayShift]).count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    int arrayShift = self.isOngoingTour ? 0 : 1;
    
    if (indexPath.section != self.sections.count-1-arrayShift) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OTFilterHeaderCell" forIndexPath:indexPath];
            
            UILabel *title = [cell viewWithTag:FILTER_SECTION_TITLE_TAG];
            [title setText:self.sections[indexPath.section+arrayShift]];
            
            return cell;
        }
            
        cell = [tableView dequeueReusableCellWithIdentifier:@"OTFilterCell" forIndexPath:indexPath];
        
        UIImageView *filterImage = [cell.contentView viewWithTag:FILTER_IMAGE_TAG];
        UILabel *filterDescription = [cell.contentView viewWithTag:FILTER_DESCRIPTION_TAG];
        UISwitch *filterSwitch = [cell.contentView viewWithTag:FILTER_SWITCH_TAG];
        // Image
        if (self.isOngoingTour && indexPath.section == 0) {
            if (indexPath.row-1 < self.maraudeIcons.count) {
                [filterImage setImage:[UIImage imageNamed:self.maraudeIcons[indexPath.row-1]]];
            }
        }
        // Description
        NSArray *sectionItems = (NSArray*)self.items[indexPath.section+arrayShift];
        [filterDescription setText:sectionItems[indexPath.row-1]];
        // Switch status
    }
    else {
        // Timeframe cell
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"OTFilterHeaderCell" forIndexPath:indexPath];
            
            UILabel *title = [cell viewWithTag:FILTER_SECTION_TITLE_TAG];
            [title setText:self.sections[indexPath.section+arrayShift]];
            
            return cell;
        }
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"OTFilterTimeframeCell" forIndexPath:indexPath];
        
        if (self.timeframeButtons.count == 0) {
            for (NSInteger tag = FILTER_TIMEFRAME_BUTTON_START_TAG; tag <= FILTER_TIMEFRAME_BUTTON_END_TAG; tag++) {
                UIButton *timeframeButton = [cell.contentView viewWithTag:tag];
                [self.timeframeButtons addObject:timeframeButton];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    int arrayShift = self.isOngoingTour ? 0 : 1;
    if (indexPath.section != self.sections.count-1-arrayShift) {
        return 44;
    }
    else {
        if (indexPath.row == 0) {
            return 44;
        }
        return 88;
    }
}

@end
