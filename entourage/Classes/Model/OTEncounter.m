//
//  OTEncounter.m
//  entourage
//
//  Created by Mathieu Hausherr on 11/10/14.
//  Copyright (c) 2014 OCTO Technology. All rights reserved.
//

#import "OTEncounter.h"

// Utils
#import "NSDictionary+Parsing.h"

@implementation OTEncounter

NSString *const kEncounterId = @"id";
NSString *const kEncounterDate = @"date";
NSString *const kEncounterLongitude = @"longitude";
NSString *const kEncounterLatitude = @"latitude";
NSString *const kEncounterUserId = @"user_id";
NSString *const kEncounterUserName = @"user_name";
NSString *const kEncounterStreetPersonName = @"street_person_name";
NSString *const kEncounterMessage = @"message";
NSString *const kEncounterVoiceMessage = @"voice_message";

+ (OTEncounter *)encounterWithJSONDictionnary:(NSDictionary *)dictionary
{
    OTEncounter *encounter = nil;
    
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        encounter = [[OTEncounter alloc] init];
        
        encounter.sid = [dictionary numberForKey:kEncounterId];
        encounter.date = [dictionary dateForKey:kEncounterDate format:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
        encounter.longitude = [[dictionary numberForKey:kEncounterLongitude] doubleValue];
        encounter.latitude = [[dictionary numberForKey:kEncounterLatitude] doubleValue];
        encounter.userId = [dictionary numberForKey:kEncounterUserId];
        encounter.userName = [dictionary stringForKey:kEncounterUserName];
        encounter.streetPersonName = [dictionary stringForKey:kEncounterStreetPersonName];
        encounter.message = [dictionary stringForKey:kEncounterMessage];
        encounter.voiceMessage = [dictionary stringForKey:kEncounterVoiceMessage];
    }
    
    return encounter;
}

@end
