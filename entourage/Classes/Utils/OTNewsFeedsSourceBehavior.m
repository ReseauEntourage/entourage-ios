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
@property (nonatomic, strong) OTNewsFeedsFilter *currentFilter;

@end

@implementation OTNewsFeedsSourceBehavior

- (void)initialize {
    self.feedItems = [NSMutableArray new];
}

- (void)reloadItemsAt:(CLLocationCoordinate2D)coordinate withFilters:(OTNewsFeedsFilter *)filter {
    printf("ME - reloadItemsAt");
    self.currentCoordinate = coordinate;
    @synchronized (self.currentFilter) {
        self.currentFilter = filter;
    }
    [self reloadItems];
}

- (void)loadMoreItems {
    printf("ME - loadMoreItems");
    NSDate *beforeDate = [NSDate date];
    if(self.feedItems.count > 0)
        beforeDate = [self.feedItems.lastObject updatedDate];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
        [self.feedItems addObjectsFromArray:[self sortItems:items]];
        [self.delegate itemsUpdated];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems];
    }];
}

- (void)pause {
    printf("ME - pause");
    [self.refreshTimer invalidate];
}

- (void)resume {
    printf("ME - resume");
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:DATA_REFRESH_RATE target:self selector:@selector(getNewItems) userInfo:nil repeats:YES];
}

#pragma mark - private methods

- (void)reloadItems {
    [self.feedItems removeAllObjects];
    NSDate *beforeDate = [NSDate date];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
        [self.feedItems addObjectsFromArray:[self sortItems:items]];
        [self.delegate itemsUpdated];
        [self resume];
    } orError:^(NSError *error) {
        [self.delegate errorLoadingFeedItems];
        [self resume];
    }];
}

- (void)getNewItems {
    NSDate *beforeDate = [NSDate date];
    [self requestData:beforeDate withSuccess:^(NSArray *items) {
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
        [self.delegate errorLoadingNewFeedItems];
    }];
}

- (void)requestData:(NSDate *)beforeDate withSuccess:(void(^)(NSArray *items))success orError:(void(^)(NSError *))failure {
    printf("ME - requestData");
    NSString *loadFilterString = self.currentFilter.description;
    NSDictionary *filterDictionary = [self.currentFilter toDictionaryWithBefore:beforeDate andLocation:self.currentCoordinate];
    [[OTFeedsService new] getAllFeedsWithParameters:filterDictionary success:^(NSMutableArray *feeds) {
        @synchronized (self.currentFilter) {
            if(![self.currentFilter.description isEqualToString:loadFilterString]) {
                printf("ME - filter changed ignoring data");
                return;
            }
        }
        if(success)
            success(feeds);
    } failure:^(NSError *error) {
        @synchronized (self.currentFilter) {
            if(![self.currentFilter.description isEqualToString:loadFilterString]) {
                printf("ME - filter changed ignoring data");
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
