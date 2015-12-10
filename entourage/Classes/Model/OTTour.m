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
NSString *const kTourUserId = @"user_id";
NSString *const kTourType = @"tour_type";
NSString *const kTourVehicle = @"vehicle_type";
NSString *const kTourStatus = @"status";
NSString *const kTourTourPoints = @"tour_points";
NSString *const kTourStats = @"stats";
NSString *const kTourOrganizationName = @"organization_name";
NSString *const kTourOrganizationDesc = @"organization_description";
NSString *const kTourDistance = @"distance";

NSString *const kToursCount = @"tour_count";
NSString *const kEncountersCount = @"encounter_count";

@implementation OTTour

/********************************************************************************/
#pragma mark - Birth & Death

- (id)init
{
    self = [super init];
    if (self)
    {
        OTUser *user = [[NSUserDefaults standardUserDefaults] currentUser];
        
        self.tourType = NSLocalizedString(@"tour_type_type", @"");
        self.vehicleType = NSLocalizedString(@"tour_vehicle_feet", @"");
        self.status = NSLocalizedString(@"tour_status_ongoing", @"");
        self.tourPoints = [NSMutableArray new];
        self.stats = [NSMutableDictionary dictionaryWithDictionary:@{kToursCount : @0, kEncountersCount : @0}];
        self.organizationName = user.organization.name;
        self.organizationDesc = user.organization.description;
        self.distance = 0.0;
    }
    return self;
}

- (id)initWithTourType:(NSString *)tourType andVehicleType:(NSString *)vehicleType
{
    self = [super init];
    if (self)
    {
        OTUser *user = [[NSUserDefaults standardUserDefaults] currentUser];
        
        self.tourType = tourType;
        self.vehicleType = vehicleType;
        self.status = NSLocalizedString(@"tour_status_ongoing", @"");
        self.tourPoints = [NSMutableArray new];
        self.stats = [NSMutableDictionary dictionaryWithDictionary:@{kToursCount : @0, kEncountersCount : @0}];
        self.organizationName = user.organization.name;
        self.organizationDesc = user.organization.description;
        self.distance = 0.0;
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
        tour.userId = [dictionary numberForKey:kTourUserId];
        tour.tourType = [dictionary stringForKey:kTourType];
        tour.vehicleType = [dictionary stringForKey:kTourVehicle];
        tour.status = [dictionary stringForKey:kTourStatus];
        tour.tourPoints = [OTTourPoint tourPointsWithJSONDictionary:dictionary andKey:kTourTourPoints];
        tour.organizationName = [dictionary stringForKey:kTourOrganizationName];
        tour.organizationDesc = [dictionary stringForKey:kTourOrganizationDesc];
        tour.distance = [[dictionary numberForKey:kTourDistance] floatValue];
    }
    
    return tour;
}

- (NSDictionary *)dictionaryForWebserviceTour
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kTourType] = self.tourType;
    dictionary[kTourVehicle] = self.vehicleType;
    dictionary[kTourStatus] = self.status;
    dictionary[kTourDistance] = @(self.distance);
    
    return dictionary;
}

- (NSDictionary *)dictionaryForWebserviceTourPoints
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    return dictionary;
}

@end
