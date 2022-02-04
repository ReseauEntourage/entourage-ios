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
#import "OTFeedItemMessage.h"
#import "OTHTTPRequestManager.h"
#import "entourage-Swift.h"


@implementation OTAppAppearance

+ (UIImage*)applicationLogo
{
    return [UIImage imageNamed:@"entourageLogo"];
}

+ (NSString*)aboutUrlString
{
    return ABOUT_CGU_URL;
}

+ (NSString*)policyUrlString
{
    return ABOUT_POLICY_URL;
}

+ (NSString *)welcomeTopDescription
{
    return OTLocalizedString(@"welcomeTopText");
}

+ (UIImage*)welcomeLogo
{
    return [UIImage imageNamed:@"logoWhiteEntourage"];
}

+ (UIImage*)welcomeImage
{
    return [UIImage imageNamed:@"welcome"];
}

+ (NSString *)userProfileNameDescription
{
    return OTLocalizedString(@"userNameDescriptionText");
}

+ (NSString *)userProfileEmailDescription
{
    return OTLocalizedString(@"userEmailDescriptionText");
}

+ (NSString *)notificationsRightsDescription
{
    return OTLocalizedString(@"userNotificationsDescriptionText");
}

+ (NSString *)defineActionZoneTitleForUser:(OTUser*)user {
    
    if (user && [user hasActionZoneDefined]) {
        return OTLocalizedString(@"modifyActionZoneTitle");
    }
    
    return OTLocalizedString(@"defineActionZoneTitle");
}

+ (NSString *)geolocalisationRightsDescription
{
    return OTLocalizedString(@"geolocalisationDescriptionText");
}

+ (NSString *)defineActionZoneSampleAddress {
    return OTLocalizedString(@"defineActionZoneSampleAddress");
}

+ (NSAttributedString *)defineActionZoneFormattedDescription {
    UIFont *regularFont = [UIFont fontWithName:@"SFUIText-Regular" size:15];
    UIFont *lightSmallFont = [UIFont fontWithName:@"SFUIText-Light" size:12];
    
    NSDictionary *regAtttributtes = @{NSFontAttributeName : regularFont,
                                   NSForegroundColorAttributeName:[UIColor whiteColor]};
    NSDictionary *lightAtttributtes = @{NSFontAttributeName : lightSmallFont,
                                              NSForegroundColorAttributeName:[UIColor whiteColor]};
    
    NSString *subtitle1 = OTLocalizedString(@"defineZoneSubtitle1");
    NSString *subtitle2 = OTLocalizedString(@"defineZoneSubtitle2");
    NSMutableAttributedString *descAttString = [[NSMutableAttributedString alloc] initWithString:subtitle1 attributes:regAtttributtes];
    [descAttString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:subtitle2 attributes:lightAtttributtes]];
    
    return descAttString;
}

+ (NSString *)notificationsNeedDescription
{
    return OTLocalizedString(@"notificationNeedDescription");
}

+ (NSString *)noMoreFeedsDescription
{
    return OTLocalizedString(@"no_more_feeds");
}

+ (NSString *)noMapFeedsDescription
{
    return OTLocalizedString(@"no_more_map_feeds");
}

+ (NSString *)extendSearchParameterDescription
{
    return OTLocalizedString(@"no_feeds_increase_radius");
}

+ (NSString *)extendMapSearchParameterDescription
{
    return OTLocalizedString(@"no_map_feeds_increase_radius");
}

+ (NSString*)userPhoneNumberNotFoundMessage {
    return OTLocalizedString(@"lost_code_phone_does_not_exist");
}

+ (NSString*)userActionsTitle {
    return OTLocalizedString(@"entourages");
}

+ (NSString*)editUserDescriptionTitle {
    return OTLocalizedString(@"edit_user_description");
}

+ (NSString*)numberOfUserActionsTitle {
    return OTLocalizedString(@"numberOfUserActions");
}

+ (NSString*)userPrivateCirclesSectionTitle:(OTUser*)user {
    return nil;
}

+ (NSString*)userNeighborhoodsSectionTitle:(OTUser*)user {
    return OTLocalizedString(@"neighborhoodsSectionTitle");
}

