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
#import "OTAnnouncement.h"
#import "NSDate+OTFormatter.h"
#import "UIImage+processing.h"
#import "UIImage+Fitting.h"

@interface OTSummaryProviderBehavior ()

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation OTSummaryProviderBehavior

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(profilePictureUpdated:) name:@kNotificationProfilePictureUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(entourageUpdated:) name:kNotificationEntourageChanged object:nil];
    
    if (!self.fontSize) {
        self.fontSize = [NSNumber numberWithFloat:DEFAULT_DESCRIPTION_SIZE];
    }
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"dd MMM";
    self.imgCategorySize = CGSizeMake(18, 18);
}

- (void)configureWith:(OTFeedItem *)feedItem {
    self.feedItem = feedItem;
    id<OTUIDelegate> uiDelegate = [[OTFeedItemFactory createFor:feedItem] getUI];
    
    if (self.lblTitle) {
        self.lblTitle.text = [uiDelegate summary];
    }
    
    if (self.lblUserCount) {
        self.lblUserCount.text = [feedItem.noPeople stringValue];
    }
    if (self.btnAvatar) {
        [self.btnAvatar setupAsProfilePictureFromUrl:feedItem.author.avatarUrl];
    }
    
    if (self.lblDescription) {
        [self.lblDescription setAttributedText:[uiDelegate descriptionWithSize:self.fontSize.floatValue]];
    }
    
    if (self.txtFeedItemDescription) {
        self.txtFeedItemDescription.text = [uiDelegate feedItemDescription];
    }
    
    if (self.lblTimeDistance) {
        double distance = [uiDelegate distance];
        if (self.showTimeAsUpdatedDate) {
            self.lblTimeDistance.text = [self formattedMessageTimeForFeedItem:feedItem distance:distance];
        } else {
            self.lblTimeDistance.text = [self formattedItemDistance:distance
                                                       creationDate:feedItem.creationDate];
        }
    }
    
    self.imgAssociation.hidden = feedItem.author.partner == nil;
    [self.imgAssociation setupFromUrl:feedItem.author.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    
    NSString *source = [uiDelegate categoryIconSource];
    UIImage *image = nil;
    
    if ([feedItem isKindOfClass:[OTAnnouncement class]]) {
        self.imgCategory.backgroundColor = [UIColor clearColor];
        self.imgCategory.contentMode = UIViewContentModeScaleAspectFit;
        [self.imgCategory setupFromUrl:source withPlaceholder:nil];
    }
    else {
        if ([feedItem isOuting]) {
            image = [[UIImage imageNamed:source] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.imgCategory.tintColor = [OTAppAppearance iconColorForFeedItem:feedItem];
            
        } else if ([feedItem isConversation]) {
            if (self.feedItem.author.avatarUrl) {
                self.imgCategory.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                self.imgCategory.contentMode = UIViewContentModeCenter;
            }
            [self.imgCategory setupFromUrl:self.feedItem.author.avatarUrl withPlaceholder:@"userSmall"];
        } else {
            image = [UIImage imageNamed:source];
        }
        self.imgCategory.backgroundColor = [UIColor whiteColor];
    }
    
    if (image) {
        [self.imgCategory setImage:image];
    }
    
    if (self.showRoundedBorder) {
        self.imgCategory.layer.borderColor = UIColor.groupTableViewBackgroundColor.CGColor;
        self.imgCategory.layer.borderWidth = 1;
        self.imgCategory.clipsToBounds = YES;
        self.imgCategory.layer.cornerRadius = self.imgCategory.bounds.size.width / 2;
        self.imgCategory.contentMode = UIViewContentModeCenter;
    }
}

- (void)clearConfiguration {
    self.lblTitle = nil;
    self.lblDescription = nil;
    self.lblUserCount = nil;
    self.btnAvatar = nil;
    self.lblTimeDistance = nil;
    self.imgAssociation = nil;
    self.imgCategory = nil;
    self.imgCategory = nil;
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

- (NSString *)formattedMessageTimeForFeedItem:(OTFeedItem*)feedItem distance:(CGFloat)distance {
    if ([feedItem.updatedDate isToday]) {
        return [feedItem.updatedDate toTimeString];
        
    } else if ([feedItem.updatedDate isYesterday]) {
        return OTLocalizedString(@"yesterday");
    } else {
        return [self.dateFormatter stringFromDate:feedItem.updatedDate];
    }
}

#pragma mark - private methods

- (void)profilePictureUpdated:(NSNotification *)notification {
    OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    if(self.feedItem.author.uID != nil)
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

- (NSString *)formattedItemDistance:(double)distance creationDate:(NSDate *)creationDate {
    NSString *fromDate = [creationDate sinceNow];
    if (distance < 0) {
        return fromDate;
    }
    NSString *distanceString = [OTSummaryProviderBehavior toDistance:distance];
    return [NSString stringWithFormat:OTLocalizedString(@"entourage_distance"), distanceString];
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
