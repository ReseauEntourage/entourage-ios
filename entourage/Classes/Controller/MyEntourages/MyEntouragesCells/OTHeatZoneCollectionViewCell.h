//
//  OTHeatZoneCollectionViewCell.h
//  entourage
//
//  Created by Veronica Gliga on 14/09/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTEntourage.h"
#import "OTSummaryProviderBehavior.h"

@interface OTHeatZoneCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblUsername;
@property (nonatomic, weak) IBOutlet UILabel *lblTimeDistance;
@property (nonatomic, weak) IBOutlet UILabel *lblNumberOfUsers;
@property (nonatomic, weak) IBOutlet OTSummaryProviderBehavior *summaryProvider;

- (void)configureWith:(OTFeedItem *)item;

@end
