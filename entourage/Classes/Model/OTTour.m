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
#import "OTConsts.h"

#import "NSUserDefaults+OT.h"
#import "UIColor+entourage.h"

#define TOUR_COLOR_MEDICAL [UIColor redColor]
#define TOUR_COLOR_SOCIAL [UIColor blueColor]
#define TOUR_COLOR_DISTRIBUTIVE [UIColor greenColor]

@implementation OTTour

/********************************************************************************/
#pragma mark - Birth & Death

- (id)initWithTourType:(NSString *)tourType andVehicleType:(NSString *)vehicleType
{
    self = [super init];
    if (self)
    {
        OTUser *user = [[NSUserDefaults standardUserDefaults] currentUser];
        
        self.type = tourType;
        self.vehicleType = vehicleType;
        self.status = OTLocalizedString(@"tour_status_ongoing");
        self.tourPoints = [NSMutableArray new];
        self.organizationName = user.organization.name;
        self.organizationDesc = user.organization.description;
        self.distance = @0.0;
        self.creationDate = [NSDate date];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.creationDate = [dictionary dateForKey:kWSKeyStartDate];
        self.endTime = [dictionary dateForKey:kWSKeyEndDate];
        self.type = [dictionary valueForKey:kWSKeyTourType];
        self.vehicleType = [dictionary valueForKey:kWSKeyVehicleType];
        self.distance = [dictionary numberForKey:kWSKeyDistance];
        self.organizationName = [dictionary valueForKey:kWSKeyOrganizationName];
        self.organizationDesc = [dictionary valueForKey:kWSKeyOrganizationDescription];
        self.tourPoints = [OTTourPoint tourPointsWithJSONDictionary:dictionary andKey:kWSKeyTourPoints];
        self.noMessages = [dictionary valueForKey:kWSNoUnreadMessages];
    }
    return self;
}

- (NSDictionary *)dictionaryForWebService
{
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kWSKeyTourType] = self.type;
    dictionary[kWSKeyVehicleType] = self.vehicleType;
    dictionary[kWSKeyStatus] = self.status;
    dictionary[kWSKeyDistance] = self.distance;
    dictionary[kWSKeyStartDate] = self.creationDate;
    if (self.endTime != nil) {
        dictionary[kWSKeyEndDate] = self.endTime;
    }
    
    return dictionary;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[self class]]) {
        OTTour *otherTour = (OTTour*)object;
        if (otherTour.uid != nil) {
            return [self.uid isEqualToValue:((OTTour*)object).uid];
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
    NSString *emaDescription = [NSString stringWithFormat:@"Tour %d with %lu points", self.uid.intValue, (unsigned long)_tourPoints.count];
    return emaDescription;
}

@end