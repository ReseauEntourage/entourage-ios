//
//  OTEntourage.m
//  entourage
//
//  Created by Ciprian Habuc on 13/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourage.h"
#import "OTConsts.h"



@implementation OTEntourage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.creationDate = [dictionary dateForKey:kWSKeyCreateDate];
        self.title = [dictionary valueForKey:kWSKeyTitle];
        self.location = [dictionary locationForKey:kWSKeyLocation
                                   withLatitudeKey:kWSKeyLatitude
                                   andLongitudeKey:kWSKeyLongitude];
        self.desc = [dictionary valueForKey:kWSKeyDescription];
        self.type = [dictionary valueForKey:kWSKeyType];
    }
    return self;
}


- (NSDictionary *)dictionaryForWebService {
    NSDictionary *dictionary = @{        kWSKeyTitle: self.title,
                                         kWSType: self.type,
                                         kWSDescription: self.desc,
                                         kWSKeyLocation: @{
                                                 kWSKeyLatitude: @(self.location.coordinate.latitude),
                                                 kWSKeyLongitude: @(self.location.coordinate.longitude)}
                                 };
    return dictionary;
}

- (NSString *)displayType {
    NSString *displayString = OTLocalizedString(self.type);
    return displayString;
}


@end
