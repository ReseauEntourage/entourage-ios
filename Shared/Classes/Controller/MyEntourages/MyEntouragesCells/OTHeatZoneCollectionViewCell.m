 //
//  OTHeatZoneCollectionViewCell.m
//  entourage
//
//  Created by Veronica Gliga on 14/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTHeatZoneCollectionViewCell.h"

@implementation OTHeatZoneCollectionViewCell

- (void)configureWith:(OTFeedItem *)item {
    self.summaryProvider.lblTitle = self.lblTitle;
    self.summaryProvider.lblDescription = self.lblUsername;
    self.summaryProvider.lblUserCount = self.lblNumberOfUsers;
    self.summaryProvider.lblTimeDistance = self.lblTimeDistance;
    self.summaryProvider.imgCategory = self.imgCategory;
    [self.summaryProvider configureWith:item];
    [self.summaryProvider clearConfiguration];
}

@end
