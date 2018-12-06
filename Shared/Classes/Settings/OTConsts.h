//
//  OTConsts.h
//  entourage
//
//  Created by Hugo Schouman on 11/02/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "PFPConsts.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#define DEVICE_TOKEN_KEY "device_token"

#define PARIS_LAT 48.856578
#define PARIS_LON  2.351828
#define MAPVIEW_REGION_SPAN_X_METERS 500
#define MAPVIEW_REGION_SPAN_Y_METERS 500

#define MAPVIEW_CLICK_REGION_SPAN_X_METERS 750
#define MAPVIEW_CLICK_REGION_SPAN_Y_METERS 750

#define DATA_REFRESH_RATE 60.0 //seconds
#define LOCATION_MIN_DISTANCE 5.f

#define ENTOURAGE_RADIUS 250
#define ENTOURAGE_RADIUS_FACTOR 1.0f

#define FEED_ITEMS_MAX_RADIUS 20
#define RADIUS_ARRAY @[@10, @20, @40]


#define TEXTVIEW_PADDING 10.0f
#define TEXTVIEW_PADDING_TOP 12.0f
#define TEXTVIEW_PADDING_BOTTOM 23.0f

#define MAP_TOUR_LINE_WIDTH 4.0f
#define CLOSED_ITEM_BACKGROUND_COLOR  [UIColor colorWithRed: 0xF8 / 255.0f green: 0xF8 / 255.0f blue: 0xF8 / 255.0f alpha: 1.0f]

#define kNotificationPushStatusChanged @"NotificationAPNSStatusChanged"
#define kNotificationPushStatusChangedStatusKey @"NotificationAPNSStatusChangedStatusKey"
#define kNotificationLocalTourConfirmation "NotificationShowTourConfirmation"

#define kNotificationShowCurrentLocation "NotificationCurrentLocation"
#define kNotificationShowFeedsMapCurrentLocation "NotificationFeedsMapCurrentLocation"
#define kNotificationShowEventDetails @"NotificationShowEventDetails"

#define kNotificationProfilePictureUpdated "NotificationProfilePictureUpdated"
#define kNotificationAboutMeUpdated "NotificationAboutMeUpdated"
#define kNotificationSupportedPartnerUpdated "NotificationSupportedPartnerUpdated"
#define kNotificationJoinRequestSent @"NotificationJoinRequestSent"
#define kNotificationEntourageCreated @"NotificationEntourageCreated"
#define kNotificationEntourageChanged @"NotificationEntourageChanged"
#define kNotificationEntourageChangedEntourageKey @"NotificationEntourageChangedEntourageKey"
#define kNotificationUpdateBadgeCountKey @"kUpdateBadgeCountKey"
#define kNotificationUpdateBadgeFeedIdKey @"kUpdateBadgeCountFeedIdKey"
#define kNotificationAssociationUpdated @"NotificationAssociationUpdated"

#define kNotificationPushReceived "NotificationPushReceived"
#define kNotificationReloadData "NotificationReloadData"
#define kNotificationSendCloseMail "NotificationSendCloseMail"
#define kNotificationSendReasonKey "NotificationReasonKey"
#define kNotificationFeedItemKey "NotificationFeedItemKey"
#define kNotificationUpdateBadge @"NotificationUpdateBadge"
#define kSolidarityGuideNotification @"NotificationSolidarityGuide"

#define ABOUT_RATE_US_URL @"itms://itunes.apple.com/app/entourage-reseau-civique/id1072244410"
#define ABOUT_FACEBOOK_URL @"https://www.facebook.com/EntourageReseauCivique"
#define ABOUT_TWITTER_URL @"https://twitter.com/r_entourage"
#define ABOUT_CGU_URL @"http://www.entourage.social/cgu/index.html"
#define ABOUT_CGU_REDIRECT_FORMAT @"%@links/terms/redirect?token=%@"
#define ABOUT_WEBSITE_URL @"http://www.entourage.social"
#define ABOUT_POLICY_URL @"https://www.entourage.social/politique-de-confidentialite"
#define ABOUT_EMAIL_ADDRESS @"contact@entourage.social"
#define ABOUT_POLITIQUE_DE_CONF_FORMAT @"%@links/privacy-policy/redirect?token=%@"

