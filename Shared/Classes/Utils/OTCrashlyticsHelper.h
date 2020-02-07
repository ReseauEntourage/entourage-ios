//
//  OTCrashlyticsHelper.h
//  entourage
//
//  Created by Grégoire Clermont on 07/02/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OTCrashlyticsHelper : NSObject

+ (void)recordError:(NSString *)message userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
