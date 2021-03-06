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
@class OTFeedItemMessage;

@interface OTAppAppearance : NSObject
+ (NSString *)aboutUrlString;
+ (NSString*)policyUrlString;
+ (NSString *)welcomeTopDescription;
+ (NSString*)lostCodeSimpleDescription;
+ (NSString*)lostCodeFullDescription;
+ (UIImage *)welcomeLogo;
+ (UIImage*)welcomeImage;
+ (UIImage *)applicationLogo;
+ (NSString *)applicationTitle;
+ (NSString *)userProfileNameDescription;
+ (NSString *)userProfileEmailDescription;
+ (NSString *)editUserDescriptionTitle;
+ (NSString *)notificationsRightsDescription;
+ (NSString *)geolocalisationRightsDescription;
+ (NSString *)notificationsNeedDescription;
+ (NSString *)defineActionZoneTitleForUser:(OTUser*)user;
+ (NSString *)defineActionZoneSampleAddress;
+ (NSAttributedString *)defineActionZoneFormattedDescription;
+ (NSString *)noMoreFeedsDescription;
+ (NSString *)noMapFeedsDescription;
+ (NSString *)extendSearchParameterDescription;
+ (NSString *)extendMapSearchParameterDescription;
+ (NSString *)reportActionSubject;
+ (NSString *)promoteEventActionSubject:(NSString*)eventName;
+ (NSString *)promoteEventActionEmailBody:(NSString*)eventName;
+ (NSString *)reportActionToRecepient;
+ (NSString*)userPhoneNumberNotFoundMessage;
+ (NSString *)userActionsTitle;
+ (NSString*)numberOfUserActionsTitle;
+ (NSString*)numberOfUserActionsValueTitle:(OTUser *)user;
+ (NSString*)userPrivateCirclesSectionTitle:(OTUser*)user;
+ (NSString*)userNeighborhoodsSectionTitle:(OTUser*)user;
+ (UIColor*)announcementFeedContainerColor;
+ (UIColor *)tagColor:(OTUser*)user;
+ (UIColor*)iconColorForFeedItem:(OTFeedItem *)feedItem;
+ (NSString *)descriptionForMessageItem:(OTEntourage *)item hasToShowDate:(BOOL)isShowDate;
+ (NSAttributedString*)formattedDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size hasToShowDate:(BOOL)isShowDate;
+ (NSAttributedString*)formattedEventDateDescriptionForMessageItem:(OTEntourage*)item size:(CGFloat)size;
+ (NSAttributedString*)formattedAuthorDescriptionForMessageItem:(OTEntourage*)item;
+ (NSString*)iconNameForEntourageItem:(OTEntourage*)item isAnnotation:(BOOL) isAnnotation;
+ (UIView*)navigationTitleViewForFeedItem:(OTFeedItem*)feedItem;
+ (NSString *)eventTitle;
+ (NSString *)eventsFilterTitle;
+ (UILabel*)navigationTitleLabelForFeedItem:(OTFeedItem*)feedItem;
+ (UIBarButtonItem *)leftNavigationBarButtonItemForFeedItem:(OTFeedItem*)feedItem;
+ (NSString *)joinEntourageLabelTitleForFeedItem:(OTFeedItem*)feedItem;
+ (NSString *)joinEntourageButtonTitleForFeedItem:(OTFeedItem*)feedItem;
+ (UIColor*)colorForNoDataPlacholderImage;
+ (UIColor*)colorForNoDataPlacholderText;
+ (NSString*)sampleTitleForNewEvent;
+ (NSString*)sampleDescriptionForNewEvent;
+ (UIImage*)JoinFeedItemConfirmationLogo;
+ (NSAttributedString*)formattedEventCreatedMessageInfo:(OTFeedItemMessage*)messageItem;
+ (NSString*)requestToJoinTitleForFeedItem:(OTFeedItem*)feedItem;
+ (NSString*)quitFeedItemConformationTitle:(OTFeedItem*)feedItem;
+ (NSString*)closeFeedItemConformationTitle:(OTFeedItem *)feedItem;
+ (NSString*)joinFeedItemConformationDescription:(OTFeedItem *)feedItem;
+ (NSString*)addActionTitleHintMessage:(BOOL)isEvent;
+ (NSString*)addActionDescriptionHintMessage:(BOOL)isEvent;
+ (NSString*)includePastEventsFilterTitle;
+ (NSString*)includePastEventsFilterTitleKey;
+ (NSString*)inviteSubtitleText:(OTFeedItem*)feedItem;
+ (NSString*)noMessagesDescription;
+ (NSAttributedString*)closedFeedChatItemMessageFormattedText:(OTFeedItemMessage*)message;
+ (NSString*)entourageConfidentialityDescription:(OTEntourage*)entourage
                                        isPublic:(BOOL)isPublic;
+ (void)leftNavigationBarButtonItemForFeedItem:(OTFeedItem*)feedItem withBarItem:(void (^)(UIBarButtonItem*))completion;
@end
