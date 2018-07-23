//
//  OTAddress.h
//  entourage
//
//  Created by Smart Care on 20/07/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface OTAddress : NSObject
@property (nonatomic) NSString *googlePlaceId;
@property (nonatomic) NSString *displayAddress;
@property (nonatomic) CLLocation *location;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
