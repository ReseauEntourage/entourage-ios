//
//  OTConsts.h
//  entourage
//
//  Created by Hugo Schouman on 11/02/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#if DEBUG
// PREPROD
//#define BASE_API_URL @"https://entourage-back-preprod.herokuapp.com/api/v1/"
#define BASE_API_URL @"https://api.entourage.social/api/v1/"

#else
// PROD
#define BASE_API_URL @"https://api.entourage.social/api/v1/"

#endif


#define kNotificationPushStatusChanged @"NotificationAPNSStatusChanged"

#define kNotificationLocalTourConfirmation "NotificationShowTourConfirmation"

#define ABOUT_RATE_US_URL @"itms://itunes.apple.com/app/entourage-reseau-civique/id1072244410"
#define ABOUT_FACEBOOK_URL @"https://www.facebook.com/EntourageReseauCivique"
#define ABOUT_CGU_URL @"https://s3-eu-west-1.amazonaws.com/entourage-ressources/charte.pdf"
#define ABOUT_WEBSITE_URL @"http://www.entourage.social"
#define ABOUT_EMAIL_ADDRESS @"contact@entourage.social"

