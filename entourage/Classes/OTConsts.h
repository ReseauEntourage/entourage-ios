//
//  OTConsts.h
//  entourage
//
//  Created by Hugo Schouman on 11/02/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#ifdef DEBUG
// PREPROD
#define BASE_API_URL @"https://entourage-back-preprod.herokuapp.com/api/v0/"

#else
// PROD
#define BASE_API_URL @"https://entourage-back.herokuapp.com/api/v0/"

#endif
