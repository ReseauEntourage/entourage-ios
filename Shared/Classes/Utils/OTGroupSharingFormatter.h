//
//  OTGroupSharingFormatter.h
//  entourage
//
//  Created by Grégoire Clermont on 06/02/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OTGroupSharingFormatter : NSObject

+ (NSString *)groupShareText:(OTEntourage *)group;

@end

NS_ASSUME_NONNULL_END
