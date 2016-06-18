//
//  OTStateFactory.h
//  entourage
//
//  Created by sergiu buceac on 6/14/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTFeedItem.h"

@protocol OTStateTransitionDelegate <NSObject>

- (void)stopWithSuccess:(void (^)())success;
- (void)deactivateWithSuccess:(void (^)(BOOL))success orFailure:(void (^)(NSError*))failure;
- (void)quitWithSuccess:(void (^)())success;

@end
