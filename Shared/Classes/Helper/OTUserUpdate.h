//
//  OTUserUpdate.h
//  entourage
//
//  Created by Grégoire Clermont on 29/05/2019.
//  Copyright © 2019 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OTUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface OTUserUpdate : NSObject

@property (strong, nonatomic) OTUser* previousValue;
@property (strong, nonatomic) OTUser* currentValue;

@end

NS_ASSUME_NONNULL_END
