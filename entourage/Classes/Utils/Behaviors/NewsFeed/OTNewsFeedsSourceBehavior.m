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

@interface OTNewsFeedsSourceBehavior ()

@property (nonatomic, strong) NSTimer *refreshTimer;
@property (nonatomic, assign) CLLocationCoordinate2D currentCoordinate;

@end

@implementation OTNewsFeedsSourceBehavior

- (void)initialize {
    self.feedItems = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadItemsAt:(CLLocationCoordinate2D)coordinate withFilters:(OTNewsFeedsFilter *)filter {
    filter.location = coordinate;
    if([self.currentFilter.description isEqualToString:filter.description])
        return;
    self.currentCoordinate = coordinate;
    self.currentFilter = [filter copy];
    self.currentFilter.location = coordinate;
    [self.feedItems removeAllObjects];
    [self.delegate itemsRemoved];
    NSDate *beforeDate = [NSDate date];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
        [self.feedItems addObjectsFromArray:[self sortItems:items]];
        [self.delegate itemsUpdated];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems:error];
    }];
}

- (void)loadMoreItems {
    NSDate *beforeDate = [NSDate date];
    if(self.feedItems.count > 0)
        beforeDate = [self.feedItems.lastObject updatedDate];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
        [self.feedItems addObjectsFromArray:[self sortItems:items]];
        [self.delegate itemsUpdated];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems:error];
    }];
}

- (void)getNewItems {
    NSDate *beforeDate = [NSDate date];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
        for(OTFeedItem *item in items)
            [self addFeedItem:item];
        [self.delegate itemsUpdated];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingNewFeedItems:error];
    }];
}

- (void)pause {
    [self.refreshTimer invalidate];
}

- (void)resume {
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE target:self selector:@selector(getNewItems) userInfo:nil repeats:YES];
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

- (void)requestData:(NSDate *)beforeDate withSuccess:(void(^)(NSArray *items))success orError:(void(^)(NSError *))failure {
    NSString *loadFilterString = self.currentFilter.description;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.indicatorView.hidden = NO;
    NSDictionary *filterDictionary = [self.currentFilter toDictionaryWithBefore:beforeDate andLocation:self.currentCoordinate];
    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary success:^(NSMutableArray *feeds) {
        self.lastOkCoordinate = self.currentCoordinate;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.indicatorView.hidden = YES;
        if(![self.currentFilter.description isEqualToString:loadFilterString])
            return;
        if(success)
            success(feeds);
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.indicatorView.hidden = YES;
        if(![self.currentFilter.description isEqualToString:loadFilterString])
            return;
        if(failure)
            failure(error);
    }];
}

- (NSArray *)sortItems:(NSArray *)array {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:NO];
    return [array sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (void)addFeedItem:(OTFeedItem *)feedItem {
    NSUInteger oldFeedIndex = [self.feedItems indexOfObject:feedItem];
    if (oldFeedIndex != NSNotFound) {
        [self.feedItems replaceObjectAtIndex:oldFeedIndex withObject:feedItem];
        return;
    }
    for (NSUInteger i = 0; i < [self.feedItems count]; i++) {
        OTFeedItem* internalFeedItem = self.feedItems[i];
        if ([internalFeedItem.updatedDate compare:feedItem.updatedDate] == NSOrderedAscending) {
            [self.feedItems insertObject:feedItem atIndex:i];
            return;
        }
    }
    [self.feedItems addObject:feedItem];
}

@end
