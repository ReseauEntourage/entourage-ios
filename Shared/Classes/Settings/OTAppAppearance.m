//
//  OTAppAppearance.m
//  entourage
//
//  Created by Smart Care on 07/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTAppAppearance.h"
#import "OTAppConfiguration.h"
#import "OTEntourage.h"
#import "OTAPIConsts.h"
#import "OTFeedItemFactory.h"
#import "OTFeedItem.h"
#import "UIImage+processing.h"
#import <AFNetworking/UIButton+AFNetworking.h>
#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTUser.h"
#import "OTConsts.h"
#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"
#import "UIColor+Expanded.h"
#import "NSDate+OTFormatter.h"
#import "NSDate+ui.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImage+Fitting.h"
#import "entourage-Swift.h"


@implementation OTAppAppearance

+ (UIImage*)applicationLogo
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIImage imageNamed:@"pfp-logo"];
    }
    
    return [UIImage imageNamed:@"entourageLogo"];
}

+ (NSString*)aboutUrlString
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return PFP_ABOUT_CGU_URL;
    }
    return ABOUT_CGU_URL;
}

+ (NSString *)welcomeDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_welcomeText");
    }
    
    return OTLocalizedString(@"welcomeText");
}

+ (UIImage*)welcomeLogo
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return nil;
    }
    
    return [UIImage imageNamed:@"logoWhiteEntourage"];
}

+ (NSString *)userProfileNameDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userNameDescriptionText");
    }
    
    return OTLocalizedString(@"userNameDescriptionText");
}

+ (NSString *)userProfileEmailDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userEmailDescriptionText");
    }
    
    return OTLocalizedString(@"userEmailDescriptionText");
}

+ (NSString *)notificationsRightsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_userNotificationsDescriptionText");
    }
    
    return OTLocalizedString(@"userNotificationsDescriptionText");
}

+ (NSString *)defineActionZoneTitle {
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_defineActionZoneTitle");
    }
    
    return OTLocalizedString(@"defineActionZoneTitle");
}

+ (NSString *)geolocalisationRightsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_geolocalisationDescriptionText");
    }
    
    return OTLocalizedString(@"geolocalisationDescriptionText");
}

+ (NSString *)defineActionZoneSampleAddress {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_defineActionZoneSampleAddress");
    }
    
    return OTLocalizedString(@"defineActionZoneSampleAddress");
}

+ (NSAttributedString *)defineActionZoneFormattedDescription {
    UIFont *regularFont = [UIFont fontWithName:@"SFUIText-Regular" size:15];
    UIFont *highlightedFont = [UIFont fontWithName:@"SFUIText-Semibold" size:15];
    UIFont *lightFont = [UIFont fontWithName:@"SFUIText-Light" size:15];
    
    NSDictionary *regAtttributtes = @{NSFontAttributeName : regularFont,
                                   NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *highlightedAtttributtes = @{NSFontAttributeName : highlightedFont,
                                      NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *lightAtttributtes = @{NSFontAttributeName : lightFont,
                                              NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        NSString *subtitle1 = OTLocalizedString(@"pfp_defineZoneSubtitle1");
        NSString *subtitle2 = OTLocalizedString(@"pfp_defineZoneSubtitle2");
        
        NSMutableAttributedString *descAttString = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:regAtttributtes];
        [descAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle2 attributes:highlightedAtttributtes]];
        
        return descAttString;
    }
    
    NSString *subtitle1 = OTLocalizedString(@"defineZoneSubtitle1");
    NSString *subtitle2 = OTLocalizedString(@"defineZoneSubtitle2");
    NSString *subtitle3 = OTLocalizedString(@"defineZoneSubtitle3");
    NSString *subtitle4 = OTLocalizedString(@"defineZoneSubtitle4");
    NSMutableAttributedString *descAttString = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:regAtttributtes];
    [descAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle2 attributes:highlightedAtttributtes]];
    [descAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle3 attributes:regAtttributtes]];
    [descAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle4 attributes:lightAtttributtes]];
    
    return descAttString;
}

+ (NSString *)notificationsNeedDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_notificationNeedDescription");
    }
    
    return OTLocalizedString(@"notificationNeedDescription");
}

+ (NSString *)noFeedsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_more_feeds");
    }
    
    return OTLocalizedString(@"no_more_feeds");
}

