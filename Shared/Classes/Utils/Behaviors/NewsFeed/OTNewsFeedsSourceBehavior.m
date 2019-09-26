//
//  OTNewsFeedsSourceBehavior.m
//  entourage
//
//  Created by sergiu buceac on 10/28/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTNewsFeedsSourceBehavior.h"
#import "OTFeedsService.h"
#import "OTFeedItem.h"
#import "OTConsts.h"
#import "OTSafariService.h"

@interface OTNewsFeedsSourceBehavior ()


@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;
@property (nonatomic, assign) int radiusIndex;
@property (nonatomic, strong) NSString *pageToken;

@end

@implementation OTNewsFeedsSourceBehavior
{
    NSMutableArray *_feedItems;
}

- (void)initialize {
    _feedItems = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    self.radiusIndex = 0;
}

- (int)radius {
    return [RADIUS_ARRAY[self.radiusIndex] intValue];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)searchFurtherAction {
    if (self.showEventsOnly) {
        [self searchMoreEvents];
    } else {
        [self increaseRadius];
    }
}

- (IBAction)searchMoreEvents {
    UIViewController *viewController = [OTAppState getTopViewController];
    if (viewController) {
        [OTSafariService launchInAppBrowserWithUrlString:VIEW_MORE_EVENTS_URL viewController:viewController];
    }
}

- (IBAction)increaseRadius {
    int sizeOfArray = (int)RADIUS_ARRAY.count;
    if (self.radiusIndex < sizeOfArray - 1) {
        self.radiusIndex++;
        [_feedItems removeAllObjects];
        [self.delegate itemsRemoved];
        [self.tableDelegate beginUpdatingFeeds];
        [self requestData:nil withSuccess:^(NSArray *items, NSString *nextPageToken) {
            [self appendNewPage:items nextPageToken:nextPageToken];
        } orError:^(NSError *error) {
            [self.delegate errorLoadingFeedItems:error];
        }];
    }
    else {
        [self.delegate itemsUpdated];
        [self.tableDelegate finishUpdatingFeeds:NO];
    }
}

- (void)reloadItemsAt:(CLLocationCoordinate2D)coordinate
          withFilters:(OTNewsFeedsFilter *)filter
          forceReload:(BOOL)forceReload {
    self.radiusIndex = 0;
    filter.distance = self.radius;
    filter.location = coordinate;
    
    if ([self.currentFilter.description isEqualToString:filter.description] &&
        filter.showPastOuting == self.currentFilter.showPastOuting &&
        !forceReload) {
        return;
    }
    
    self.currentCoordinate = coordinate;
    self.currentFilter = [filter copy];
    self.currentFilter.location = coordinate;
    
    [_feedItems removeAllObjects];
    [self.delegate itemsRemoved];
    
    [self requestData:nil withSuccess:^(NSArray *items, NSString *nextPageToken) {
        [self appendNewPage:items nextPageToken:nextPageToken];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems:error];
    }];
}

- (void)loadEventsAt:(CLLocationCoordinate2D)coordinate {
    self.radiusIndex = 0;
    self.currentCoordinate = coordinate;
    self.currentFilter.location = coordinate;
    
    [_feedItems removeAllObjects];
    [self.delegate itemsRemoved];
    self.lastEventGuid = nil;
    
    [self requestEventsStartingWithSuccess:^(NSArray *items) {
        if(items.count > 0) {
            [self->_feedItems addObjectsFromArray:items];
            [self.delegate itemsUpdated];
        }
        [self.tableDelegate finishUpdatingFeeds:items.count];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems:error];
    }];
}

- (void)loadMoreItems {
    if (self.showEventsOnly) {
        [self loadMoreEvents];
    } else {
        [self loadMoreFeeds];
    }
}

- (void)getNewItems {
    if (self.showEventsOnly) {
        return;
    }
    
    [self requestData:nil withSuccess:^(NSArray *items, NSString *nextPageToken) {
        [self updateItemsInPlace:items];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingNewFeedItems:error];
    }];
}

- (void)updateItemsInPlace:(NSArray *)items {
    if (items.count == 0) {
        return;
    }
    NSUInteger topItemIndex = 0;
    for (OTFeedItem *item in items) {
        NSUInteger oldFeedIndex = [self indexOfExistingLoadedFeedItem:item];
        if (oldFeedIndex != NSNotFound) {
            [_feedItems replaceObjectAtIndex:oldFeedIndex withObject:item];
        } else {
            [_feedItems insertObject:item atIndex:topItemIndex];
            topItemIndex += 1;
        }
    }
    [self.delegate itemsUpdated];
}

- (void)pause {
    [self.refreshTimer invalidate];
}

