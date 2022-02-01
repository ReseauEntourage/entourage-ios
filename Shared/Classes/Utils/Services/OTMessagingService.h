//
//  OTMessagingService.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"
#import "OTDataSourceBehavior.h"

@interface OTMessagingService : NSObject

- (void)readFor:(OTFeedItem *)feedItem onDataSource:(OTDataSourceBehavior *)dataSource;

@end
