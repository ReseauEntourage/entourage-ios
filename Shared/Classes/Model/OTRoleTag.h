//
//  OTRoleTag.h
//
//  Created by Grégoire Clermont on 06/02/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OTRoleTag : NSObject
- (instancetype)initWithName:(NSString *)name;
- (NSString *)name;
- (NSString *)title;
- (UIColor *)color;
- (BOOL)visible;
@end

NS_ASSUME_NONNULL_END
