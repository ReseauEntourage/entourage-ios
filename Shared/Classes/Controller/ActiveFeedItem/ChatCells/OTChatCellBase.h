//
//  OTChatCellBase.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemTimelinePoint.h"

@interface OTChatCellBase : UITableViewCell

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint;

@end
