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

// Onboarding
#define API_URL_ONBOARD  @"users"


// Feeds
#define API_URL_FEEDS    @"feeds?token=%@"
#define API_URL_MYFEEDS  @"myfeeds?token=%@"

// Tours
#define API_URL_TOUR_JOIN_REQUEST @"tours/%@/users?token=%@"
#define API_URL_TOUR_JOIN_MESSAGE @"tours/%@/users/%@?token=%@"



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
#define API_URL_ENTOURAGE_HANDLE_INVITE @"invitation/%@?token=%@"

#endif /* OTAPIConsts_h */
