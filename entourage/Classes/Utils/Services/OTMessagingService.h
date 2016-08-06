//
//  OTMessagingService.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"

@interface OTMessagingService : NSObject

- (void)readFor:(OTFeedItem *)feedItem withResultBlock:(void (^)(NSArray *))result;

@end
