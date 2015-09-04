//
//  OTTour.m
//  entourage
//
//  Created by Nicolas Telera on 25/08/2015.
//  Copyright (c) 2015 OCTO Technology. All rights reserved.
//

#import "OTTour.h"
#import "OTTourPoint.h"
#import "OTUser.h"

#import "NSDictionary+Parsing.h"
#import "NSUserDefaults+OT.h"

NSString *const kTourId = @"id";
NSString *const kTourType = @"tour_type";
NSString *const kTourVehicule = @"vehicule_type";
NSString *const kTourStatus = @"status";
NSString *const kTourStats = @"stats";
NSString *const kTourOrganization = @"organization";

NSString *const kToursCount = @"tour_count";
NSString *const kEncountersCount = @"encounter_count";
NSString *const kOrganizationName = @"name";
NSString *const kOrganizationDescription = @"description";
NSString *const kOrganizationPhone = @"phone";
NSString *const kOrganizationAddress = @"address";

@implementation OTTour

/********************************************************************************/
#pragma mark - Birth & Death

- (id)init
{
    self = [super init];
    if (self)
    {
        self.tourType = @"social";
        self.vehiculeType = @"feet";
        self.status = @"ongoing";
        self.tourPoints = [NSMutableArray new];
        self.stats = [NSMutableDictionary dictionaryWithDictionary:@{kToursCount : @0, kEncountersCount : @0}];
        self.organization = [NSMutableDictionary dictionaryWithDictionary:@{kOrganizationName : @"",
                                                                            kOrganizationDescription : @"",
                                                                            kOrganizationPhone : @"",
                                                                        kOrganizationAddress : @""}];
    }
    return self;
}

+ (OTTour *)tourWithJSONDictionary:(NSDictionary *)dictionary
{
    OTTour *tour = nil;
    
    if ([dictionary isKindOfClass:[NSDictionary class]])
    {
        tour = [[OTTour alloc] init];
        
        tour.sid = [dictionary numberForKey:kTourId];
        tour.tourType = [dictionary stringForKey:kTourType];
        tour.vehiculeType = [dictionary stringForKey:kTourVehicule];
        tour.status = [dictionary stringForKey:kTourStatus];
        //tour.stats = [dictionary ...] // TODO
    }
    
    return tour;
}

- (NSDictionary *)dictionaryForWebservice
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kTourType] = self.tourType;
    dictionary[kTourVehicule] = self.vehiculeType;
    dictionary[kTourStatus] = self.status;
    
    return dictionary;
}

/********************************************************************************/
#pragma mark - Private methods

/********************************************************************************/
#pragma mark - Utils

@end
