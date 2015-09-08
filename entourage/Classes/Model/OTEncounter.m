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
NSString *const kEncounterStreetPersonName = @"street_person_name";
NSString *const kEncounterDate = @"date";
NSString *const kEncounterLatitude = @"latitude";
NSString *const kEncounterLongitude = @"longitude";
NSString *const kEncounterMessage = @"message";

+ (OTEncounter *)encounterWithJSONDictionary:(NSDictionary *)dictionary {
	OTEncounter *encounter = nil;

	if ([dictionary isKindOfClass:[NSDictionary class]]) {
		encounter = [[OTEncounter alloc] init];

		encounter.sid = [dictionary numberForKey:kEncounterId];
        encounter.date = [dictionary dateForKey:kEncounterDate format:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
        encounter.latitude = [[dictionary numberForKey:kEncounterLatitude] doubleValue];
        encounter.longitude = [[dictionary numberForKey:kEncounterLongitude] doubleValue];
        encounter.streetPersonName = [dictionary stringForKey:kEncounterStreetPersonName];
        encounter.message = [dictionary stringForKey:kEncounterMessage];
	}

	return encounter;
}

- (NSDictionary *)dictionaryForWebservice {
	NSMutableDictionary *dictionary = [NSMutableDictionary new];

    dictionary[kEncounterStreetPersonName] = self.streetPersonName;
	dictionary[kEncounterDate] = self.date;
    dictionary[kEncounterLatitude] = [NSNumber numberWithDouble:self.latitude];
	dictionary[kEncounterLongitude] = [NSNumber numberWithDouble:self.longitude];
    if (self.message) {
        dictionary[kEncounterMessage] = self.message;
    }
    
	return dictionary;
}

@end
