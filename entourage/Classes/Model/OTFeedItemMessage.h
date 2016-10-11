//
//  OTFeedItemMessage.h
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemTimelinePoint.h"

@interface OTFeedItemMessage : OTFeedItemTimelinePoint

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userAvatarURL;
@property (nonatomic, strong) NSNumber *uID;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
