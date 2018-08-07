//
//  OTEntourage.m
//  entourage
//
//  Created by Ciprian Habuc on 13/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourage.h"
#import "OTConsts.h"
#import "OTTour.h"
#import "ISO8601DateFormatter.h"

@implementation OTEntourage

- (instancetype)init {
    self = [super init];
    if (self) {
        self.status = ENTOURAGE_STATUS_OPEN;
    }
    return self;
}

- (instancetype)initWithGroupType:(NSString*)groupType
{
    self = [super initWithGroupType:groupType];
    if (self) {
        self.status = ENTOURAGE_STATUS_OPEN;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    OTEntourage *copy = [super copyWithZone:zone];
    copy.title = self.title;
    copy.desc = self.desc;
    copy.location = self.location;
    copy.category = self.category;
    copy.entourage_type = self.entourage_type;
    copy.categoryObject = self.categoryObject;
    copy.entourage_type = self.entourage_type;

    return copy;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.creationDate = [dictionary dateForKey:kWSKeyCreateDate];
        self.title = [dictionary stringForKey:kWSKeyTitle];
        self.location = [dictionary locationForKey:kWSKeyLocation
                                   withLatitudeKey:kWSKeyLatitude
                                   andLongitudeKey:kWSKeyLongitude];
        self.desc = [dictionary stringForKey:kWSKeyDescription];
        self.type = [dictionary stringForKey:kWSKeyEntourageType];
        self.entourage_type = [dictionary stringForKey:kWSKeyEntourageType];
        self.noPeople = [dictionary numberForKey:kWSNoPeople];
        self.category = [dictionary stringForKey:kWSKeyCategory];
        
        if (self.category) {
            if ([self.category isEqualToString:@""]) {
                self.category = @"other";
            }
        }
    }
    return self;
}

- (NSDictionary *)dictionaryForWebService {
    
    NSDictionary *entourageInfo = @{
                                    kWSKeyTitle: self.title,
                                    kWSDescription: self.desc ? self.desc : @"",
                                    kWSKeyStatus: self.status,
                                    kWSKeyLocation: @{
                                            kWSKeyLatitude: @(self.location.coordinate.latitude),
                                            kWSKeyLongitude: @(self.location.coordinate.longitude)
                                        }
                                    };
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:entourageInfo];
    if (self.entourage_type) {
        [params setObject:self.entourage_type forKey:kWSKeyEntourageType];
    }
    
    if (self.category) {
        [params setObject:self.category forKey:kWSKeyCategory];
    }
    
    if ([self isOuting]) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        formatter.includeTime = YES;
        NSString *dateString = [formatter stringFromDate:self.startsAt];
        NSDictionary *eventInfo  = @{kWSKeyStartsAt: dateString,
                                     kWSKeyStreetAddress: self.streetAddress ?: @"",
                                     kWSKeyPlaceName: self.placeName ?: @"",
                                     kWSKeyGooglePlaceId: self.googlePlaceId ?: @"",
                                     };
        [params setObject:eventInfo forKey:kWSKeyMetadata];
        [params setObject:self.groupType forKey:kWSKeyGroupType];
    }
    
    return params;
}

@end
