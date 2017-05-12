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
#import "NSDate+ui.h"
#import "UIImageView+entourage.h"

@interface OTSummaryProviderBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;

@end

@implementation OTSummaryProviderBehavior

- (void)awakeFromNib {
    [super awakeFromNib];
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
    if(self.txtFeedItemDescription)
        self.txtFeedItemDescription.text = [uiDelegate feedItemDescription];
    if(self.lblTimeDistance) {
        double distance = [uiDelegate distance];
        self.lblTimeDistance.text = [OTLocalizedString(@"feed_item_time_distance") stringByAppendingString: [self getDistance:distance with:feedItem.creationDate]];
    }
    self.imgAssociation.hidden = feedItem.author.partner == nil;
    [self.imgAssociation setupFromUrl:feedItem.author.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
}

- (void)clearConfiguration {
    self.lblTitle = nil;
    self.lblDescription = nil;
    self.lblUserCount = nil;
    self.btnAvatar = nil;
    self.lblTimeDistance = nil;
    self.imgAssociation = nil;
    [self configureWith:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString *)toDistance:(double)distance {
    int distanceAmount = [self getDistance:distance];
    NSString *distanceQualifier = [self getDistanceQualifier:distance];
    return [NSString stringWithFormat:@"%d%@", distanceAmount, distanceQualifier];
}

#pragma mark - private methods

- (void)profilePictureUpdated:(NSNotification *)notification {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if([currentUser.sid isEqualToNumber:self.feedItem.author.uID])
        [self.btnAvatar setupAsProfilePictureFromUrl:currentUser.avatarURL withPlaceholder:@"user"];
}

- (void)entourageUpdated:(NSNotification *)notification {
    OTFeedItem *feedItem = (OTFeedItem *)[notification.userInfo objectForKey:kNotificationEntourageChangedEntourageKey];
    [[[OTFeedItemFactory createFor:self.feedItem] getChangedHandler] updateWith:feedItem];
    [self configureWith:self.feedItem];
}

- (NSString *)getDistance:(double)distance with:(NSDate *)creationDate {
    NSString *fromDate = [creationDate sinceNow];
    if(distance < 0)
        return fromDate;
    NSString *distanceString = [OTSummaryProviderBehavior toDistance:distance];
    return [NSString stringWithFormat:OTLocalizedString(@"entourage_time_data"), fromDate, distanceString];
}

+ (int)getDistance:(double)from {
    if(from < 1000)
        return round(from);
    return round(from / 1000);
}

+ (NSString *)getDistanceQualifier:(double)from {
    if(from < 1000)
        return @"m";
    return @"km";
}

@end
