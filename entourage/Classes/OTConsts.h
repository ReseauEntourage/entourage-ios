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

#define DATA_REFRESH_RATE 60.0 //seconds
#define LOCATION_MIN_DISTANCE 5.f

#define ENTOURAGE_RADIUS 250
#define ENTOURAGE_RADIUS_FACTOR 1.0f

#define TEXTVIEW_PADDING 10.0f
#define TEXTVIEW_PADDING_TOP 12.0f
#define TEXTVIEW_PADDING_BOTTOM 23.0f

#define MAP_TOUR_LINE_WIDTH 4.0f

#define kNotificationPushStatusChanged @"NotificationAPNSStatusChanged"
#define kNotificationPushStatusChangedStatusKey @"NotificationAPNSStatusChangedStatusKey"
#define kNotificationLocalTourConfirmation "NotificationShowTourConfirmation"

#define kNotificationShowFilters "NotificationShowFilter"
#define kNotificationShowCurrentLocation "NotificationCurrentLocation"

#define kNotificationProfilePictureUpdated "NotificationProfilePictureUpdated"
#define kNotificationSupportedPartnerUpdated "NotificationSupportedPartnerUpdated"
#define kNotificationEntourageCreated @"NotificationEntourageCreated"
#define kNotificationEntourageChanged @"NotificationEntourageChanged"
#define kNotificationEntourageChangedEntourageKey @"NotificationEntourageChangedEntourageKey"

#define kNotificationPushReceived "NotificationPushReceived"

#define ABOUT_RATE_US_URL @"itms://itunes.apple.com/app/entourage-reseau-civique/id1072244410"
#define ABOUT_FACEBOOK_URL @"https://www.facebook.com/EntourageReseauCivique"
#define ABOUT_CGU_URL @"http://www.entourage.social/cgu/index.html"
#define ABOUT_CGU_URL_OLD @"https://s3-eu-west-1.amazonaws.com/entourage-ressources/charte.pdf"
#define ABOUT_WEBSITE_URL @"http://www.entourage.social"
#define ABOUT_EMAIL_ADDRESS @"contact@entourage.social"

#define OTLocalizedString(key) [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]

#define SNAPSHOT_START "snapshot_start_%d.png"
#define SNAPSHOT_STOP "snapshot_end_%d.png"

#define INVALID_PHONE_FORMAT @"INVALID_PHONE_FORMAT"
#define UNAUTHORIZED @"UNAUTHORIZED"
#define PHONE_ALREADY_EXIST @"PHONE_ALREADY_EXIST"

#define PUBLIC_ENTOURAGE_CREATION_CHART @"http://www.entourage.social/chartes/grand-public.html"
#define PRO_ENTOURAGE_CREATION_CHART @"http://www.entourage.social/chartes/pro.html"

#define MENU_BLOG_URL @"https://blog.entourage.social/2016/10/28/franchir-le-pas/"

#define TUTORIAL_BLOG_LINK @"https://blog.entourage.social/franchir-le-pas"
#define PRO_MENU_CHART_URL @"http://www.entourage.social/chartes/pro.html"
#define PUBLIC_MENU_CHART_URL @"http://www.entourage.social/chartes/grand-public.html"

#define NO_GIUDE_DATA_LINK @"https://goo.gl/jD5uIQ"
