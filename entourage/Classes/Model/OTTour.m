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
        self.endTime = [dictionary dateForKey:kWSKeyEndDate];
        self.type = [dictionary valueForKey:kWSKeyTourType];
        self.distance = [dictionary numberForKey:kWSKeyDistance];
        self.organizationName = [dictionary valueForKey:kWSKeyOrganizationName];
        self.organizationDesc = [dictionary valueForKey:kWSKeyOrganizationDescription];
        self.tourPoints = [OTTourPoint tourPointsWithJSONDictionary:dictionary andKey:kWSKeyTourPoints];
        self.noMessages = [dictionary valueForKey:kWSNoUnreadMessages];
        
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

- (NSString *)debugDescription {
    NSString *emaDescription = [NSString stringWithFormat:@"Tour %d with %lu points", self.uid.intValue, (unsigned long)_tourPoints.count];
    return emaDescription;
}

- (NSString *)navigationTitle {
    return OTLocalizedString(@"tour");
}

- (NSString *)summary {
    return self.organizationName;
}

- (NSString *)displayType {
    NSString *tourType;
    if ([self.type isEqualToString:@"barehands"]) {
        tourType = OTLocalizedString(@"tour_type_display_social");
    } else     if ([self.type isEqualToString:@"medical"]) {
        tourType = OTLocalizedString(@"tour_type_display_medical");
    } else if ([self.type isEqualToString:@"alimentary"]) {
        tourType = OTLocalizedString(@"tour_type_display_distributive");
    }
    return tourType;
}

- (NSAttributedString *)typeByNameAttributedString {
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formatter_tour_by"), [self displayType]]
                                                                         attributes:ATTR_LIGHT_15];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:self.author.displayName
                                                                         attributes:ATTR_SEMIBOLD_15];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    
    return typeByNameAttrString;
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

- (NSString *)newsfeedStatus {
    //OTUser *currentUser = [NSUserDefaults standardUserDefaults].currentUser;
    //if (self.author.uID.intValue == currentUser.sid.intValue)
    {
        if ([self.status isEqualToString:TOUR_STATUS_ONGOING] || [self.status isEqualToString:FEEDITEM_STATUS_CLOSED])
            return FEEDITEM_STATUS_ACTIVE;
    }
    return self.joinStatus;
}

@end