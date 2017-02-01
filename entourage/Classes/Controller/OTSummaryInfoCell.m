//
//  OTSummaryInfoCell.m
//  entourage
//
//  Created by sergiu buceac on 10/27/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSummaryInfoCell.h"
#import "OTFeedItem.h"

@implementation OTSummaryInfoCell

- (void)configureWith:(OTFeedItem *)item {
    self.summaryProvider.lblTitle = self.lblTitle;
    self.summaryProvider.lblDescription = self.lblDescription;
    self.summaryProvider.lblUserCount = self.lblUserCount;
    self.summaryProvider.btnAvatar = self.btnAvatar;
    self.summaryProvider.lblTimeDistance = self.lblTimeDistance;
    self.summaryProvider.imgAssociation = self.imgAssociation;
    [self.summaryProvider configureWith:item];
    [self.summaryProvider clearConfiguration];
}

@end
