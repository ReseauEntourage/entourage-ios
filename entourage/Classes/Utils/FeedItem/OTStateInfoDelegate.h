//
//  OTStateInfoDelegate.h
//  entourage
//
//  Created by sergiu buceac on 6/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FeedItemStateNone = -1,
    FeedItemStateOpen,
    FeedItemStateClosed,
    FeedItemStateFrozen,
    FeedItemStateQuit
} FeedItemState;

@protocol OTStateInfoDelegate <NSObject>

- (FeedItemState)getActionableState;
- (BOOL)canChangeState;

@end