- (void)resume {
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE
                                                         target:self
                                                       selector:@selector(getNewItems)
                                                       userInfo:nil
                                                        repeats:YES];
}

#pragma mark - background notifications

- (void)willEnterForeground {
    [self getNewItems];
    [self resume];
}

- (void)didEnterBackground {
    [self pause];
}

#pragma mark - private methods

- (void)loadMoreFeeds {
    NSDate *beforeDate = [NSDate date];
    if (self.feedItems.count > 0) {
        beforeDate = [self.feedItems.lastObject updatedDate] ? [self.feedItems.lastObject updatedDate] : [self.feedItems objectAtIndex:self.feedItems.count - 2];
    }
    
    [self.tableDelegate beginUpdatingFeeds];
    [self requestData:self.pageToken withSuccess:^(NSArray *items, NSString *nextPageToken) {
        [self appendNewPage:items nextPageToken:nextPageToken];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems:error];
        [self.tableDelegate errorUpdatingFeeds];
    }];
}

- (void)appendNewPage:(NSArray *)items nextPageToken:(NSString *)nextPageToken {
    self.pageToken = nextPageToken;
    if (items.count > 0) {
        [self->_feedItems addObjectsFromArray:items];
        [self.delegate itemsUpdated];
        [self.tableDelegate finishUpdatingFeeds:items.count];
    }
    if (nextPageToken == nil) {
        [self.tableDelegate finishUpdatingFeeds:0];
    }
}

- (void)loadMoreEvents {
    self.lastEventGuid = [self.feedItems.lastObject uuid];
    [self.tableDelegate beginUpdatingFeeds];
    
    [self requestEventsStartingWithSuccess:^(NSArray *items) {
        if(items.count > 0) {
            [self->_feedItems addObjectsFromArray:items];
            [self.delegate itemsUpdated];
        }
        [self.tableDelegate finishUpdatingFeeds:items.count];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems:error];
        [self.tableDelegate errorUpdatingFeeds];
    }];
}

- (void)requestData:(NSString *)pageToken
        withSuccess:(void(^)(NSArray *items, NSString *pageToken))success
            orError:(void(^)(NSError *))failure {
    self.currentFilter.distance = self.radius;
    NSString *loadFilterString = self.currentFilter.description;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.indicatorView.hidden = NO;
    NSDictionary *filterDictionary = [self.currentFilter toDictionaryWithPageToken:pageToken andLocation:self.currentCoordinate];
    
    NSLog(@"ALA_BALA - Calling with %@", filterDictionary);

    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary
                                            success:^(NSMutableArray *feeds, NSString *nextPageToken) {
        self.lastOkCoordinate = self.currentCoordinate;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.indicatorView.hidden = YES;
                                                if (![self.currentFilter.description isEqualToString:loadFilterString]) {
                                                    return;
                                                }
                                                if (success) {
                                                    success(feeds, nextPageToken);
                                                }
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.indicatorView.hidden = YES;
        
        if (![self.currentFilter.description isEqualToString:loadFilterString]) {
            return;
        }
        
        if (failure) {
            failure(error);
        }
    }];
}

- (void)requestEventsStartingWithSuccess:(void(^)(NSArray *items))success
                                 orError:(void(^)(NSError *))failure {

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.indicatorView.hidden = NO;
    
    NSMutableDictionary *params = @{
             @"latitude": @(self.currentCoordinate.latitude),
             @"longitude": @(self.currentCoordinate.longitude),
             }.mutableCopy;
    if (self.lastEventGuid) {
        [params setObject:self.lastEventGuid forKey:@"starting_after"];
    }
    
    NSLog(@"Filter Events - Calling with %@", params);
    
    [[OTFeedsService new] getEventsWithParameters:params
                                          success:^(NSMutableArray *feeds) {
        self.lastOkCoordinate = self.currentCoordinate;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.indicatorView.hidden = YES;
        if (success) {
            success(feeds);
        }
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.indicatorView.hidden = YES;
        
        if (failure) {
            failure(error);
        }
    }];
}

- (NSUInteger)indexOfExistingLoadedFeedItem:(OTFeedItem*)feedItem {
    for (OTFeedItem *item in self.feedItems) {
        if (item.uid.integerValue == feedItem.uid.integerValue) {
            return [self.feedItems indexOfObject:item];
        }
    }
    
    return NSNotFound;
}

- (NSArray *)feedItems {
    return _feedItems.copy;
}

- (void)addFeedItemToFront:(id)feedItem {
    [_feedItems insertObject:feedItem atIndex:0];
    [self.delegate itemsUpdated];
}

- (void)removeAllFeedItems {
    [_feedItems removeAllObjects];
    [self.delegate itemsUpdated];
}

@end
