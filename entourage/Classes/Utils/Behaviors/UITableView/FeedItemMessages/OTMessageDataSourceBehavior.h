//
//  OTMessageDataSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/8/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTDataSourceBehavior.h"
#import "OTFeedItemJoiner.h"

@interface OTMessageDataSourceBehavior : OTDataSourceBehavior

- (void)acceptJoin:(OTFeedItemJoiner *)joiner atPath:(NSIndexPath *)path;
- (void)rejectJoin:(OTFeedItemJoiner *)joiner atPath:(NSIndexPath *)path;

@end