+ (NSString*)numberOfUserActionsValueTitle:(OTUser *)user {
    
    if ([user isPro]) {
        return [NSString stringWithFormat:@"%d", user.tourCount.intValue];
    }
    else {
        return [NSString stringWithFormat:@"%d", user.entourageCount.intValue];
    }
}

+ (NSString *)reportActionSubject {
    return OTLocalizedString(@"mail_signal_subject");
}

+ (NSString *)eventTitle {
    return OTLocalizedString(@"event");
}

+ (NSString *)eventsFilterTitle {
    return OTLocalizedString(@"filter_events_title");
}

+ (NSString *)applicationTitle {
    return @"Entourage";
}

+ (NSString *)promoteEventActionSubject:(NSString*)eventName {
    NSString *eventType = [OTAppAppearance eventTitle];
    NSString *eventDetails = [NSString stringWithFormat:@"%@ %@", eventType, eventName];
    NSString *subject = [NSString stringWithFormat:OTLocalizedString(@"promote_event_subject_format"), eventDetails];
    return subject;
}

+ (NSString *)promoteEventActionEmailBody:(NSString*)eventName {
    NSString *body = [NSString stringWithFormat:OTLocalizedString(@"promote_event_mail_body_format"), eventName];
    return body;
}



+ (NSString *)reportActionToRecepient {
    return SIGNAL_ENTOURAGE_TO;
}

+ (UIColor*)tagColor:(OTUser*)user {
    if (user.roleTag) {
        return [UIColor appOrangeColor];
    }
    
    return [UIColor clearColor];
}

+ (NSString *)descriptionForMessageItem:(OTEntourage *)item hasToShowDate:(BOOL)isShowDate {

    if ([item isNeighborhood] ||
        [item isPrivateCircle]) {
        return @"Voisinage";
    }
    if ([item isConversation]) {
        return @"";
    }
    if ([item isOuting]) {
        return [self eventDateDescriptionForMessageItem:item hasToShowDate:isShowDate];
    }
    
    return [NSString stringWithFormat:OTLocalizedString(@"formater_by"), OTLocalizedString(item.entourage_type)];
}

+ (NSAttributedString*)formattedDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size  hasToShowDate:(BOOL)isShowDate {
    NSAttributedString *formattedDescription = [[NSAttributedString alloc] initWithString: [self descriptionForMessageItem:item hasToShowDate:isShowDate] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:size]}];
    
    if ([item isNeighborhood] ||
        [item isPrivateCircle] ||
        [item isConversation] ||
        [item isOuting]) {
        return formattedDescription;
    }

    NSAttributedString *formattedUserName = [[NSAttributedString alloc] initWithString:item.author.displayName attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:size]}];
    
    NSMutableAttributedString *formattedDescriptionWithUser = formattedDescription.mutableCopy;
    [formattedDescriptionWithUser appendAttributedString:formattedUserName];
    
    return formattedDescriptionWithUser;
}

+ (NSAttributedString*)formattedAuthorDescriptionForMessageItem:(OTEntourage*)item {
    
    UIColor *textColor = [UIColor colorWithHexString:@"4a4a4a"];
    NSString *organizerText = @"\nOrganisé";
    NSString *fontName = @"SFUIText-Medium";
    CGFloat fontSize = DEFAULT_DESCRIPTION_SIZE;
    
    NSDictionary *atttributtes = @{NSFontAttributeName :
                                       [UIFont fontWithName:fontName size:fontSize],
                                   NSForegroundColorAttributeName:textColor};
    NSMutableAttributedString *organizerAttributedText = [[NSMutableAttributedString alloc] initWithString:organizerText attributes:atttributtes];
    
    NSAttributedString *byAttrString = [[NSAttributedString alloc] initWithString: OTLocalizedString(@"by") attributes:@{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]}];
    
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:item.author.displayName attributes:@{NSFontAttributeName : [UIFont fontWithName:fontName size:fontSize]}];
    
    NSMutableAttributedString *orgByNameAttrString = organizerAttributedText.mutableCopy;
    [orgByNameAttrString appendAttributedString:byAttrString];
    [orgByNameAttrString appendAttributedString:nameAttrString];
    
    return orgByNameAttrString;
}

