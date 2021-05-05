//
//  OTAPIConsts.h
//  entourage
//
//  Created by Ciprian Habuc on 16/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#ifndef OTAPIConsts_h
#define OTAPIConsts_h

#define TOKEN [[NSUserDefaults standardUserDefaults] currentUser].token
#define USER_ID [[NSUserDefaults standardUserDefaults] currentUser].sid
#define USER_UUID [[NSUserDefaults standardUserDefaults] currentUser].uuid
#define IS_PRO_USER [[NSUserDefaults standardUserDefaults].currentUser.type isEqualToString:USER_TYPE_PRO]
#define IS_ANONYMOUS_USER [[NSUserDefaults standardUserDefaults] currentUser].isAnonymous

#define FONT_NORMAL_DESCRIPTION @"SFUIText-Light"
#define FONT_BOLD_DESCRIPTION @"SFUIText-Bold"
#define DEFAULT_DESCRIPTION_SIZE 15.0

// Mixpanel
#define API_URL_MIXPANEL_ENGAGE @"http://api.mixpanel.com/engage/?data=%@"

// Onboarding
#define API_URL_ONBOARD  @"users"
#define API_URL_REPORT_USER @"users/%@/report?token=%@"
#define API_URL_REPORT_ENTOURAGE @"entourages/%@/report?token=%@"

//Menu
#define API_URL_MENU_OPTIONS @"links/%@/redirect?token=%@"
#define API_URL_MENU_OPTIONS_NO_TOKEN @"links/%@/redirect"

// Feeds
#define API_URL_FEEDS    @"feeds?token=%@"
#define API_URL_MYFEEDS  @"myfeeds?token=%@"
#define API_URL_EVENTS    @"feeds/outings?token=%@"

//New Feed
#define API_URL_NEW_FEED    @"home?token=%@"

// Tours
#define API_URL_TOUR_JOIN_REQUEST @"tours/%@/users?token=%@"
#define API_URL_TOUR_JOIN_MESSAGE @"tours/%@/users/%@?token=%@"
#define API_URL_TOUR_SEND @"%@.json?token=%@"
#define API_URL_TOUR_CLOSE @"%@/%@.json?token=%@"
#define API_URL_TOUR_QUIT @"%@/%@/users/%@?token=%@"
#define API_URL_TOUR_SEND_POINT @"%@/%@/%@.json?token=%@"
#define API_URL_TOURs_AROUND @"%@.json?token=%@"
#define API_URL_TOUR @"%@/%@?token=%@"
#define API_URL_TOUR_FEED_ITEM_USERS @"%@/%@/users.json?token=%@"
#define API_URL_TOUR_JOIN_REQUEST_RESPONSE @"tours/%@/users/%@?token=%@"
#define API_URL_TOUR_MESSAGES @"%@/%@/chat_messages.json?token=%@"
#define API_URL_TOUR_ENCOUNTERS @"%@/%@/encounters.json?token=%@"
#define API_URL_TOURS_USER @"%@/%@/%@.json?token=%@"
#define API_URL_TOUR_SEND_ENCOUNTER @"%@/%@/%@.json?token=%@"
#define API_URL_ENCOUNTER_UPDATE @"encounters/%@?token=%@"


//Associations
#define API_URL_GET_ALL_ASSOCIATIONS @"partners?token=%@"
#define API_URL_ADD_PARTNER @"users/%@/partners?token=%@"
#define API_URL_DELETE_PARTNER @"users/%@/partners/%@?token=%@"
#define API_URL_USER_UPDATE_ASSOCIATION_INFO @"partners/join_request?token=%@"
#define API_URL_GET_ASSOCIATION_DETAIL @"partners/%d?token=%@"
// Entourages
#define API_URL_ENTOURAGES @"entourages?token=%@"
#define API_URL_ENTOURAGE_BY_ID @"entourages/%@"
#define API_URL_ENTOURAGE_UPDATE @"entourages/%@?token=%@"
#define API_URL_ENTOURAGE_QUIT @"entourages/%@/users/%@?token=%@"
#define API_URL_ENTOURAGE_JOIN_REQUEST @"entourages/%@/users?token=%@"
#define API_URL_ENTOURAGE_JOIN_UPDATE @"entourages/%@/users/%@?token=%@"
#define API_URL_ENTOURAGE_SEND_MESSAGE "entourages/%@/chat_messages.json?token=%@"
#define API_URL_ENTOURAGE_GET_MESSAGES "entourages/%@/chat_messages.json?token=%@"
#define API_URL_ENTOURAGE_INVITE @"entourages/%@/invitations?token=%@"
#define API_URL_ENTOURAGE_GET_INVITES @"invitations?token=%@&status=%@"
#define API_URL_ENTOURAGE_HANDLE_INVITE @"invitations/%@?token=%@"
#define API_URL_ENTOURAGE_SEND @"entourages"
#define API_URL_ENTOURAGE_RETRIEVE @"entourages/%@?distance=%d&feed_rank=%@&token=%@"

#define API_URL_DISABLE_REPORT_USER @"entourages/%@/report_prompt?token=%@"

//Messages
#define API_URL_TOUR_SET_READ_MESSAGES  "tours/%@/read?token=%@"
#define API_URL_ENTOURAGE_SET_READ_MESSAGES "entourages/%@/read?token=%@"

//Profile
#define API_URL_USER_DETAILS @"users/%@?token=%@"
#define API_URL_UPDATE_USER @"%@/%@.json?token=%@"
#define API_URL_DELETE_ACCOUNT @"users/me?token=%@"
#define API_URL_REGENERATE_CODE @"%@/%@/%@.json"
#define API_URL_UPDATE_ADDRESS_PRIMARY @"users/me/addresses/1?token=%@"
#define API_URL_UPDATE_ADDRESS_SECONDARY @"users/me/addresses/2?token=%@"
#define API_URL_UPDATE_ACCOUNT_PARTNER @"users/me/following?token=%@"

//Upload Photo
#define API_URL_USER_PREPARE_AVATAR_UPLOAD @"users/me/presigned_avatar_upload.json"

//Sharing Entourage
#define API_URL_SHARINGS    @"sharing/groups?token=%@"

#define SLUG_EVENT_BRITE @"event-brite"

#define API_URL_TOUR_AREAS @"tour_areas?token=%@"
#define API_URL_TOUR_AREAS_ANSWER @"tour_areas/%d/request?token=%@"

#endif /* OTAPIConsts_h */
