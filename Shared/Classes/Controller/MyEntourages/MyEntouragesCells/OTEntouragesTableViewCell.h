//
//  OTEntouragesTableViewCell.h
//  entourage
//
//  Created by sergiu buceac on 8/10/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTSummaryProviderBehavior.h"
#import "OTUserProfileBehavior.h"
#import "OTDataSourceBehavior.h"

@interface OTEntouragesTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblTimeDistance;
@property (nonatomic, weak) IBOutlet UILabel *lblLastMessage;
@property (nonatomic, weak) IBOutlet UIImageView *imgCategory;

@property (nonatomic, weak) IBOutlet OTSummaryProviderBehavior *summaryProvider;
@property (nonatomic, weak) IBOutlet OTUserProfileBehavior *userProfile;
@property (nonatomic, weak) IBOutlet OTDataSourceBehavior *dataSource;

- (void)configureWith:(OTFeedItem *)item;

@end