+ (NSString*)eventDateDescriptionForMessageItem:(OTEntourage*)item  hasToShowDate:(BOOL)isShowDate {
    
    NSString *eventName = OTLocalizedString(@"event").capitalizedString;
    
    if (isShowDate && item.startsAt) {
        NSString *_message = @"";
        if ([[NSCalendar currentCalendar] isDate:item.startsAt inSameDayAsDate:item.endsAt]) {
           _message = [NSString stringWithFormat:@"%@ %@", eventName, [NSString stringWithFormat:OTLocalizedString(@"le_"),[item.startsAt asStringWithFormat:@"EEEE dd/MM"]]];
        }
        else {
            NSString *_dateStr = [NSString stringWithFormat:OTLocalizedString(@"du_au"), [item.startsAt asStringWithFormat:@"dd/MM"],[item.endsAt asStringWithFormat:@"dd/MM"]];
            _message = [NSString stringWithFormat:@"%@ %@", eventName,_dateStr ];
        }
        
        return _message;
    } else {
        return eventName;
    }
}

+ (NSAttributedString*)formattedEventDateDescriptionForMessageItem:(OTEntourage*)item
                                                              size:(CGFloat)size {
    
    UIColor *textColor = [UIColor colorWithHexString:@"4a4a4a"];
    UIColor *typeColor = textColor;
    NSString *eventName = OTLocalizedString(@"event").capitalizedString;
    
    NSDictionary *atttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size],
                                   NSForegroundColorAttributeName:typeColor};
    NSMutableAttributedString *eventAttrDescString = [[NSMutableAttributedString alloc] initWithString:eventName attributes:atttributtes];
    
    NSString *dateString = [NSString stringWithFormat:@" le %@", [item.startsAt asStringWithFormat:@"EEEE dd/MM"]];
    NSDictionary *dateAtttributtes = @{NSFontAttributeName : [UIFont fontWithName:FONT_NORMAL_DESCRIPTION size:size], NSForegroundColorAttributeName:textColor};
    NSMutableAttributedString *dateAttrString = [[NSMutableAttributedString alloc] initWithString:dateString attributes:dateAtttributtes];
    
    if (item.startsAt) {
        [eventAttrDescString appendAttributedString:dateAttrString];
    }
    
    return eventAttrDescString;
}

+ (NSString*)iconNameForEntourageItem:(OTEntourage*)item isAnnotation:(BOOL) isAnnotation {
    NSString *icon = [NSString stringWithFormat:@"%@_%@", item.entourage_type, item.category];
    
    if ([item isOuting]) {
        if (isAnnotation) {
            icon = @"ask_for_help_event_poi";
        }
        else {
            icon = @"ask_for_help_event";
        }
    }
    
    return icon;
}

+ (UIColor*)announcementFeedContainerColor {
    return [UIColor whiteColor];
}