+ (NSString *)noMapFeedsDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_more_map_feeds");
    }
    
    return OTLocalizedString(@"no_more_map_feeds");
}

+ (NSString *)extendSearchParameterDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_feeds_increase_radius");
    }
    
    return OTLocalizedString(@"no_feeds_increase_radius");
}

+ (NSString *)extendMapSearchParameterDescription
{
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_no_map_feeds_increase_radius");
    }
    
    return OTLocalizedString(@"no_map_feeds_increase_radius");
}

+ (NSString*)userPhoneNumberNotFoundMessage {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_lost_code_phone_does_not_exist");
    }
    
    return OTLocalizedString(@"lost_code_phone_does_not_exist");
}

+ (NSString*)userActionsTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_entourages");
    }
    
    return OTLocalizedString(@"entourages");
}

+ (NSString*)editUserDescriptionTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_edit_user_description");
    }
    
    return OTLocalizedString(@"edit_user_description");
}

+ (NSString*)numberOfUserActionsTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_numberOfUserActions");
    }
    
    return OTLocalizedString(@"numberOfUserActions");
}

+ (NSString*)userPrivateCirclesSectionTitle:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([user isCoordinator]) {
            return OTLocalizedString(@"pfp_visitorPrivateCirclesSectionTitle");
        } else {
            return OTLocalizedString(@"pfp_visitedPrivateCirclesSectionTitle");
        }
    }
    
    return nil;
}

+ (NSString*)userNeighborhoodsSectionTitle:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_neighborhoodsSectionTitle");
    }
    
    return OTLocalizedString(@"neighborhoodsSectionTitle");
}

+ (NSString*)numberOfUserActionsValueTitle:(OTUser *)user {
    /*
     https://jira.mytkw.com/browse/EMA-1949
     During the pilot phase with PFP (first 3 months) we will not try to import the number of Sorties (outings) all the users have been to since they started being members of PFP (that data is more or less available on the current website but we won't import it now). So everyone's score in "Nombre de sorties" will be 0.
    Then when we add the feature to create and join "Sorties" in the Feed this will start to be incremented. So for now in the 5.1 version you can just hard-code 0, to be replaced by the API endpoint later.
     */
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return @"0";
    }
    
    if ([user isPro]) {
        return [NSString stringWithFormat:@"%d", user.tourCount.intValue];
    }
    else {
        return [NSString stringWithFormat:@"%d", user.entourageCount.intValue];
    }
}

+ (NSString *)reportActionSubject {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_mail_signal_subject");
    }
    
    return OTLocalizedString(@"mail_signal_subject");
}

+ (NSString *)eventTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_event");
    }
    
    return OTLocalizedString(@"event");
}

+ (NSString *)eventsFilterTitle {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_filter_events_title");
    }
    
    return OTLocalizedString(@"filter_events_title");
}

+ (NSString *)promoteEventActionSubject:(NSString*)eventName {
    NSString *eventType = [OTAppAppearance eventTitle];
    NSString *eventDetails = [NSString stringWithFormat:@"%@ %@", eventType, eventName];
    NSString *subject = [NSString stringWithFormat:OTLocalizedString(@"promote_event_subject_format"), eventDetails];
    return subject;
}

+ (NSString *)promoteEventActionEmailBody:(NSString*)eventName {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        NSString *body = [NSString stringWithFormat:OTLocalizedString(@"pfp_promote_event_mail_body_format"), eventName];
        return body;
    }
    
    NSString *body = [NSString stringWithFormat:OTLocalizedString(@"promote_event_mail_body_format"), eventName];
    return body;
}



+ (NSString *)reportActionToRecepient {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return CONTACT_PFP_TO;
    }
    
    return SIGNAL_ENTOURAGE_TO;
}

+ (UIColor*)leftTagColor:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return (user.leftTag) ? [UIColor pfpPurpleColor] : [UIColor clearColor];
    }
    
    return [UIColor clearColor];
}

+ (UIColor*)rightTagColor:(OTUser*)user {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if (user.rightTag) {
            return ([user.roles containsObject:kCoordinatorUserTag]) ?
            [UIColor pfpGreenColor] : [UIColor pfpPurpleColor];
        }
    }
    
    return [UIColor clearColor];
}

