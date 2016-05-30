//
//  OTConsts.h
//  entourage
//
//  Created by Hugo Schouman on 11/02/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#if DEBUG
// PREPROD - Staging
#define BASE_API_URL @"https://entourage-back-preprod.herokuapp.com/api/v1/"
//#define BASE_API_URL @"https://api.entourage.social/api/v1/"

#else
// PROD
#define BASE_API_URL @"https://api.entourage.social/api/v1/"

#endif



#define API_KEY @"fbe5b5e0bd4ec94146b3dc9b"

#define PARIS_LAT 48.856578
#define PARIS_LON  2.351828

#define ATTR_LIGHT_15       @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightLight]}
#define ATTR_SEMIBOLD_15    @{NSFontAttributeName : [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold]}


#define TEXTVIEW_PADDING 10.0f
#define TEXTVIEW_PADDING_TOP 12.0f
#define TEXTVIEW_PADDING_BOTTOM 23.0f


#define kNotificationPushStatusChanged @"NotificationAPNSStatusChanged"
#define kNotificationLocalTourConfirmation "NotificationShowTourConfirmation"

#define kNotificationShowFilters "NotificationShowFilter"
#define kNotificationShowCurrentLocation "NotificationCurrentLocation"

#define ABOUT_RATE_US_URL @"itms://itunes.apple.com/app/entourage-reseau-civique/id1072244410"
#define ABOUT_FACEBOOK_URL @"https://www.facebook.com/EntourageReseauCivique"
#define ABOUT_CGU_URL @"https://api.entourage.social/cgu"
#define ABOUT_CGU_URL_OLD @"https://s3-eu-west-1.amazonaws.com/entourage-ressources/charte.pdf"
#define ABOUT_WEBSITE_URL @"http://www.entourage.social"
#define ABOUT_EMAIL_ADDRESS @"contact@entourage.social"

#define OTLocalizedString(key) \
    [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]



#define SNAPSHOT_START "snapshot_start_%d.png"
#define SNAPSHOT_STOP "snapshot_end_%d.png"