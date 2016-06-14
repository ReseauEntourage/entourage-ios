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

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super initWithDictionary:dictionary];
    if (self) {
        self.creationDate = [dictionary dateForKey:kWSKeyCreateDate];
        self.title = [dictionary valueForKey:kWSKeyTitle];
        self.location = [dictionary locationForKey:kWSKeyLocation
                                   withLatitudeKey:kWSKeyLatitude
                                   andLongitudeKey:kWSKeyLongitude];
        self.desc = [dictionary valueForKey:kWSKeyDescription];
        self.type = [dictionary valueForKey:kWSKeyEntourageType];
    }
    return self;
}


- (NSDictionary *)dictionaryForWebService {
    NSDictionary *dictionary = @{        kWSKeyTitle: self.title,
                                         kWSKeyEntourageType: self.type,
                                         kWSDescription: self.desc,
                                         kWSKeyStatus: self.status,
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

- (NSString *)navigationTitle {
    return OTLocalizedString([self displayType]);
}

- (NSString *)summary {
    return self.title;
}

- (NSAttributedString *)typeByNameAttributedString {
    NSAttributedString *typeAttrString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:OTLocalizedString(@"formater_by"), [self displayType].capitalizedString]
                                                                         attributes:ATTR_LIGHT_15];
    NSAttributedString *nameAttrString = [[NSAttributedString alloc] initWithString:self.author.displayName
                                                                         attributes:ATTR_SEMIBOLD_15];
    NSMutableAttributedString *typeByNameAttrString = typeAttrString.mutableCopy;
    [typeByNameAttrString appendAttributedString:nameAttrString];
    
    return typeByNameAttrString;
}


- (NSString *)newsfeedStatus {
    if ([self.status isEqualToString:ENTOURAGE_STATUS_OPEN])
        return FEEDITEM_STATUS_ACTIVE;
    return self.status;
}

@end
