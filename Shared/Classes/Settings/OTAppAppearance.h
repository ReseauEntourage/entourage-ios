//
//  OTAppAppearance.h
//  entourage
//
//  Created by Smart Care on 07/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAppAppearance : NSObject
+ (NSString*)aboutUrlString;
+ (NSString *)welcomeDescription;
+ (UIImage*)welcomeLogo;
+ (NSString *)userProfileNameDescription;
+ (NSString *)userProfileEmailDescription;
+ (NSString *)notificationsRightsDescription;
+ (NSString *)geolocalisationRightsDescription;
+ (NSString *)notificationsNeedDescription;
+ (NSString *)noFeedsDescription;
+ (NSString *)noMapFeedsDescription;
+ (NSString *)extendSearchParameterDescription;
+ (NSString *)extendMapSearchParameterDescription;
@end
