//
//  OTStatusChangedProtocol.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTCloseReason.h"

@protocol OTStatusChangedProtocol <NSObject>

- (void)joinFeedItem;
- (void)stoppedFeedItem;
- (void)closedFeedItemWithReason: (OTCloseReason) reason;
- (void)quitedFeedItem;
- (void)cancelledJoinRequest;

@end
