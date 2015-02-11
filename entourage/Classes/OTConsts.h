//
//  OTConsts.h
//  entourage
//
//  Created by Hugo Schouman on 11/02/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#ifdef DEBUG
// PREPROD
#define LOGIN_API_SOUNDCLOUD @"hschouman@octo.com"
#define BASE_API_URL @"https://entourage-back-preprod.herokuapp.com/"
#define PASS_API_SOUNDCLOUD @"passDevForAPI"

#else
// PROD
#define LOGIN_API_SOUNDCLOUD @"entourage@octo.com"
#define BASE_API_URL @"https://entourage-back.herokuapp.com/"

#endif


#define CLIENT_ID_API_SOUNDCLOUD @"8ea64716590a242e6f205bf1f821bb4a"
#define SECRET_API_SOUNDCLOUD @"119dea503c758179e90aa30d4b21d665"