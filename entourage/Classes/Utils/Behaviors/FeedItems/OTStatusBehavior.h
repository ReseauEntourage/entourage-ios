//
//  OTStatusBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/4/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"

@interface OTStatusBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIButton *btnStatus;
@property (nonatomic, weak) IBOutlet UILabel *lblStatus;

- (void)updateWith:(OTFeedItem *)feedItem;

@end
