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
#import "entourage-Swift.h"

#define LOAD_MORE_DRAG_OFFSET 100

#define MAPVIEW_REGION_SPAN_X_METERS 500
#define MAPVIEW_REGION_SPAN_Y_METERS 500
#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define FEEDS_REQUEST_DISTANCE_KM 10

#define FEEDS_TABLEVIEW_FOOTER_HEIGHT 4.0f
#define TABLEVIEW_BOTTOM_INSET 86.0f
#define SMALL_FOOTER_HEIGHT 126
#define BIG_FOOTER_HEIGHT 300

#define kMapHeaderOffsetY 0.0

#define FEEDS_FILTER_HEIGHT 98.f

@interface OTFeedItemsTableView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, weak) IBOutlet OTNewsFeedsSourceBehavior *sourceBehavior;

@property (nonatomic) UIView *panToShowMapView;
@property (nonatomic) UIView *filterView;
@property (nonatomic) UIButton *showEventsOnlyButton;
@property (nonatomic) UIButton *showAllFeedItemsButton;

@property (nonatomic, weak) IBOutlet UIButton *furtherEntouragesBtn;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, weak) IBOutlet UIButton *tourOptionsBtn;

@property (nonatomic, strong) UIView *emptyFooterView;
@property (nonatomic, strong) UIView *currentNewsfeedFooter;
@property (nonatomic, strong) UILabel *lblEmptyTableReason;
@property (nonatomic, weak) IBOutlet UILabel *infoLabel;
@property (nonatomic) CGFloat headerMapViewHeight;
@property (nonatomic) BOOL showFilteringHeader;

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
    self.infoLabel.adjustsFontSizeToFitWidth = YES;
}

- (CGFloat)feedsFilterHeaderHeight {
    return FEEDS_FILTER_HEIGHT;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleFilterPan:(UIPanGestureRecognizer*)pan {
    if (pan.view != self.filterView && pan.view != self.panToShowMapView) {
        return;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if ([pan velocityInView:self].y > 0) {
            if ([self.feedItemsDelegate respondsToSelector:@selector(didPanHeaderDown)]) {
                [self.feedItemsDelegate didPanHeaderDown];
            }
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.view == self.filterView || gestureRecognizer.view == self.panToShowMapView) {
        CGPoint translation = [(UIPanGestureRecognizer*)gestureRecognizer translationInView:self];
        if (fabs(translation.y) > fabs(translation.x)) {
            return YES;
        }

        return NO;
    }
    
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.lblEmptyTableReason.frame = self.frame;
}

- (void)configureWithMapView:(MKMapView *)mapView {
    self.emptyFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, TABLEVIEW_BOTTOM_INSET)];
    self.tableFooterView = self.emptyFooterView;
        
    self.tableHeaderView = [self headerViewWithMap:mapView mapHeight:MAPVIEW_HEIGHT showFilter:NO];
    CGPoint center = self.tableHeaderView.center;
    mapView.center = center;
}

- (void)updateWithMapView:(MKMapView*)mapView
                mapHeight:(CGFloat)mapHeight
                 showFilter:(BOOL)showFilter {
    self.tableHeaderView = [self headerViewWithMap:mapView mapHeight:mapHeight showFilter:showFilter];
    CGPoint center = self.tableHeaderView.center;
    mapView.center = center;
}

