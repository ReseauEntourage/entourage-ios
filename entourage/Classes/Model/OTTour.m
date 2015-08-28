//
//  OTTour.m
//  entourage
//
//  Created by Nicolas Telera on 25/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTTour.h"
#import "OTTourPoint.h"

#import "NSDictionary+Parsing.h"

NSString *const kTourId = @"id";

/* RunKeeper in progress - properties are meant to evolve (webservice attributes names may by wrong too) */
NSString *const kTourDuration = @"duration";
NSString *const kTourDistance = @"distance";
NSString *const kTourDate = @"date";
NSString *const kTourLocations = @"locations";

@implementation OTTour

/********************************************************************************/
#pragma mark - Birth & Death

+ (OTTour *)tourWithJSONDictionary:(NSDictionary *)dictionary
{
    OTTour *tour = nil;
    
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        tour = [[OTTour alloc] init];
        
        tour.sid = [dictionary numberForKey:kTourId];
        tour.duration = [dictionary numberForKey:kTourDuration];
        tour.distance = [dictionary numberForKey:kTourDistance];
        tour.date = [dictionary dateForKey:kTourDate format:@"yyyy-MM-dd HH:mm:ss"];
        tour.locations = [dictionary arrayWithObjectsOfClass:[OTTourPoint class] forKey:kTourLocations];
    }
    
    return tour;
}

/********************************************************************************/
#pragma mark - Utils

@end
