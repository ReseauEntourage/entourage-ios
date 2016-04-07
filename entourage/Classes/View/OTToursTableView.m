//
//  OTToursTableView.m
//  entourage
//
//  Created by Mihai Ionescu on 06/04/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTToursTableView.h"
#import "OTTour.h"

#import "UIButton+entourage.h"
#import "UIColor+entourage.h"
#import "UILabel+entourage.h"

#define TAG_ORGANIZATION 1
#define TAG_TOURTYPE 2
#define TAG_TIMELOCATION 3
#define TAG_TOURUSERIMAGE 4
#define TAG_TOURUSERSCOUNT 5
#define TAG_STATUSBUTTON 6
#define TAG_STATUSTEXT 7

#define TABLEVIEW_FOOTER_HEIGHT 15.0f

#define LOAD_MORE_CELLS_DELTA 4

@interface OTToursTableView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *tours;

@end

@implementation OTToursTableView

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

/********************************************************************************/
#pragma mark - Tour list handlind

- (NSMutableArray*)tours {
    if (_tours == nil) {
        _tours = [[NSMutableArray alloc] init];
    }
    return _tours;
}

- (void)addTours:(NSArray*)tours {
    for (OTTour* tour in tours) {
        [self addTour:tour];
    }
}

- (void)addTour:(OTTour*)tour {
    NSUInteger oldTourIndex = [self.tours indexOfObject:tour];
    if (oldTourIndex != NSNotFound) {
        [self.tours replaceObjectAtIndex:oldTourIndex withObject:tour];
        return;
    }
    if (tour.startTime != nil) {
        for (NSUInteger i = 0; i < [self.tours count]; i++) {
            OTTour* internalTour = self.tours[i];
            if (internalTour.startTime != nil) {
                if ([internalTour.startTime compare:tour.startTime] == NSOrderedAscending) {
                    [self.tours insertObject:tour atIndex:i];
                    return;
                }
            }
        }
    }
    [self.tours addObject:tour];
}

- (void)removeTour:(OTTour*)tour {
    for (OTTour* internalTour in self.tours) {
        if ([internalTour.sid isEqualToNumber:tour.sid]) {
            [self.tours removeObject:internalTour];
            return;
        }
    }
}

- (void)removeAll {
    [self.tours removeAllObjects];
}

/********************************************************************************/
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.tours.count;
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
    
    OTTour *tour = self.tours[indexPath.section];
    NSLog(@"TourID %@ by %@", tour.sid, tour.author.displayName);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AllToursCell" forIndexPath:indexPath];
    UILabel *organizationLabel = [cell viewWithTag:TAG_ORGANIZATION];
    organizationLabel.text = tour.organizationName;
    
    UILabel *typeByNameLabel = [cell viewWithTag:TAG_TOURTYPE];
    [typeByNameLabel setupWithTypeAndAuthorOfTour:tour];
    
    // dateString - location
    UILabel *timeLocationLabel = [cell viewWithTag:TAG_TIMELOCATION];
    [timeLocationLabel setupWithTimeAndLocationOfTour:tour];
    
    UIButton *userProfileImageButton = [cell viewWithTag:TAG_TOURUSERIMAGE];
    [userProfileImageButton addTarget:self action:@selector(doShowProfile:) forControlEvents:UIControlEventTouchUpInside];
    [userProfileImageButton setupAsProfilePictureFromUrl:tour.author.avatarUrl];
    
    UILabel *noPeopleLabel = [cell viewWithTag:TAG_TOURUSERSCOUNT];
    noPeopleLabel.text = [NSString stringWithFormat:@"%d", tour.noPeople.intValue];
    
    UIButton *statusButton = [cell viewWithTag:TAG_STATUSBUTTON];
    [statusButton addTarget:self action:@selector(doJoinRequest:) forControlEvents:UIControlEventTouchUpInside];
    [statusButton setupWithJoinStatusOfTour:tour];
    
    UILabel *statusLabel = [cell viewWithTag:TAG_STATUSTEXT];
    [statusLabel setupWithJoinStatusOfTour:tour];
    
    //check if we need to load more data
    if (indexPath.section + LOAD_MORE_CELLS_DELTA >= self.tours.count) {
        if (self.toursDelegate && [self.toursDelegate respondsToSelector:@selector(loadMoreTours)]) {
            [self.toursDelegate loadMoreTours];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OTTour *selectedTour = (OTTour*)self.tours[indexPath.section];
    if (self.toursDelegate != nil && [self.toursDelegate respondsToSelector:@selector(showTourInfo:)]) {
        [self.toursDelegate showTourInfo:selectedTour];
    }
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
    OTTour *selectedTour = self.tours[index];
    
    if (self.toursDelegate != nil && [self.toursDelegate respondsToSelector:@selector(showUserProfile:)]) {
        [self.toursDelegate showUserProfile:selectedTour.author.uID];
    }
}

- (void)doJoinRequest:(UIButton*)statusButton {
    UITableViewCell *cell = (UITableViewCell*)statusButton.superview.superview;
    NSInteger index = [self indexPathForCell:cell].section;
    OTTour *selectedTour = self.tours[index];
    
    if (self.toursDelegate != nil && [self.toursDelegate respondsToSelector:@selector(doJoinRequest:)]) {
        [self.toursDelegate doJoinRequest:selectedTour];
    }
}

@end