- (UIView*)headerViewWithMap:(MKMapView*)mapView
                   mapHeight:(CGFloat)mapHeight
                  showFilter:(BOOL)showFilter {
    //show map on table header
    CGFloat panViewHeight = 15;
    CGFloat h = mapHeight;
    if (showFilter && !self.showSolidarityGuidePOIs) {
        h += [self feedsFilterHeaderHeight];
    } else {
        h += panViewHeight;
    }
    
    self.showFilteringHeader = showFilter;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width+8, h)];
    mapView.frame = headerView.bounds;
    
    CGFloat buttonSize = 42;
    CGFloat marginOffset = 20;
    CGFloat y = marginOffset + 64;
    
    if (@available(iOS 11.0, *)) {
        y = self.safeAreaInsets.top + marginOffset;
    }
    
    CGFloat x = UIScreen.mainScreen.bounds.size.width - buttonSize - marginOffset;
    UIButton *showCurrentLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(x, y, buttonSize, buttonSize)];
    
    [showCurrentLocationButton setImage:[UIImage imageNamed:@"geoloc"] forState:UIControlStateNormal];
    showCurrentLocationButton.backgroundColor = [UIColor whiteColor];
    showCurrentLocationButton.clipsToBounds = YES;
    showCurrentLocationButton.layer.cornerRadius = buttonSize / 2;
    [showCurrentLocationButton addTarget:self action:@selector(requestCurrentLocation) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:mapView];
    //[headerView addSubview:showCurrentLocationButton];
    [headerView sendSubviewToBack:mapView];
    //[headerView bringSubviewToFront:showCurrentLocationButton];
    
    // Add pan view used to drag to show map
    [self setupPanToShowMapView:panViewHeight mapHeight:mapHeight];
    
    // Add filter view if supported
    [self setupFilteringHeaderView:mapHeight];
    if (showFilter && !self.showSolidarityGuidePOIs) {
        [headerView addSubview:self.filterView];
    }
    
    [headerView addSubview:self.panToShowMapView];
    
    return headerView;
}

- (void)requestCurrentLocation
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@kNotificationShowFeedsMapCurrentLocation object:nil];
}

- (void)updateItems:(NSArray *)items {
    if (![self.items isEqual:items]) {
        self.items = items;
        self.panToShowMapView.hidden = items.count == 0;
        [self reloadData];
    }
}

- (void)loadBegun {
    self.panToShowMapView.hidden = YES;
    self.lblEmptyTableReason.text = @"";
}

- (void)setNoConnection {
    self.lblEmptyTableReason.text = OTLocalizedString(@"no_internet_connexion");
}

- (void)setNoFeeds {
    if (self.showEventsOnly) {
        self.lblEmptyTableReason.text = @"cascdsc";
    } else {
        self.lblEmptyTableReason.text = [OTAppAppearance noMoreFeedsDescription];
    }
}

