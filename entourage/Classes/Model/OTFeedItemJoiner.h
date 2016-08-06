//
//  OTFeedItemJoiner.h
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItemTimelinePoint.h"

@interface OTFeedItemJoiner : OTFeedItemTimelinePoint

@property (strong, nonatomic) NSNumber *uID;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *status;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
