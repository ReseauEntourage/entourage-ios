//
//  OTFeedItem.h
//  entourage
//
//  Created by Ciprian Habuc on 19/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTAPIKeys.h"
#import "NSDictionary+Parsing.h"



#import "OTTourAuthor.h"

@interface OTFeedItem : NSObject

@property (nonatomic, strong) NSNumber *uid;
@property (nonatomic, strong) OTTourAuthor *author;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *joinStatus;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSNumber *noPeople;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSString *)navigationTitle;
- (NSString *)summary;
- (NSAttributedString *)typeByNameAttributedString;

@end
