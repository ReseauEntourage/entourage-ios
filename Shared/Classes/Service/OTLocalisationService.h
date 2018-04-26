//
//  OTLocalisationService.h
//  entourage
//
//  Created by Smart Care on 26/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

#define OTLocalizedString(key) [OTLocalisationService getLocalizedValueForKey:(key)]

@interface OTLocalisationService : NSObject

+ (NSString*)getLocalizedValueForKey:(NSString*)key;

@end
