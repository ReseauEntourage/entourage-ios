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

#define TAG_ORGANIZATION 1
#define TAG_TOURTYPE 2
#define TAG_TIMELOCATION 3
#define TAG_TOURUSERIMAGE 4
#define TAG_TOURUSERSCOUNT 5
#define TAG_STATUSBUTTON 6
#define TAG_STATUSTEXT 7

#define TABLEVIEW_FOOTER_HEIGHT 15.0f

#define LOAD_MORE_CELLS_DELTA 4

#define MAPVIEW_HEIGHT 160.f
#define MAPVIEW_REGION_SPAN_X_METERS 500
#define MAPVIEW_REGION_SPAN_Y_METERS 500
#define MAX_DISTANCE_FOR_MAP_CENTER_MOVE_ANIMATED_METERS 100
#define FEEDS_REQUEST_DISTANCE_KM 10
#define LOCATION_MIN_DISTANCE 5.f

#define TABLEVIEW_FOOTER_HEIGHT 15.0f
#define TABLEVIEW_BOTTOM_INSET 86.0f


@interface OTFeedItemsTableView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *feedItems;

@end

@implementation OTFeedItemsTableView

/********************************************************************************/
#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

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
}

- (NSArray *)items {
    return self.feedItems;
}


- (void)configureWithMapView:(MKMapView *)mapView {
    
    self.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, -TABLEVIEW_FOOTER_HEIGHT, 0.0f);
    UIView *dummyView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, TABLEVIEW_BOTTOM_INSET)];
    self.tableFooterView = dummyView;
    
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


/********************************************************************************/
#pragma mark - Tour list handlind

- (NSMutableArray*)feedItems {
    if (_feedItems == nil) {
        _feedItems = [[NSMutableArray alloc] init];
    }
    return _feedItems;
}

- (void)addFeedItems:(NSArray*)feedItems {
    for (OTFeedItem* feedItem in feedItems) {
        [self addFeedItem:feedItem];
    }
}

- (void)addFeedItem:(OTFeedItem *)feedItem {
    NSUInteger oldFeedIndex = [self.feedItems indexOfObject:feedItem];
    if (oldFeedIndex != NSNotFound) {
        [self.feedItems replaceObjectAtIndex:oldFeedIndex withObject:feedItem];
        return;
    }
    
    if (feedItem.creationDate != nil) {
        for (NSUInteger i = 0; i < [self.feedItems count]; i++) {
            OTFeedItem* internalFeedItem = self.feedItems[i];
            if (internalFeedItem.creationDate != nil) {
                if ([internalFeedItem.creationDate compare:feedItem.creationDate] == NSOrderedAscending) {
                    [self.feedItems insertObject:feedItem atIndex:i];
                    return;
                }
            }
        }
    }
    [self.feedItems addObject:feedItem];
}

- (void)removeFeedItem:(OTFeedItem*)feedItem; {
    for (OTFeedItem* internalFeedItem in self.feedItems) {
        if ([internalFeedItem.uid isEqualToNumber:feedItem.uid] && [internalFeedItem.type isEqualToString:feedItem.type]) {
            [self.feedItems removeObject:internalFeedItem];
            return;
        }
    }
}

- (void)removeAll {
    [self.feedItems removeAllObjects];
}

- (NSUInteger)itemsCount {
    return [self.feedItems count];
}

/********************************************************************************/
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.feedItems.count;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AllToursCell" forIndexPath:indexPath];
    
    OTFeedItem *item = self.feedItems[indexPath.section];
    NSLog(@">> %ld: %@", (long)indexPath.section, [item isKindOfClass:[OTTour class]] ? ((OTTour*)item).organizationName : ((OTEntourage*)item).title);
    
    UILabel *organizationLabel = [cell viewWithTag:TAG_ORGANIZATION];
    UILabel *typeByNameLabel = [cell viewWithTag:TAG_TOURTYPE];
    UILabel *timeLocationLabel = [cell viewWithTag:TAG_TIMELOCATION];
    UIButton *userProfileImageButton = [cell viewWithTag:TAG_TOURUSERIMAGE];
    [userProfileImageButton addTarget:self action:@selector(doShowProfile:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *noPeopleLabel = [cell viewWithTag:TAG_TOURUSERSCOUNT];
    UIButton *statusButton = [cell viewWithTag:TAG_STATUSBUTTON];
    UILabel *statusLabel = [cell viewWithTag:TAG_STATUSTEXT];
    
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:item] getUI];
    CLLocation *startPointLocation = nil;
    if ([item isKindOfClass:[OTTour class]]) {
        OTTour *tour = (OTTour *)item;
        // dateString - location
        OTTourPoint *startPoint = tour.tourPoints.firstObject;
        startPointLocation = [[CLLocation alloc] initWithLatitude:startPoint.latitude longitude:startPoint.longitude];
    } else {
        OTEntourage *ent = (OTEntourage*)item;
        startPointLocation = ent.location;
    }
    typeByNameLabel.attributedText = [uiDelegate descriptionWithSize:DEFAULT_DESCRIPTION_SIZE];
    organizationLabel.text = [uiDelegate summary];
    [timeLocationLabel setupWithTime:item.creationDate andLocation:startPointLocation];

    [userProfileImageButton setupAsProfilePictureFromUrl:item.author.avatarUrl];
    noPeopleLabel.text = [NSString stringWithFormat:@"%d", item.noPeople.intValue];
    [statusButton addTarget:self action:@selector(doJoinRequest:) forControlEvents:UIControlEventTouchUpInside];
    [statusButton setupAsStatusButtonForFeedItem:item];
    [statusLabel setupAsStatusButtonForFeedItem:item];

    //check if we need to load more data
     if (indexPath.section + LOAD_MORE_CELLS_DELTA >= self.feedItems.count) {
        if (self.feedItemsDelegate && [self.feedItemsDelegate respondsToSelector:@selector(loadMoreData)]) {
            [self.feedItemsDelegate loadMoreData];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id selectedFeedItem = self.feedItems[indexPath.section];

    if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showFeedInfo:)]) {
        [self.feedItemsDelegate showFeedInfo:selectedFeedItem];
    }
    [[tableView cellForRowAtIndexPath:indexPath] setSelected:NO];
}

#define kMapHeaderOffsetY 0.0
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.tableHeaderView == nil) return;
    
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGRect headerFrame = self.tableHeaderView.frame;//self.mapView.frame;
    
    if (scrollOffset < 0)
    {
        headerFrame.origin.y = scrollOffset;// MIN(kMapHeaderOffsetY - ((scrollOffset / 3)), 0);
        headerFrame.size.height = 160 - scrollOffset;
        
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
    UITableViewCell *cell = (UITableViewCell*)userButton.superview.superview;
    NSInteger index = [self indexPathForCell:cell].section;
    OTFeedItem *selectedFeedItem = self.feedItems[index];
    
    if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(showUserProfile:)]) {
        [self.feedItemsDelegate showUserProfile:selectedFeedItem.author.uID];
    }
}

- (void)doJoinRequest:(UIButton*)statusButton {
    UITableViewCell *cell = (UITableViewCell*)statusButton.superview.superview;
    NSInteger index = [self indexPathForCell:cell].section;
    OTFeedItem *selectedFeedItem = self.feedItems[index];
    
    if (self.feedItemsDelegate != nil && [self.feedItemsDelegate respondsToSelector:@selector(doJoinRequest:)]) {
        [self.feedItemsDelegate doJoinRequest:selectedFeedItem];
    }
}

@end
