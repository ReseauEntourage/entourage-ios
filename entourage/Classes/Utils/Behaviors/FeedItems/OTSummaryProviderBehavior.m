//
//  OTSummaryProviderBehavior.m
//  entourage
//
//  Created by sergiu buceac on 8/2/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTSummaryProviderBehavior.h"
#import "UIButton+entourage.h"
#import "OTFeedItemFactory.h"
#import "OTUIDelegate.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "OTUser.h"
#import "UIButton+entourage.h"

@interface OTSummaryProviderBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTSummaryProviderBehavior

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilePictureUpdated:) name:@kNotificationProfilePictureUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(entourageUpdated:) name:kNotificationEntourageChanged object:nil];
    if(!self.fontSize)
        self.fontSize = [NSNumber numberWithFloat:DEFAULT_DESCRIPTION_SIZE];
}

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:feedItem] getUI];
    if(self.lblTitle)
        self.lblTitle.text = [uiDelegate summary];
    if(self.lblUserCount)
        self.lblUserCount.text = [feedItem.noPeople stringValue];
    if(self.btnAvatar)
        [self.btnAvatar setupAsProfilePictureFromUrl:feedItem.author.avatarUrl];
    if(self.lblDescription)
        [self.lblDescription setAttributedText:[uiDelegate descriptionWithSize:self.fontSize.floatValue]];
    if(self.lblFeedItemDescription)
        self.lblFeedItemDescription.text = [uiDelegate feedItemDescription];
    if(self.lblTimeDistance) {
    self.lblTimeDistance.text = @"";
        [uiDelegate timeDataWithCompletion:^(NSString *result) {
            self.lblTimeDistance.text = result;
        }];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - private methods

- (void)profilePictureUpdated:(NSNotification *)notification {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    [self.btnAvatar setupAsProfilePictureFromUrl:currentUser.avatarURL withPlaceholder:@"user"];
}

- (void)entourageUpdated:(NSNotification *)notification {
    OTFeedItem *feedItem = (OTFeedItem *)[notification.userInfo objectForKey:kNotificationEntourageChangedEntourageKey];
    [[[OTFeedItemFactory createFor:self.feedItem] getChangedHandler] updateWith:feedItem];
    [self configureWith:self.feedItem];
}

@end