+ (UIColor*)iconColorForFeedItem:(OTFeedItem *)feedItem {
    UIColor *color = [ApplicationTheme shared].backgroundThemeColor;
    
    BOOL isActive = [[[OTFeedItemFactory createFor:feedItem] getStateInfo] isActive];
    color = [UIColor appOrangeColor];
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
                color = [UIColor appOrangeColor];
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
    titleLabel.numberOfLines = 1;
    
    if ([feedItem isConversation]) {
        titleLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile)];
        [titleLabel addGestureRecognizer:tap];
    }
    
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
    UIImage *iconImage = [UIImage imageNamed:iconName];
    [iconView setImage:iconImage forState:UIControlStateNormal];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeEntourage) {
        if ([feedItem isOuting]) {
            iconView.tintColor = [ApplicationTheme shared].backgroundThemeColor;
            [iconView setImage:[[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
        }
    }

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];

    return barButtonItem;
}

+ (void)leftNavigationBarButtonItemForFeedItem:(OTFeedItem*)feedItem withBarItem:(void (^)(UIBarButtonItem*))completion
{
    CGFloat iconSize = 36.0f;
    
    if ([feedItem isConversation]) {
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
        iconView.backgroundColor = UIColor.whiteColor;
        iconView.layer.cornerRadius = iconSize / 2;
        iconView.userInteractionEnabled = YES;
        iconView.clipsToBounds = YES;
        iconView.layer.masksToBounds = YES;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showProfile)];
        [iconView addGestureRecognizer:tap];
        
        UIImage *placeholder = [[UIImage imageNamed:@"user"] resizeTo:iconView.frame.size];
        NSString *urlPath = feedItem.author.avatarUrl;
        if (urlPath != nil && [urlPath class] != [NSNull class] && urlPath.length > 0) {
            NSURL *url = [NSURL URLWithString:urlPath];
            
            [iconView sd_setImageWithURL:url completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                if (error != nil) {
                    [iconView setImage:placeholder];
                }
                else {
                    [iconView setImage:[image resizeTo:iconView.frame.size]];
                }
                
                UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
                completion(barButtonItem);
            }];
        } else {
            [iconView setImage:placeholder];
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
            completion(barButtonItem);
        }
        return;
    }
    
    id iconName = [[[OTFeedItemFactory createFor:feedItem] getUI] categoryIconSource];
    UIButton *iconView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, iconSize, iconSize)];
    iconView.backgroundColor = UIColor.whiteColor;
    iconView.layer.cornerRadius = iconSize / 2;
    iconView.userInteractionEnabled = NO;
    iconView.clipsToBounds = YES;
    UIImage *iconImage = [UIImage imageNamed:iconName];
    [iconView setImage:iconImage forState:UIControlStateNormal];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([OTAppConfiguration applicationType] == ApplicationTypeEntourage) {
        if ([feedItem isOuting]) {
            iconView.tintColor = [ApplicationTheme shared].backgroundThemeColor;
            [iconView setImage:[[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                      forState:UIControlStateNormal];
        }
    }
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:iconView];
    
    completion(barButtonItem);
}

+(void) showProfile {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showUserProfile" object:nil];
}

+ (NSString *)joinEntourageLabelTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"join_event_lbl");
        }
        return OTLocalizedString(@"join_entourage_lbl");
    }
    else {
        return OTLocalizedString(@"join_tour_lbl");
    }
}

+ (NSString *)joinEntourageButtonTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([feedItem isKindOfClass:[OTEntourage class]]) {
        if ([feedItem isOuting]) {
            return OTLocalizedString(@"join_entourage_btn");
        }
        return OTLocalizedString(@"join_entourage2_btn");
    }
    else {
        return OTLocalizedString(@"join_tour_btn");
    }
}

+ (UIColor*)colorForNoDataPlacholderImage {
    return [UIColor colorWithHexString:@"efeff4"];
}

+ (UIColor*)colorForNoDataPlacholderText {
    return [UIColor colorWithHexString:@"4a4a4a"];
}

+ (NSString*)sampleTitleForNewEvent {
    return OTLocalizedString(@"event_title_example");
}

+ (NSString*)sampleDescriptionForNewEvent {
    return OTLocalizedString(@"event_desc_example");
}

+ (UIImage*)JoinFeedItemConfirmationLogo {
    return [UIImage imageNamed:@"logoWhiteEntourage"];
}