/********************************************************************************/
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.items.count == 0) {
        self.backgroundView = self.lblEmptyTableReason;
    }
    else {
        self.backgroundView = nil;
    }
    
    return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return FEEDS_TABLEVIEW_FOOTER_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, FEEDS_TABLEVIEW_FOOTER_HEIGHT)];
    footerView.backgroundColor = [UIColor clearColor];
    return footerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id item = self.items[indexPath.section];
    NSString *identifier = [self getCellIdentifier:item];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    [self configureCell:cell withItem:item reloadAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id selectedItem = self.items[indexPath.section];
    if ([self isGuideItem:selectedItem]) {
        if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showPoiDetails:)]) {
            [self.feedItemsDelegate showPoiDetails:selectedItem];
        }
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
    if ([[self.items firstObject] isKindOfClass:[OTPoi class]]) {
        return;
    }
    
    if (self.tableFooterView != self.emptyFooterView) {
        return;
    }
    
    CGPoint offset = scrollView.contentOffset;
    CGRect bounds = scrollView.bounds;
    CGSize size = scrollView.contentSize;
    UIEdgeInsets inset = scrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = LOAD_MORE_DRAG_OFFSET;
    
    CGFloat topOffset = 84;
    if (@available(iOS 11.0, *)) {
        topOffset += self.safeAreaInsets.top;
    }
    
    if (y > h - reload_distance - topOffset) {
        dispatch_async(dispatch_get_main_queue(), ^() {
            if (self.feedItemsDelegate &&
                [self.feedItemsDelegate respondsToSelector:@selector(loadMoreData)]) {
             
                [self.feedItemsDelegate loadMoreData];
            }
        });
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableHeaderView == nil) {
        [self.feedItemsDelegate mapDidBecomeVisible:NO];
        return;
    }
    
    [UIView animateWithDuration:0.5 animations:^() {
        if (self.contentSize.height - scrollView.contentOffset.y <= scrollView.frame.size.height &&
            self.tableFooterView != self.emptyFooterView &&
            self.contentSize.height > self.frame.size.height) {
            
            [self.superview layoutIfNeeded];
        }
    }];

    CGFloat scrollOffset = scrollView.contentOffset.y;
    __block CGRect headerFrame = self.tableHeaderView.frame;

    if (scrollOffset < 0) {
        headerFrame.origin.y = scrollOffset;
        headerFrame.size.height = MAPVIEW_HEIGHT - scrollOffset;
    }
    else //scrolling up
    {
        headerFrame.origin.y = kMapHeaderOffsetY;//- scrollOffset;
    }
    
    self.tableHeaderView.subviews[0].frame = headerFrame;
    
    CGFloat topOffset = 84;
    if (@available(iOS 11.0, *)) {
        topOffset += self.safeAreaInsets.top;
    }
    if (self.showFilteringHeader) {
        topOffset += [self feedsFilterHeaderHeight];
    }
    BOOL mapVisible = headerFrame.size.height > 0 &&
        self.contentOffset.y < headerFrame.size.height - topOffset;
    [self.feedItemsDelegate mapDidBecomeVisible: mapVisible];
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
    if (withFeeds) {
        self.tableFooterView = self.emptyFooterView;
        return;
    }
    self.activityIndicator.hidden = YES;
    self.infoLabel.hidden = NO;
    self.loadingView.frame = CGRectMake(0, 0, 1, BIG_FOOTER_HEIGHT);
    
    if (self.showEventsOnly) {
        if (self.items.count == 0) {
            self.infoLabel.text = OTLocalizedString(@"no_data_events");
        }
        self.furtherEntouragesBtn.hidden = NO;
        
    } else {
        BOOL isMaxRadius = self.sourceBehavior.radius == [RADIUS_ARRAY[RADIUS_ARRAY.count - 1] intValue];
        self.furtherEntouragesBtn.hidden = isMaxRadius;
        
        if (self.items.count > 0) {
            if (isMaxRadius) {
                self.infoLabel.text = [OTAppAppearance noMoreFeedsDescription];
            } else {
                self.infoLabel.text = [OTAppAppearance extendSearchParameterDescription];
            }
        }
        else if (self.items.count == 0) {
            if (isMaxRadius) {
                self.furtherEntouragesBtn.hidden = YES;
                self.infoLabel.text = [OTAppAppearance noMapFeedsDescription];
            }
            else {
                self.furtherEntouragesBtn.hidden = NO;
                self.infoLabel.text = [OTAppAppearance extendMapSearchParameterDescription];
                self.loadingView.frame = CGRectMake(0, 0, 1, BIG_FOOTER_HEIGHT);
            }
        }
    }
    
    self.tableFooterView = self.loadingView;
}

- (void)errorUpdatingFeeds {
    self.tableFooterView = self.emptyFooterView;
}

- (void)switchToGuide {
    self.currentNewsfeedFooter = self.tableFooterView;
    self.tableFooterView = self.emptyFooterView;
    self.showSolidarityGuidePOIs = YES;
}

