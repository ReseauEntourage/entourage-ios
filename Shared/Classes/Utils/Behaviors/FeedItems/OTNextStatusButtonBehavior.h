//
//  OTNextStatusButtonBehavior.h
//  entourage
//
//  Created by sergiu buceac on 8/6/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import "OTBehavior.h"
#import "OTFeedItem.h"
#import "OTStatusChangedProtocol.h"

@interface OTNextStatusButtonBehavior : OTBehavior

@property (nonatomic, weak) IBOutlet UIViewController *owner;
@property (nonatomic, weak) IBOutlet UIButton *btnNextState;

- (void)configureWith:(OTFeedItem *)feedItem andProtocol:(id<OTStatusChangedProtocol>)protocol;
- (BOOL)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender;

@end
