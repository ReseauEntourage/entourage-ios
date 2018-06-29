//
//  OTAppAppearance.h
//  entourage
//
//  Created by Smart Care on 07/05/2018.
//  Copyright © 2018 OCTO Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OTEntourage;
@class OTFeedItem;

@interface OTAppAppearance : NSObject
+ (NSString *)aboutUrlString;
+ (NSString *)welcomeDescription;
+ (UIImage *)welcomeLogo;
+ (UIImage *)applicationLogo;
+ (NSString *)userProfileNameDescription;
+ (NSString *)userProfileEmailDescription;
+ (NSString *)editUserDescriptionTitle;
+ (NSString *)notificationsRightsDescription;
+ (NSString *)geolocalisationRightsDescription;
+ (NSString *)notificationsNeedDescription;
+ (NSString *)noFeedsDescription;
+ (NSString *)noMapFeedsDescription;
+ (NSString *)extendSearchParameterDescription;
+ (NSString *)extendMapSearchParameterDescription;
+ (NSString *)reportActionSubject;
+ (NSString *)reportActionToRecepient;
+ (NSString*)userPhoneNumberNotFoundMessage;
+ (NSString *)userActionsTitle;
+ (NSString*)numberOfUserActionsTitle;
+ (NSString*)numberOfUserActionsValueTitle:(OTUser *)user;
+ (NSString*)userPrivateCirclesSectionTitle:(OTUser*)user;
+ (NSString*)userNeighborhoodsSectionTitle:(OTUser*)user;
+ (UIColor*)announcementFeedContainerColor;
+ (UIColor *)leftTagColor:(OTUser*)user;
+ (UIColor *)rightTagColor:(OTUser*)user;
+ (UIColor*)iconColorForFeedItem:(OTFeedItem *)feedItem;
+ (NSAttributedString*)formattedDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size;
+ (NSString*)iconNameForEntourageItem:(OTEntourage*)item;
+ (UIView*)navigationTitleViewForFeedItem:(OTFeedItem*)feedItem;
+ (NSString *)joinEntourageLabelTitleForFeedItem:(OTFeedItem*)feedItem;
+ (NSString *)joinEntourageButtonTitleForFeedItem:(OTFeedItem*)feedItem;
@end