+ (NSAttributedString*)formattedDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size {
    
    // Pfp items
    UIColor *typeColor = [ApplicationTheme shared].backgroundThemeColor;
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([item isNeighborhood] ||
            [item isPrivateCircle]) {
            return [[NSAttributedString alloc] initWithString:@"Voisinage"];
            
        } else if ([item isConversation]) {
            return [[NSAttributedString alloc] initWithString:@""];
            
        } else if ([item isOuting]) {
            return [self formattedEventDateDescriptionForMessageItem:item size:size];
        }
    }
    
    // Entourage Outing items
    if ([item.category isEqualToString:@"event"] || [item isOuting]) {
        return [self formattedEventDateDescriptionForMessageItem:item size:size];;
    }
    
    // The rest of items
    if ([item.entourage_type isEqualToString:@"contribution"]) {
        typeColor = [UIColor brightBlue];
    } else if ([item.entourage_type isEqualToString:@"ask_for_help"]) {
        typeColor = [UIColor appOrangeColor];
    }
    
    NSString *itemType = OTLocalizedString(item.entourage_type);
    NSDictionary *atttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size],
                                   NSForegroundColorAttributeName:typeColor};
    
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString: itemType attributes:atttributtes];
    NSAttributedString *byAttrString = [[NSAttributedString alloc] initWithString: OTLocalizedString(@"by") attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size]}];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:item.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_BOLD_DESCRIPTION size:size]}];
    
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:byAttrString];
    [typeByNameAttrString appendAttributedString:nameAttrString];
    
    return typeByNameAttrString;
}

+ (NSAttributedString*)formattedEventDateDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size {
    
    UIColor *typeColor = [UIColor appGreyishColor];
    NSString *eventName = OTLocalizedString(@"event").capitalizedString;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        typeColor = [UIColor pfpOutingCircleColor];
        eventName = OTLocalizedString(@"pfp_event").capitalizedString;
    }
    
    NSDictionary *atttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size],
                                   NSForegroundColorAttributeName:typeColor};
    NSMutableAttributedString *eventAttrDescString = [[NSMutableAttributedString alloc] initWithString:eventName attributes:atttributtes];
    
    NSString *dateString = [NSString stringWithFormat:@" le %@", [item.startsAt asStringWithFormat:@"EEEE dd/MM"]];
    NSDictionary *dateAtttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size], NSForegroundColorAttributeName:[UIColor appGreyishColor]};
    NSMutableAttributedString *dateAttrString = [[NSMutableAttributedString alloc] initWithString:dateString attributes:dateAtttributtes];
    
    if (item.startsAt) {
        [eventAttrDescString appendAttributedString:dateAttrString];
    }
    
    return eventAttrDescString;
}

+ (NSString*)iconNameForEntourageItem:(OTEntourage*)item {
    NSString *icon = [NSString stringWithFormat:@"%@_%@", item.entourage_type, item.category];
    
    if ([item isPrivateCircle]) {
        icon = @"private-circle";
    } else if ([item isNeighborhood]) {
        icon = @"neighborhood";
    } else if ([item isOuting]) {
        icon = @"outing";
    }
    
    return icon;
}

+ (UIColor*)announcementFeedContainerColor {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIColor pfpNeighborhoodColor];
    }
    
    return [UIColor colorWithHexString:@"ffc57f"];
}

+ (UIColor*)iconColorForFeedItem:(OTFeedItem *)feedItem {
    UIColor *color = [ApplicationTheme shared].backgroundThemeColor;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        if ([feedItem isNeighborhood]) {
            color = [UIColor pfpNeighborhoodColor];
        } else if ([feedItem isPrivateCircle]) {
            color = [UIColor pfpPrivateCircleColor];
        } else if ([feedItem isOuting]) {
            color = [UIColor pfpOutingCircleColor];
        }
        return color;
    }
    
    BOOL isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    color = [UIColor appGreyishColor];
    if (isActive) {
        OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
        if (feedItem.author.uID.intValue == currentUser.sid.intValue) {
            color = [UIColor appOrangeColor];
        } else {
            if ([JOIN_ACCEPTED isEqualToString:feedItem.joinStatus] ||
                [JOIN_PENDING isEqualToString:feedItem.joinStatus]) {
                color = [UIColor appOrangeColor];
            } else if ([JOIN_REJECTED isEqualToString:feedItem.joinStatus]) {
                color = [UIColor appTomatoColor];
            } else {
                color = [UIColor appGreyishColor];
            }
        }
    }
    
    return color;
}

