//
//  OTLocalisationService.m
//  entourage
//
//  Created by Smart Care on 26/04/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import "OTLocalisationService.h"

#define PFP_LOCALIZABLE_FILE  @"Pfp-Localizable"

@implementation OTLocalisationService

+ (NSString*)getLocalizedValueForKey:(NSString*)key
{
    // Search first in custom files
    NSString *filePath = [[NSBundle mainBundle] pathForResource:PFP_LOCALIZABLE_FILE ofType:@"strings"];
    NSDictionary *localizedInfoDictionary = [NSDictionary dictionaryWithContentsOfFile:filePath];

    if ([[localizedInfoDictionary allKeys] containsObject:key]) {
        return [[NSBundle mainBundle] localizedStringForKey:key value:nil table:PFP_LOCALIZABLE_FILE];
    }
    
    // Search in the default localization file
    return [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil];
}

@end