+ (NSAttributedString*)formattedEventCreatedMessageInfo:(OTFeedItemMessage*)messageItem {
    UIFont *regularFont = [UIFont fontWithName:@"SFUIText-Regular" size:15.0];
    UIFont *boldFont = [UIFont fontWithName:@"SFUIText-Bold" size:15.0];
    UIFont *semiboldFont = [UIFont fontWithName:@"SFUIText-Semibold" size:15.0];
    UIColor *regularColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    NSString *authorAndAction = [NSString stringWithFormat:@"%@ a créé une", messageItem.userName];
    NSString *event = [OTAppAppearance eventTitle];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE dd/MM à HH:mm"];
    NSString *date = [formatter stringFromDate:messageItem.startsAt];
    
    NSString *fullText = [NSString stringWithFormat:@"%@ %@:\n%@\n\n%@", authorAndAction, event, messageItem.title, date];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:fullText attributes:@{NSFontAttributeName: regularFont,                                                                               NSForegroundColorAttributeName: regularColor}];
    
    NSRange eventRange = NSMakeRange(authorAndAction.length + 1, event.length);
    NSRange titleRange = NSMakeRange(authorAndAction.length + event.length + 3, messageItem.title.length);
    [attributedString addAttributes:@{NSFontAttributeName: semiboldFont,                                                                               NSForegroundColorAttributeName: [UIColor appOutingCircleColor]} range:eventRange];
    [attributedString addAttributes:@{NSFontAttributeName: boldFont,                                                                               NSForegroundColorAttributeName: regularColor} range:titleRange];
    
    return attributedString;
}

+ (NSString*)requestToJoinTitleForFeedItem:(OTFeedItem*)feedItem {
    if ([feedItem isKindOfClass:[OTTour class]]) {
        return OTLocalizedString(@"want_to_join_tour");
    }
    
    return OTLocalizedString(@"want_to_join_entourage");
}

+ (NSString*)quitFeedItemConformationTitle:(OTFeedItem *)feedItem {
    return OTLocalizedString(@"quitted_item");
}

+ (NSString*)closeFeedItemConformationTitle:(OTFeedItem *)feedItem {
    return OTLocalizedString(@"closed_item");
}

+ (NSString*)joinFeedItemConformationDescription:(OTFeedItem *)feedItem {
    if ([feedItem isOuting]) {
        return OTLocalizedString(@"join_event_greeting_lbl");
    }
    else if ([feedItem isKindOfClass:[OTEntourage class]]) {
        return OTLocalizedString(@"join_entourage_greeting_lbl");
    }
    else {
        return OTLocalizedString(@"join_tour_greeting_lbl");
    }
}



+ (NSString*)addActionTitleHintMessage:(BOOL)isEvent {
    if (isEvent) {
        return OTLocalizedString(@"add_event_title_hint");
    }
    return OTLocalizedString(@"add_title_hint");
}

+ (NSString*)addActionDescriptionHintMessage:(BOOL)isEvent {
    if (isEvent) {
        return OTLocalizedString(@"add_event_description_hint");
    }
    
    return OTLocalizedString(@"add_description_hint");
}

+ (NSString*)includePastEventsFilterTitle {    
    return OTLocalizedString([OTAppAppearance includePastEventsFilterTitleKey]);
}

+ (NSString*)includePastEventsFilterTitleKey {
    return @"filter_events_include_past_events_title";
}

+ (NSString*)inviteSubtitleText:(OTFeedItem*)feedItem {
    if ([feedItem isOuting]) {
        return OTLocalizedString(@"invite_event_subtitle");
    }
    
    return OTLocalizedString(@"invite_action_subtitle");
}

+ (NSString*)lostCodeSimpleDescription {
    return OTLocalizedString(@"lostCodeMessage1");
}

+ (NSString*)lostCodeFullDescription {
    return OTLocalizedString(@"lostCodeMessage2");
}

+ (NSString*)noMessagesDescription {
    return OTLocalizedString(@"no_messages_description");
}

+ (NSAttributedString*)closedFeedChatItemMessageFormattedText:(OTFeedItemMessage*)message {
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:message.userName attributes:@{NSForegroundColorAttributeName: [ApplicationTheme shared].backgroundThemeColor}];
    NSAttributedString *infoAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", message.text] attributes:@{NSForegroundColorAttributeName: [UIColor appGreyishColor]}];
    NSMutableAttributedString *nameInfoAttrString = nameAttrString.mutableCopy;
    [nameInfoAttrString appendAttributedString:infoAttrString];
    
    return nameInfoAttrString;
}

+ (NSString*)entourageConfidentialityDescription:(OTEntourage*)entourage
                                        isPublic:(BOOL)isPublic {
    if (isPublic) {
        return OTLocalizedString(@"event_confidentiality_description_public");
        
    }
    return OTLocalizedString(@"event_confidentiality_description_private");
}

@end
