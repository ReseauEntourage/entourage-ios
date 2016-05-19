//
//  OTEntourage.h
//  entourage
//
//  Created by Ciprian Habuc on 13/05/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OTFeedItem.h"

#define ENTOURAGE_DEMANDE @"ask_for_help"
#define ENTOURAGE_CONTRIBUTION @"contribution"


@interface OTEntourage : OTFeedItem

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) CLLocation *location;

- (instancetype) initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *) dictionaryForWebService;

- (NSString *)displayType;

@end
