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

#define TOUR_COLOR_MEDICAL [UIColor colorWithRed:1 green:153.0/255.0 blue:153.0/255.0 alpha:1]
#define TOUR_COLOR_SOCIAL [UIColor colorWithRed:151.0/255.0 green:215.0/255.0 blue:145.0/255.0 alpha:1]
#define TOUR_COLOR_DISTRIBUTIVE [UIColor colorWithRed:1 green:197.0/255.0 blue:127.0/255.0 alpha:1]

@implementation OTTour

/********************************************************************************/
#pragma mark - Birth & Death

- (instancetype)init {
    self = [super init];
    if (self) {
        //self.status = TOUR_STATUS_ONGOING;
    }
    return self;
}

- (id)initWithTourType:(NSString *)tourType {
    self = [super init];
    if (self)
    {
        OTUser *user = [[NSUserDefaults standardUserDefaults] currentUser];
        
        self.type = tourType;
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
        self.startTime = [dictionary dateForKey:kWSKeyStartDate];
        self.endTime = [dictionary dateForKey:kWSKeyEndDate];
        self.type = [dictionary valueForKey:kWSKeyTourType];
        self.distance = [dictionary numberForKey:kWSKeyDistance];
        self.organizationName = [dictionary stringForKey:kWSKeyOrganizationName];
        self.organizationDesc = [dictionary stringForKey:kWSKeyOrganizationDescription];
        self.tourPoints = [OTTourPoint tourPointsWithJSONDictionary:dictionary andKey:kWSKeyTourPoints];
        self.noMessages = [dictionary numberForKey:kWSNoUnreadMessages];
        self.noPeople = [dictionary numberForKey:kWSNoPeople];
        
        if (self.distance == nil || self.distance.doubleValue == 0) {
            [self computeDistance];
        }
    }
    return self;
}

- (NSDictionary *)dictionaryForWebService {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    dictionary[kWSKeyTourType] = self.type;
    dictionary[kWSKeyStatus] = self.status;
    dictionary[kWSKeyDistance] = self.distance;
    dictionary[kWSKeyStartDate] = self.creationDate;
    dictionary[kWSKeyTourPoints] = [OTTourPoint arrayForWebservice:self.tourPoints];
    if (self.endTime != nil) {
        dictionary[kWSKeyEndDate] = self.endTime;
    }
    
    return dictionary;
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

- (void)computeDistance {
    // We need at least two points to compute the distance
    if (self.tourPoints == nil || self.tourPoints.count < 2) return;
    self.distance = @0.0;
    CLLocation *firstLocation = ((OTTourPoint*)self.tourPoints[0]).toLocation;
    for (NSUInteger i = 1; i < self.tourPoints.count; i++) {
        CLLocation *secondLocation = ((OTTourPoint*)self.tourPoints[i]).toLocation;
        self.distance = @(self.distance.doubleValue + [secondLocation distanceFromLocation:firstLocation]);
        firstLocation = ((OTTourPoint*)self.tourPoints[i]).toLocation;
    }
}

@end
