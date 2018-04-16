//
//  OTMembersDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/25/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDataSourceBehavior.h"
#import "OTFeedItem.h"

@interface OTMembersDataSource : OTDataSourceBehavior

- (void)loadDataFor:(OTFeedItem *)feedItem;

@end
