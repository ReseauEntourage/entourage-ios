//
//  OTStatusChangedProtocol.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OTStatusChangedProtocol <NSObject>

- (void)joinFeedItem;
- (void)stoppedFeedItem;
- (void)closedFeedItem;

@end
