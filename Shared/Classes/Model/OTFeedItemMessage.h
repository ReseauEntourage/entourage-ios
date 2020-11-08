//
//  OTFeedItemMessage.h
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemTimelinePoint.h"
#import "OTAssociation.h"

@interface OTFeedItemMessage : OTFeedItemTimelinePoint

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userAvatarURL;
@property (nonatomic, strong) NSNumber *uID;
@property (nonatomic, strong) OTAssociation *partner;

// Outing
@property (nonatomic, strong) NSString *messageType;
@property (nonatomic, strong) NSString *displayAddress;
@property (nonatomic, strong) NSDate *startsAt;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *itemUuid;
@property (nonatomic, strong) NSString *itemType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
