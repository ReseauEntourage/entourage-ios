//
//  OTShareFeedItemBehavior.m
//  entourage
//
//  Created by sergiu.buceac on 06/04/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import "OTShareFeedItemBehavior.h"
#import "OTConsts.h"
#import "OTUser.h"
#import "NSUserDefaults+OT.h"
#import "OTActivityProvider.h"

@interface OTShareFeedItemBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, strong) OTUser *currentUser;

@end

@implementation OTShareFeedItemBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
    self.currentUser = [NSUserDefaults standardUserDefaults].currentUser;
}

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
}

- (void)sharePublic:(id)sender {
    [OTLogger logEvent:@"OpenNativeShare"];
    [OTLogger logEvent:@"ShareLinkAsNonMember"];
    NSString *content = [NSString stringWithFormat:OTLocalizedString(@"share_public"), self.feedItem.shareUrl];
    [self share:content excludedActivities:@[UIActivityTypeCopyToPasteboard]];
}

- (void)shareMember:(id)sender {
    NSString *content = [self.currentUser.sid isEqualToNumber:self.feedItem.author.uID] ? @"share_creator" : @"share_joiner";
    content = [NSString stringWithFormat:OTLocalizedString(content), self.feedItem.shareUrl];
    [self share:content excludedActivities:nil];
}

#pragma mark - private methods

- (void)share:(NSString *)content excludedActivities:(NSArray*)excludedActivities {
    NSURL *url = [NSURL URLWithString:self.feedItem.shareUrl];
    OTActivityProvider *activity = [[OTActivityProvider alloc] initWithPlaceholderItem:@{@"body":content, @"url": url}];
    activity.emailBody = content;
    activity.emailSubject = @"";
    activity.url = url;
    NSArray *objectsToShare = @[activity];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = excludedActivities;
    [self.owner presentViewController:activityVC animated:YES completion:nil];
}

@end
