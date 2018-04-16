//
//  OTFeedItemTimelinePoint.h
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(long) {
    TimelinePointTagStatus,
    TimelinePointTagEncounter,
    TimelinePointTagJoiner,
    TimelinePointTagMessage
} TimelinePointTag;

@interface OTFeedItemTimelinePoint : NSObject

@property (strong, nonatomic) NSDate *date;
@property (nonatomic) NSInteger tag;
@property (strong, nonatomic) NSNumber *tID;

- (NSComparisonResult)compare:(OTFeedItemTimelinePoint *)otherObject;

@end
