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
}

- (BOOL)reloadItemsAt:(CLLocationCoordinate2D)coordinate withFilters:(OTNewsFeedsFilter *)filter {
    printf("\nME - reloadItemsAt");
    filter.location = coordinate;
    if([self.currentFilter.description isEqualToString:filter.description])
        return NO;
    self.currentCoordinate = coordinate;
    @synchronized (self.currentFilter) {
        self.currentFilter = [filter copy];
        self.currentFilter.location = coordinate;
    }
    [self.feedItems removeAllObjects];
    NSDate *beforeDate = [NSDate date];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
        [self.feedItems addObjectsFromArray:[self sortItems:items]];
        [self.delegate itemsUpdated];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems:error];
    }];
    return YES;
}

- (void)loadMoreItems {
    printf("\nME - loadMoreItems");
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
    printf("\nME - get new items");
    NSDate *beforeDate = [NSDate date];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
        if(items.count == 0)
            return;
        NSArray *sortedNewItems = [self sortItems:items];
        if(self.feedItems.count == 0)
            [self.feedItems addObjectsFromArray:sortedNewItems];
        else {
            NSDate *newestDate = [self.feedItems.firstObject updatedDate];
            int index = 0;
            for(OTFeedItem *item in sortedNewItems) {
                if([item.updatedDate compare:newestDate] != NSOrderedDescending)
                    break;
                [self.feedItems insertObject:item atIndex:index];
                index++;
            }
        }
        [self.delegate itemsUpdated];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingNewFeedItems:error];
    }];
}

- (void)pause {
    printf("\nME - pause");
    [self.refreshTimer invalidate];
}

- (void)resume {
    printf("\nME - resume");
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE target:self selector:@selector(getNewItems) userInfo:nil repeats:YES];
}

#pragma mark - private methods

- (void)requestData:(NSDate *)beforeDate withSuccess:(void(^)(NSArray *items))success orError:(void(^)(NSError *))failure {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    printf("\nME - requestData");
    NSString *loadFilterString = self.currentFilter.description;
    NSDictionary *filterDictionary = [self.currentFilter toDictionaryWithBefore:beforeDate andLocation:self.currentCoordinate];
    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary success:^(NSMutableArray *feeds) {
        printf("\nME - requestData ok");
        self.lastOkCoordinate = self.currentCoordinate;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        @synchronized (self.currentFilter) {
            if(![self.currentFilter.description isEqualToString:loadFilterString]) {
                printf("\nME - filter changed ignoring data");
                return;
            }
        }
        if(success)
            success(feeds);
    } failure:^(NSError *error) {
        printf("\nME - requestData fail");
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        @synchronized (self.currentFilter) {
            if(![self.currentFilter.description isEqualToString:loadFilterString]) {
                printf("\nME - filter changed ignoring this data");
                return;
            }
        }
        if(failure)
            failure(error);
    }];
}

- (NSArray *)sortItems:(NSArray *)array {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updatedDate" ascending:NO];
    return [array sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
