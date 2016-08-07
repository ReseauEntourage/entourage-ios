//
//  OTMessageSentCell.m
//  entourage
//
//  Created by sergiu buceac on 8/7/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTMessageSentCell.h"
#import "OTFeedItemMessage.h"

@implementation OTMessageSentCell

- (void)awakeFromNib {
    self.lblMessage.edgeInsets = UIEdgeInsetsMake(8, 17, 8, 17);
}

- (void)configureWithTimelinePoint:(OTFeedItemTimelinePoint *)timelinePoint {
    OTFeedItemMessage *msgData = (OTFeedItemMessage *)timelinePoint;
    self.lblMessage.text = msgData.text;
}

@end
