//
//  OTConsts.h
//  entourage
//
//  Created by Hugo Schouman on 11/02/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

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

#define kNotificationProfilePictureUpdated "NotificationProfilePictureUpdated"
#define kNotificationAboutMeUpdated "NotificationAboutMeUpdated"
#define kNotificationSupportedPartnerUpdated "NotificationSupportedPartnerUpdated"
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
#define ABOUT_WEBSITE_URL @"http://www.entourage.social"
#define ABOUT_EMAIL_ADDRESS @"contact@entourage.social"
#define REPORT_EMAIL_ADDRESS @"contact@entourage.social"

#define OTLocalizedString(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

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
#define CHARTE_LINK_ID @"ethics-charter"
#define FAQ_LINK_ID @"faq"
#define SUGGESTION_LINK_ID @"feedback"
#define JOIN_LINK_ID @"volunteering"

#define TUTORIAL_BLOG_LINK @"https://blog.entourage.social/franchir-le-pas"
#define MENU_BLOG_APPLICATION_USAGE_URL @"http://blog.entourage.social/comment-utiliser-l-application-entourage/"
#define PRO_MENU_CHART_URL @"https://blog.entourage.social/charte-ethique/"
#define PUBLIC_MENU_CHART_URL @"http://www.entourage.social/chartes/grand-public.html"

#define NO_GIUDE_DATA_LINK @"https://goo.gl/jD5uIQ"

#define PROPOSE_STRUCTURE_URL @"https://docs.google.com/forms/d/e/1FAIpQLSdcpYpAWz9zllF2TUS4USDQzu4T4ywu_XjXaD-ovsTS5eo1YA/viewform"
