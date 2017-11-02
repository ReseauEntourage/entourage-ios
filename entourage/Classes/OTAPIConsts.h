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
#define IS_PRO_USER [[NSUserDefaults standardUserDefaults].currentUser.type isEqualToString:USER_TYPE_PRO]

// Onboarding
#define API_URL_ONBOARD  @"users"

//Menu
#define API_URL_MENU_OPTIONS @"links/%@/redirect?token=%@"

// Feeds
#define API_URL_FEEDS    @"feeds?token=%@"
#define API_URL_MYFEEDS  @"myfeeds?token=%@"

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

// Entourages
#define API_URL_ENTOURAGES @"entourages?token=%@"
#define API_URL_ENTOURAGE_BY_ID @"entourages/%@?token=%@"
#define API_URL_ENTOURAGE_UPDATE @"entourages/%@?token=%@"
#define API_URL_ENTOURAGE_QUIT @"entourages/%@/users/%@?token=%@"
#define API_URL_ENTOURAGE_JOIN_REQUEST @"entourages/%@/users?token=%@"
#define API_URL_ENTOURAGE_JOIN_UPDATE @"entourages/%@/users/%@?token=%@"
#define API_URL_ENTOURAGE_SEND_MESSAGE "entourages/%@/chat_messages.json?token=%@"
#define API_URL_ENTOURAGE_GET_MESSAGES "entourages/%@/chat_messages.json?token=%@"
#define API_URL_ENTOURAGE_INVITE @"entourages/%@/invitations?token=%@"
#define API_URL_ENTOURAGE_GET_INVITES @"invitations?token=%@"
#define API_URL_ENTOURAGE_HANDLE_INVITE @"invitations/%@?token=%@"
#define API_URL_ENTOURAGE_SEND @"entourages"
#define API_URL_ENTOURAGE_RETRIEVE @"entourages/%@?distance=%d&feed_rank=%@&token=%@"

//Messages
#define API_URL_TOUR_SET_READ_MESSAGES  "tours/%@/read?token=%@"
#define API_URL_ENTOURAGE_SET_READ_MESSAGES "entourages/%@/read?token=%@"

//Profile
#define API_URL_USER_DETAILS @"users/%@?token=%@"
#define API_URL_UPDATE_USER @"%@/%@.json?token=%@"
#define API_URL_DELETE_ACCOUNT @"users/me?token=%@"
#define API_URL_REGENERATE_CODE @"%@/%@/%@.json"

#endif /* OTAPIConsts_h */
