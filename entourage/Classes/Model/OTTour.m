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
#import "UIColor+entourage.h"

#define TOUR_COLOR_MEDICAL [UIColor redColor]
#define TOUR_COLOR_SOCIAL [UIColor blueColor]
#define TOUR_COLOR_DISTRIBUTIVE [UIColor greenColor]

NSString *const kTourId = @"id";
NSString *const kTourAuthor = @"author";
NSString *const kTourAuthorID = @"id";
NSString *const kTourAuthorName = @"display_name";
NSString *const kTourAuthorAvatarURL = @"avatar_url";

NSString *const kTourUserId = @"user_id";
NSString *const kTourType = @"tour_type";
NSString *const kTourVehicle = @"vehicle_type";
NSString *const kTourStatus = @"status";
NSString *const kTourJoinStatus = @"join_status";
NSString *const kTourNoPeople = @"number_of_people";
NSString *const kTourTourPoints = @"tour_points";
NSString *const kTourStats = @"stats";
NSString *const kTourOrganizationName = @"organization_name";
NSString *const kTourOrganizationDesc = @"organization_description";
NSString *const kTourStartTime = @"start_time";
NSString *const ktourEndTime = @"end_time";
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
        self.joinStatus = NSLocalizedString(@"tour_status_ongoing", @"");
        self.noPeople = @0;
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
        self.startTime = [NSDate date];
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
        tour.joinStatus = [dictionary stringForKey:kTourJoinStatus];
        tour.noPeople = [dictionary numberForKey:kTourNoPeople];
        NSDictionary *authorDictionary = [dictionary objectForKey:kTourAuthor];
        OTTourAuthor *author = [[OTTourAuthor alloc] init];
        author.uID = [authorDictionary numberForKey:kTourAuthorID];
        author.avatarUrl = [authorDictionary stringForKey:kTourAuthorAvatarURL];
        author.displayName = [authorDictionary stringForKey:kTourAuthorName];
        tour.author = author;
        tour.tourPoints = [OTTourPoint tourPointsWithJSONDictionary:dictionary andKey:kTourTourPoints];
        tour.organizationName = [dictionary stringForKey:kTourOrganizationName];
        tour.organizationDesc = [dictionary stringForKey:kTourOrganizationDesc];
        tour.distance = [[dictionary numberForKey:kTourDistance] floatValue];
        
        // Java format : "2015-09-09T08:56:48.065+02:00"
        tour.startTime = [dictionary dateForKey:kTourStartTime format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        if (tour.startTime == nil) {
            // Objective-C format : "2015-11-20 09:28:52 +0000"
            tour.startTime = [dictionary dateForKey:kTourStartTime format:@"yyyy-MM-dd HH:mm:ss Z"];
        }
        
        // Java format : "2015-09-09T08:56:48.065+02:00"
        tour.endTime = [dictionary dateForKey:ktourEndTime format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        if (tour.endTime == nil) {
            // Objective-C format : "2015-11-20 09:28:52 +0000"
            tour.endTime = [dictionary dateForKey:ktourEndTime format:@"yyyy-MM-dd HH:mm:ss Z"];
        }
        //NSLog(@"Tour %@ is %@", tour.sid, tour.status);
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
    dictionary[kTourStartTime] = self.startTime;
    if (self.endTime != nil) {
        dictionary[ktourEndTime] = self.endTime;
    }
    
    return dictionary;
}

- (NSDictionary *)dictionaryForWebserviceTourPoints
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    return dictionary;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        OTTour *otherTour = (OTTour*)object;
        if (otherTour.sid != nil) {
            return [self.sid isEqualToValue:((OTTour*)object).sid];
        }
    }
    return false;
}

+ (UIColor *)colorForTourType:(NSString*)tourType {
    UIColor *color = [UIColor appOrangeColor];
    
    if ([tourType isEqualToString:@"medical"]) {
        color = TOUR_COLOR_MEDICAL;
    }
    else if ([tourType isEqualToString:@"barehands"]) {
        color = TOUR_COLOR_SOCIAL;
    }
    else if ([tourType isEqualToString:@"alimentary"])
    {
        color = TOUR_COLOR_DISTRIBUTIVE;
    }
    return color;
}

- (NSString *)debugDescription {
    NSString *emaDescription = [NSString stringWithFormat:@"Tour %d with %lu points", _sid.intValue, (unsigned long)_tourPoints.count];
    return emaDescription;
}


@end
