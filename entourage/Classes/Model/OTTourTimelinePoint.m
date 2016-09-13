//
//  OTTourTimelinePoint.m
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourTimelinePoint.h"

@implementation OTTourTimelinePoint

- (NSComparisonResult)compare:(OTTourTimelinePoint *)otherObject {
    return [self.date compare:otherObject.date];
}

@end