#define SNAPSHOT_START "snapshot_start_%d.png"
#define SNAPSHOT_STOP "snapshot_end_%d.png"

#define INVALID_PHONE_FORMAT @"INVALID_PHONE_FORMAT"
#define UNAUTHORIZED @"UNAUTHORIZED"
#define PHONE_ALREADY_EXIST @"PHONE_ALREADY_EXIST"

#define PUBLIC_ENTOURAGE_CREATION_CHART @"https://blog.entourage.social/charte-ethique-grand-public/"
#define PRO_ENTOURAGE_CREATION_CHART @"https://blog.entourage.social/charte-ethique-maraudeur"

//Menu
#define SCB_LINK_ID @"pedagogic-content"
#define GOAL_LINK_ID @"action-examples"
#define DONATE_LINK_ID @"donation"
#define ATD_LINK_ID @"atd-partnership"
#define FAQ_LINK_ID @"faq"
#define SUGGESTION_LINK_ID @"feedback"
#define JOIN_LINK_ID @"volunteering"

// Chart Ethique
#define CHARTE_LINK_ID @"ethics-charter"
#define CHARTE_LINK_FORMAT_PUBLIC @"https://entourage-asso.typeform.com/to/whN9kq?user_id=%@"
#define CHARTE_LINK_FORMAT_PRO @"https://entourage-asso.typeform.com/to/LI7viw?user_id=%@"
#define CHARTE_LINK_FORMAT_PFP @"https://entourage-asso.typeform.com/to/uBxsHI?user_id="

#define TUTORIAL_BLOG_LINK @"https://blog.entourage.social/franchir-le-pas"
#define MENU_BLOG_APPLICATION_USAGE_URL @"http://blog.entourage.social/comment-utiliser-l-application-entourage/"
#define PRO_MENU_CHART_URL @"https://blog.entourage.social/charte-ethique/"
#define PUBLIC_MENU_CHART_URL @"http://www.entourage.social/chartes/grand-public.html"
#define VIEW_MORE_EVENTS_URL @"https://www.facebook.com/EntourageReseauCivique/events"

#define NO_GIUDE_DATA_LINK @"https://goo.gl/jD5uIQ"

#define PROPOSE_STRUCTURE_URL_GOOGLE_DOCS @"https://docs.google.com/forms/d/e/1FAIpQLSdcpYpAWz9zllF2TUS4USDQzu4T4ywu_XjXaD-ovsTS5eo1YA/viewform"
#define PROPOSE_STRUCTURE_URL @"%@links/propose-poi/redirect?token=%@"

// Entourages
#define ENTOURAGE_DEMANDE @"ask_for_help"
#define ENTOURAGE_CONTRIBUTION @"contribution"
#define ENTOURAGE_STATUS_OPEN @"open"
#define ENTOURAGE_STATUS_SUSPENDED @"suspended"
#define ENTOURAGE_TYPE_PUBLIC @"public"

#define GROUP_TYPE_ACTION @"action"
#define GROUP_TYPE_NEIGHBORHOOD @"neighborhood"
#define GROUP_TYPE_PRIVATE_CIRCLE @"private_circle"
#define GROUP_TYPE_CONVERSATION @"conversation"
#define GROUP_TYPE_OUTING @"outing"

// Email addresses
#define SIGNAL_ENTOURAGE_TO @"contact@entourage.social"
#define CONTACT_PFP_TO @"voisinage-test@petitsfreresdespauvres.org"

// Tabbar Indexes
#if PFP
    #define MAP_TAB_INDEX 0
    #define SOLIDARITY_MAP_INDEX 0
    #define MESSAGES_TAB_INDEX 1
    #define MENU_TAB_INDEX 2
# else
    #define MAP_TAB_INDEX 0
    #define SOLIDARITY_MAP_INDEX 1
    #define MESSAGES_TAB_INDEX 2
    #define MENU_TAB_INDEX 3
#endif
