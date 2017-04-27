//
//  OTNewsFeedCell.m
//  entourage
//
//  Created by veronica.gliga on 26/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTNewsFeedCell.h"
#import "OTSummaryProviderBehavior.h"
#import "OTFeedItemFactory.h"
#import "UIButton+entourage.h"

@interface OTNewsFeedCell ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTNewsFeedCell

- (void)configureWith:(OTFeedItem *) item {
    self.feedItem = item;
    OTSummaryProviderBehavior *summaryBehavior = [OTSummaryProviderBehavior new];
    summaryBehavior.lblTimeDistance = self.timeLocationLabel;
    summaryBehavior.imgAssociation = self.imgAssociation;
    [summaryBehavior configureWith:item];
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:item] getUI];
    self.typeByNameLabel.attributedText = [uiDelegate descriptionWithSize:DEFAULT_DESCRIPTION_SIZE];
    self.organizationLabel.text = [uiDelegate summary];
    [self.userProfileImageButton setupAsProfilePictureFromUrl:item.author.avatarUrl];
    self.noPeopleLabel.text = [NSString stringWithFormat:@"%d", item.noPeople.intValue];
    [self.statusButton setupAsStatusButtonForFeedItem:item];
    [self.statusTextButton setupAsStatusTextButtonForFeedItem:item];
    [self.statusLineMarker setBackgroundColor:self.statusTextButton.currentTitleColor];
    self.unreadCountText.hidden = item.unreadMessageCount.intValue == 0;
    self.unreadCountText.text = item.unreadMessageCount.stringValue;
}

- (IBAction)doShowProfile {
    [OTLogger logEvent:@"UserProfileClick"];
    if (self.tableViewDelegate != nil && [self.tableViewDelegate respondsToSelector:@selector(showUserProfile:)])
        [self.tableViewDelegate showUserProfile:self.feedItem.author.uID];
}

- (IBAction)doJoinRequest {
    if (self.tableViewDelegate != nil && [self.tableViewDelegate respondsToSelector:@selector(doJoinRequest:)])
        [self.tableViewDelegate doJoinRequest:self.feedItem];
}

@end
