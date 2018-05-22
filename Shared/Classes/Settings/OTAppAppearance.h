//
//  OTAppAppearance.h
//  entourage
//
//  Created by Smart Care on 07/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OTAppAppearance : NSObject
+ (NSString *)aboutUrlString;
+ (NSString *)welcomeDescription;
+ (UIImage *)welcomeLogo;
+ (UIImage *)applicationLogo;
+ (NSString *)userProfileNameDescription;
+ (NSString *)userProfileEmailDescription;
+ (NSString *)notificationsRightsDescription;
+ (NSString *)geolocalisationRightsDescription;
+ (NSString *)notificationsNeedDescription;
+ (NSString *)noFeedsDescription;
+ (NSString *)noMapFeedsDescription;
+ (NSString *)extendSearchParameterDescription;
+ (NSString *)extendMapSearchParameterDescription;
+ (NSString *)userActionsTitle;
+ (NSString*)numberOfUserActionsTitle;
+ (NSString*)numberOfUserActionsValueTitle:(OTUser *)user;
+ (UIColor *)leftTagColor:(OTUser*)user;
+ (UIColor *)rightTagColor:(OTUser*)user;
@end
