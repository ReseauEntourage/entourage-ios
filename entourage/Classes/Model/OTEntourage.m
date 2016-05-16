//
//  OTEntourage.m
//  entourage
//
//  Created by Ciprian Habuc on 13/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTEntourage.h"
#import "NSDictionary+Parsing.h"

#define kWSID @"id"
#define kWSEntourage @"entourage"
#define kWSName @"title"
#define kWSType @"entourage_type"
#define kWSDescription @"description"
#define kWSLocation @"location"
#define kWSLatitude @"latitude"
#define kWSLongitude @"longitude"
#define kWSCreateDate @"created_at"
#define kWSJoinStatus @"join_status"
#define kWSNoPeople @"number_of_people"
#define kWSNoUnreadMessages @"number_of_unread_messages"
#define kWSStatus @"status"




@implementation OTEntourage

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        //self.author = [[OTTourAuthor alloc] initWithDictionary:];
        self.creationDate =  [dictionary dateForKey:kWSCreateDate format:@"yyyy-MM-dd'T'HH:mm:ss.SSSXXX"];
        if (self.creationDate == nil) {
            // Objective-C format : "2015-11-20 09:28:52 +0000"
            self.creationDate = [dictionary dateForKey:kWSCreateDate format:@"yyyy-MM-dd HH:mm:ss Z"];
        }
        self.type = [ENTOURAGE_DEMANDE isEqualToString:[dictionary valueForKey:kWSType]] ? EntourageTypeDemande : EntourageTypeContribution;
        self.sid = [dictionary numberForKey:kWSID];
        self.join_status = [dictionary valueForKey:kWSJoinStatus];
        self.latitude = [dictionary numberForKey:kWSLatitude];
        self.longitude = [dictionary numberForKey:kWSLongitude];
        self.noPeople = [dictionary numberForKey:kWSNoPeople];
        self.noUnreadMessages = [dictionary numberForKey:kWSNoUnreadMessages];
        self.status = [dictionary valueForKey:kWSStatus];
        self.name = [dictionary valueForKey:kWSName];
    }
    return self;
}

- (NSString *)stringFromType {
    switch (self.type) {
        case EntourageTypeDemande:
            return ENTOURAGE_DEMANDE;
        case EntourageTypeContribution:
            return ENTOURAGE_CONTRIBUTION;
            
        default:
            return @"";
            break;
    }
}

- (NSDictionary *)dictionaryForWebService {
    NSDictionary *dictionary = @{        kWSName: self.name,
                                         kWSType: [self stringFromType],
                                         kWSDescription: self.desc,
                                         kWSLocation: @{
                                                 kWSLatitude: self.latitude,
                                                 kWSLongitude: self.longitude}
                                 };
    return dictionary;
}


@end
