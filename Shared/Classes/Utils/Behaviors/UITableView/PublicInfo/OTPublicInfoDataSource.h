//
//  OTPublicInfoDataSource.h
//  entourage
//
//  Created by sergiu buceac on 10/26/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDataSourceBehavior.h"
#import "OTFeedItem.h"

@interface OTPublicInfoDataSource : OTDataSourceBehavior

- (void)loadDataFor:(OTFeedItem *)feedItem;

@end
