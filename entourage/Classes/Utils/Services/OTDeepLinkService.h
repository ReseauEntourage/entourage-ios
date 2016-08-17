//
//  OTDeepLinkService.h
//  entourage
//
//  Created by sergiu buceac on 8/17/16.
//  Copyright © 2016 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTDeepLinkService : NSObject

- (void)navigateTo:(NSNumber *)feedItemId withType:(NSString *)feedItemType;

@end
