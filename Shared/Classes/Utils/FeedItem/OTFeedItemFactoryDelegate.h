//
//  OTFeedItemFactoryProtocol.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"
#import "OTStateTransitionDelegate.h"
#import "OTStateInfoDelegate.h"
#import "OTMessagingDelegate.h"
#import "OTUIDelegate.h"
#import "OTMapHandlerDelegate.h"
#import "OTJoinerDelegate.h"
#import "OTChangedHandlerDelegate.h"

@protocol OTFeedItemFactoryDelegate <NSObject>

- (id<OTUIDelegate>)getUI;

@optional
- (BOOL)isTour;
- (id<OTStateTransitionDelegate>)getStateTransition;
- (id<OTStateInfoDelegate>)getStateInfo;
- (id<OTMessagingDelegate>)getMessaging;
- (id<OTMapHandlerDelegate>)getMapHandler;
- (id<OTJoinerDelegate>)getJoiner;
- (id<OTChangedHandlerDelegate>)getChangedHandler;

@end
