//
//  OTEntourage.h
//  entourage
//
//  Created by Ciprian Habuc on 13/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTTourAuthor.h"

#define ENTOURAGE_DEMANDE @"ask_for_help"
#define ENTOURAGE_CONTRIBUTION @"contribution"

typedef NS_ENUM(NSInteger) {
    EntourageTypeDemande,
    EntourageTypeContribution
} EntourageType;

/*
 entourage =     {
 author =         {
 "avatar_url" = "<null>";
 "display_name" = "Jean-Marc A";
 id = 1;
 };
 "created_at" = "2016-05-13T16:29:00.838+02:00";
 "entourage_type" = "ask_for_help";
 id = 7;
 "join_status" = accepted;
 location =         {
 latitude = 0;
 longitude = 0;
 };
 "number_of_people" = 0;
 "number_of_unread_messages" = 0;
 status = open;
 title = R;
 };
 
 */

@interface OTEntourage : NSObject

@property (nonatomic, strong) NSNumber *sid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) EntourageType type;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;
@property (nonatomic, strong) OTTourAuthor *author;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *join_status;
@property (nonatomic, strong) NSNumber *noPeople;
@property (nonatomic, strong) NSNumber *noUnreadMessages;
@property (nonatomic, strong) NSString *status;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *) dictionaryForWebService;

@end
