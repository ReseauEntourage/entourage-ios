//
//  OTAnnouncementCell.m
//  entourage
//
//  Created by veronica.gliga on 02/11/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTAnnouncementCell.h"
#import "OTFeedItemFactory.h"
#import "UIButton+entourage.h"
#import "OTSummaryProviderBehavior.h"

NSString* const OTAnnouncementTableViewCellIdentifier = @"OTAnnouncementTableViewCellIdentifier";

@interface OTAnnouncementCell ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTAnnouncementCell

- (void)configureWith:(OTFeedItem *) item {
    self.feedItem = item;
    OTSummaryProviderBehavior *summaryBehavior = [OTSummaryProviderBehavior new];
    summaryBehavior.imgAssociation = self.imgAssociation;
    summaryBehavior.imgCategory = self.iconImage;
    [summaryBehavior configureWith:item];
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:item] getUI];
    self.titleLabel.text = [uiDelegate summary];
    self.descriptionLabel.text = [uiDelegate feedItemDescription];
    [self.userProfileImageButton setupAsProfilePictureFromUrl:item.author.avatarUrl];
    [self.statusTextButton setTitle:[uiDelegate feedItemActionButton] forState:UIControlStateNormal];
}

- (IBAction)doShowProfile {
    [OTLogger logEvent:@"UserProfileClick"];
    if (self.tableViewDelegate != nil && [self.tableViewDelegate respondsToSelector:@selector(showUserProfile:)])
        [self.tableViewDelegate showUserProfile:self.feedItem.author.uID];
}

@end
