//
//  OTFeedItemTimelinePoint.m
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTFeedItemTimelinePoint.h"

@implementation OTFeedItemTimelinePoint

- (NSComparisonResult)compare:(OTFeedItemTimelinePoint *)otherObject {
    return [self.date compare:otherObject.date];
}

@end