- (void)switchToFeeds {
    self.tableFooterView = self.currentNewsfeedFooter;
    self.showSolidarityGuidePOIs = NO;
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

- (void)configureCell:(UITableViewCell *)cell withItem:(id)item reloadAtIndexPath:(NSIndexPath*)indexPath {
    if([self isGuideItem:item]) {
        OTSolidarityGuideCell *guideCell = (OTSolidarityGuideCell *)cell;
        [guideCell configureWith:(OTPoi *) item];
    }
    else if ([self isAnnouncementItem:item]) {
        OTAnnouncementCell *announcementCell = (OTAnnouncementCell *)cell;
        [announcementCell configureWith:(OTAnnouncement *)item completion:^{
            if (self.items.count > indexPath.row && [self.visibleCells containsObject:announcementCell]) {
                [self reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
    else {
        OTNewsFeedCell *feedCell = (OTNewsFeedCell *)cell;
        [feedCell configureWith:(OTFeedItem *)item];
    }
}

- (void)setupPanToShowMapView:(CGFloat)height mapHeight:(CGFloat)mapHeight {
    self.panToShowMapView = [[UIView alloc] initWithFrame:CGRectMake(0, mapHeight, self.frame.size.width, height)];
    self.panToShowMapView.backgroundColor = [UIColor whiteColor];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: self.panToShowMapView.bounds
                                           byRoundingCorners: UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii: (CGSize){15.0, 15.0}].CGPath;
    
    self.panToShowMapView.layer.mask = maskLayer;
    
    UIView *topShadow = [[UIView alloc] initWithFrame:CGRectMake(7.0f, mapHeight, self.frame.size.width - 14, 0.5)];
    topShadow.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    topShadow.layer.masksToBounds = NO;
    [topShadow.layer setShadowColor:[UIColor blackColor].CGColor];
    [topShadow.layer setShadowOpacity:0.5];
    [topShadow.layer setShadowRadius:4.0];
    [topShadow.layer setShadowOffset:CGSizeMake(0.0, 1.0)];
    [self.panToShowMapView addSubview:topShadow];
    
    UIView *panIndicator = [[UIView alloc] initWithFrame:CGRectMake((self.frame.size.width - 30) / 2, 3, 30, 3)];
    panIndicator.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    panIndicator.layer.cornerRadius = 3;
    [self.panToShowMapView addSubview:panIndicator];
    
    UIPanGestureRecognizer *pgr1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilterPan:)];
    [self.panToShowMapView addGestureRecognizer:pgr1];
}

#pragma mark - Filtering

- (void)setupFilteringHeaderView:(CGFloat)mapHeight {
    self.filterView = (UIView*)[[NSBundle mainBundle] loadNibNamed:@"OTFeedsTableFilterHeader" owner:nil options:nil].firstObject;
    self.filterView.frame = CGRectMake(0, mapHeight, UIScreen.mainScreen.bounds.size.width + 8, [self feedsFilterHeaderHeight]);
    self.filterView.clipsToBounds = YES;
    self.filterView.layer.cornerRadius = 12;
    
    self.showAllFeedItemsButton = [self.filterView viewWithTag:1];
    [self.showAllFeedItemsButton setImage:[[UIImage imageNamed:@"handshake"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.showAllFeedItemsButton.tintColor = [UIColor whiteColor];
    [self.showAllFeedItemsButton addTarget:self action:@selector(showAllFeedItemsAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.showEventsOnlyButton = [self.filterView viewWithTag:2];
    [self.showEventsOnlyButton setImage:[[UIImage imageNamed:@"ask_for_help_event"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.showEventsOnlyButton.tintColor = [UIColor whiteColor];
    [self.showEventsOnlyButton addTarget:self action:@selector(showEventsOnlyAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self updateFilterButtons];
    
    UIPanGestureRecognizer *pgr2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleFilterPan:)];
    [self.filterView addGestureRecognizer:pgr2];
}

- (void)updateFilterButtons {
    UIColor *buttonSelectedColor = [ApplicationTheme shared].backgroundThemeColor;
    UIColor *buttonDisabledColor = [UIColor appGreyishColor];
    [self.showAllFeedItemsButton setBackgroundColor:self.showEventsOnly ? buttonDisabledColor : buttonSelectedColor];
    [self.showEventsOnlyButton setBackgroundColor:self.showEventsOnly ? buttonSelectedColor: buttonDisabledColor];
    
    UILabel *showAllLabel = [self.filterView viewWithTag:3];
    showAllLabel.textColor = self.showAllFeedItemsButton.backgroundColor;
    
    UILabel *showEventsLabel = [self.filterView viewWithTag:4];
    showEventsLabel.textColor = self.showEventsOnlyButton.backgroundColor;
    
    self.showEventsOnlyButton.userInteractionEnabled = !self.showEventsOnly;
    self.showAllFeedItemsButton.userInteractionEnabled = self.showEventsOnly;
    
    NSString *searchMoreTitle = self.showEventsOnly ?
    OTLocalizedString(@"search_more_further_events") :
    OTLocalizedString(@"search_more_further_feeds");
    
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:searchMoreTitle];
    [title setAttributes:@{NSForegroundColorAttributeName:[ApplicationTheme shared].backgroundThemeColor, NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)} range:NSMakeRange(0, title.length)];
    [self.furtherEntouragesBtn setAttributedTitle:title forState:UIControlStateNormal];
}

- (void)showEventsOnlyAction {
    self.showEventsOnly = YES;
    [self updateFilterButtons];
    [self.feedItemsDelegate showEventsOnly];
}

- (void)showAllFeedItemsAction {
    self.showEventsOnly = NO;
    [self updateFilterButtons];
    [self.feedItemsDelegate showAllFeedItems];
}

@end
