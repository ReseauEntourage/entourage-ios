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


@interface OTEntourage : NSObject

@property (nonatomic, strong) NSNumber *sid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) EntourageType type;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic) NSNumber *latitude;
@property (nonatomic) NSNumber *longitude;
@property (nonatomic, strong) OTTourAuthor *author;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *joinStatus;
@property (nonatomic, strong) NSNumber *noPeople;
@property (nonatomic, strong) NSNumber *noUnreadMessages;
@property (nonatomic, strong) NSString *status;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *) dictionaryForWebService;
- (NSString *)stringFromType;

@end
