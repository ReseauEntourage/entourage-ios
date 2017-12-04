//
//  OTToursTableView.m
//  entourage
//
//  Created by Mihai Ionescu on 06/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemsTableView.h"
#import "OTTour.h"
#import "OTEntourage.h"
#import "UIButton+entourage.h"
#import "UIColor+entourage.h"
#import "UILabel+entourage.h"
#import "OTTourPoint.h"
#import "OTFeedItemFactory.h"
#import "OTUIDelegate.h"
#import "OTSummaryProviderBehavior.h"
#import "OTConsts.h"
#import "UIImageView+entourage.h"
#import "UIButton+entourage.h"
#import "OTNewsFeedCell.h"
#import "OTSolidarityGuideCell.h"
#import "OTPoi.h"
#import "OTNewsFeedsSourceBehavior.h"
#import "OTEntourageService.h"
#import "OTAnnouncement.h"
#import "OTAnnouncementCell.h"

#define TABLEVIEW_FOOTER_HEIGHT 15.0f

#define LOAD_MORE_DRAG_OFFSET 50

#define MAPVIEW_HEIGHT 224.f
#define MAPVIEW_REGION_SPAN_X_METERS 500
#define MAPVIEW_REGION_SPAN_Y_METERS 500
#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define FEEDS_REQUEST_DISTANCE_KM 10

#define TABLEVIEW_FOOTER_HEIGHT 15.0f
#define TABLEVIEW_BOTTOM_INSET 86.0f
#define SMALL_FOOTER_HEIGHT 126
#define BIG_FOOTER_HEIGHT 300


@interface OTFeedItemsTableView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UILabel *lblEmptyTableReason;
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UIView *emptyFooterView;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic, weak) IBOutlet UIButton *furtherEntouragesBtn;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *tourOptionsBtn;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *tourOptionBottomContraint;
@property (nonatomic, weak) IBOutlet OTNewsFeedsSourceBehavior *sourceBehavior;
@property (nonatomic, strong) UIView *currentNewsfeedFooter;;

@end

@implementation OTFeedItemsTableView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _init];
    }
    return self;
}

- (void)_init {
    self.dataSource = self;
    self.delegate = self;
    self.rowHeight = UITableViewAutomaticDimension;
    self.estimatedRowHeight = 300;
    self.lblEmptyTableReason = [UILabel new];
    self.lblEmptyTableReason.font = [UIFont fontWithName:@"SFUItext-Semibold" size:17];
    self.lblEmptyTableReason.textAlignment = NSTextAlignmentCenter;
    self.lblEmptyTableReason.numberOfLines = 0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lblEmptyTableReason.frame = self.frame;
}

- (void)configureWithMapView:(MKMapView *)mapView {
    self.emptyFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, TABLEVIEW_BOTTOM_INSET)];
    self.tableFooterView = self.emptyFooterView;
    
    //show map on table header
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width+8, MAPVIEW_HEIGHT)];
    mapView.frame = headerView.bounds;
    [headerView addSubview:mapView];
    [headerView sendSubviewToBack:mapView];
    //[self configureMapView];
    
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 156.0f , headerView.frame.size.width + 130.0f, 4.0f)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = shadowView.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor clearColor] CGColor], (id)([UIColor colorWithRed:0 green:0 blue:0 alpha:.2].CGColor),  nil];
    [shadowView.layer insertSublayer:gradient atIndex:1];
    [headerView addSubview:shadowView];
    
    NSDictionary *viewsDictionary = @{@"shadow":shadowView};
    NSArray *constraint_height = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[shadow(4)]"
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewsDictionary];
    NSArray *constraint_pos_horizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-8)-[shadow]-(-8)-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:viewsDictionary];
    NSArray *constraint_pos_bottom = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[shadow]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary];
    shadowView.translatesAutoresizingMaskIntoConstraints = NO;
    [shadowView addConstraints:constraint_height];
    [headerView addConstraints:constraint_pos_horizontal];
    [headerView addConstraints:constraint_pos_bottom];
    mapView.center = headerView.center;
        
    self.tableHeaderView = headerView;
}

- (void)updateItems:(NSArray *)items {
    self.items = items;
    [self reloadData];
}

- (void)loadBegun {
    self.lblEmptyTableReason.text = @"";
}

- (void)setNoConnection {
    self.lblEmptyTableReason.text = OTLocalizedString(@"no_internet_connexion");
}

- (void)setNoFeeds {
    self.lblEmptyTableReason.text = OTLocalizedString(@"no_feeds_received");
}

/********************************************************************************/
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.items.count == 0)
        self.backgroundView = self.lblEmptyTableReason;
    else
        self.backgroundView = nil;
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return TABLEVIEW_FOOTER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, TABLEVIEW_FOOTER_HEIGHT)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.items[indexPath.section];
    NSString *identifier = [self getCellIdentifier:item];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell withItem:item];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id selectedItem = self.items[indexPath.section];
    if([self isGuideItem:selectedItem]) {
        if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showPoiDetails:)])
            [self.feedItemsDelegate showPoiDetails:selectedItem];
    }
    else if([self isAnnouncementItem:selectedItem])
    {
        if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showAnnouncementDetails:)])
        {
                [self.feedItemsDelegate showAnnouncementDetails:selectedItem];
        }
    } else {
        if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showFeedInfo:)])
            [self.feedItemsDelegate showFeedInfo:selectedItem];
            if([selectedItem isKindOfClass:[OTEntourage class]]
               && [[selectedItem joinStatus] isEqualToString:@"not_requested"])
            {
                NSNumber *rank = @(indexPath.section);
                [[OTEntourageService new] retrieveEntourage:(OTEntourage *)selectedItem
                                                   fromRank:rank
                                                    success:nil
                                                    failure:nil];
            }

    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if([[self.items firstObject] isKindOfClass:[OTPoi class]])
        return;
    if(self.tableFooterView != self.emptyFooterView)
        return;
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = LOAD_MORE_DRAG_OFFSET;
    if(y > h + reload_distance) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.feedItemsDelegate && [self.feedItemsDelegate respondsToSelector:@selector(loadMoreData)])
                [self.feedItemsDelegate loadMoreData];
        });
    }
}

