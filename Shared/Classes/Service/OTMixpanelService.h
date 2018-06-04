//
//  OTMixpanelService.h
//  entourage
//
//  Created by veronica.gliga on 15/12/2017.
//  Copyright © 2017 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTMixpanelService : NSObject

- (void)sendTokenDataWithDictionary:(NSDictionary *)dictionary
                            success:(void (^)(void))success
                            failure:(void (^)(NSError *))failure;

@end
