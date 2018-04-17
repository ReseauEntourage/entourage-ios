//
//  OTMyEntouragesDataSource.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDataSourceBehavior.h"
#import "OTFeedItemsFilterDelegate.h"

@interface OTMyEntouragesDataSource : OTDataSourceBehavior <OTFeedItemsFilterDelegate>

- (void)loadNextPage;

@end