#define kMapHeaderOffsetY 0.0
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableHeaderView == nil) return;
    [UIView animateWithDuration:0.5 animations:^() {
        if(self.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height && self.tableFooterView != self.emptyFooterView && self.contentSize.height > self.frame.size.height)
            self.tourOptionBottomContraint.constant = 12 + self.loadingView.frame.size.height;
        else
            self.tourOptionBottomContraint.constant = 12;
        [self.superview layoutIfNeeded];
    }];
    
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGRect headerFrame = self.tableHeaderView.frame;//self.mapView.frame;
    
    if (scrollOffset < 0)
    {
        headerFrame.origin.y = scrollOffset;// MIN(kMapHeaderOffsetY - ((scrollOffset / 3)), 0);
        headerFrame.size.height = MAPVIEW_HEIGHT - scrollOffset;
        
    }
    else //scrolling up
    {
        headerFrame.origin.y = kMapHeaderOffsetY ;//- scrollOffset;
    }
    
    self.tableHeaderView.subviews[0].frame = headerFrame;
}

/********************************************************************************/
#pragma mark - Tour Cell Handling

- (void)doShowProfile:(UIButton*)userButton {
    [OTLogger logEvent:@"UserProfileClick"];
    UITableViewCell *cell = (UITableViewCell*)userButton.superview.superview;
    NSInteger index = [self indexPathForCell:cell].section;
    if(self.items.count > index) {
        OTFeedItem *selectedFeedItem = self.items[index];
        if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showUserProfile:)])
            [self.feedItemsDelegate showUserProfile:selectedFeedItem.author.uID];
    }
}

- (void)doJoinRequest:(UIButton*)statusButton {
    UITableViewCell *cell = (UITableViewCell*)statusButton.superview.superview.superview.superview;
    NSIndexPath *path = [self indexPathForCell:cell];
    NSInteger index = path.section;
    if(self.items.count > index) {
        OTFeedItem *selectedFeedItem = self.items[index];
        if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(doJoinRequest:)])
            [self.feedItemsDelegate doJoinRequest:selectedFeedItem];
    }
}

#pragma mark - OTNewsFeedTableDelegate

- (void)beginUpdatingFeeds {
    self.infoLabel.hidden = YES;
    self.furtherEntouragesBtn.hidden = YES;
    self.activityIndicator.hidden = NO;
    self.tableFooterView = self.loadingView;
}

- (void)finishUpdatingFeeds:(BOOL)withFeeds {
    if(withFeeds){
        self.tableFooterView = self.emptyFooterView;
        return;
    }
    self.activityIndicator.hidden = YES;
    self.infoLabel.hidden = NO;
    BOOL isMaxRadius = self.sourceBehavior.radius == [RADIUS_ARRAY[RADIUS_ARRAY.count - 1] intValue];
    self.furtherEntouragesBtn.hidden = isMaxRadius;
    self.loadingView.frame = CGRectMake(0, 0, 1, SMALL_FOOTER_HEIGHT);
    if(self.items.count > 0)
        self.infoLabel.text = OTLocalizedString(isMaxRadius ? @"no_more_feeds" : @"increase_radius");
    else {
        if(!isMaxRadius)
            self.loadingView.frame = CGRectMake(0, 0, 1, BIG_FOOTER_HEIGHT);
        self.infoLabel.text = OTLocalizedString(isMaxRadius ? @"no_feeds_received" : @"no_feeds_increase_radius");
    }
    self.tableFooterView = self.loadingView;
}

- (void)errorUpdatingFeeds {
    self.tableFooterView = self.emptyFooterView;
}

- (void)switchToGuide {
    self.currentNewsfeedFooter = self.tableFooterView;
    self.tableFooterView = self.emptyFooterView;
}

- (void)switchToFeeds {
    self.tableFooterView = self.currentNewsfeedFooter;
}

#pragma mark - private methods
     
- (BOOL)isGuideItem:(id)item {
    return [item isKindOfClass:[OTPoi class]];
}

- (BOOL)isAnnouncementItem:(id)item {
    return [item isKindOfClass:[OTAnnouncement class]];
}
     
- (NSString *)getCellIdentifier:(id)item {
    if([self isGuideItem:item])
        return OTSolidarityGuideTableViewCellIdentifier;
    else if ([self isAnnouncementItem:item])
        return OTAnnouncementTableViewCellIdentifier;
    return OTNewsFeedTableViewCellIdentifier;
}
     
- (void)configureCell:(UITableViewCell *)cell withItem:(id)item {
    if([self isGuideItem:item]) {
        OTSolidarityGuideCell *guideCell = (OTSolidarityGuideCell *)cell;
        [guideCell configureWith:(OTPoi *) item];
    }
    else if ([self isAnnouncementItem:item]) {
        OTAnnouncementCell *announcementCell = (OTAnnouncementCell *)cell;
        [announcementCell configureWith:(OTAnnouncement *)item];
    }
    else {
        OTNewsFeedCell *feedCell = (OTNewsFeedCell *)cell;
        [feedCell configureWith:(OTFeedItem *)item];
    }
}

@end
