//
//  OTConfirmCloseViewController.h
//  entourage
//
//  Created by veronica.gliga on 16/03/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OTFeedItem.h"
#import "OTStatusChangedProtocol.h"
#import "OTCloseReason.h"

@protocol OTConfirmCloseProtocol <NSObject>

- (void)feedItemClosedWithReason: (OTCloseReason)reason andComment:(NSString*) comment ;

@end

@interface OTConfirmCloseViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) OTFeedItem *feedItem;
@property (nonatomic, weak) id<OTConfirmCloseProtocol> closeDelegate;

@end
