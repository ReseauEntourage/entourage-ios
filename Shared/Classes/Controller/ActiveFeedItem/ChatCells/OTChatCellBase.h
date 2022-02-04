//
//  OTChatCellBase.h
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItemTimelinePoint.h"

@interface OTChatCellBase : UITableViewCell <UITextViewDelegate>

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint;

@end
