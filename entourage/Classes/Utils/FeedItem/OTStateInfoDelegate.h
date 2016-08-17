//
//  OTStateInfoDelegate.h
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FeedItemStateNone,
    FeedItemStateOpen,
    FeedItemStateClosed,
    FeedItemStateOngoing,
    FeedItemStateFrozen,
    FeedItemStateJoinAccepted,
    FeedItemStateJoinPending,
    FeedItemStateJoinNotRequested,
    FeedItemStateJoinRejected
} FeedItemState;

@protocol OTStateInfoDelegate <NSObject>

- (FeedItemState)getState;
- (BOOL)canChangeEditState;
- (BOOL)canInvite;
- (BOOL)isActive;
- (BOOL)isPublic;
- (void)loadById:(NSNumber *)feedItemId withSuccess:(void(^)(OTFeedItem *))success error:(void(^)(NSError *))failure;

@end
