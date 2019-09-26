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
    self.summaryProvider.lblUserName = self.lblUserName;
    self.summaryProvider.lblUserCount = self.lblUserCount;
    self.summaryProvider.btnAvatar = self.btnAvatar;
    self.summaryProvider.lblLocation = self.lblLocation;
    self.summaryProvider.imgAssociation = self.imgAssociation;
    self.summaryProvider.imgCategory = self.imgCategory;
    [self.summaryProvider configureWith:item];
    [self.summaryProvider clearConfiguration];
}

@end
