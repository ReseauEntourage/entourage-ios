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
        self.consentObtained = @(NO);
    }
    return self;
}

- (instancetype)initWithGroupType:(NSString*)groupType
{
    self = [super initWithGroupType:groupType];
    if (self) {
        self.status = ENTOURAGE_STATUS_OPEN;
        self.consentObtained = @(NO);
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
    copy.isPublic = self.isPublic;
    copy.consentObtained = self.consentObtained;

    return copy;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self && dictionary) {
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
        self.isPublic = [dictionary numberForKey:kWSKeyPublic];
        self.consentObtained = [dictionary numberForKey:kWSKeyConsentObtained];
        
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
    
    if (self.consentObtained) {
        [params setObject:self.consentObtained forKey:kWSKeyConsentObtained];
    }
    
    if (self.isPublic) {
        [params setObject:self.isPublic forKey:kWSKeyPublic];
    }
    
    if (self.status) {
        [params setObject:self.status forKey:kWSKeyStatus];
    }
    
    if ([self isOuting]) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        formatter.includeTime = YES;
        NSString *dateStartString = [formatter stringFromDate:self.startsAt];
        NSString *dateEndString = [formatter stringFromDate:self.endsAt];
        NSDictionary *eventInfo  = @{kWSKeyStartsAt: dateStartString,
                                     kWSKeyEndsAt: dateEndString,
                                     kWSKeyStreetAddress: self.streetAddress ?: @"",
                                     kWSKeyPlaceName: self.placeName ?: @"",
                                     kWSKeyGooglePlaceId: self.googlePlaceId ?: @"",
        };
        [params setObject:eventInfo forKey:kWSKeyMetadata];
        [params setObject:self.groupType forKey:kWSKeyGroupType];
    }
    
    return params;
}

- (BOOL)isContribution {
    return [self.entourage_type isEqualToString:ENTOURAGE_CONTRIBUTION];
}

- (BOOL)isAskForHelp {
    return [self.entourage_type isEqualToString:ENTOURAGE_DEMANDE];
}

@end
