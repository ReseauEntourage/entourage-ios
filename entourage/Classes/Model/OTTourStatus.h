//
//  OTTourStatus.h
//  entourage
//
//  Created by Ciprian Habuc on 11/03/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTTourTimelinePoint.h"

typedef NS_ENUM(NSInteger) {
    OTTourStatusStart,
    OTTourStatusEnd
} OTTourStatusType;

@interface OTTourStatus : OTTourTimelinePoint

@property(nonatomic, strong) NSString *status;
@property(nonatomic) NSTimeInterval duration;
@property(nonatomic) CGFloat distance;
@property(nonatomic) OTTourStatusType type;

@end
