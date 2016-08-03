//
//  OTFeedItemFactoryProtocol.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"
#import "OTStateTransitionDelegate.h"
#import "OTStateInfoDelegate.h"
#import "OTMessagingDelegate.h"
#import "OTUIDelegate.h"
#import "OTMapHandlerDelegate.h"

@protocol OTFeedItemFactoryDelegate <NSObject>

- (BOOL)isTour;
- (id<OTStateTransitionDelegate>)getStateTransition;
- (id<OTStateInfoDelegate>)getStateInfo;
- (id<OTMessagingDelegate>)getMessaging;
- (id<OTUIDelegate>)getUI;
- (id<OTMapHandlerDelegate>)getMapHandler;

@end
