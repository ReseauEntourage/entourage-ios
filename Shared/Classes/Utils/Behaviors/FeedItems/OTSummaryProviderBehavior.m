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
        if ([feedItem isNeighborhood] || [feedItem isPrivateCircle]) {
            self.btnAvatar.hidden = true;
        } else {
            self.btnAvatar.hidden = false;
            [self.btnAvatar setupAsProfilePictureFromUrl:feedItem.author.avatarUrl];
        }
    }
    
    if (self.lblDescription) {
        if ([feedItem isNeighborhood] || [feedItem isPrivateCircle]) {
            self.lblDescription.text = @" ";
        } else if (self.lblUserName) {
            self.lblDescription.text = [uiDelegate descriptionWithoutUserName_hasToShowDate:NO];
        } else {
            [self.lblDescription setAttributedText:[uiDelegate descriptionWithSize:self.fontSize.floatValue hasToShowDate:NO]];
        }
    }

    if (self.lblUserName) {
        if ([feedItem isOuting] || [feedItem isNeighborhood] || [feedItem isPrivateCircle]) {
            self.lblUserName.text = nil;
        } else {
            self.lblUserName.text = [uiDelegate userName];
        }
    }

    if (self.txtFeedItemDescription) {
        self.txtFeedItemDescription.text = [uiDelegate feedItemDescription];
    }
    
    if (self.lblLocation) {
        if ([feedItem isOuting]) {
            self.lblLocation.hidden = true;
        } else {
            self.lblLocation.hidden = false;
        }
        
        if (feedItem.displayAddress.length > 0) {
            self.lblLocation.text = [NSString stringWithFormat:OTLocalizedString(@"entourage_location"), feedItem.displayAddress];
        } else {
            self.lblLocation.text = @" ";
        }
    }

    if (self.lblTimeDistance) {
        double distance = [uiDelegate distance];
        NSString *distanceStr = @"";
        if (self.showTimeAsUpdatedDate) {
            distanceStr = [self formattedMessageTimeForFeedItem:feedItem distance:distance];
            if (distanceStr.length > 0) {
                distanceStr = [NSString stringWithFormat:@"%@ - ",distanceStr];
            }
        } else if (distance < 1000000.f) {
            distanceStr = [self formattedItemDistance:distance
                                         creationDate:feedItem.creationDate];
            if (distanceStr.length > 0) {
                distanceStr = [NSString stringWithFormat:@"%@ - ",distanceStr];
            }
        } else {
            distanceStr = @"";
        }
        if (self.isFromMyEntourages) {
            distanceStr = [distanceStr stringByReplacingOccurrencesOfString:@" - " withString:@""];
            self.lblTimeDistance.text = distanceStr;
        }
        else {
            self.lblTimeDistance.text = [NSString stringWithFormat:@"%@%@",distanceStr,feedItem.postalCode];
        }
    }
    
    self.imgAssociation.hidden = feedItem.author.partner == nil;
    [self.imgAssociation setupFromUrl:feedItem.author.partner.smallLogoUrl withPlaceholder:@"badgeDefault"];
    
    NSString *source = [uiDelegate categoryIconSource];
    UIImage *image = nil;
    
    if ([feedItem isKindOfClass:[OTAnnouncement class]]) {
        self.imgCategory.backgroundColor = [UIColor clearColor];
        self.imgCategory.contentMode = UIViewContentModeScaleAspectFit;
        [self.imgCategory setupFromUrl:source
                       withPlaceholder:nil
                               success:^(id request, id response, UIImage *image) {
                                   self.imgCategory.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                               }
                               failure:nil];
    }
    else {
        if ([feedItem isOuting]) {
            image = [[UIImage imageNamed:source] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.imgCategory.tintColor = [OTAppAppearance iconColorForFeedItem:feedItem];
            self.imgCategory.contentMode = UIViewContentModeCenter;
            
        } else if ([feedItem isConversation]) {
            if (self.feedItem.author.avatarUrl) {
                self.imgCategory.contentMode = UIViewContentModeScaleAspectFit;
            } else {
                self.imgCategory.contentMode = UIViewContentModeCenter;
            }
            [self.imgCategory setupFromUrl:self.feedItem.author.avatarUrl withPlaceholder:@"userSmall"];
        } else {
            image = [UIImage imageNamed:source];
            self.imgCategory.contentMode = UIViewContentModeCenter;
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
    }
}

- (void)clearConfiguration {
    self.lblTitle = nil;
    self.lblDescription = nil;
    self.lblUserName = nil;
    self.lblLocation = nil;
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
    if (self.feedItem.author.uID != nil) {
        if ([currentUser.sid isEqualToNumber:self.feedItem.author.uID]) {
            [self.btnAvatar setupAsProfilePictureFromUrl:currentUser.avatarURL withPlaceholder:@"user"];
        }
    }
}

- (void)entourageUpdated:(NSNotification *)notification {
    OTFeedItem *feedItem = (OTFeedItem *)[notification.userInfo objectForKey:kNotificationEntourageChangedEntourageKey];
    [[[OTFeedItemFactory createFor:self.feedItem] getChangedHandler] updateWith:feedItem];
    [self configureWith:self.feedItem];
}

- (NSString *)getDistance:(double)distance with:(NSDate *)creationDate {
    NSString *fromDate = [creationDate sinceNow];
    if (distance < 0) {
        return fromDate;
    }
    NSString *distanceString = [OTSummaryProviderBehavior toDistance:distance];
    return [NSString stringWithFormat:OTLocalizedString(@"entourage_time_data"), fromDate, distanceString];
}

- (NSString *)formattedItemDistance:(double)distance creationDate:(NSDate *)creationDate {
    //NSString *fromDate = [creationDate sinceNow];
    if (distance < 0) {
        // If negative distance, means no location for the entourage item/feed/action
        //return fromDate;
        return @"";
    }
    NSString *distanceString = [OTSummaryProviderBehavior toDistance:distance];
    return [NSString stringWithFormat:OTLocalizedString(@"entourage_distance"), distanceString];
}

+ (int)getDistance:(double)from {
    if (from < 1000) {
        return round(from);
    }
    
    return round(from / 1000);
}

+ (NSString *)getDistanceQualifier:(double)from {
    if (from < 1000) {
        return @"m";
    }
    
    return @"km";
}

@end
