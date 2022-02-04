//
//  OTAddress.m
//  entourage
//
//  Created by Smart Care on 20/07/2018.
//  Copyright © 2018 Entourage. All rights reserved.
//

#import "OTAddress.h"
#import "NSDictionary+Parsing.h"

@implementation OTAddress

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if(dictionary == nil || [dictionary isKindOfClass:[NSNull class]])
        return nil;
    self = [super init];
    if (self)
    {
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            self.googlePlaceId = [dictionary objectForKey:kWSKeyGooglePlaceId];
            self.displayAddress = [dictionary objectForKey:kWSKeyDisplayAddress];
            
            CLLocationDegrees lat = [dictionary degreesForKey:kWSKeyLatitude];
            CLLocationDegrees lon = [dictionary degreesForKey:kWSKeyLongitude];
            self.location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.googlePlaceId forKey:kWSKeyGooglePlaceId];
    [encoder encodeObject:self.displayAddress forKey:kWSKeyDisplayAddress];
    [encoder encodeObject:self.location forKey:kWSKeyLocation];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init]))
    {
        self.googlePlaceId = [decoder decodeObjectForKey:kWSKeyGooglePlaceId];
        self.displayAddress = [decoder decodeObjectForKey:kWSKeyDisplayAddress];
        self.location = [decoder decodeObjectForKey:kWSKeyLocation];
    }
    return self;
}

@end
