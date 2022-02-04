//
//  OTMessageTableDataSourceBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTTableDataSourceBehavior.h"
#import "MessageCellType.h"
#import "OTFeedItemTimelinePoint.h"

@interface OTMessageTableDataSourceBehavior : OTTableDataSourceBehavior

- (MessageCellType)getCellType:(OTFeedItemTimelinePoint *)timelinePoint;

@end
