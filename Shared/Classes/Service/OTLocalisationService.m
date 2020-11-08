//
//  OTLocalisationService.m
//  entourage
//
//  Created by Smart Care on 26/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTLocalisationService.h"

@implementation OTLocalisationService

+ (NSString*)getLocalizedValueForKey:(NSString*)key
{    
    // Search in the default localization file
    return [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
}

@end