+ (UIView*)navigationTitleViewForFeedItem:(OTFeedItem*)feedItem {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    id iconName = [[[OTFeedItemFactory createFor:feedItem] getUI] categoryIconSource];
    
    id titleString = [[[OTFeedItemFactory createFor:feedItem] getUI] navigationTitle];
    
    UIButton *iconView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    iconView.backgroundColor = UIColor.whiteColor;
    iconView.layer.cornerRadius = 18;
    iconView.userInteractionEnabled = NO;
    iconView.clipsToBounds = YES;
    
    UIImage *placeholder = [UIImage imageNamed:@"user"];
    
    if ([feedItem isConversation]) {
        NSString *urlPath = feedItem.author.avatarUrl;
        if (urlPath != nil && [urlPath class] != [NSNull class] && urlPath.length > 0) {
            NSURL *url = [NSURL URLWithString:urlPath];
            [iconView setImageForState:UIControlStateNormal withURL:url placeholderImage:placeholder];
        } else {
            [iconView setImage:placeholder forState:UIControlStateNormal];
        }
    } else {
        [iconView setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    }
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 130, 40)];
    title.text = titleString;
    title.textColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    [titleView addSubview:iconView];
    [titleView addSubview:title];
    
    return titleView;
}
    
+ (UILabel*)navigationTitleLabelForFeedItem:(OTFeedItem*)feedItem {
    id titleString = [[[OTFeedItemFactory createFor:feedItem] getUI] navigationTitle];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
    titleLabel.text = titleString;
    titleLabel.textColor = [ApplicationTheme shared].secondaryNavigationBarTintColor;
    titleLabel.numberOfLines = 2;
    
    return titleLabel;
}
    
+ (UIBarButtonItem *)leftNavigationBarButtonItemForFeedItem:(OTFeedItem*)feedItem
{
    CGFloat iconSize = 36.0f;
    
    if ([feedItem isConversation]) {
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
        iconView.backgroundColor = UIColor.whiteColor;
        iconView.layer.cornerRadius = iconSize / 2;
        iconView.userInteractionEnabled = NO;
        iconView.clipsToBounds = YES;
        iconView.layer.masksToBounds = YES;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        
        UIImage *placeholder = [[UIImage imageNamed:@"user"] resizeTo:iconView.frame.size];
        NSString *urlPath = feedItem.author.avatarUrl;
        if (urlPath != nil && [urlPath class] != [NSNull class] && urlPath.length > 0) {
            NSURL *url = [NSURL URLWithString:urlPath];
            [iconView sd_setImageWithURL:url placeholderImage:placeholder];
        } else {
            [iconView setImage:placeholder];
        }
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
        return barButtonItem;
    }
    
    id iconName = [[[OTFeedItemFactory createFor:feedItem] getUI] categoryIconSource];
    UIButton *iconView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
    iconView.backgroundColor = UIColor.whiteColor;
    iconView.layer.cornerRadius = iconSize / 2;
    iconView.userInteractionEnabled = NO;
    iconView.clipsToBounds = YES;
    [iconView setImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
    return barButtonItem;
}

+ (NSString *)joinEntourageLabelTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_join_group_title");
    }
    
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        return OTLocalizedString(@"join_entourage_lbl");
    }
    else {
        return OTLocalizedString(@"join_tour_lbl");
    }
}

+ (NSString *)joinEntourageButtonTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return OTLocalizedString(@"pfp_join_group_button");
    }
    
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        return OTLocalizedString(@"join_entourage_btn");
    }
    else {
        return OTLocalizedString(@"join_tour_btn");
    }
}

+ (UIColor*)colorForNoDataPlacholderImage {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [[UIColor pfpBlueColor] colorWithAlphaComponent:0.1];
    }
    
    return [UIColor colorWithHexString:@"efeff4"];
}

+ (UIColor*)colorForNoDataPlacholderText {
    if ([OTAppConfiguration applicationType] == ApplicationTypeVoisinAge) {
        return [UIColor colorWithHexString:@"025e7f"];
    }
    
    return [UIColor colorWithHexString:@"4a4a4a"];
}

@end
