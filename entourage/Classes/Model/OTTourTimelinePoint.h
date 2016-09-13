//
//  OTTourTimelinePoint.h
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

@interface OTTourTimelinePoint : NSObject

@property (strong, nonatomic) NSDate *date;
@property (nonatomic) NSInteger tag;

- (NSComparisonResult)compare:(OTTourTimelinePoint *)otherObject;

@end
