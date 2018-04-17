//
//  OTFeedItemStatus.h
//
//  Created by Ciprian Habuc on 11/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemTimelinePoint.h"

typedef NS_ENUM(NSInteger) {
    OTFeedItemStatusStart,
    OTFeedItemStatusEnd
} OTFeedItemStatusType;

@interface OTFeedItemStatus : OTFeedItemTimelinePoint

@property(nonatomic, strong) NSString *status;
@property(nonatomic) NSTimeInterval duration;
@property(nonatomic) CGFloat distance;
@property(nonatomic) OTFeedItemStatusType type;
@property(nonatomic, strong) NSNumber *uID;

@end
