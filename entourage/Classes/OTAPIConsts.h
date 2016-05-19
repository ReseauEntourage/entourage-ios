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

// Feeds
#define API_URL_FEEDS    @"feeds?token=%@"

// Entourages
#define API_URL_ENTOURAGES @"entourages?token=%@"
#define API_URL_ENTOURAGE_JOIN_REQUEST @"entourages/%@?token=%@"
#define API_URL_ENTOURAGE_JOIN_UPDATE @"entourages/%@/users/%@?token=%@"


#endif /* OTAPIConsts_h */
