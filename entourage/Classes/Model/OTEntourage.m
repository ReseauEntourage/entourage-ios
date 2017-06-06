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


@implementation OTEntourage

- (instancetype)init {
    self = [super init];
    if (self) {
        self.status = ENTOURAGE_STATUS_OPEN;
    }
    return self;
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
        self.noPeople = [dictionary numberForKey:kWSNoPeople];
    }
    return self;
}

- (NSDictionary *)dictionaryForWebService {
    
    return @{
        kWSKeyTitle: self.title,
        kWSKeyEntourageType: self.type,
        kWSDescription: self.desc ? self.desc : @"",
        kWSKeyStatus: self.status,
        kWSKeyLocation: @{
            kWSKeyLatitude: @(self.location.coordinate.latitude),
            kWSKeyLongitude: @(self.location.coordinate.longitude)
        }
    };
}

@end
