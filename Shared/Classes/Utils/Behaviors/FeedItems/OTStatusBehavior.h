//
//  OTStatusBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"
#import "OTStatusChangedBehavior.h"

@interface OTStatusBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIView *statusLineMarker;
@property (nonatomic, weak) IBOutlet UIButton *btnStatus;
@property (nonatomic, weak) IBOutlet OTStatusChangedBehavior *statusChangedBehavior;
@property (nonatomic, assign) BOOL isJoinPossible;

- (void)updateWith:(OTFeedItem *)feedItem;
+ (NSString *)statusTitleForItem:(OTFeedItem*)feedItem;

@end
