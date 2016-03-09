//
//  OTTourTimelinePoint.h
//  entourage
//
//  Created by Ciprian Habuc on 09/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTTourTimelinePoint : NSObject

@property (strong, nonatomic) NSDate *date;

- (NSComparisonResult)compare:(OTTourTimelinePoint *)otherObject;

@end
