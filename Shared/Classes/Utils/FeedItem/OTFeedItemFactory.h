//
//  OTFeedItemFactory.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"
#import "OTFeedItemFactoryDelegate.h"

@interface OTFeedItemFactory : NSObject

- (id)initWithFeedItem:(OTFeedItem *)feedItem;

+ (id<OTFeedItemFactoryDelegate>)createFor:(OTFeedItem *)item;
+ (id<OTFeedItemFactoryDelegate>)createForType:(NSString *)feedItemType
                                         andId:(NSNumber *)feedItemId;
+ (id<OTFeedItemFactoryDelegate>)createEntourageForGroupType:(NSString *)groupType
                                                       andId:(NSNumber *)feedItemId;
+ (id<OTFeedItemFactoryDelegate>)createForId:(NSString *)feedItemId;

@end
